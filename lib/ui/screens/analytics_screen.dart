import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../analytics_view_model.dart';
import '../theme/theme.dart';
import '../common/bar_chart.dart';
import '../common/donut_chart.dart';
import '../common/cat_avatar.dart';
import '../../util/date_utils.dart' as app_date;
import 'package:datagrooming_v3/l10n/app_localizations.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load analytics data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _AnalyticsBody(vm: vm, isDark: isDark, l10n: l10n),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  final AnalyticsViewModel vm;
  final bool isDark;
  final AppLocalizations l10n;

  const _AnalyticsBody({
    required this.vm,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─── Period Selector ─────────────────────────────
        _buildPeriodSelector(context),
        const SizedBox(height: 16),

        // ─── Summary Cards ───────────────────────────────
        _buildSummaryCards(context),
        const SizedBox(height: 20),

        // ─── Revenue Trend ───────────────────────────────
        _buildSection(
          context,
          icon: Icons.trending_up_rounded,
          title: l10n.revenueTrend,
          child: _buildRevenueTrend(context),
        ),
        const SizedBox(height: 16),

        // ─── Income Breakdown ────────────────────────────
        _buildSection(
          context,
          icon: Icons.pie_chart_rounded,
          title: l10n.incomeBreakdown,
          child: _buildIncomeBreakdown(context),
        ),
        const SizedBox(height: 16),

        // ─── Busiest Days ────────────────────────────────
        _buildSection(
          context,
          icon: Icons.calendar_today_rounded,
          title: l10n.busiestDays,
          child: _buildBusiestDays(context),
        ),
        const SizedBox(height: 16),

        // ─── Popular Services ────────────────────────────
        if (vm.popularServices.isNotEmpty) ...[
          _buildSection(
            context,
            icon: Icons.star_rounded,
            title: l10n.popularServices,
            child: _buildHorizontalBarList(
              context,
              items: vm.popularServices,
              color: isDark ? AppColors.accentPurple : AppColors.lightPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ─── Common Findings ─────────────────────────────
        if (vm.commonFindings.isNotEmpty) ...[
          _buildSection(
            context,
            icon: Icons.search_rounded,
            title: l10n.commonFindings,
            child: _buildHorizontalBarList(
              context,
              items: vm.commonFindings,
              color: isDark ? AppColors.accentYellow : Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ─── Top Customers ───────────────────────────────
        if (vm.topCustomers.isNotEmpty)
          _buildSection(
            context,
            icon: Icons.people_rounded,
            title: l10n.topCustomers,
            child: _buildTopCustomers(context),
          ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PERIOD SELECTOR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPeriodSelector(BuildContext context) {
    final periods = [
      _PeriodOption(1, l10n.thisMonth),
      _PeriodOption(3, l10n.last3Months),
      _PeriodOption(6, l10n.last6Months),
      _PeriodOption(12, l10n.lastYear),
      _PeriodOption(0, l10n.allTime),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((p) {
          final selected = vm.periodMonths == p.months;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p.label),
              selected: selected,
              onSelected: (_) => vm.setPeriod(p.months),
              selectedColor: isDark
                  ? AppColors.accentBlue.withOpacity(0.3)
                  : AppColors.lightPrimary.withOpacity(0.2),
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? (isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUMMARY CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.content_cut_rounded,
            label: l10n.totalSessions,
            value: vm.totalSessions.toString(),
            color: isDark ? AppColors.accentBlue : AppColors.lightPrimary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.attach_money_rounded,
            label: l10n.avgRevenuePerSession,
            value: app_date.formatCurrencyDouble(vm.avgRevenuePerSession),
            color: isDark ? AppColors.accentGreen : const Color(0xFF2E7D32),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.replay_rounded,
            label: l10n.customerRetention,
            value: '${vm.customerRetentionRate.toStringAsFixed(0)}%',
            color: isDark ? AppColors.accentPurple : Colors.deepPurple,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REVENUE TREND
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRevenueTrend(BuildContext context) {
    final trend = vm.monthlyRevenueTrend;
    if (trend.isEmpty) {
      return _emptyState(l10n.noSessionsYet);
    }

    final months = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec,
    ];

    final data = trend.map((t) {
      final label = months[t.month.month - 1].substring(0, 3);
      return BarData(
        label: label,
        value: t.grooming,
        secondaryValue: t.hotel,
      );
    }).toList();

    return Column(
      children: [
        SimpleBarChart(
          data: data,
          height: 180,
          barColor: isDark ? AppColors.accentBlue : AppColors.lightPrimary,
          secondaryBarColor: isDark ? AppColors.accentPurple : Colors.deepPurple.shade300,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(isDark ? AppColors.accentBlue : AppColors.lightPrimary, 'Grooming'),
            const SizedBox(width: 16),
            _legendDot(isDark ? AppColors.accentPurple : Colors.deepPurple.shade300, 'Hotel'),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INCOME BREAKDOWN
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildIncomeBreakdown(BuildContext context) {
    if (vm.totalRevenue <= 0) {
      return _emptyState(l10n.noSessionsYet);
    }

    final groomingColor = isDark ? AppColors.accentBlue : AppColors.lightPrimary;
    final hotelColor = isDark ? AppColors.accentPurple : Colors.deepPurple.shade400;

    return Row(
      children: [
        DonutChart(
          segments: [
            DonutSegment(label: 'Grooming', value: vm.totalGroomingRevenue, color: groomingColor),
            DonutSegment(label: 'Hotel', value: vm.totalHotelRevenue, color: hotelColor),
          ],
          size: 130,
          centerValue: app_date.formatCurrencyDouble(vm.totalRevenue),
          centerLabel: l10n.totalLabel,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _breakdownRow(
                groomingColor,
                'Grooming',
                app_date.formatCurrencyDouble(vm.totalGroomingRevenue),
                '${vm.groomingPercentage.toStringAsFixed(0)}%',
              ),
              const SizedBox(height: 12),
              _breakdownRow(
                hotelColor,
                'Hotel',
                app_date.formatCurrencyDouble(vm.totalHotelRevenue),
                '${vm.hotelPercentage.toStringAsFixed(0)}%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _breakdownRow(Color color, String label, String value, String pct) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Text(pct, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUSIEST DAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBusiestDays(BuildContext context) {
    final days = vm.busiestDays;
    final dayLabels = [
      l10n.shortMonday, l10n.shortTuesday, l10n.shortWednesday,
      l10n.shortThursday, l10n.shortFriday, l10n.shortSaturday,
      l10n.shortSunday,
    ];

    final data = List.generate(7, (i) {
      return BarData(
        label: dayLabels[i],
        value: (days[i + 1] ?? 0).toDouble(),
      );
    });

    return SimpleBarChart(
      data: data,
      height: 160,
      barColor: isDark ? AppColors.accentGreen : const Color(0xFF26A69A),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POPULAR SERVICES / COMMON FINDINGS (HORIZONTAL BAR LIST)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHorizontalBarList(
    BuildContext context, {
    required List<PopularItem> items,
    required Color color,
  }) {
    if (items.isEmpty) return _emptyState('-');

    final maxCount = items.first.count;

    return Column(
      children: items.map((item) {
        final fraction = maxCount > 0 ? item.count / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  '${item.count}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP CUSTOMERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTopCustomers(BuildContext context) {
    return Column(
      children: vm.topCustomers.asMap().entries.map((entry) {
        final i = entry.key;
        final customer = entry.value;
        final medal = i < 3 ? ['🥇', '🥈', '🥉'][i] : '#${i + 1}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  medal,
                  style: TextStyle(
                    fontSize: i < 3 ? 18 : 13,
                    fontWeight: FontWeight.bold,
                    color: i < 3 ? null : (isDark ? Colors.white54 : Colors.black45),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              CatAvatar(imagePath: customer.imagePath, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.catName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      customer.ownerName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${customer.sessionCount}x',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark,
                    ),
                  ),
                  Text(
                    app_date.formatCurrencyDouble(customer.totalRevenue),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.accentGreen : const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? BorderSide(color: Colors.white.withOpacity(0.05))
            : BorderSide.none,
      ),
      color: isDark ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black26,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Summary Card Widget ─────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isDark
            ? BorderSide(color: color.withOpacity(0.2))
            : BorderSide.none,
      ),
      color: isDark ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Period Option ───────────────────────────────────────────────────────────

class _PeriodOption {
  final int months;
  final String label;
  const _PeriodOption(this.months, this.label);
}
