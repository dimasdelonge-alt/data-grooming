import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert' as dart_convert;
import '../grooming_view_model.dart';
import '../../util/security_preferences.dart';
import '../../util/image_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _storeIdController = TextEditingController();

  Future<void> _pickLogo(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Encode and compress to Base64
        final bytes = await image.readAsBytes();
        final base64Str = await ImageUtils.compressAndEncodeFromBytes(
          bytes,
          minWidth: 400,
          minHeight: 400,
          quality: 65
        );

        if (context.mounted && base64Str != null) {
          await context.read<GroomingViewModel>().updateLogo(base64Str);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo berhasil diperbarui ✅')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking logo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }
  // int _secretTapCount = 0; // Removed legacy admin

  SecurityPreferences? _securityPrefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<GroomingViewModel>();
      _nameController.text = vm.businessName;
      _phoneController.text = vm.businessPhone;
      _addressController.text = vm.businessAddress;
      _storeIdController.text = vm.currentShopId;
    });
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _securityPrefs = SecurityPreferences(prefs));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _storeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroomingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Theme Settings ──────────────────────────────────────────────
            _SectionHeader('Tampilan'),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Ikuti Sistem'),
                    value: ThemeMode.system,
                    groupValue: vm.themeMode,
                    onChanged: (val) => vm.setTheme(0),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Mode Terang'),
                    value: ThemeMode.light,
                    groupValue: vm.themeMode,
                    onChanged: (val) => vm.setTheme(1),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Mode Gelap'),
                    value: ThemeMode.dark,
                    groupValue: vm.themeMode,
                    onChanged: (val) => vm.setTheme(2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Branding / Logo ─────────────────────────────────────────────
            _SectionHeader('Branding Toko'),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: vm.logoPath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: ImageUtils.isBase64Image(vm.logoPath) 
                              ? Image.memory(
                                  dart_convert.base64Decode(vm.logoPath),
                                  width: 56, height: 56, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 28),
                                )
                              : Image.asset('assets/logo_app.png', width: 56, height: 56, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 28)),
                        )
                      : const Icon(Icons.store, size: 28),
                ),
                title: const Text('Logo Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  vm.userPlan.toLowerCase() == 'pro'
                      ? 'Sesuaikan logo untuk struk/invoice Anda.'
                      : 'Upgrade ke PRO untuk ganti logo.',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                trailing: vm.userPlan.toLowerCase() == 'pro'
                    ? const Icon(Icons.edit_rounded)
                    : Icon(Icons.lock, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                onTap: vm.userPlan.toLowerCase() == 'pro'
                    ? () => _pickLogo(context)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur khusus PRO! Silakan upgrade langganan.')),
                        );
                      },
              ),
            ),
            const SizedBox(height: 24),

            // ─── Business Info ───────────────────────────────────────────────
            _SectionHeader('Informasi Bisnis'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Bisnis',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        hintText: 'Untuk header struk/invoice',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Bisnis',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _storeIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID Toko',
                        hintText: 'cth: my_petshop',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                        helperText: 'Gunakan huruf kecil, tanpa spasi',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final oldStoreId = vm.currentShopId;
                          vm.updateBusinessInfo(
                            _nameController.text.trim(),
                            _phoneController.text.trim(),
                            address: _addressController.text.trim(),
                            storeId: _storeIdController.text.trim(),
                          );
                          if (_storeIdController.text.trim() != oldStoreId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID Toko berubah. Cek menu Akun untuk Sinkronisasi.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perubahan Disimpan')),
                            );
                          }
                        },
                        child: const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Notification Settings ──────────────────────────────────────
            _SectionHeader('Pengaturan Notifikasi'),
            _NotificationSection(vm: vm),
            const SizedBox(height: 24),

            // ─── Security ────────────────────────────────────────────────────
            _SectionHeader('Keamanan'),
            if (_securityPrefs != null)
              _SecuritySection(securityPrefs: _securityPrefs!),
            const SizedBox(height: 24),

            // ─── Account & Security Nav ─────────────────────────────────────
            _SectionHeader('Akun & Keamanan'),
            Card(
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                title: const Text('Kelola Akun & Langganan', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Status: ${vm.userPlan.toUpperCase().isEmpty ? "FREE" : vm.userPlan.toUpperCase()}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/account'),
              ),
            ),
            const SizedBox(height: 24),

            // ─── About ───────────────────────────────────────────────────────
            _SectionHeader('Tentang Aplikasi'),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Jeni Cat App'),
                subtitle: Text('Versi 13.0 (Stable)'),
                // legacy admin tap logic removed
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(13.0),
              child: Text(
                'Terima kasih telah menggunakan Jeni Cat App.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _showAdminLoginDialog removed
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationSection extends StatefulWidget {
  final GroomingViewModel vm;
  const _NotificationSection({required this.vm});

  @override
  State<_NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<_NotificationSection> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.vm.isBookingReminderEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final formattedTime = '${vm.reminderHour.toString().padLeft(2, '0')}:${vm.reminderMinute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Card(
          child: SwitchListTile(
            secondary: Icon(
              _isEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: _isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            title: const Text('Aktifkan Pengingat', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_isEnabled ? 'Notifikasi H-1 aktif' : 'Notifikasi dimatikan'),
            value: _isEnabled,
            onChanged: (val) {
              setState(() => _isEnabled = val);
              // Save to prefs via direct access
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('booking_reminder_enabled', val);
                vm.updateReminders();
              });
            },
          ),
        ),
        if (_isEnabled) ...[
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
              title: const Text('Waktu Pengingat (H-1)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Jam: $formattedTime WIB'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showTimeDialog(context, vm),
            ),
          ),
        ],
      ],
    );
  }

  void _showTimeDialog(BuildContext context, GroomingViewModel vm) {
    final hourController = TextEditingController(text: vm.reminderHour.toString());
    final minuteController = TextEditingController(text: vm.reminderMinute.toString());
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Atur Waktu Pengingat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Notifikasi akan muncul 1 hari sebelum jadwal (H-1) pada jam yang ditentukan.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hourController,
                      decoration: const InputDecoration(labelText: 'Jam (0-23)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: minuteController,
                      decoration: const InputDecoration(labelText: 'Menit (0-59)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final h = int.tryParse(hourController.text);
                final m = int.tryParse(minuteController.text);
                if (h == null || m == null) {
                  setState(() => error = 'Masukkan angka yang valid');
                } else if (h < 0 || h > 23) {
                  setState(() => error = 'Jam harus 0-23');
                } else if (m < 0 || m > 59) {
                  setState(() => error = 'Menit harus 0-59');
                } else {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setInt('reminder_hour', h);
                    prefs.setInt('reminder_minute', m);
                    vm.updateReminders();
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Waktu pengingat disimpan!')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECURITY SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _SecuritySection extends StatefulWidget {
  final SecurityPreferences securityPrefs;
  const _SecuritySection({required this.securityPrefs});

  @override
  State<_SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<_SecuritySection> {
  late bool _isAppLockEnabled;
  late bool _isBiometricEnabled;

  @override
  void initState() {
    super.initState();
    _isAppLockEnabled = widget.securityPrefs.isAppLockEnabled;
    _isBiometricEnabled = widget.securityPrefs.isBiometricEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN Lock Toggle
        Card(
          child: SwitchListTile(
            secondary: Icon(
              Icons.lock,
              color: _isAppLockEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            title: const Text('Kunci Aplikasi (PIN)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_isAppLockEnabled ? 'PIN Aktif' : 'Kunci dimatikan'),
            value: _isAppLockEnabled,
            onChanged: (val) {
              if (val) {
                _showPinCreationDialog();
              } else {
                setState(() => _isAppLockEnabled = false);
                widget.securityPrefs.isAppLockEnabled = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kunci Aplikasi Dimatikan')),
                );
              }
            },
          ),
        ),

        // Biometric Toggle (only show when PIN is active)
        if (_isAppLockEnabled) ...[
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                Icons.fingerprint,
                color: _isBiometricEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              title: const Text('Biometrik (Sidik Jari)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_isBiometricEnabled ? 'Aktif' : 'Tidak Aktif'),
              value: _isBiometricEnabled,
              onChanged: (val) {
                setState(() => _isBiometricEnabled = val);
                widget.securityPrefs.isBiometricEnabled = val;
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showPinCreationDialog() {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Atur PIN Baru (6 Digit)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                decoration: const InputDecoration(labelText: 'PIN Baru', border: OutlineInputBorder()),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(labelText: 'Konfirmasi PIN', border: OutlineInputBorder()),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (pinController.text.length != 6) {
                  setState(() => error = 'PIN harus 6 digit');
                } else if (pinController.text != confirmController.text) {
                  setState(() => error = 'PIN tidak cocok');
                } else {
                  widget.securityPrefs.savePin(pinController.text);
                  widget.securityPrefs.isAppLockEnabled = true;
                  this.setState(() => _isAppLockEnabled = true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN Berhasil Diatur!')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header Widget ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
