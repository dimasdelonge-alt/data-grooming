import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../financial_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../../data/entity/session.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/pdf_generator.dart';
import '../common/empty_state.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

/// Searchable list of all grooming sessions with multi-select for combined invoices.
/// Multi-select restricts selection to same-owner cats only.
class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  String _search = '';
  bool _isSelecting = false;
  final Set<int> _selectedIds = {};
  String? _lockedOwnerName; // Only allow selecting cats from this owner
  bool _isPrinting = false;

  /// Get the owner of a session via catId lookup
  String? _getOwnerOfSession(int sessionId) {
    final vm = context.read<GroomingViewModel>();
    final session = vm.allSessions.where((s) => s.sessionId == sessionId).firstOrNull;
    if (session == null) return null;
    final cat = vm.allCats.where((c) => c.catId == session.catId).firstOrNull;
    return cat?.ownerName;
  }

  void _toggleSelection(int sessionId) {
    setState(() {
      if (_selectedIds.contains(sessionId)) {
        _selectedIds.remove(sessionId);
        if (_selectedIds.isEmpty) {
          _isSelecting = false;
          _lockedOwnerName = null;
        }
      } else {
        // Check same owner
        final owner = _getOwnerOfSession(sessionId);
        if (_lockedOwnerName == null || _lockedOwnerName == owner) {
          _selectedIds.add(sessionId);
          _lockedOwnerName ??= owner;
        } else {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.onlySelectSameOwnerSession(_lockedOwnerName ?? '')),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _enterSelectionMode(int sessionId) {
    final owner = _getOwnerOfSession(sessionId);
    setState(() {
      _isSelecting = true;
      _selectedIds.add(sessionId);
      _lockedOwnerName = owner;
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
      _lockedOwnerName = null;
    });
  }

  void _selectAllSameOwner(List<Session> filtered) {
    if (_lockedOwnerName == null) return;
    final vm = context.read<GroomingViewModel>();
    setState(() {
      for (final s in filtered) {
        final cat = vm.allCats.where((c) => c.catId == s.catId).firstOrNull;
        if (cat?.ownerName == _lockedOwnerName) {
          _selectedIds.add(s.sessionId);
        }
      }
    });
  }

  Future<void> _printCombinedInvoice(BuildContext context) async {
    if (_selectedIds.isEmpty || _isPrinting) return;

    setState(() => _isPrinting = true);

    final vm = context.read<GroomingViewModel>();
    final selectedSessions = vm.allSessions
        .where((s) => _selectedIds.contains(s.sessionId))
        .toList();

    if (selectedSessions.isEmpty) {
      setState(() => _isPrinting = false);
      return;
    }

    try {
      final finVm = context.read<FinancialViewModel>();

      if (selectedSessions.length == 1) {
        // Single session — use single invoice
        final session = selectedSessions.first;
        final cat = vm.allCats.where((c) => c.catId == session.catId).firstOrNull;
        if (cat != null) {
          final depositPaid = await finVm.getDepositPaidForSession(session.sessionId);
          await PdfGenerator.printSessionInvoice(
            session: session,
            cat: cat,
            businessName: vm.businessName,
            businessPhone: vm.businessPhone,
            businessAddress: vm.businessAddress,
            logoPath: vm.logoPath,
            userPlan: vm.userPlan,
            servicePrices: {
              for (final s in vm.services) s.serviceName: s.defaultPrice
            },
            depositDeducted: depositPaid,
          );
        }
      } else {
        // Combined — sum all deposits for selected sessions
        double totalDeposit = 0.0;
        for (final s in selectedSessions) {
          totalDeposit += await finVm.getDepositPaidForSession(s.sessionId);
        }
        await PdfGenerator.printCombinedSessionInvoice(
          sessions: selectedSessions,
          cats: vm.allCats,
          businessName: vm.businessName,
          businessPhone: vm.businessPhone,
          businessAddress: vm.businessAddress,
          logoPath: vm.logoPath,
          userPlan: vm.userPlan,
          depositDeducted: totalDeposit,
        );
      }
    } catch (e) {
      debugPrint('Error printing combined invoice: $e');
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.printFailed(e.toString()))),
        );
      }
    }

    setState(() => _isPrinting = false);
    _cancelSelection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allSessions = vm.allSessions;
    final cats = vm.allCats;
    final query = _search.trim().toLowerCase();

    // Filter sessions by cat name, owner, or groomer notes
    final filtered = query.isEmpty
        ? allSessions
        : allSessions.where((s) {
            final cat = cats.where((c) => c.catId == s.catId).firstOrNull;
            return (cat?.catName.toLowerCase().contains(query) ?? false) ||
                (cat?.ownerName.toLowerCase().contains(query) ?? false) ||
                s.groomerNotes.toLowerCase().contains(query);
          }).toList();

    // Sort newest first
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: _isSelecting
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _cancelSelection,
              ),
              title: Text(l10n.selectedCount(_selectedIds.length)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  tooltip: l10n.selectAllOwner(_lockedOwnerName ?? ''),
                  onPressed: () => _selectAllSameOwner(filtered),
                ),
                _isPrinting
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.print_rounded),
                        tooltip: l10n.printCombinedInvoiceBtn,
                        onPressed: _selectedIds.isNotEmpty
                            ? () => _printCombinedInvoice(context)
                            : null,
                      ),
              ],
            )
          : AppBar(title: Text(l10n.sessionHistoryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: l10n.searchSession,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        onPressed: () => setState(() => _search = ''),
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
            ),
          ),

          if (_isSelecting && _lockedOwnerName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, size: 16,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.ownerOnlySessionWarning(_lockedOwnerName ?? ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    message: query.isEmpty ? l10n.noSessionsYet : l10n.notFound,
                    subMessage: query.isEmpty ? l10n.tapPlusButtonInCatDetail : l10n.tryAnotherKeyword,
                    icon: query.isEmpty ? Icons.spa_rounded : Icons.search_off_rounded,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final session = filtered[index];
                      final cat = cats.where((c) => c.catId == session.catId).firstOrNull;
                      final isSelected = _selectedIds.contains(session.sessionId);
                      final isDifferentOwner = _isSelecting && _lockedOwnerName != null && cat?.ownerName != _lockedOwnerName;
                      return Opacity(
                        opacity: isDifferentOwner ? 0.4 : 1.0,
                        child: _SessionCard(
                          session: session,
                          catName: cat?.catName ?? l10n.unknownCat,
                          catImage: cat?.imagePath,
                          isDark: isDark,
                          isSelected: isSelected,
                          isSelecting: _isSelecting,
                          onTap: _isSelecting
                              ? () => _toggleSelection(session.sessionId)
                              : () => Navigator.pushNamed(context, '/session_detail', arguments: session.sessionId),
                          onLongPress: _isSelecting
                              ? null
                              : () => _enterSelectionMode(session.sessionId),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final String catName;
  final String? catImage;
  final bool isDark;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SessionCard({
    required this.session,
    required this.catName,
    this.catImage,
    required this.isDark,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    this.onLongPress,
  });

  Color _statusColor() {
    switch (session.status) {
      case 'DONE':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'PICKUP_READY':
        return Colors.amber;
      default:
        return isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (isSelecting)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                )
              else
                CatAvatar(imagePath: catImage, size: 44),
              if (!isSelecting) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            catName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            session.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          app_date.formatDateTime(session.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          app_date.formatCurrencyDouble(session.totalCost.toDouble()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (!isSelecting)
                Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
            ],
          ),
        ),
      ),
    );
  }
}
