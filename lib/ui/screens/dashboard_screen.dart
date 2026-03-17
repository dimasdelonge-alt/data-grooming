import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import '../grooming_view_model.dart';
import '../financial_view_model.dart';
import 'dart:ui';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../common/mini_sparkline.dart';
import '../common/animated_counter.dart';
import '../../data/entity/cat.dart';
import '../../data/entity/session.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/reminder_utils.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

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
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    
    // Check for global message
    if (vm.globalMessage != null) {
      final msg = vm.globalMessage!;
      if (vm.settingsPrefs.dismissedMessageId != msg.id && !_isDialogShowing) {
        _isDialogShowing = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: msg.dismissible,
            builder: (ctx) => AlertDialog(
              title: Text(msg.title),
              content: Text(msg.body),
              actions: [
                if (msg.dismissible)
                  FilledButton(
                    onPressed: () {
                      vm.markGlobalMessageAsDismissed(msg.id);
                      _isDialogShowing = false;
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.close ?? 'OK'),
                  ),
              ],
            ),
          ).then((_) {
            if (mounted) {
              setState(() => _isDialogShowing = false);
            }
          });
        });
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : null,
      body: CustomScrollView(
        slivers: [
          // ─── Gradient Header ───────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context, vm, isDark, l10n)),

          // ─── Stats Card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 32 : 16, isDesktop ? 32 : 16, 8),
              child: _buildStatsCard(context, vm, isDark, l10n),
            ),
          ),
    
                // ─── Feature Grid ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 24 : 8, isDesktop ? 32 : 16, 8),
                    child: _buildFeatureGrid(context, isDark, l10n),
                  ),
                ),
    
                // ─── Active Sessions Banner ────────────────────────
                if (vm.activeSessions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 8, isDesktop ? 32 : 16, 8),
                      child: _buildActiveBanner(context, vm, isDark, l10n),
                    ),
                  ),
    
                // ─── Recent Activity ───────────────────────────────
                if (vm.recentSessions.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 24 : 8, isDesktop ? 32 : 16, 4),
                      child: _sectionHeader(
                        context,
                        l10n.recentActivity,
                        l10n,
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
                          return _StaggeredFadeIn(
                            index: index,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 4),
                              child: _SessionCard(session: session, cat: cat, isDark: isDark),
                            ),
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
                        l10n.catListCount(vm.allCats.length),
                        l10n,
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
                          return _StaggeredFadeIn(
                            index: index,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 4),
                              child: _CatCard(cat: cat, isDark: isDark),
                            ),
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

  Widget _buildHeader(BuildContext context, GroomingViewModel vm, bool isDark, AppLocalizations l10n) {
    // V2 Logic: count only new reminders since last check
    final lastCheck = vm.lastNotificationCheck;
    final urgentCount = vm.marketingReminders.where((r) {
      final triggerDate = r.lastDate + (14 * 24 * 60 * 60 * 1000);
      return r.daysSince > 14 && (triggerDate > lastCheck);
    }).length;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
      decoration: BoxDecoration(
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
                      _getGreetingText(l10n),
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
                  vm.businessName.isEmpty ? l10n.businessNamePlaceholder : vm.businessName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                if (vm.pendingSyncCount > 0)
                  Badge.count(
                    count: vm.pendingSyncCount,
                    backgroundColor: Colors.orange,
                    offset: const Offset(-6, 6),
                    child: IconButton(
                      onPressed: () => _showSyncDialog(context, vm, l10n),
                      icon: const Icon(Icons.cloud_off_rounded, color: Colors.orange),
                      tooltip: 'Sync pending',
                    ),
                  ),
                Badge.count(
                  count: urgentCount,
                  isLabelVisible: urgentCount > 0,
                  offset: const Offset(-6, 6),
                  child: IconButton(
                    onPressed: () => _showReminders(context, vm, l10n),
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

  String _getGreetingText(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 10) return l10n.goodMorning;
    if (hour < 15) return l10n.goodAfternoon;
    if (hour < 18) return l10n.goodEvening;
    return l10n.goodNight;
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

  Widget _buildStatsCard(BuildContext context, GroomingViewModel vm, bool isDark, AppLocalizations l10n) {
    return Hero(
      tag: 'financial_card',
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        return Material(
          type: MaterialType.transparency,
          child: flightDirection == HeroFlightDirection.push
              ? fromHeroContext.widget
              : toHeroContext.widget,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark ? BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1) : BorderSide.none,
        ),
        color: isDark ? AppColors.darkCard : Colors.white,
        shadowColor: isDark && vm.currentMonthNetProfit > 0 
            ? AppColors.accentGreen.withValues(alpha: 0.2)
            : null,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/financial'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.netProfit} ${vm.currentMonthName}',
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
                        l10n.sessionsCountLabel(vm.currentMonthSessionCount),
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
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedCounter(
                            value: vm.currentMonthNetProfit,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: vm.currentMonthNetProfit >= 0
                                      ? (isDark ? AppColors.accentGreen : const Color(0xFF2E7D32))
                                      : Colors.redAccent,
                                  shadows: isDark && vm.currentMonthNetProfit > 0
                                      ? [
                                          Shadow(
                                            color: AppColors.accentGreen.withOpacity(0.4),
                                            blurRadius: 15,
                                          )
                                        ]
                                      : null,
                                ),
                          ),
                          if (vm.currentMonthNetProfit != 0 || vm.lastMonthNetProfit != 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  vm.profitGrowthPct >= 0 ? Icons.trending_up : Icons.trending_down,
                                  size: 14,
                                  color: vm.profitGrowthPct >= 0 ? AppColors.accentGreen : Colors.redAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${vm.profitGrowthPct >= 0 ? "+" : ""}${vm.profitGrowthPct.toStringAsFixed(1)}% vs last month',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: vm.profitGrowthPct >= 0 
                                        ? (isDark ? AppColors.accentGreen.withOpacity(0.8) : Colors.green)
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    MiniSparkline(
                      data: vm.profitTrendData,
                      color: isDark ? AppColors.accentGreen : const Color(0xFF2E7D32),
                      width: 120,
                      height: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statMini(
                      context,
                      Icons.arrow_upward_rounded,
                      const Color(0xFF66BB6A),
                      l10n.income,
                      vm.currentMonthIncome,
                    ),
                    const SizedBox(width: 24),
                    _statMini(
                      context,
                      Icons.arrow_downward_rounded,
                      const Color(0xFFEF5350),
                      l10n.expense,
                      vm.currentMonthExpense,
                    ),
                  ],
                ),
                // Total Piutang
                Builder(
                  builder: (context) {
                    final finVm = context.watch<FinancialViewModel>();
                    if (finVm.totalReceivables <= 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Text(
                            '${l10n.totalReceivables}: ${app_date.formatCurrencyDouble(finVm.totalReceivables)}',
                            style: TextStyle(fontSize: 11, color: Colors.red.withOpacity(0.8), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _statMini(BuildContext context, IconData icon, Color color, String label, double value) {
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
                AnimatedCounter(
                  value: value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
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

  Widget _buildFeatureGrid(BuildContext context, bool isDark, AppLocalizations l10n) {
    final features = [
      _FeatureItem(Icons.content_cut_rounded, l10n.newSession, 0, () => Navigator.pushNamed(context, '/session_entry')),
      _FeatureItem(Icons.pets_rounded, l10n.cats, 1, () => Navigator.pushNamed(context, '/cat_list')),
      _FeatureItem(Icons.hotel_rounded, l10n.hotel, 2, () => Navigator.pushNamed(context, '/hotel')),
      _FeatureItem(Icons.event_note_rounded, l10n.booking, 3, () => Navigator.pushNamed(context, '/booking')),
      _FeatureItem(Icons.account_balance_wallet_rounded, l10n.deposit, 4, () => Navigator.pushNamed(context, '/deposit')),
      _FeatureItem(Icons.list_alt_rounded, l10n.services, 5, () => Navigator.pushNamed(context, '/service_list')),
      _FeatureItem(Icons.calendar_today_rounded, l10n.calendar, 6, () => Navigator.pushNamed(context, '/calendar')),
      _FeatureItem(Icons.settings_rounded, l10n.settings, 7, () => Navigator.pushNamed(context, '/settings')),
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

  Widget _buildActiveBanner(BuildContext context, GroomingViewModel vm, bool isDark, AppLocalizations l10n) {
    return _BreathAnimation(
      child: InkWell(
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
                child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white, // Standardized for banner
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vm.activeSessions.length} ${l10n.activeSessions}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      l10n.processingNow,
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionHeader(BuildContext context, String title, AppLocalizations l10n, {VoidCallback? onSeeAll}) {
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
                Text(l10n.seeAll, style: const TextStyle(fontSize: 12)),
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

  void _showReminders(BuildContext context, GroomingViewModel vm, AppLocalizations l10n) {
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
                    l10n.groomingSchedule,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (vm.marketingReminders.isEmpty)
                    Expanded(
                      child: Center(child: Text(l10n.noReschedule)),
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
                                '${r.cat.ownerName} • ${l10n.daysAgoLabel(r.daysSince)}',
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

  void _showSyncDialog(BuildContext context, GroomingViewModel vm, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(l10n.syncPending),
            ],
          ),
          content: Text(l10n.syncPendingDesc(vm.pendingSyncCount)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                vm.retrySyncNow();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retryNow),
            ),
          ],
        );
      },
    );
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
    final l10n = AppLocalizations.of(context)!;
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
                      _getStatusLabel(session.status, l10n),
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

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'WAITING':
        return l10n.statusWaiting;
      case 'BATHING':
        return l10n.statusBathing;
      case 'DRYING':
        return l10n.statusDrying;
      case 'FINISHING':
        return l10n.statusFinishing;
      case 'PICKUP_READY':
        return l10n.statusPickupReady;
      case 'DONE':
        return l10n.statusDone;
      default:
        return status;
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
                      '${cat.breed} • ${_getGenderLabel(cat.gender, AppLocalizations.of(context)!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.owner}: ${cat.ownerName}',
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

  String _getGenderLabel(String gender, AppLocalizations l10n) {
    if (gender.toLowerCase() == 'male') return l10n.male;
    if (gender.toLowerCase() == 'female') return l10n.female;
    return gender;
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

// ─── HELPER WIDGETS FOR ANIMATION ───────────────────────────────────────────

class _StaggeredFadeIn extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggeredFadeIn({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _BreathAnimation extends StatefulWidget {
  final Widget child;
  const _BreathAnimation({required this.child});

  @override
  State<_BreathAnimation> createState() => _BreathAnimationState();
}

class _BreathAnimationState extends State<_BreathAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}
