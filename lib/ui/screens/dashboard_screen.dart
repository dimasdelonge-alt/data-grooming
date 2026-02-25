import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../../data/entity/cat.dart';
import '../../data/entity/session.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/reminder_utils.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardBody();
  }
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : null,
      body: CustomScrollView(
        slivers: [
          // ─── Gradient Header ───────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context, vm, isDark)),

          // ─── Stats Card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 32 : 16, isDesktop ? 32 : 16, 8),
              child: _buildStatsCard(context, vm, isDark),
            ),
          ),
    
                // ─── Feature Grid ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 24 : 8, isDesktop ? 32 : 16, 8),
                    child: _buildFeatureGrid(context, isDark),
                  ),
                ),
    
                // ─── Active Sessions Banner ────────────────────────
                if (vm.activeSessions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 8, isDesktop ? 32 : 16, 8),
                      child: _buildActiveBanner(context, vm, isDark),
                    ),
                  ),
    
                // ─── Recent Activity ───────────────────────────────
                if (vm.recentSessions.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 24 : 8, isDesktop ? 32 : 16, 4),
                      child: _sectionHeader(
                        context,
                        'Aktivitas Terbaru',
                        onSeeAll: () {
                          Navigator.pushNamed(context, '/session_list');
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: isDesktop ? 350 : 270,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: vm.recentSessions.length.clamp(0, 5),
                        itemBuilder: (context, index) {
                          final session = vm.recentSessions[index];
                          final cat = vm.allCats.where((c) => c.catId == session.catId).firstOrNull;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 4),
                            child: _SessionCard(session: session, cat: cat, isDark: isDark),
                          );
                        },
                      ),
                    ),
                  ),
                ],
    
                // ─── Cats Preview ──────────────────────────────────
                if (vm.allCats.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 24 : 12, isDesktop ? 32 : 16, 4),
                      child: _sectionHeader(
                        context,
                        'Daftar Kucing (${vm.allCats.length})',
                        onSeeAll: () {
                          Navigator.pushNamed(context, '/cat_list');
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: isDesktop ? 400 : 310,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: vm.allCats.length.clamp(0, 5),
                        itemBuilder: (context, index) {
                          final cat = vm.allCats[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 4),
                            child: _CatCard(cat: cat, isDark: isDark),
                          );
                        },
                      ),
                    ),
                  ),
                ],
    
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, GroomingViewModel vm, bool isDark) {
    // V2 Logic: count only new reminders since last check
    final lastCheck = vm.lastNotificationCheck;
    final urgentCount = vm.marketingReminders.where((r) {
      final triggerDate = r.lastDate + (14 * 24 * 60 * 60 * 1000);
      return r.daysSince > 14 && (triggerDate > lastCheck);
    }).length;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : null,
        border: isDark 
            ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5))
            : null,
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkBackground, AppColors.darkSurface.withValues(alpha: 0.8)]
              : [AppColors.lightPrimaryDark, AppColors.lightPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 16, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getGreetingText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    if (vm.weatherIconUrl != null) ...[
                      const SizedBox(width: 6),
                      Image.network(
                        vm.weatherIconUrl!,
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ] else ...[
                      const SizedBox(width: 4),
                      Text(
                        _getWeatherEmoji(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
                Text(
                  vm.businessName.isEmpty ? 'Nama Bisnis' : vm.businessName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                    fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                // Notification bell with badge (V2 Style)
                Badge.count(
                  count: urgentCount,
                  isLabelVisible: urgentCount > 0,
                  offset: const Offset(-6, 6), // Pull it closer to the bell
                  child: IconButton(
                    onPressed: () => _showReminders(context, vm),
                    icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getWeatherEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 10) return '🌅';
    if (hour < 15) return '☀️';
    if (hour < 18) return '🌇';
    return '🌙';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATS CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatsCard(BuildContext context, GroomingViewModel vm, bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isDark ? BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1) : BorderSide.none,
      ),
      color: isDark ? AppColors.darkCard : Colors.white,
      shadowColor: isDark && vm.currentMonthNetProfit > 0 
          ? AppColors.accentGreen.withValues(alpha: 0.2)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Laba Bersih ${vm.currentMonthName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.accentGreen : AppColors.lightPrimary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${vm.currentMonthSessionCount} sesi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.accentGreen : AppColors.lightPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              app_date.formatCurrencyDouble(vm.currentMonthNetProfit),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: vm.currentMonthNetProfit >= 0
                        ? (isDark ? AppColors.accentGreen : const Color(0xFF2E7D32))
                        : Colors.redAccent,
                    shadows: isDark && vm.currentMonthNetProfit > 0
                        ? [
                            Shadow(
                              color: AppColors.accentGreen.withValues(alpha: 0.5),
                              blurRadius: 12,
                            )
                          ]
                        : null,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statMini(
                  context,
                  Icons.arrow_upward_rounded,
                  const Color(0xFF66BB6A),
                  'Pemasukan',
                  app_date.formatCurrencyDouble(vm.currentMonthIncome),
                ),
                const SizedBox(width: 24),
                _statMini(
                  context,
                  Icons.arrow_downward_rounded,
                  const Color(0xFFEF5350),
                  'Pengeluaran',
                  app_date.formatCurrencyDouble(vm.currentMonthExpense),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statMini(BuildContext context, IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE GRID
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFeatureGrid(BuildContext context, bool isDark) {
    final features = [
      _FeatureItem(Icons.content_cut_rounded, 'Sesi Baru', 0, () => Navigator.pushNamed(context, '/session_entry')),
      _FeatureItem(Icons.pets_rounded, 'Kucing', 1, () => Navigator.pushNamed(context, '/cat_list')),
      _FeatureItem(Icons.hotel_rounded, 'Hotel', 2, () => Navigator.pushNamed(context, '/hotel')),
      _FeatureItem(Icons.event_note_rounded, 'Booking', 3, () => Navigator.pushNamed(context, '/booking')),
      _FeatureItem(Icons.account_balance_wallet_rounded, 'Deposit', 4, () => Navigator.pushNamed(context, '/deposit')),
      _FeatureItem(Icons.list_alt_rounded, 'Layanan', 5, () => Navigator.pushNamed(context, '/service_list')),
      _FeatureItem(Icons.calendar_today_rounded, 'Kalender', 6, () => Navigator.pushNamed(context, '/calendar')),
      _FeatureItem(Icons.settings_rounded, 'Pengaturan', 7, () => Navigator.pushNamed(context, '/settings')),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    double iconSize = 24;
    double fontSize = 11;
    double paddingScale = 12;

    if (screenWidth >= 900) {
      crossAxisCount = 8;
      iconSize = 32;
      fontSize = 13;
      paddingScale = 16;
    } else if (screenWidth >= 600) {
      crossAxisCount = 6;
      iconSize = 28;
      fontSize = 12;
      paddingScale = 14;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: features.map((f) {
        return _FeatureTile(
          item: f,
          isDark: isDark,
          iconSize: iconSize,
          fontSize: fontSize,
          paddingScale: paddingScale,
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVE SESSIONS BANNER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildActiveBanner(BuildContext context, GroomingViewModel vm, bool isDark) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/session_entry'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.accentBlue.withValues(alpha: 0.2), AppColors.accentPurple.withValues(alpha: 0.2)]
                : [AppColors.lightPrimary.withValues(alpha: 0.1), AppColors.lightSecondary.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? AppColors.accentBlue : AppColors.lightPrimary).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accentBlue : AppColors.lightPrimary).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.pets_rounded,
                color: isDark ? AppColors.accentBlue : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vm.activeSessions.length} Sesi Aktif',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    'Sedang diproses sekarang',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionHeader(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              children: [
                const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, size: 10),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REMINDERS BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  void _showReminders(BuildContext context, GroomingViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Jadwal Grooming',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (vm.marketingReminders.isEmpty)
                    const Expanded(
                      child: Center(child: Text('Tidak ada jadwal ulang')),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: vm.marketingReminders.length,
                        itemBuilder: (context, index) {
                          final r = vm.marketingReminders[index];
                          final indicatorColor = r.daysSince > 30
                              ? Colors.redAccent
                              : r.daysSince > 14
                                  ? Colors.orangeAccent
                                  : AppColors.accentGreen;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: indicatorColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(
                                r.cat.catName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${r.cat.ownerName} • ${r.daysSince} hari lalu',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone_rounded, color: Color(0xFF25D366)),
                                onPressed: () {
                                  sendMarketingReminder(
                                    r.cat,
                                    app_date.formatDate(r.lastDate),
                                    r.daysSince,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      vm.markNotificationsAsRead();
    });
  }
}

// ─── FEATURE TILE WITH HOVER ──────────────────────────────────────────────────

class _FeatureTile extends StatefulWidget {
  final _FeatureItem item;
  final bool isDark;
  final double iconSize;
  final double fontSize;
  final double paddingScale;

  const _FeatureTile({
    required this.item,
    required this.isDark,
    required this.iconSize,
    required this.fontSize,
    required this.paddingScale,
  });

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark
        ? AppColors.accentByIndex(widget.item.colorIndex)
        : AppColors.lightPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: InkWell(
          onTap: widget.item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(widget.paddingScale),
                decoration: BoxDecoration(
                  color: _isHovered ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isHovered && widget.isDark
                      ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)]
                      : [],
                ),
                child: Icon(widget.item.icon, size: widget.iconSize, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
                  color: widget.isDark ? AppColors.darkText : AppColors.lightText,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SessionCard extends StatelessWidget {
  final Session session;
  final Cat? cat;
  final bool isDark;

  const _SessionCard({required this.session, this.cat, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(session.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // TODO: Navigate to session detail
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CatAvatar(imagePath: cat?.imagePath, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat?.catName ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app_date.formatDate(session.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    app_date.formatCurrencyDouble(session.totalCost.toDouble()),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      session.status,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'WAITING':
        return const Color(0xFFFFB74D);
      case 'BATHING':
        return const Color(0xFF4FC3F7);
      case 'DRYING':
        return const Color(0xFF81C784);
      case 'FINISHING':
        return const Color(0xFFBA68C8);
      case 'PICKUP_READY':
        return const Color(0xFF66BB6A);
      case 'DONE':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CAT CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _CatCard extends StatelessWidget {
  final Cat cat;
  final bool isDark;

  const _CatCard({required this.cat, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pushNamed(context, '/cat_detail', arguments: cat.catId);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CatAvatar(imagePath: cat.imagePath, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.catName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cat.breed} • ${cat.gender}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                    ),
                    Text(
                      'Owner: ${cat.ownerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              if (cat.permanentAlert.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.redAccent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FEATURE ITEM MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class _FeatureItem {
  final IconData icon;
  final String label;
  final int colorIndex;
  final VoidCallback onTap;

  const _FeatureItem(this.icon, this.label, this.colorIndex, this.onTap);
}
