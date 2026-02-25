import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/whatsapp_utils.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh subscription on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroomingViewModel>().refreshSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun & Backup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Shop Connection ─────────────────────────────────────────────
            _SectionHeader('Sinkronisasi Toko'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      vm.currentShopId.isNotEmpty ? Icons.store_mall_directory : Icons.store_mall_directory_outlined,
                      color: vm.currentShopId.isNotEmpty ? Colors.green : Colors.grey,
                    ),
                    title: Text(vm.currentShopId.isNotEmpty ? 'Toko Terhubung' : 'Hubungkan Toko'),
                    subtitle: Text(vm.currentShopId.isNotEmpty ? 'ID: ${vm.currentShopId}' : 'Belum terhubung ke toko'),
                    trailing: vm.currentShopId.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            onPressed: () => _showDisconnectDialog(context, vm),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: vm.currentShopId.isEmpty
                        ? () => _showConnectDialog(context, vm)
                        : null,
                  ),
                  if (vm.currentShopId.isNotEmpty && !kIsWeb) ...[
                    const Divider(height: 1),
                    _SecretKeyTile(secretKey: vm.currentSecretKey),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Subscription Status ─────────────────────────────────────────
            _SectionHeader('Status Langganan'),
            _SubscriptionCard(vm: vm, isDark: isDark),
            const SizedBox(height: 24),

            // ─── Backup & Restore ─────────────────────────────────────────────
            _SectionHeader('Backup & Restore Cloud'),
            if (vm.currentShopId.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Hubungkan ke Toko terlebih dahulu untuk menggunakan fitur Cloud Backup.'),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.cloud_upload, color: Colors.white)),
                      title: const Text('Backup Data'),
                      subtitle: const Text('Upload semua data lokal ke Cloud'),
                      onTap: vm.isLoading ? null : () => _confirmAction(context, 'Backup Data', 'Upload data sekarang?', vm.backupData),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.cloud_download, color: Colors.white)),
                      title: const Text('Restore Data'),
                      subtitle: const Text('Download dan timpa data lokal dari Cloud'),
                      onTap: vm.isLoading ? null : () => _confirmAction(context, 'Restore Data', 'Data lokal akan ditimpa! Lanjutkan?', vm.restoreData),
                    ),
                  ],
                ),
              ),

              if (!kIsWeb) ...[
              const SizedBox(height: 24),
               
              // ─── Offline Backup ────────────────────────────────────────────
              _SectionHeader('Backup & Restore Lokal'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.folder_zip, color: Colors.white)),
                      title: const Text('Backup Offline (ZIP)'),
                      subtitle: const Text('Simpan database & foto ke file ZIP'),
                      onTap: vm.isLoading ? null : () => vm.backupOffline(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.file_open, color: Colors.white)),
                      title: const Text('Restore Offline (ZIP)'),
                      subtitle: const Text('Pulihkan data dari file ZIP'),
                      onTap: vm.isLoading ? null : () => _confirmAction(context, 'Restore Offline', 'Data saat ini akan ditimpa! Lanjutkan?', () async {
                        await vm.restoreOffline();
                      }),
                    ),
                  ],
                ),
              ),
              ],

              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
          ],
        ),
      ),
    );
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  void _showConnectDialog(BuildContext context, GroomingViewModel vm) {
    final shopIdController = TextEditingController();
    final secretKeyController = TextEditingController();
    bool isLoading = false;
    bool isChecked = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hubungkan Toko'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopIdController,
                decoration: const InputDecoration(labelText: 'Shop ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: secretKeyController,
                decoration: InputDecoration(
                  labelText: 'Secret Key',
                  suffixIcon: IconButton(
                    icon: Icon(isChecked ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                         isChecked = !isChecked;
                      });
                    },
                  ),
                ),
                obscureText: !isChecked,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              if (isLoading) ...[
                 const SizedBox(height: 16),
                 const LinearProgressIndicator(),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () {
                Navigator.pop(ctx);
                _showCreateShopDialog(context, vm);
              },
              child: const Text('Buat Baru'),
            ),
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading ? null : () async {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                final success = await vm.connectShop(
                  shopIdController.text.trim(),
                  secretKeyController.text.trim(),
                );
                if (success) {
                  Navigator.pop(ctx);
                  _showRestorePrompt(context, vm);
                } else {
                  setState(() {
                    isLoading = false;
                    error = 'ID atau Key salah, atau periksa koneksi internet.';
                  });
                }
              },
              child: const Text('Hubungkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateShopDialog(BuildContext context, GroomingViewModel vm) {
    final nameController = TextEditingController(text: vm.businessName);
    final idController = TextEditingController(); // Added Manual ID
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Buat Toko Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ID dan Secret Key akan dibuat otomatis. Anda juga dapat menentukan ID sendiri (opsional). Data lokal saat ini akan di-upload ke cloud.'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Toko'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Custom Shop ID (Opsional)',
                  hintText: 'Misal: JENICATHOUSE',
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading ? null : () async {
                if (nameController.text.trim().isEmpty) return;
                setState(() => isLoading = true);
                
                final success = await vm.createNewShop(
                  nameController.text.trim(),
                  manualId: idController.text.trim(),
                );
                
                if (success) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Toko berhasil dibuat! ID: ${vm.currentShopId}')),
                  );
                } else {
                   setState(() => isLoading = false);
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Gagal membuat toko. Periksa koneksi.')),
                   );
                }
              },
              child: const Text('Buat & Upload'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestorePrompt(BuildContext context, GroomingViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Data?'),
        content: const Text('Berhasil terhubung. Apakah Anda ingin download & restore data dari cloud sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Nanti Saja'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.restoreData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                      ? 'Restore berhasil! Data sedang diperbarui.'
                      : 'Restore gagal! Periksa koneksi atau Secret Key Anda.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Ya, Restore'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, GroomingViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Putuskan Koneksi?'),
        content: const Text('Fitur sinkronisasi dan backup cloud akan dinonaktifkan. Data lokal tetap aman.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              await vm.disconnectShop();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Koneksi toko diputuskan')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Putuskan'),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String content, Future<void> Function() action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              action();
            },
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );
  }
}

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

class _SecretKeyTile extends StatelessWidget {
  final String secretKey;
  const _SecretKeyTile({required this.secretKey});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.vpn_key, color: Colors.orange),
      title: Text('Secret Key'),
      subtitle: Text(
        '•••••••• (Tersembunyi demi keamanan)',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTION CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _SubscriptionCard extends StatelessWidget {
  final GroomingViewModel vm;
  final bool isDark;

  const _SubscriptionCard({required this.vm, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final plan = vm.userPlan.toUpperCase();
    final isPro = vm.userPlan.toLowerCase() == 'pro';
    final planColor = isPro ? const Color(0xFFFFC107) : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan badge + refresh
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: planColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.isEmpty ? 'FREE' : plan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mengecek status...')),
                    );
                    await vm.refreshSubscription();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Status: ${vm.userPlan.toUpperCase()}')),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Cek Status'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Valid until (PRO only)
            if (isPro && vm.validUntil > 0)
              _InfoRow(Icons.event, 'Berlaku Sampai: ${app_date.formatDate(vm.validUntil)}'),

            // Device limit
            _InfoRow(Icons.devices, 'Limit Perangkat: ${vm.maxDevices}'),
            const SizedBox(height: 4),

            // Device ID
            if (vm.deviceId.isNotEmpty)
              _InfoRow(Icons.smartphone, 'Device ID: ${vm.deviceId.length > 8 ? '${vm.deviceId.substring(0, 8)}...' : vm.deviceId}'),

            // Upgrade button (starter only)
            if (!isPro) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    WhatsAppUtils.openWhatsApp(
                      '082137895794',
                      'Halo Admin, saya ingin upgrade aplikasi DataGrooming saya ke PRO. ID Toko: ${vm.currentShopId}',
                    );
                  },
                  icon: const Icon(Icons.star, size: 18),
                  label: const Text('Tingkatkan ke PRO', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
