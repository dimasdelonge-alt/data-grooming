import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../../data/entity/cat.dart';
import '../../data/entity/session.dart';
import '../../util/date_utils.dart' as app_date;
import 'package:share_plus/share_plus.dart';
import '../../data/entity/hotel_entities.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

class CatDetailScreen extends StatefulWidget {
  final int catId;

  const CatDetailScreen({super.key, required this.catId});

  @override
  State<CatDetailScreen> createState() => _CatDetailScreenState();
}

class _CatDetailScreenState extends State<CatDetailScreen> {
  Cat? _cat;
  List<Session> _sessions = [];
  List<HotelBooking> _hotelBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vm = context.read<GroomingViewModel>();
    final cat = await vm.getCat(widget.catId);
    if (cat != null && mounted) {
      setState(() {
        _cat = cat;
        _isLoading = false;
      });
      vm.getSessionsForCat(widget.catId).listen((sessions) {
        if (mounted) setState(() => _sessions = sessions);
      });
      vm.getHotelBookingsForCat(widget.catId).listen((bookings) {
        if (mounted) setState(() => _hotelBookings = bookings);
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmArchive(BuildContext context, Cat cat) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.archiveCatPrompt),
        content: Text(l10n.archiveCatDesc(cat.catName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.archive),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = context.read<GroomingViewModel>();
      await vm.archiveCat(cat);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.catArchivedSuccess(cat.catName))),
        );
      }
    }
  }

  Future<void> _confirmUnarchive(BuildContext context, Cat cat) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unarchiveCatPrompt),
        content: Text(l10n.unarchiveCatDesc(cat.catName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.unarchive),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = context.read<GroomingViewModel>();
      await vm.unarchiveCat(cat);
      setState(() {
        _cat = cat.copyWith(
          permanentAlert: cat.permanentAlert.replaceFirst('[ARCHIVED]', '').trim()
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catUnarchivedSuccess(cat.catName))),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Cat cat) async {
    final l10n = AppLocalizations.of(context)!;
    if (_sessions.isNotEmpty || _hotelBookings.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteFailedHasHistory)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCatPrompt),
        content: Text(l10n.deleteCatDesc(cat.catName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = context.read<GroomingViewModel>();
      await vm.deleteCat(cat);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.catDeletedSuccess(cat.catName))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cat == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.catNotFound)),
      );
    }

    final cat = _cat!;

    return Scaffold(

      body: CustomScrollView(
        slivers: [
          // ─── Profile Header ────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              if (cat.permanentAlert.startsWith('[ARCHIVED]'))
                IconButton(
                  onPressed: () => _confirmUnarchive(context, cat),
                  icon: const Icon(Icons.settings_backup_restore_rounded, color: Colors.white),
                  tooltip: l10n.unarchiveCatPrompt,
                )
              else ...[
                if (_sessions.isNotEmpty || _hotelBookings.isNotEmpty)
                  IconButton(
                    onPressed: () => _confirmArchive(context, cat),
                    icon: const Icon(Icons.archive_outlined, color: Colors.white),
                    tooltip: l10n.archive,
                  )
                else
                  IconButton(
                    onPressed: () => _confirmDelete(context, cat),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    tooltip: l10n.delete,
                  ),
              ],
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/cat_entry', arguments: cat.catId);
                  if (context.mounted) _loadData();
                },
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkBackground, AppColors.darkCard]
                        : [AppColors.lightPrimaryDark, AppColors.lightPrimary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      CatAvatar(imagePath: cat.imagePath, size: 80),
                      const SizedBox(height: 12),
                      Text(
                        cat.catName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cat.breed} • ${_getGenderLabel(cat.gender, l10n)}',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Alert Banner ──────────────────────────────────
          if (cat.permanentAlert.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat.permanentAlert,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Info Cards ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildInfoCard(cat, isDark, l10n),
            ),
          ),

          // ─── Loyalty Tracker ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildLoyaltyTracker(context, isDark, l10n),
            ),
          ),

          // ─── Session History ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.groomingHistoryCount(_sessions.length),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (_sessions.isEmpty)
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(child: Text(l10n.noGroomingHistoryYet)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final session = _sessions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _SessionHistoryCard(
                      session: session,
                      cat: cat,
                      isDark: isDark,
                      l10n: l10n,
                    ),
                  );
                },
                childCount: _sessions.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INFO CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoCard(Cat cat, bool isDark, AppLocalizations l10n) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.information,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const Divider(height: 20),
            _infoRow(Icons.person_rounded, l10n.owner, cat.ownerName, isDark),
            _infoRow(Icons.phone_rounded, l10n.phone, cat.ownerPhone, isDark),
            _infoRow(Icons.palette_rounded, l10n.furColor, cat.furColor.isEmpty ? '-' : cat.furColor, isDark),
            _infoRow(Icons.visibility_rounded, l10n.eyeColor, cat.eyeColor.isEmpty ? '-' : cat.eyeColor, isDark),
            _infoRow(Icons.monitor_weight_rounded, l10n.weight, cat.weight > 0 ? '${cat.weight} kg' : '-', isDark),
            _infoRow(
              Icons.medical_services_rounded,
              l10n.sterile,
              cat.isSterile ? l10n.isSterileYes : l10n.isSterileNo,
              isDark,
              valueColor: cat.isSterile ? const Color(0xFF66BB6A) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? (isDark ? AppColors.darkText : AppColors.lightText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOYALTY TRACKER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLoyaltyTracker(BuildContext context, bool isDark, AppLocalizations l10n) {
    final totalVisits = _sessions.length;
    final progress = (totalVisits > 0 && totalVisits % 10 == 0) ? 10 : totalVisits % 10;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark
          ? AppColors.accentPurple.withValues(alpha: 0.15)
          : AppColors.lightSecondary.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.loyaltyTracker,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? AppColors.accentPurple : AppColors.lightPrimaryDark,
                  ),
                ),
                Text(
                  '$progress/10',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentPurple : AppColors.lightPrimaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (i) {
                final isActive = i < progress;
                return Icon(
                  Icons.pets_rounded,
                  size: 22,
                  color: isActive
                      ? (isDark ? AppColors.accentPurple : AppColors.lightPrimary)
                      : (isDark ? Colors.white12 : Colors.grey[300]),
                );
              }),
            ),
            if (progress == 10) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.celebration_rounded, color: Color(0xFF66BB6A), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.loyaltyCompleted,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF66BB6A)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getGenderLabel(String gender, AppLocalizations l10n) {
    if (gender.toLowerCase() == 'male') return l10n.male;
    if (gender.toLowerCase() == 'female') return l10n.female;
    return gender;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION HISTORY CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _SessionHistoryCard extends StatelessWidget {
  final Session session;
  final Cat cat;
  final bool isDark;
  final AppLocalizations l10n;

  const _SessionHistoryCard({
    required this.session,
    required this.cat,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Navigate to edit session (matches V2 session_detail)
          Navigator.pushNamed(context, '/session_entry', arguments: session.sessionId);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.accentBlue : AppColors.lightPrimary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.content_cut_rounded,
                  size: 20,
                  color: isDark ? AppColors.accentBlue : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app_date.formatDate(session.timestamp),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    if (session.groomerNotes.isNotEmpty)
                      Text(
                        session.groomerNotes,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                app_date.formatCurrencyDouble(session.totalCost.toDouble()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? AppColors.accentGreen : const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 4),
              // Share button — matching V2
              IconButton(
                onPressed: () {
                  final text = l10n.groomingReportShare(
                      cat.catName,
                      app_date.formatDate(session.timestamp),
                      app_date.formatCurrencyDouble(session.totalCost.toDouble()),
                      session.groomerNotes
                  );
                  Share.share(text);
                },
                icon: Icon(
                  Icons.share_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
