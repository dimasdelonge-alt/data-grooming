import 'package:flutter/foundation.dart';
import 'dart:async';
import '../data/repository/grooming_repository.dart';
import '../data/entity/session.dart';
import '../data/entity/cat.dart';
import '../data/entity/hotel_entities.dart';

/// ViewModel for the Analytics & Insights dashboard.
///
/// Computes all metrics from existing data: sessions, cats, hotel bookings.
/// No new database tables needed.
class AnalyticsViewModel extends ChangeNotifier {
  final GroomingRepository _repository;

  AnalyticsViewModel(this._repository);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<Session> _allSessions = [];
  List<Cat> _allCats = [];
  List<HotelBooking> _hotelBookings = [];
  bool _isLoading = true;

  /// Period filter: 1 = this month, 3 = 3 months, 6 = 6 months, 12 = 1 year, 0 = all
  int _periodMonths = 6;

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isLoading => _isLoading;
  int get periodMonths => _periodMonths;

  /// Sessions filtered by current period
  List<Session> get _filteredSessions {
    if (_periodMonths == 0) {
      return _allSessions.where((s) => s.status == 'DONE').toList();
    }
    final cutoff = DateTime.now()
        .subtract(Duration(days: _periodMonths * 30))
        .millisecondsSinceEpoch;
    return _allSessions
        .where((s) => s.status == 'DONE' && s.timestamp >= cutoff)
        .toList();
  }

  /// Hotel bookings filtered by current period
  List<HotelBooking> get _filteredHotelBookings {
    if (_periodMonths == 0) {
      return _hotelBookings
          .where((b) => b.status == BookingStatus.completed)
          .toList();
    }
    final cutoff = DateTime.now()
        .subtract(Duration(days: _periodMonths * 30))
        .millisecondsSinceEpoch;
    return _hotelBookings
        .where((b) =>
            b.status == BookingStatus.completed && b.checkOutDate >= cutoff)
        .toList();
  }

  // ─── Summary Stats ─────────────────────────────────────────────────────────

  int get totalSessions => _filteredSessions.length;

  double get totalGroomingRevenue =>
      _filteredSessions.fold(0.0, (sum, s) => sum + s.totalCost);

  double get totalHotelRevenue =>
      _filteredHotelBookings.fold(0.0, (sum, b) => sum + b.totalCost);

  double get totalRevenue => totalGroomingRevenue + totalHotelRevenue;

  double get avgRevenuePerSession =>
      totalSessions > 0 ? totalGroomingRevenue / totalSessions : 0;

  /// Percentage of cats with more than 1 session (returning customers)
  double get customerRetentionRate {
    final catSessionCounts = <int, int>{};
    for (final s in _filteredSessions) {
      catSessionCounts[s.catId] = (catSessionCounts[s.catId] ?? 0) + 1;
    }
    final returning = catSessionCounts.values.where((c) => c > 1).length;
    final total = catSessionCounts.length;
    if (total == 0) return 0;
    return (returning / total) * 100;
  }

  // ─── Top Customers ─────────────────────────────────────────────────────────

  /// Top 10 cats by session count
  List<TopCustomer> get topCustomers {
    final catSessionCounts = <int, int>{};
    final catRevenue = <int, double>{};
    for (final s in _filteredSessions) {
      catSessionCounts[s.catId] = (catSessionCounts[s.catId] ?? 0) + 1;
      catRevenue[s.catId] = (catRevenue[s.catId] ?? 0) + s.totalCost;
    }

    final catMap = {for (final c in _allCats) c.catId: c};

    final result = catSessionCounts.entries.map((e) {
      final cat = catMap[e.key];
      return TopCustomer(
        catName: cat?.catName ?? 'Unknown',
        ownerName: cat?.ownerName ?? '',
        sessionCount: e.value,
        totalRevenue: catRevenue[e.key] ?? 0,
        imagePath: cat?.imagePath,
      );
    }).toList()
      ..sort((a, b) => b.sessionCount.compareTo(a.sessionCount));

    return result.take(10).toList();
  }

  // ─── Busiest Days ──────────────────────────────────────────────────────────

  /// Sessions count per weekday (1=Monday … 7=Sunday)
  Map<int, int> get busiestDays {
    final map = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
    for (final s in _filteredSessions) {
      final weekday =
          DateTime.fromMillisecondsSinceEpoch(s.timestamp).weekday;
      map[weekday] = (map[weekday] ?? 0) + 1;
    }
    return map;
  }

  // ─── Popular Services ──────────────────────────────────────────────────────

  /// Services usage count from session.treatment
  List<PopularItem> get popularServices {
    final counts = <String, int>{};
    for (final s in _filteredSessions) {
      for (final t in s.treatment) {
        if (t.isNotEmpty) {
          counts[t] = (counts[t] ?? 0) + 1;
        }
      }
    }
    final result = counts.entries
        .map((e) => PopularItem(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return result.take(10).toList();
  }

  // ─── Common Findings ───────────────────────────────────────────────────────

  /// Findings occurrence count from session.findings
  List<PopularItem> get commonFindings {
    final counts = <String, int>{};
    for (final s in _filteredSessions) {
      for (final f in s.findings) {
        if (f.isNotEmpty) {
          counts[f] = (counts[f] ?? 0) + 1;
        }
      }
    }
    final result = counts.entries
        .map((e) => PopularItem(name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return result.take(10).toList();
  }

  // ─── Monthly Revenue Trend ─────────────────────────────────────────────────

  /// Revenue per month for the last N months
  List<MonthlyRevenue> get monthlyRevenueTrend {
    final now = DateTime.now();
    final months = _periodMonths == 0 ? 12 : _periodMonths;
    final result = <MonthlyRevenue>[];

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final start = month.millisecondsSinceEpoch;
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59)
          .millisecondsSinceEpoch;

      final grooming = _allSessions
          .where((s) =>
              s.status == 'DONE' &&
              s.timestamp >= start &&
              s.timestamp <= end)
          .fold(0.0, (sum, s) => sum + s.totalCost);

      final hotel = _hotelBookings
          .where((b) =>
              b.status == BookingStatus.completed &&
              b.checkOutDate >= start &&
              b.checkOutDate <= end)
          .fold(0.0, (sum, b) => sum + b.totalCost);

      result.add(MonthlyRevenue(
        month: month,
        grooming: grooming,
        hotel: hotel,
      ));
    }
    return result;
  }

  // ─── Income Breakdown ──────────────────────────────────────────────────────

  double get groomingPercentage {
    if (totalRevenue <= 0) return 0;
    return (totalGroomingRevenue / totalRevenue) * 100;
  }

  double get hotelPercentage {
    if (totalRevenue <= 0) return 0;
    return (totalHotelRevenue / totalRevenue) * 100;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void setPeriod(int months) {
    _periodMonths = months;
    notifyListeners();
  }

  /// Load all data needed for analytics.
  /// Called when entering the screen.
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSessions = await _repository.getAllSessions().first;
      _allCats = await _repository.getAllCats().first;

      // Load all completed hotel bookings (wide range to get all)
      _hotelBookings = await _repository
          .getCompletedHotelBookings(
              0, DateTime.now().millisecondsSinceEpoch + 86400000)
          .first;
    } catch (e) {
      debugPrint('AnalyticsViewModel.loadData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class TopCustomer {
  final String catName;
  final String ownerName;
  final int sessionCount;
  final double totalRevenue;
  final String? imagePath;

  const TopCustomer({
    required this.catName,
    required this.ownerName,
    required this.sessionCount,
    required this.totalRevenue,
    this.imagePath,
  });
}

class PopularItem {
  final String name;
  final int count;

  const PopularItem({required this.name, required this.count});
}

class MonthlyRevenue {
  final DateTime month;
  final double grooming;
  final double hotel;

  double get total => grooming + hotel;

  const MonthlyRevenue({
    required this.month,
    required this.grooming,
    required this.hotel,
  });
}
