import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert' as dart_convert;
import '../grooming_view_model.dart';
import '../../util/security_preferences.dart';
import '../../util/image_utils.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

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
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 65,
      );
      
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
            SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking logo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Theme Settings ──────────────────────────────────────────────
            _SectionHeader(l10n.appearance),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.followSystem),
                    value: ThemeMode.system,
                    groupValue: vm.themeMode,
                    onChanged: (val) => vm.setTheme(0),
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.lightMode),
                    value: ThemeMode.light,
                    groupValue: vm.themeMode,
                    onChanged: (val) => vm.setTheme(1),
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.darkMode),
                    value: ThemeMode.dark,
                    groupValue: vm.themeMode,
                    onChanged: (val) => vm.setTheme(2),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.language,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      value: vm.currentLanguage,
                      items: const [
                        DropdownMenuItem(value: 'id', child: Text('🇮🇩 Bahasa Indonesia')),
                        DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                        DropdownMenuItem(value: 'ms', child: Text('🇲🇾 Bahasa Melayu')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          vm.setLanguage(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Branding / Logo ─────────────────────────────────────────────
            _SectionHeader(l10n.shopBranding),
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
                title: Text(l10n.invoiceLogo, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  vm.userPlan.toLowerCase() == 'pro'
                      ? l10n.logoCustomizationDesc
                      : l10n.upgradeToProForLogo,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                trailing: vm.userPlan.toLowerCase() == 'pro'
                    ? const Icon(Icons.edit_rounded)
                    : Icon(Icons.lock, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                onTap: vm.userPlan.toLowerCase() == 'pro'
                    ? () => _pickLogo(context)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.proFeatureUpgradeRequired)),
                        );
                      },
              ),
            ),
            const SizedBox(height: 24),

            // ─── Business Info ───────────────────────────────────────────────
            _SectionHeader(l10n.businessInformation),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.businessName,
                        prefixIcon: const Icon(Icons.store),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: l10n.businessPhone,
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        hintText: l10n.invoiceHeaderHint,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: l10n.businessAddress,
                        prefixIcon: const Icon(Icons.location_on),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _storeIdController,
                      decoration: InputDecoration(
                        labelText: l10n.shopId,
                        hintText: 'cth: my_petshop',
                        prefixIcon: const Icon(Icons.tag),
                        border: const OutlineInputBorder(),
                        helperText: l10n.shopIdLowerHint,
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
                              SnackBar(content: Text(l10n.shopIdChangedSyncAccount)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.changesSaved)),
                            );
                          }
                        },
                        child: Text(l10n.saveChanges),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Notification Settings ──────────────────────────────────────
            _SectionHeader(l10n.notificationSettings),
            _NotificationSection(vm: vm),
            const SizedBox(height: 24),

            // ─── Security ────────────────────────────────────────────────────
            _SectionHeader(l10n.security),
            if (_securityPrefs != null)
              _SecuritySection(securityPrefs: _securityPrefs!),
            const SizedBox(height: 24),

            // ─── Account & Security Nav ─────────────────────────────────────
            _SectionHeader(l10n.accountAndBackup),
            Card(
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.accountAndBackup, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${l10n.status}: ${vm.userPlan.toUpperCase().isEmpty ? l10n.planFree : vm.userPlan.toUpperCase()}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/account'),
              ),
            ),
            const SizedBox(height: 24),

            // ─── About ───────────────────────────────────────────────────────
            _SectionHeader(l10n.aboutApp),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Data Groomer App'),
                subtitle: Text('v13.0 (Stable)'),
                // legacy admin tap logic removed
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Text(
                l10n.thankYouUsingApp,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
    final l10n = AppLocalizations.of(context)!;
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
            title: Text(l10n.enableReminders, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_isEnabled ? l10n.h1NotificationActive : l10n.notificationsDisabled),
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
              title: Text(l10n.reminderTimeH1, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.wibTimeLabel(formattedTime)),
              trailing: const Icon(Icons.edit),
              onTap: () => _showTimeDialog(context, vm),
            ),
          ),
        ],
      ],
    );
  }

  void _showTimeDialog(BuildContext context, GroomingViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final hourController = TextEditingController(text: vm.reminderHour.toString());
    final minuteController = TextEditingController(text: vm.reminderMinute.toString());
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.setReminderTime),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.reminderTimeDesc),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hourController,
                      decoration: InputDecoration(labelText: l10n.hour023, border: const OutlineInputBorder()),
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
                      decoration: InputDecoration(labelText: l10n.minute059, border: const OutlineInputBorder()),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final h = int.tryParse(hourController.text);
                final m = int.tryParse(minuteController.text);
                if (h == null || m == null) {
                  setState(() => error = l10n.invalidNumber);
                } else if (h < 0 || h > 23) {
                  setState(() => error = l10n.hourLimit);
                } else if (m < 0 || m > 59) {
                  setState(() => error = l10n.minuteLimit);
                } else {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setInt('reminder_hour', h);
                    prefs.setInt('reminder_minute', m);
                    vm.updateReminders();
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.reminderTimeSaved)),
                  );
                }
              },
              child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
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
            title: Text(l10n.appLockPin, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_isAppLockEnabled ? l10n.pinActive : l10n.lockDisabled),
            value: _isAppLockEnabled,
            onChanged: (val) {
              if (val) {
                _showPinCreationDialog();
              } else {
                setState(() => _isAppLockEnabled = false);
                widget.securityPrefs.isAppLockEnabled = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.lockDisabledMsg)),
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
              title: Text(l10n.biometricFingerprint, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_isBiometricEnabled ? l10n.active : l10n.inactive),
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
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.setNewPin6Digit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                decoration: InputDecoration(labelText: l10n.newPin, border: const OutlineInputBorder()),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(labelText: l10n.confirmPin, border: const OutlineInputBorder()),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (pinController.text.length != 6) {
                  setState(() => error = l10n.pinMustBe6Digit);
                } else if (pinController.text != confirmController.text) {
                  setState(() => error = l10n.pinMismatch);
                } else {
                  widget.securityPrefs.savePin(pinController.text);
                  widget.securityPrefs.isAppLockEnabled = true;
                  this.setState(() => _isAppLockEnabled = true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pinSuccessSet)),
                  );
                }
              },
              child: Text(l10n.save),
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
