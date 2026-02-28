import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../../data/entity/booking.dart';
import '../../data/entity/cat.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/reminder_utils.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

/// Upcoming booking list with add/edit/delete/check-in actions.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upcoming = vm.upcomingBookings;
    final cats = vm.allCats;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingGrooming)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookingDialog(context, vm, cats, l10n),
        child: const Icon(Icons.add_rounded),
      ),
      body: upcoming.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black12),
                  const SizedBox(height: 12),
                  Text(l10n.noBookingSchedule, style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                final booking = upcoming[index];
                final cat = cats.where((c) => c.catId == booking.catId).firstOrNull;
                return BookingCard(
                  booking: booking,
                  catName: cat?.catName ?? l10n.unknown,
                  ownerName: cat?.ownerName ?? l10n.unknown,
                  isDark: isDark,
                  l10n: l10n,
                  onCheckIn: () {
                    vm.updateBookingStatus(booking, 'COMPLETED');
                    Navigator.pushNamed(context, '/session_entry', arguments: {'catId': booking.catId});
                  },
                  onWhatsApp: (cat != null && cat.ownerPhone.isNotEmpty)
                      ? () => sendWhatsAppReminder(cat, booking)
                      : null,
                  onConfirm: () => vm.updateBookingStatus(booking, 'CONFIRMED'),
                  onCancel: () => vm.updateBookingStatus(booking, 'CANCELLED'),
                  onReschedule: () => _showRescheduleDialog(context, vm, booking, l10n),
                  onDelete: () => _showDeleteDialog(context, vm, booking, l10n),
                );
              },
            ),
    );
  }

  // ─── Add Booking Dialog ────────────────────────────────
  void _showBookingDialog(BuildContext context, GroomingViewModel vm, List<Cat> cats, AppLocalizations l10n) {
    Cat? selectedCat;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    final serviceController = TextEditingController(text: 'Mandi Sehat');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDlgState) {
          return AlertDialog(
            title: Text(l10n.addBooking),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cat search (Autocomplete)
                  Row(
                    children: [
                      Expanded(
                        child: Autocomplete<Cat>(
                          displayStringForOption: (c) => c.catName,
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Cat>.empty();
                            }
                            return cats.where((c) =>
                                c.catName.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                c.ownerName.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (cat) => setDlgState(() => selectedCat = cat),
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: l10n.searchCatOrOwner,
                                prefixIcon: const Icon(Icons.search_rounded),
                              ),
                              onFieldSubmitted: (value) => onFieldSubmitted(),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 280),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder: (c, i) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final cat = options.elementAt(index);
                                      return ListTile(
                                        title: Text(cat.catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('${l10n.owner}: ${cat.ownerName}'),
                                        onTap: () => onSelected(cat),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(ctx); 
                          Navigator.pushNamed(context, '/cat_entry');
                        },
                        icon: const Icon(Icons.add_rounded),
                        tooltip: l10n.addNewCat,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date + Time row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setDlgState(() => selectedDate = picked);
                          },
                          icon: const Icon(Icons.date_range_rounded, size: 16),
                          label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(context: ctx, initialTime: selectedTime);
                          if (picked != null) setDlgState(() => selectedTime = picked);
                        },
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: serviceController, decoration: InputDecoration(labelText: l10n.serviceType)),
                  const SizedBox(height: 12),
                  TextField(controller: notesController, decoration: InputDecoration(labelText: l10n.notes), maxLines: 2),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
              FilledButton(
                onPressed: selectedCat == null
                    ? null
                    : () {
                        final dateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                        vm.addBooking(Booking(
                          catId: selectedCat!.catId,
                          serviceType: serviceController.text,
                          bookingDate: dateTime.millisecondsSinceEpoch,
                          durationMinutes: 60,
                          status: 'SCHEDULED',
                          notes: notesController.text,
                        ));
                        Navigator.pop(ctx);
                      },
                child: Text(l10n.save),
              ),
            ],
          );
        });
      },
    );
  }

  // ─── Reschedule Dialog ─────────────────────────────────
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

  // ─── Delete Dialog ─────────────────────────────────────
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
// BOOKING CARD
// ═══════════════════════════════════════════════════════════════════════════════

class BookingCard extends StatelessWidget {
  final Booking booking;
  final String catName;
  final String ownerName;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onCheckIn;
  final VoidCallback? onWhatsApp;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  const BookingCard({
    super.key,
    required this.booking,
    required this.catName,
    required this.ownerName,
    required this.isDark,
    required this.l10n,
    required this.onCheckIn,
    this.onWhatsApp,
    required this.onConfirm,
    required this.onCancel,
    required this.onReschedule,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (booking.status) {
      case 'COMPLETED': return Colors.green;
      case 'CONFIRMED': return const Color(0xFF64B5F6);
      case 'CANCELLED': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _localizeStatus(String status) {
    switch (status) {
      case 'SCHEDULED': return l10n.statusScheduled;
      case 'COMPLETED': return l10n.statusCompleted;
      case 'CONFIRMED': return l10n.statusConfirmed;
      case 'CANCELLED': return l10n.statusCancelled;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(catName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(l10n.ownerLabel(ownerName), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_localizeStatus(booking.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor())),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        switch (action) {
                          case 'confirm': onConfirm(); break;
                          case 'cancel': onCancel(); break;
                          case 'reschedule': onReschedule(); break;
                          case 'delete': onDelete(); break;
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'confirm', child: ListTile(leading: const Icon(Icons.check, color: Colors.blue), title: Text(l10n.confirm), dense: true, contentPadding: EdgeInsets.zero)),
                        PopupMenuItem(value: 'cancel', child: ListTile(leading: const Icon(Icons.close, color: Colors.red), title: Text(l10n.cancelBooking), dense: true, contentPadding: EdgeInsets.zero)),
                        PopupMenuItem(value: 'reschedule', child: ListTile(leading: const Icon(Icons.date_range), title: Text(l10n.reschedule), dense: true, contentPadding: EdgeInsets.zero)),
                        PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: Text(l10n.delete, style: const TextStyle(color: Colors.red)), dense: true, contentPadding: EdgeInsets.zero)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${l10n.dateLabel}: ${app_date.formatDateTime(booking.bookingDate)}'),
            Text('${l10n.serviceLabel}: ${booking.serviceType}'),
            if (booking.notes.isNotEmpty) Text('${l10n.notes}: ${booking.notes}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onWhatsApp != null)
                  IconButton(
                    onPressed: onWhatsApp,
                    icon: const Icon(Icons.phone, color: Colors.green),
                    tooltip: l10n.whatsappReminder,
                  ),
                if (booking.status != 'COMPLETED' && booking.status != 'CANCELLED')
                  FilledButton.icon(
                    onPressed: onCheckIn,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(l10n.checkIn),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
