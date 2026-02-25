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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arsipkan Kucing?'),
        content: Text('"${cat.catName}" memiliki riwayat transaksi dan tidak bisa dihapus. Dengan mengarsipkan, data keuangan tetap aman namun kucing tidak akan muncul lagi di daftar dan pengingat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Arsipkan'),
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
          SnackBar(content: Text('${cat.catName} telah diarsipkan')),
        );
      }
    }
  }

  Future<void> _confirmUnarchive(BuildContext context, Cat cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktifkan Kembali?'),
        content: Text('Apakah Anda ingin memulihkan "${cat.catName}"? Kucing ini akan muncul kembali di daftar aktif.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aktifkan'),
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
        SnackBar(content: Text('${cat.catName} telah diaktifkan kembali')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Cat cat) async {
    if (_sessions.isNotEmpty || _hotelBookings.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hapus gagal: Kucing ini memiliki riwayat. Gunakan fitur Arsip.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kucing?'),
        content: Text('Apakah Anda yakin ingin menghapus "${cat.catName}"? Semua riwayat grooming juga akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
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
          SnackBar(content: Text('${cat.catName} telah dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cat == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kucing tidak ditemukan.')),
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
                  tooltip: 'Aktifkan Kembali',
                )
              else ...[
                if (_sessions.isNotEmpty || _hotelBookings.isNotEmpty)
                  IconButton(
                    onPressed: () => _confirmArchive(context, cat),
                    icon: const Icon(Icons.archive_outlined, color: Colors.white),
                    tooltip: 'Arsipkan',
                  )
                else
                  IconButton(
                    onPressed: () => _confirmDelete(context, cat),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    tooltip: 'Hapus',
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
                        '${cat.breed} • ${cat.gender}',
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
              child: _buildInfoCard(cat, isDark),
            ),
          ),

          // ─── Loyalty Tracker ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildLoyaltyTracker(context, isDark),
            ),
          ),

          // ─── Session History ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Riwayat Grooming (${_sessions.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (_sessions.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(child: Text('Belum ada riwayat grooming.')),
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

  Widget _buildInfoCard(Cat cat, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const Divider(height: 20),
            _infoRow(Icons.person_rounded, 'Pemilik', cat.ownerName, isDark),
            _infoRow(Icons.phone_rounded, 'Telepon', cat.ownerPhone, isDark),
            _infoRow(Icons.palette_rounded, 'Warna Bulu', cat.furColor.isEmpty ? '-' : cat.furColor, isDark),
            _infoRow(Icons.visibility_rounded, 'Warna Mata', cat.eyeColor.isEmpty ? '-' : cat.eyeColor, isDark),
            _infoRow(Icons.monitor_weight_rounded, 'Berat', cat.weight > 0 ? '${cat.weight} kg' : '-', isDark),
            _infoRow(
              Icons.medical_services_rounded,
              'Steril',
              cat.isSterile ? 'Sudah Steril' : 'Belum Steril',
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

  Widget _buildLoyaltyTracker(BuildContext context, bool isDark) {
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
                  'Loyalty Tracker',
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration_rounded, color: Color(0xFF66BB6A), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Loyalty Completed! 🎉',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF66BB6A)),
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION HISTORY CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _SessionHistoryCard extends StatelessWidget {
  final Session session;
  final Cat cat;
  final bool isDark;

  const _SessionHistoryCard({
    required this.session,
    required this.cat,
    required this.isDark,
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
                  final text = 'Grooming Report\n'
                      'Kucing: ${cat.catName}\n'
                      'Tanggal: ${app_date.formatDate(session.timestamp)}\n'
                      'Biaya: ${app_date.formatCurrencyDouble(session.totalCost.toDouble())}\n'
                      'Catatan: ${session.groomerNotes}';
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
