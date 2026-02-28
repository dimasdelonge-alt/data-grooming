import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../../data/entity/booking.dart';
import '../../util/reminder_utils.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';
import 'booking_screen.dart';

/// Monthly calendar view with booking dots and day-detail section.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDate = now;
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookings = vm.bookings;
    final cats = vm.allCats;

    // Group bookings by date (date part only)
    final grouped = <String, List<Booking>>{};
    for (final b in bookings) {
      final d = DateTime.fromMillisecondsSinceEpoch(b.bookingDate);
      final key = '${d.year}-${d.month}-${d.day}';
      grouped.putIfAbsent(key, () => []).add(b);
    }

    // Bookings for selected date
    final selKey = '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
    final dayBookings = grouped[selKey] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groomingSchedule)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Month Header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left_rounded)),
                  Text(
                    '${_monthName(_currentMonth.month, l10n)} ${_currentMonth.year}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right_rounded)),
                ],
              ),
            ),

            // ─── Day Headers ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [l10n.shortMonday, l10n.shortTuesday, l10n.shortWednesday, l10n.shortThursday, l10n.shortFriday, l10n.shortSaturday, l10n.shortSunday]
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark)),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 4),

            // ─── Calendar Grid ─────────────────────────────
            _CalendarGrid(
              currentMonth: _currentMonth,
              selectedDate: _selectedDate,
              groupedBookings: grouped,
              isDark: isDark,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),

            const Divider(),

            // ─── Day Detail ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bookingOn('${_selectedDate.day} ${_monthName(_selectedDate.month, l10n)} ${_selectedDate.year}'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (dayBookings.isEmpty)
                    Text(l10n.noSchedule, style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext))
                  else
                    ...dayBookings.map((b) {
                      final cat = cats.where((c) => c.catId == b.catId).firstOrNull;
                      return BookingCard(
                        booking: b,
                        catName: cat?.catName ?? l10n.unknown,
                        ownerName: cat?.ownerName ?? l10n.unknown,
                        isDark: isDark,
                        l10n: l10n,
                        onCheckIn: () {
                          vm.updateBookingStatus(b, 'COMPLETED');
                          Navigator.pushNamed(context, '/session_entry', arguments: {'catId': b.catId});
                        },
                        onWhatsApp: (cat != null && cat.ownerPhone.isNotEmpty)
                            ? () => sendWhatsAppReminder(cat, b)
                            : null,
                        onConfirm: () => vm.updateBookingStatus(b, 'CONFIRMED'),
                        onCancel: () => vm.updateBookingStatus(b, 'CANCELLED'),
                        onReschedule: () => _showRescheduleDialog(context, vm, b, l10n),
                        onDelete: () => _showDeleteDialog(context, vm, b, l10n),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1: return l10n.monthJan;
      case 2: return l10n.monthFeb;
      case 3: return l10n.monthMar;
      case 4: return l10n.monthApr;
      case 5: return l10n.monthMay;
      case 6: return l10n.monthJun;
      case 7: return l10n.monthJul;
      case 8: return l10n.monthAug;
      case 9: return l10n.monthSep;
      case 10: return l10n.monthOct;
      case 11: return l10n.monthNov;
      case 12: return l10n.monthDec;
      default: return '';
    }
  }

  void _showRescheduleDialog(BuildContext _, GroomingViewModel vm, Booking booking, AppLocalizations l10n) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(booking.bookingDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(booking.bookingDate)),
    );
    if (time == null || !mounted) return;

    final newDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
    vm.rescheduleBooking(booking, newDate.millisecondsSinceEpoch);
  }

  void _showDeleteDialog(BuildContext context, GroomingViewModel vm, Booking booking, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSchedule),
        content: Text(l10n.deleteScheduleConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              vm.deleteBooking(booking);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CALENDAR GRID
// ═══════════════════════════════════════════════════════════════════════════════

class _CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<String, List<Booking>> groupedBookings;
  final bool isDark;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarGrid({
    required this.currentMonth,
    required this.selectedDate,
    required this.groupedBookings,
    required this.isDark,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    // Monday=1 … Sunday=7. We want Monday=0
    final firstDayOfWeek = (DateTime(currentMonth.year, currentMonth.month, 1).weekday - 1) % 7;
    final totalCells = daysInMonth + firstDayOfWeek;
    final rows = (totalCells + 6) ~/ 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final dayNum = row * 7 + col - firstDayOfWeek + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }
              final date = DateTime(currentMonth.year, currentMonth.month, dayNum);
              final key = '${date.year}-${date.month}-${date.day}';
              final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
              final bookings = groupedBookings[key] ?? [];

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                        if (bookings.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: bookings.take(3).map((b) {
                              final dotColor = b.status == 'COMPLETED' ? Colors.green : Colors.orange;
                              return Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
