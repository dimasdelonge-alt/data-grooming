import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../financial_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../../data/entity/cat.dart';
import '../../data/entity/session.dart';
import '../../data/entity/deposit_entities.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/currency_formatter.dart';
import 'package:share_plus/share_plus.dart';
import '../../util/whatsapp_utils.dart';
import '../../util/phone_number_utils.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

/// Grooming session entry screen.
///
/// - [sessionId] == null → **Check-In** mode (creates new WAITING session)
/// - [sessionId] != null → **Edit** mode (update findings, treatment, cost, status)
class SessionEntryScreen extends StatelessWidget {
  final int? sessionId;
  final int? preSelectedCatId;
  final String? preSelectedService;

  const SessionEntryScreen({
    super.key,
    this.sessionId,
    this.preSelectedCatId,
    this.preSelectedService,
  });

  @override
  Widget build(BuildContext context) {
    if (sessionId == null) {
      return _CheckInView(preSelectedCatId: preSelectedCatId);
    }
    return _EditSessionView(sessionId: sessionId!);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHECK-IN VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _CheckInView extends StatefulWidget {
  final int? preSelectedCatId;
  const _CheckInView({this.preSelectedCatId});

  @override
  State<_CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<_CheckInView> {
  int? _selectedCatId;
  final _searchController = TextEditingController();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _selectedCatId = widget.preSelectedCatId;
    if (_selectedCatId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<GroomingViewModel>();
        final cat = vm.allCats.where((c) => c.catId == _selectedCatId).firstOrNull;
        if (cat != null) _searchController.text = cat.catName;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkIn() {
    if (_selectedCatId == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final token = 'RES-${now.toString().substring(now.toString().length - 8)}';

    final session = Session(
      catId: _selectedCatId!,
      timestamp: now,
      status: 'WAITING',
      trackingToken: token,
      updatedAt: now,
    );

    context.read<GroomingViewModel>().addSession(session, []);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.sessionStarted)),
    );
    _searchController.clear();
    setState(() {
      _selectedCatId = null;
      _showDropdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cats = vm.allCats;
    final query = _searchController.text.trim().toLowerCase();
    // #8: Match V2 behavior — empty search = no results (must type first)
    final filtered = query.isEmpty
        ? <Cat>[]
        : cats.where((c) =>
            c.catName.toLowerCase().contains(query) ||
            c.ownerName.toLowerCase().contains(query)).toList();

    // Show all cats when dropdown expanded but no search text
    final displayCats = (query.isEmpty && _showDropdown) ? cats : filtered;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groomingCheckIn)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── New Session Card ─────────────────────────────
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.startNewSession,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Cat search
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() {
                            _showDropdown = true;
                            if (v.isEmpty) _selectedCatId = null;
                          }),
                          onTap: () => setState(() => _showDropdown = true),
                          decoration: InputDecoration(
                            hintText: l10n.searchCatOrOwner,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _selectedCatId = null;
                                        _showDropdown = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => Navigator.pushNamed(context, '/cat_entry'),
                        icon: const Icon(Icons.add_rounded),
                        tooltip: l10n.addNewCat,
                      ),
                    ],
                  ),

                  // Dropdown
                  if (_showDropdown && displayCats.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF424242) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          color: Colors.transparent,
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const ClampingScrollPhysics(),
                            itemCount: displayCats.length,
                            separatorBuilder: (c, i) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final cat = displayCats[index];
                              return ListTile(
                                dense: true,
                                leading: CatAvatar(imagePath: cat.imagePath, size: 36),
                                title: Text(cat.catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(l10n.ownerLabel(cat.ownerName)),
                                onTap: () {
                                  setState(() {
                                    _selectedCatId = cat.catId;
                                    _searchController.text = cat.catName;
                                    _showDropdown = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: _selectedCatId != null ? _checkIn : null,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.checkInStartQueue),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ─── Active Queue ─────────────────────────────────
          Text(
            l10n.currentQueue(vm.activeSessions.length),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (vm.activeSessions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.noActiveQueue,
                style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
              ),
            )
          else
            ...vm.activeSessions.map((session) {
              final cat = cats.where((c) => c.catId == session.catId).firstOrNull;
              return _ActiveSessionCard(
                session: session,
                cat: cat,
                isDark: isDark,
                l10n: l10n,
                onEdit: () {
                  Navigator.pushNamed(context, '/session_entry', arguments: session.sessionId);
                },
              );
            }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTIVE SESSION CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _ActiveSessionCard extends StatelessWidget {
  final Session session;
  final Cat? cat;
  final bool isDark;
  final VoidCallback onEdit;
  final AppLocalizations l10n;

  const _ActiveSessionCard({
    required this.session,
    this.cat,
    required this.isDark,
    required this.onEdit,
    required this.l10n,
  });

  Color _statusBgColor() {
    switch (session.status) {
      case 'WAITING':
        return isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.1);
      case 'PICKUP_READY':
        return isDark ? Colors.green.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.1);
      default:
        return isDark ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.lightPrimary.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<GroomingViewModel>();
    final shopId = vm.currentShopId;

    return Card(
      color: _statusBgColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat?.catName ?? l10n.unknownCat,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      session.status,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark,
                      ),
                    ),
                  ],
                ),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        '${l10n.token}: ${session.trackingToken ?? "-"}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                      ),
                      Text(
                        app_date.formatDateTime(session.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // #9 + #3 + #4: Full-width buttons like V2, with proper validation
            Row(
              children: [
                // #3: Only show WhatsApp button if owner has phone number
                if (cat?.ownerPhone.isNotEmpty == true)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        // #4: Validate Shop ID
                        if (shopId.isEmpty) {
                          Navigator.pushNamed(context, '/settings');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.setShopIdInSettings)),
                          );
                          return;
                        }
                        final token = session.trackingToken;
                        if (token == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.trackingTokenNotAvailable)),
                          );
                          return;
                        }
                        final link = 'https://smartgroomer.my.id/tracking.html?shop=$shopId&token=$token';
                        // #2: Personal template message like V2
                        final ownerName = cat!.ownerName.split(' ').first;
                        final message = l10n.whatsappTrackingMessage(ownerName, cat!.catName, link);
                        
                        WhatsAppUtils.openWhatsApp(cat!.ownerPhone, message);
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: Text(l10n.whatsapp),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (cat?.ownerPhone.isNotEmpty == true)
                  const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // #4: Validate Shop ID
                      if (shopId.isEmpty) {
                        Navigator.pushNamed(context, '/settings');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.setShopIdInSettings)),
                        );
                        return;
                      }
                      final token = session.trackingToken;
                      if (token == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.trackingTokenNotAvailable)),
                        );
                        return;
                      }
                      final link = 'https://smartgroomer.my.id/tracking.html?shop=$shopId&token=$token';
                      Share.share(link);
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text(l10n.shareLink),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EDIT SESSION VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _EditSessionView extends StatefulWidget {
  final int sessionId;
  const _EditSessionView({required this.sessionId});

  @override
  State<_EditSessionView> createState() => _EditSessionViewState();
}

class _EditSessionViewState extends State<_EditSessionView> {
  Session? _session;
  Cat? _cat;
  bool _isLoading = true;

  Set<String> _findings = {};
  Set<int> _selectedServiceIds = {};
  String _currentStatus = 'WAITING';
  final _notesController = TextEditingController();
  final _costController = TextEditingController(text: '0');
  bool _useDeposit = false;
  OwnerDeposit? _ownerDeposit;

  static const _statuses = ['WAITING', 'BATHING', 'DRYING', 'FINISHING', 'PICKUP_READY', 'DONE'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final vm = context.read<GroomingViewModel>();
    final session = await vm.getSession(widget.sessionId);
    if (session != null && mounted) {
      final cat = await vm.getCat(session.catId);
      final matchedIds = vm.services
          .where((s) => session.treatment.contains(s.serviceName))
          .map((s) => s.id)
          .toSet();

      if (!mounted) return;

      // #5: Load deposit for this owner
      OwnerDeposit? deposit;
      if (cat != null && cat.ownerPhone.isNotEmpty) {
        final finVm = context.read<FinancialViewModel>();
        final normalizedPhone = PhoneNumberUtils.normalize(cat.ownerPhone);
        deposit = finVm.deposits.where((d) => 
          PhoneNumberUtils.normalize(d.ownerPhone) == normalizedPhone
        ).firstOrNull;
      }

      setState(() {
        _session = session;
        _cat = cat;
        _findings = session.findings.toSet();
        _selectedServiceIds = matchedIds;
        _notesController.text = session.groomerNotes;
        _costController.text = session.totalCost.toString();
        _currentStatus = session.status;
        _ownerDeposit = deposit;
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _recalcCost() {
    final vm = context.read<GroomingViewModel>();
    final cost = vm.services
        .where((s) => _selectedServiceIds.contains(s.id))
        .fold<int>(0, (sum, s) => sum + s.defaultPrice);
    if (cost > 0) {
      _costController.text = cost.toString();
    }
  }

  Future<void> _save() async {
    if (_session == null) return;
    final vm = context.read<GroomingViewModel>();
    // #7: Parse cost from formatted text (remove thousands separator dots)
    final costClean = int.tryParse(_costController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    final updatedSession = _session!.copyWith(
      findings: _findings.toList(),
      treatment: vm.services
          .where((s) => _selectedServiceIds.contains(s.id))
          .map((s) => s.serviceName)
          .toList(),
      groomerNotes: _notesController.text,
      totalCost: costClean,
      status: _currentStatus,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // #5: Deduct deposit if applicable
    if (_useDeposit && _ownerDeposit != null && _currentStatus == 'DONE' && costClean > 0 && _cat != null) {
      try {
        final deductAmount = _ownerDeposit!.balance < costClean.toDouble()
            ? _ownerDeposit!.balance
            : costClean.toDouble();
        final finVm = context.read<FinancialViewModel>();
        await finVm.deductDeposit(
          _cat!.ownerPhone,
          deductAmount,
          'Grooming: ${_cat!.catName}',
          _session!.sessionId,
          transactionType: TransactionType.groomingPayment,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deposit error: $e')),
          );
        }
      }
    }

    await vm.updateSession(updatedSession);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final vm = context.read<GroomingViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSession),
        content: Text(l10n.deleteSessionConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && _session != null) {
      await vm.deleteSession(_session!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editSession)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editSession)),
        body: Center(child: Text(l10n.sessionNotFound)),
      );
    }

    // #5: Deposit calculation
    final costValue = int.tryParse(_costController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    final showDepositOption = _currentStatus == 'DONE' &&
        costValue > 0 &&
        _ownerDeposit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editSession),
        actions: [
          IconButton(
            onPressed: () => _delete(l10n),
            icon: const Icon(Icons.delete_rounded),
            color: Colors.redAccent,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cat Name
            Text(
              'Cat: ${_cat?.catName ?? "Unknown"}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ─── Status Chips ──────────────────────────────
            Card(
              color: isDark ? AppColors.darkCard : AppColors.lightIconBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.status, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _statuses.map((s) {
                        final selected = _currentStatus == s;
                        return FilterChip(
                          selected: selected,
                          label: Text(s),
                          onSelected: (_) => setState(() => _currentStatus = s),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Findings Chips ────────────────────────────
            Text(l10n.findings, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ...vm.findingOptions.map((opt) {
                  final selected = _findings.contains(opt.label);
                  // #6: Long-press to delete chip option
                  return GestureDetector(
                    onLongPress: () => _showDeleteChipDialog(opt),
                    child: FilterChip(
                      selected: selected,
                      label: Text(opt.label),
                      onSelected: (_) {
                        setState(() {
                          if (selected) {
                            _findings.remove(opt.label);
                          } else {
                            _findings.add(opt.label);
                          }
                        });
                      },
                    ),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: Text(l10n.add),
                  onPressed: () => _showAddOptionDialog('finding'),
                ),
              ],
            ),

            const Divider(height: 24),

            // ─── Treatment Chips ───────────────────────────
            Text(l10n.treatments, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: vm.services.map((svc) {
                final selected = _selectedServiceIds.contains(svc.id);
                return FilterChip(
                  selected: selected,
                  label: Text('${svc.serviceName} (${app_date.formatCurrencyInt(svc.defaultPrice)})'),
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedServiceIds.remove(svc.id);
                      } else {
                        _selectedServiceIds.add(svc.id);
                      }
                      _recalcCost();
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ─── Notes ─────────────────────────────────────
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes,
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // ─── Total Cost ────────────────────────────────
            // #7: ThousandsSeparator format on cost field
            // #7: ThousandsSeparator format on cost field
            TextField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: l10n.totalCost,
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),

            // #5: Deposit Payment Option
            if (showDepositOption) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: _ownerDeposit!.balance >= costValue.toDouble()
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  border: Border.all(
                    color: _ownerDeposit!.balance >= costValue.toDouble()
                        ? Colors.green.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Checkbox(
                      value: _useDeposit,
                      onChanged: _ownerDeposit!.balance > 0
                          ? (val) => setState(() => _useDeposit = val ?? false)
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.payFromDeposit, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            l10n.balanceStr(app_date.formatCurrencyDouble(_ownerDeposit!.balance)),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _ownerDeposit!.balance >= costValue.toDouble()
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          if (_ownerDeposit!.balance < costValue.toDouble() && _ownerDeposit!.balance > 0)
                            Text(
                              l10n.balanceNotEnoughDeduct(app_date.formatCurrencyDouble(_ownerDeposit!.balance)),
                              style: const TextStyle(fontSize: 11, color: Colors.orange),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ─── Save Button ───────────────────────────────
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Update Session'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionDialog(String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Opsi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<GroomingViewModel>().addChipOption(category, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // #6: Long-press delete chip option dialog
  void _showDeleteChipDialog(dynamic option) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Opsi'),
        content: Text('Hapus "${option.label}" dari daftar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              context.read<GroomingViewModel>().deleteChipOption(option);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
