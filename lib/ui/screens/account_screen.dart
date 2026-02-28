import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/whatsapp_utils.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountAndBackup)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Shop Connection ─────────────────────────────────────────────
            _SectionHeader(l10n.shopSync),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      vm.currentShopId.isNotEmpty ? Icons.store_mall_directory : Icons.store_mall_directory_outlined,
                      color: vm.currentShopId.isNotEmpty ? Colors.green : Colors.grey,
                    ),
                    title: Text(vm.currentShopId.isNotEmpty ? l10n.shopConnected : l10n.connectShop),
                    subtitle: Text(vm.currentShopId.isNotEmpty ? l10n.shopIdValue(vm.currentShopId) : l10n.notConnectedToShop),
                    trailing: vm.currentShopId.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            onPressed: () => _showDisconnectDialog(context, vm, l10n),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: vm.currentShopId.isEmpty
                        ? () => _showConnectDialog(context, vm, l10n)
                        : null,
                  ),
                  if (vm.currentShopId.isNotEmpty) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: Colors.blue),
                      title: Text(l10n.changePassword),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(context, vm, l10n),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Subscription Status ─────────────────────────────────────────
            _SectionHeader(l10n.subscriptionStatus),
            _SubscriptionCard(vm: vm, isDark: isDark, l10n: l10n),
            const SizedBox(height: 24),

            // ─── Backup & Restore ─────────────────────────────────────────────
            _SectionHeader(l10n.cloudBackupRestore),
            if (vm.currentShopId.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(l10n.connectShopFirstForCloud),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.cloud_upload, color: Colors.white)),
                      title: Text(l10n.backupData),
                      subtitle: Text(l10n.backupDataDesc),
                      onTap: vm.isLoading ? null : () => _confirmAction(context, l10n.backupData, l10n.uploadDataNow, vm.backupData, l10n),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.cloud_download, color: Colors.white)),
                      title: Text(l10n.restoreData),
                      subtitle: Text(l10n.restoreDataDesc),
                      onTap: vm.isLoading ? null : () => _confirmAction(context, l10n.restoreData, l10n.dataWillBeOverwrittenProceed, vm.restoreData, l10n),
                    ),
                  ],
                ),
              ),

              if (!kIsWeb) ...[
              const SizedBox(height: 24),
               
              // ─── Offline Backup ────────────────────────────────────────────
              _SectionHeader(l10n.localBackupRestore),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.folder_zip, color: Colors.white)),
                      title: Text(l10n.offlineBackupZip),
                      subtitle: Text(l10n.offlineBackupZipDesc),
                      onTap: vm.isLoading ? null : () => vm.backupOffline(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.file_open, color: Colors.white)),
                      title: Text(l10n.offlineRestoreZip),
                      subtitle: Text(l10n.offlineRestoreZipDesc),
                      onTap: vm.isLoading ? null : () => _confirmAction(context, l10n.restoreOffline, l10n.dataWillBeOverwrittenProceed, () async {
                        await vm.restoreOffline();
                      }, l10n),
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

  void _showConnectDialog(BuildContext context, GroomingViewModel vm, AppLocalizations l10n) {
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
          title: Text(l10n.connectShop),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopIdController,
                decoration: InputDecoration(labelText: l10n.shopId),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: secretKeyController,
                decoration: InputDecoration(
                  labelText: l10n.secretKey,
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
                _showCreateShopDialog(context, vm, l10n);
              },
              child: Text(l10n.createNew),
            ),
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
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
                  _showRestorePrompt(context, vm, l10n);
                } else {
                  setState(() {
                    isLoading = false;
                    error = l10n.invalidIdOrKey;
                  });
                }
              },
              child: Text(l10n.connect),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateShopDialog(BuildContext context, GroomingViewModel vm, AppLocalizations l10n) {
    final nameController = TextEditingController(text: vm.businessName);
    final idController = TextEditingController(); // Added Manual ID
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.createNewShop),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.createNewShopDesc),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.shopName),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: l10n.customShopIdOptional,
                  hintText: l10n.customShopIdHint,
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
              child: Text(l10n.cancel),
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
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(l10n.shopCreatedSuccess(vm.currentShopId))),
                    );
                  }
                } else {
                   setState(() => isLoading = false);
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(l10n.shopCreatedFail)),
                     );
                   }
                }
              },
              child: Text(l10n.createAndUpload),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestorePrompt(BuildContext context, GroomingViewModel vm, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreDataPrompt),
        content: Text(l10n.restoreDataPromptDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text(l10n.later),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.restoreData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? l10n.restoreSuccess : l10n.restoreFail),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text(l10n.yesRestore),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, GroomingViewModel vm, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.disconnectShopPrompt),
        content: Text(l10n.disconnectShopDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              await vm.disconnectShop();
              if (context.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.shopConnectionDisconnected)),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.disconnect),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, GroomingViewModel vm, AppLocalizations l10n) {
    final oldPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();
    bool isLoading = false;
    bool obscureOld = true;
    bool obscureNew = true;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.changePassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPwdController,
                obscureText: obscureOld,
                decoration: InputDecoration(
                  labelText: l10n.oldPassword,
                  suffixIcon: IconButton(
                    icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureOld = !obscureOld),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newPwdController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPwdController,
                obscureText: obscureNew,
                decoration: InputDecoration(labelText: l10n.confirmNewPassword),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              if (isLoading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: isLoading ? null : () async {
                final oldPwd = oldPwdController.text;
                final newPwd = newPwdController.text;
                final confirmPwd = confirmPwdController.text;

                if (newPwd.length < 6) {
                  setState(() => error = l10n.passwordMinLength);
                  return;
                }
                if (newPwd != confirmPwd) {
                  setState(() => error = l10n.passwordMismatch);
                  return;
                }

                setState(() { isLoading = true; error = null; });
                final result = await vm.changePassword(oldPwd, newPwd);
                if (!context.mounted) return;

                if (result == 'success') {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.passwordChanged), backgroundColor: Colors.green),
                  );
                } else if (result == 'wrong_old') {
                  setState(() { isLoading = false; error = l10n.wrongOldPassword; });
                } else {
                  setState(() { isLoading = false; error = l10n.passwordChangeFailed; });
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String content, Future<void> Function() action, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              action();
            },
            child: Text(l10n.yesProceed),
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

// ═══════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTION CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _SubscriptionCard extends StatelessWidget {
  final GroomingViewModel vm;
  final bool isDark;
  final AppLocalizations l10n;

  const _SubscriptionCard({required this.vm, required this.isDark, required this.l10n});

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
                      plan.isEmpty ? l10n.planFree : plan,
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
                      SnackBar(content: Text(l10n.checkingStatus)),
                    );
                    await vm.refreshSubscription();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.statusValue(vm.userPlan.toUpperCase()))),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.checkStatus),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Valid until (PRO only)
            if (isPro && vm.validUntil > 0)
              _InfoRow(Icons.event, l10n.validUntilValue(app_date.formatDate(vm.validUntil))),

            // Device limit
            _InfoRow(Icons.devices, l10n.deviceLimitValue(vm.maxDevices)),
            const SizedBox(height: 4),

            // Device ID
            if (vm.deviceId.isNotEmpty)
              _InfoRow(Icons.smartphone, l10n.deviceIdValue(vm.deviceId.length > 8 ? '${vm.deviceId.substring(0, 8)}...' : vm.deviceId)),

            // Upgrade button (starter only)
            if (!isPro) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    WhatsAppUtils.openWhatsApp(
                      '082137895794',
                      l10n.upgradeToProWhatsapp(vm.currentShopId),
                    );
                  },
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(l10n.upgradeToPro, style: const TextStyle(fontWeight: FontWeight.bold)),
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
