import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../util/currency_formatter.dart';
import '../hotel_view_model.dart';
import '../grooming_view_model.dart';
import '../financial_view_model.dart';
import '../../data/entity/hotel_entities.dart';
import '../../data/entity/cat.dart';
import '../../data/entity/deposit_entities.dart';
import '../../data/model/hotel_models.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/pdf_generator.dart';
import '../common/cat_avatar.dart';
import 'package:intl/intl.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotelVm = context.watch<HotelViewModel>();
    final groomingVm = context.watch<GroomingViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Kucing'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status Kamar'),
            Tab(text: 'Biaya'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoomDialog(context, hotelVm),
        child: const Icon(Icons.add_rounded),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoomStatusTab(context, hotelVm, groomingVm),
          _buildBillingTab(context, hotelVm),
          _buildHistoryTab(context, hotelVm),
        ],
      ),
    );
  }

  Widget _buildRoomStatusTab(BuildContext context, HotelViewModel hotelVm, GroomingViewModel groomingVm) {
    if (hotelVm.rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bedroom_child_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Belum ada kamar.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    // Starter plan: only first 2 rooms allowed
    final isStarter = groomingVm.userPlan == 'starter';
    final allowedRoomIds = hotelVm.rooms
        .toList()
        .map((r) => r.id)
        .toList()
      ..sort();
    final allowedSet = allowedRoomIds.take(2).toSet();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: hotelVm.rooms.length,
      itemBuilder: (context, index) {
        final room = hotelVm.rooms[index];
        final isLocked = isStarter && !allowedSet.contains(room.id);
        final activeBooking = hotelVm.activeBookings
            .where((b) => b.roomId == room.id)
            .firstOrNull;
            
        Cat? cat;
        if (activeBooking != null) {
          cat = groomingVm.allCats.where((c) => c.catId == activeBooking.catId).firstOrNull;
        }

        // Overdue detection
        bool isOverdue = false;
        if (activeBooking != null && activeBooking.checkOutDate > 0) {
          isOverdue = DateTime.fromMillisecondsSinceEpoch(activeBooking.checkOutDate).isBefore(DateTime.now());
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return _RoomCard(
          room: room,
          booking: activeBooking,
          cat: cat,
          isDark: isDark,
          isLocked: isLocked,
          isOverdue: isOverdue,
          onTap: () {
            if (isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kamar ini terkunci (Limit Starter 2). Silakan upgrade ke PRO!')),
              );
              return;
            }
            if (activeBooking != null) {
              _showEditBookingDatesDialog(context, hotelVm, activeBooking, cat);
            } else {
              Navigator.pushNamed(context, '/room_detail', arguments: room.id);
            }
          },
          onLongPress: () => _showRoomDialog(context, hotelVm, room: room),
        );
      },
    );
  }

  void _showEditBookingDatesDialog(BuildContext context, HotelViewModel vm, HotelBooking booking, Cat? cat) {
    if (cat == null) return;
    final checkIn = DateTime.fromMillisecondsSinceEpoch(booking.checkInDate);
    final checkOut = DateTime.fromMillisecondsSinceEpoch(booking.checkOutDate > 0 ? booking.checkOutDate : DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch);

    DateTime newCheckIn = checkIn;
    DateTime newCheckOut = checkOut;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Booking: ${cat.catName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Tanggal Masuk'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(newCheckIn)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: newCheckIn,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => newCheckIn = picked);
                      // Auto adjust checkout if it becomes before checkin
                      if (probs(newCheckOut, newCheckIn)) {
                         setState(() => newCheckOut = newCheckIn.add(const Duration(days: 1)));
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('Tanggal Keluar'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(newCheckOut)),
                  trailing: const Icon(Icons.event_busy),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: newCheckOut,
                      firstDate: newCheckIn.add(const Duration(days: 1)),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => newCheckOut = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Hapus Booking', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    onPressed: () {
                      // Confirm delete
                      showDialog(
                        context: context,
                        builder: (confirmCtx) => AlertDialog(
                          title: const Text('Hapus Booking?'),
                          content: const Text('Tindakan ini tidak dapat dibatalkan.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(confirmCtx), child: const Text('Batal')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                vm.deleteBooking(booking);
                                Navigator.pop(confirmCtx); // Close confirm
                                Navigator.pop(ctx); // Close edit dialog
                              },
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _tabController.animateTo(1); // Switch to Billing tab
                },
                child: const Text('Lihat Tagihan'),
              ),
              FilledButton(
                onPressed: () {
                  vm.updateBookingDates(
                    booking, 
                    newCheckIn.millisecondsSinceEpoch, 
                    newCheckOut.millisecondsSinceEpoch,
                    (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        }
      ),
    );
  }
  
  bool probs(DateTime a, DateTime b) {
      return a.isBefore(b) || a.isAtSameMomentAs(b);
  }

  Widget _buildBillingTab(BuildContext context, HotelViewModel vm) {
    if (vm.activeBookings.isEmpty) {
      return const Center(child: Text('Tidak ada tagihan aktif.'));
    }
    
    final groups = vm.billingGroups;
    if (groups.isEmpty) {
       return const Center(child: Text('Tidak ada tagihan.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _BillingGroupCard(group: groups[index], vm: vm);
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, HotelViewModel vm) {
    final groups = vm.historyGroups; // Sorted flat list
    if (groups.isEmpty) {
      return const Center(child: Text('Belum ada riwayat.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final firstBookingDate = group.bookings.isNotEmpty 
             ? DateTime.fromMillisecondsSinceEpoch(group.bookings.first.checkInDate) 
             : DateTime.now();
        final dateStr = DateFormat('dd MMM yyyy').format(firstBookingDate);
        final catCount = group.cats.length;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(group.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$dateStr - $catCount Kucing'),
            children: [
               Padding(
                 padding: const EdgeInsets.all(16),
                 child: _BillingGroupCard(
                   group: group, vm: vm, isHistory: true, hideHeader: true,
                   onBookingTap: (booking, cat) {
                     _showEditBookingDatesDialog(context, vm, booking, cat);
                   },
                 ),
               ),
            ],
          ),
        );
      },
    );
  }

  void _showRoomDialog(BuildContext context, HotelViewModel vm, {HotelRoom? room}) {
    final nameController = TextEditingController(text: room?.name ?? '');
    final priceText = room != null ? NumberFormat.decimalPattern('id').format(room.pricePerNight) : '';
    final priceController = TextEditingController(text: priceText);
    final capController = TextEditingController(text: room?.capacity.toString() ?? '1');
    final notesController = TextEditingController(text: room?.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(room == null ? 'Tambah Kamar' : 'Edit Kamar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Kamar')),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga per Malam', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capController,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Catatan')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final rawPrice = priceController.text.replaceAll('.', '');
              final price = double.tryParse(rawPrice) ?? 0;
              final cap = int.tryParse(capController.text) ?? 1;
              if (name.isNotEmpty) {
                if (room == null) {
                  vm.addRoom(name, price, cap, notesController.text);
                } else {
                  vm.updateRoom(room.copyWith(
                    name: name,
                    pricePerNight: price,
                    capacity: cap,
                    notes: notesController.text,
                  ));
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}


class _RoomCard extends StatelessWidget {
  final HotelRoom room;
  final HotelBooking? booking;
  final Cat? cat;
  final bool isDark;
  final bool isLocked;
  final bool isOverdue;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _RoomCard({
    required this.room,
    this.booking,
    this.cat,
    required this.isDark,
    this.isLocked = false,
    this.isOverdue = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = booking != null;

    // Color logic: overdue = orange/red bold, occupied = red, available = green
    Color color;
    Color bgColor;
    String statusText;
    if (isOverdue) {
      color = Colors.deepOrange;
      bgColor = isDark ? Colors.deepOrange.withOpacity(0.2) : Colors.deepOrange.withOpacity(0.1);
      statusText = 'OVERDUE!';
    } else if (isOccupied) {
      color = Colors.redAccent;
      bgColor = isDark ? Colors.red.withOpacity(0.15) : Colors.red.withOpacity(0.1);
      statusText = cat?.catName ?? 'Terisi';
    } else {
      color = Colors.green;
      bgColor = isDark ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1);
      statusText = 'Kosong';
    }

    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Card(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: isLocked ? null : onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon / Avatar / Lock
                if (isLocked)
                  Icon(Icons.lock_rounded, size: 32, color: Colors.grey)
                else if (isOccupied && cat != null)
                  CatAvatar(imagePath: cat!.imagePath, size: 40)
                else if (isOccupied)
                  Icon(Icons.pets_rounded, size: 32, color: color)
                else
                  Icon(Icons.meeting_room_rounded, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  room.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isLocked ? 'Terkunci' : statusText,
                  style: TextStyle(
                    color: isOverdue ? Colors.deepOrange : color,
                    fontWeight: isOverdue ? FontWeight.w900 : FontWeight.bold,
                    fontSize: isOverdue ? 13 : 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isOccupied && cat != null && !isLocked) ...[
                  const SizedBox(height: 2),
                  Text(
                    cat!.ownerName,
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black45),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  app_date.formatCurrencyDouble(room.pricePerNight),
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BillingGroupCard extends StatelessWidget {
  final BillingGroup group;
  final HotelViewModel vm;
  final bool isHistory;
  final bool hideHeader;
  final void Function(HotelBooking booking, Cat? cat)? onBookingTap;

  const _BillingGroupCard({required this.group, required this.vm, this.isHistory = false, this.hideHeader = false, this.onBookingTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = group.remaining; // Calculated in VM (Total - DP)
    final isPaid = remaining <= 0;

    return Card(
      elevation: isHistory ? 0 : 2, // Flat if invalid history expansion
      color: isHistory ? Colors.transparent : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Owner & Summary
            if (!hideHeader) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${group.bookings.length} Kamar/Kucing', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        app_date.formatCurrencyDouble(remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: isPaid ? Colors.green : Colors.redAccent,
                        ),
                      ),
                      Text(isPaid ? 'Lunas / Lebih Bayar' : 'Sisa Tagihan', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
            
            // Details List
            ...List.generate(group.bookings.length, (index) {
              final booking = group.bookings[index];
              final room = group.rooms[index];
              final cat = group.cats[index];
              
              // Calculate days for display (Real-time or historic)
              final checkIn = DateTime.fromMillisecondsSinceEpoch(booking.checkInDate);
              final checkOut = DateTime.fromMillisecondsSinceEpoch(booking.checkOutDate > 0 ? booking.checkOutDate : DateTime.now().millisecondsSinceEpoch);
              // Logic matches VM: diffInDays + 1 if active? 
              // VM used: (now - checkIn).inDays. 
              // If booking.totalCost is from VM, we trust it.
              
              final bookingWidget = Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${cat.catName} (${room.name})', style: const TextStyle(fontWeight: FontWeight.bold))),
                        Text(app_date.formatCurrencyDouble(booking.totalCost)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                           '${DateFormat('dd MMM').format(checkIn)} - ${isHistory ? DateFormat('dd MMM').format(checkOut) : 'Sekarang'}',
                           style: const TextStyle(fontSize: 11, color: Colors.grey),
                         ),
                         if (!isHistory)
                            Text('Running...', style: const TextStyle(fontSize: 10, color: Colors.green, fontStyle: FontStyle.italic)),
                         if (isHistory && onBookingTap != null)
                            Icon(Icons.edit_outlined, size: 14, color: Colors.grey[400]),
                      ],
                    ),
                  ],
                ),
              );

              if (isHistory && onBookingTap != null) {
                return InkWell(
                  onTap: () => onBookingTap!(booking, cat),
                  borderRadius: BorderRadius.circular(8),
                  child: bookingWidget,
                );
              }
              return bookingWidget;
            }),
            
            const SizedBox(height: 12),
            
            // Add-Ons Section ------------------------------------------------
            if (group.addOns.isNotEmpty) ...[
               const Text('Biaya Tambahan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent, fontSize: 12)),
               const SizedBox(height: 4),
               ...group.addOns.map((addon) => Padding(
                 padding: const EdgeInsets.only(bottom: 4),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('${addon.itemName} ${addon.qty > 1 ? "x${addon.qty}" : ""}', style: const TextStyle(fontSize: 12)),
                     Text(app_date.formatCurrencyDouble(addon.price * addon.qty), style: const TextStyle(fontSize: 12)),
                   ],
                 ),
               )),
               const SizedBox(height: 8),
            ],

            // Add Add-On Button (Active Only)
            if (!isHistory) 
               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 8),
                 child: SizedBox(
                   height: 36,
                   child: OutlinedButton(
                     onPressed: () => _manageAddOns(context, vm, group),
                     style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                     ),
                     child: const Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('Kelola Add-on'),
                         Icon(Icons.add, size: 16),
                       ],
                     ),
                   ),
                 ),
               ),
            
            // ----------------------------------------------------------------

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Down Payment (DP):'),
                InkWell(
              onTap: () => _showEditDpDialog(context, vm, group),
                  child: Row(
                    children: [
                      Text(app_date.formatCurrencyDouble(group.totalDp)),
                      if (!isHistory) const SizedBox(width: 4),
                      if (!isHistory) const Icon(Icons.edit, size: 14, color: Colors.grey),
                      if (isHistory) const SizedBox(width: 4),
                      if (isHistory) const Icon(Icons.edit, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
            
            if (!isHistory) ...[
               const SizedBox(height: 4),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text('Total Biaya (Est):', style: TextStyle(fontWeight: FontWeight.bold)),
                   Text(app_date.formatCurrencyDouble(group.totalCost), style: const TextStyle(fontWeight: FontWeight.bold)),
                 ],
               ),
            ],

            if (!isHistory) ...[
               const SizedBox(height: 16),
               Row(
                 children: [
                   Expanded(
                     child: OutlinedButton.icon(
                       icon: const Icon(Icons.print, size: 16),
                       label: const Text('Invoice DP', style: TextStyle(fontSize: 12)),
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 12),
                       ),
                       onPressed: () {
                          final groomingVm = context.read<GroomingViewModel>();
                           PdfGenerator.printHotelDpInvoice(
                             group: group,
                             businessName: groomingVm.businessName,
                             businessPhone: groomingVm.businessPhone,
                             businessAddress: groomingVm.businessAddress,
                             logoPath: groomingVm.logoPath,
                             userPlan: groomingVm.userPlan,
                           );
                       },
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     flex: 2,
                     child: FilledButton.icon(
                       icon: const Icon(Icons.check_circle_outline),
                       onPressed: () => _showCheckoutGroupDialog(context, vm, group),
                       label: const Text('Check Out'),
                       style: FilledButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 12),
                       ),
                     ),
                   ),
                 ],
               ),
            ] else ...[
               const SizedBox(height: 16),
               SizedBox(
                 width: double.infinity,
                 child: OutlinedButton.icon(
                   icon: const Icon(Icons.print),
                   label: const Text('Cetak Invoice'),
                   onPressed: () {
                     final groomingVm = context.read<GroomingViewModel>();
                      PdfGenerator.printHotelInvoice(
                        group: group,
                        businessName: groomingVm.businessName,
                        businessPhone: groomingVm.businessPhone,
                        businessAddress: groomingVm.businessAddress,
                        logoPath: groomingVm.logoPath,
                        userPlan: groomingVm.userPlan,
                      );
                   },
                 ),
               ),
            ],
          ],
        ),
      ),
    );
  }

  void _manageAddOns(BuildContext context, HotelViewModel vm, BillingGroup group) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Kelola Add-on', style: TextStyle(fontWeight: FontWeight.bold))),
              
              // Add Item Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AddOnForm(vm: vm, bookings: group.bookings, groupCats: group.cats),
              ),
              const Divider(),
              // List Existing
              if (group.addOns.isEmpty) 
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Belum ada item tambahan.'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: group.addOns.length,
                    itemBuilder: (context, index) {
                      final addon = group.addOns[index];
                      // Find which cat/booking this belongs to
                      final bookingIndex = group.bookings.indexWhere((b) => b.id == addon.bookingId);
                      final catName = bookingIndex != -1 ? group.cats[bookingIndex].catName : 'Unknown';
                      
                      return ListTile(
                        dense: true,
                        title: Text('${addon.itemName} (x${addon.qty})'),
                        subtitle: Text('$catName - ${app_date.formatCurrencyDouble(addon.price * addon.qty)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                             vm.deleteAddOn(addon);
                             Navigator.pop(ctx); // Close to refresh (since sheet doesn't listen) or keep open?
                             // Since BillingGroup is rebuilt in parent, we might need to close or use stateful.
                             // Simple: Close and let user reopen if needed, or better:
                             // The bottom sheet won't rebuild automatically unless it watches VM.
                             // For now, close it.
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
  }

  void _showEditDpDialog(BuildContext context, HotelViewModel vm, BillingGroup group) {
     final initialText = group.totalDp > 0 ? NumberFormat.decimalPattern('id').format(group.totalDp) : '';
     final controller = TextEditingController(text: initialText);
     
     // Check if this group's bookings are history (completed) or active
     final isHistoryGroup = group.bookings.isNotEmpty && 
         group.bookings.first.status == BookingStatus.completed;
     
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: const Text('Update Total DP'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Text('DP ini akan dibagi rata ke semua booking dalam grup ini.'),
             const SizedBox(height: 12),
             TextField(
               controller: controller,
               keyboardType: TextInputType.number,
               inputFormatters: [CurrencyInputFormatter()],
               decoration: const InputDecoration(labelText: 'Total DP', prefixText: 'Rp '),
             ),
           ],
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
           FilledButton(
             onPressed: () {
               final raw = controller.text.replaceAll('.', '');
               final amount = double.tryParse(raw);
               if (amount != null) {
                  if (isHistoryGroup) {
                    // For history, use distributeDpByIds (searches both active + history)
                    vm.distributeDpByIds(
                      group.bookings.map((b) => b.id).toList(),
                      amount,
                    );
                  } else {
                    // For active, use distributeDp (by owner identifier)
                    vm.distributeDp(group.ownerPhone.isNotEmpty ? group.ownerPhone : group.ownerName, amount);
                  }
                  Navigator.pop(ctx);
               }
             },
             child: const Text('Simpan'),
           ),
         ],
       ),
     );
  }

  void _showCheckoutGroupDialog(BuildContext context, HotelViewModel vm, BillingGroup group) {
    final finVm = context.read<FinancialViewModel>();
    final ownerDeposit = finVm.deposits.where((d) => d.ownerPhone == group.ownerPhone).firstOrNull;
    bool useDeposit = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final remaining = group.remaining;
          return AlertDialog(
            title: const Text('Konfirmasi Check Out'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selesaikan ${group.bookings.length} booking untuk ${group.ownerName}?'),
                Text('Total: ${app_date.formatCurrencyDouble(remaining)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (ownerDeposit != null && remaining > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: ownerDeposit.balance >= remaining
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      border: Border.all(
                        color: ownerDeposit.balance >= remaining
                            ? Colors.green.withOpacity(0.5)
                            : Colors.orange.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      value: useDeposit,
                      onChanged: ownerDeposit.balance > 0
                          ? (val) => setDialogState(() => useDeposit = val ?? false)
                          : null,
                      title: const Text('Bayar dari Deposit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saldo: ${app_date.formatCurrencyDouble(ownerDeposit.balance)}',
                              style: TextStyle(
                                color: ownerDeposit.balance >= remaining ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              )),
                          if (ownerDeposit.balance < remaining && ownerDeposit.balance > 0)
                            Text('Saldo kurang, akan dipotong ${app_date.formatCurrencyDouble(ownerDeposit.balance)}',
                                style: const TextStyle(fontSize: 11, color: Colors.orange)),
                        ],
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              FilledButton(
                onPressed: () async {
                  // Deduct deposit if applicable
                  double actualDeducted = 0.0;
                  if (useDeposit && ownerDeposit != null && remaining > 0) {
                    try {
                      final deductAmount = ownerDeposit.balance < remaining
                          ? ownerDeposit.balance
                          : remaining;
                      await finVm.deductDeposit(
                        group.ownerPhone,
                        deductAmount,
                        'Hotel: ${group.bookings.length} booking',
                        null,
                        transactionType: TransactionType.hotelPayment,
                      );
                      actualDeducted = deductAmount;
                    } catch (e) {
                      debugPrint('Deposit deduct error: $e');
                    }
                  }

                  vm.checkoutGroup(group.bookings);
                  if (ctx.mounted) Navigator.pop(ctx);
                  // Auto-print invoice after checkout (matching V2)
                  final groomingVm = context.read<GroomingViewModel>();
                  // Fix: Update checkOutDate in the group passed to PDF generator
                  // So the invoice reflects "Stay until NOW" instead of the original planned date.
                  final now = DateTime.now().millisecondsSinceEpoch;
                  final updatedBookings = group.bookings.map((b) => b.copyWith(checkOutDate: now)).toList();
                  final updatedGroup = group.copyWith(bookings: updatedBookings);

                  PdfGenerator.printHotelInvoice(
                    group: updatedGroup,
                    businessName: groomingVm.businessName,
                    businessPhone: groomingVm.businessPhone,
                    businessAddress: groomingVm.businessAddress,
                    logoPath: groomingVm.logoPath,
                    userPlan: groomingVm.userPlan,
                    depositDeducted: actualDeducted,
                  );
                },
                child: const Text('Check Out'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddOnForm extends StatefulWidget {
  final HotelViewModel vm;
  final List<HotelBooking> bookings;
  final List<Cat> groupCats;

  const _AddOnForm({required this.vm, required this.bookings, required this.groupCats});

  @override
  State<_AddOnForm> createState() => _AddOnFormState();
}

class _AddOnFormState extends State<_AddOnForm> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  HotelBooking? _selectedBooking;

  @override
  void initState() {
    super.initState();
    if (widget.bookings.isNotEmpty) {
      _selectedBooking = widget.bookings.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<HotelBooking>(
          initialValue: _selectedBooking,
          decoration: const InputDecoration(labelText: 'Pilih Kucing/Kamar'),
          items: widget.bookings.asMap().entries.map((entry) {
            final idx = entry.key;
            final booking = entry.value;
            final cat = widget.groupCats[idx];
            return DropdownMenuItem(
              value: booking,
              child: Text(cat.catName),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedBooking = val),
        ),
        const SizedBox(height: 8),
        TextField(controller: _itemController, decoration: const InputDecoration(labelText: 'Nama Item (Contoh: Whiskas)')),
        const SizedBox(height: 8),
        TextField(
          controller: _priceController,
          decoration: const InputDecoration(labelText: 'Harga', prefixText: 'Rp '),
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedBooking != null && _itemController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                 final rawPrice = _priceController.text.replaceAll('.', '');
                 final price = double.tryParse(rawPrice) ?? 0;
                 final addon = HotelAddOn(
                   bookingId: _selectedBooking!.id,
                   itemName: _itemController.text,
                   price: price,
                   qty: 1, // Default 1 for now
                   date: DateTime.now().millisecondsSinceEpoch,
                 );
                 widget.vm.addAddOn(addon);
                 // Clear form
                 _itemController.clear();
                 _priceController.clear();
                 // Close sheet
                 Navigator.pop(context);
              }
            },
            child: const Text('Tambah Item'),
          ),
        ),
      ],
    );
  }
}


