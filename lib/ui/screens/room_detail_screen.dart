import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../hotel_view_model.dart';
import '../grooming_view_model.dart';
import '../../data/entity/hotel_entities.dart';
import '../../data/entity/cat.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/currency_formatter.dart';
import '../../util/phone_number_utils.dart';
import '../common/cat_avatar.dart';

class RoomDetailScreen extends StatefulWidget {
  final int roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final hotelVm = context.watch<HotelViewModel>();
    final groomingVm = context.watch<GroomingViewModel>();
    final room = hotelVm.rooms.where((r) => r.id == widget.roomId).firstOrNull;

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Kamar')),
        body: const Center(child: Text('Kamar tidak ditemukan.')),
      );
    }

    final activeBooking = hotelVm.activeBookings.where((b) => b.roomId == room.id).firstOrNull;
    final isOccupied = activeBooking != null;

    Cat? cat;
    if (isOccupied) {
      cat = groomingVm.allCats.where((c) => c.catId == activeBooking.catId).firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(title: Text(room.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Room Info ───────────────────────────────────────────────────
            Card(
              child: ListTile(
                leading: Icon(Icons.meeting_room_rounded, size: 40, color: Theme.of(context).primaryColor),
                title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('Kapasitas: ${room.capacity} • ${app_date.formatCurrencyDouble(room.pricePerNight)} / malam\n${room.notes}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () {
                     // Reuse the dialog from HotelScreen?
                     // Ideally refactor dialog to separate widget or static method.
                     // For now just show a simple edit dialog here or copy logic.
                     _showEditRoomDialog(context, hotelVm, room);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Status Section ──────────────────────────────────────────────
            Text(
              isOccupied ? 'Status: TERISI' : 'Status: KOSONG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isOccupied ? Colors.redAccent : Colors.green,
              ),
            ),
            const SizedBox(height: 12),

            if (isOccupied) ...[
              // OCCUPIED VIEW
              Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: cat?.imagePath != null ? AssetImage(cat!.imagePath!) : null, // Uses local path logic
                          child: cat?.imagePath == null ? const Icon(Icons.pets) : null,
                        ),
                        title: Text(cat?.catName ?? 'Unknown Cat', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Owner: ${cat?.ownerName ?? "-"}'),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DateInfo('Check In', DateTime.fromMillisecondsSinceEpoch(activeBooking.checkInDate)),
                          _DateInfo('Check Out', DateTime.fromMillisecondsSinceEpoch(activeBooking.checkOutDate)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _checkOut(context, hotelVm, activeBooking),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Check Out'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size.fromHeight(45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // EMPTY VIEW
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.hotel_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showCheckInDialog(context, hotelVm, groomingVm, room),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Check In (Masuk Kamar)'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
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

  void _showEditRoomDialog(BuildContext context, HotelViewModel vm, HotelRoom room) {
    // Simplified edit dialog
    final priceController = TextEditingController(text: room.pricePerNight.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Harga'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: const InputDecoration(labelText: 'Harga per Malam', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final raw = priceController.text.replaceAll('.', '');
              final p = double.tryParse(raw);
              if (p != null) {
                vm.updateRoom(room.copyWith(pricePerNight: p));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showCheckInDialog(BuildContext context, HotelViewModel hotelVm, GroomingViewModel groomingVm, HotelRoom room) {
    Cat? selectedCat;
    DateTimeRange? selectedRange;
    final searchController = TextEditingController();
    bool showResults = false;
    bool showQuickAdd = false;
    
    // Quick-add cat form controllers
    final quickNameController = TextEditingController();
    final quickBreedController = TextEditingController();
    final quickOwnerController = TextEditingController();
    final quickPhoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDlgState) {
          final query = searchController.text.toLowerCase();
          final allCats = groomingVm.allCats;
          final filtered = query.isEmpty 
              ? <Cat>[]
              : allCats.where((c) => c.catName.toLowerCase().contains(query) || c.ownerName.toLowerCase().contains(query)).take(5).toList();

          // Get unique owner names for autocomplete
          final ownerNames = allCats.map((c) => c.ownerName).toSet().toList()..sort();

          return AlertDialog(
            title: const Text('Hotel Check In'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Search Field (Primary Action)
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari Kucing / Owner',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear), 
                              onPressed: () {
                                setDlgState(() {
                                  searchController.clear();
                                  selectedCat = null;
                                  showResults = false;
                                });
                              }
                            ) 
                          : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) => setDlgState(() {
                         showResults = true;
                         if (val.isEmpty) selectedCat = null;
                      }),
                      onTap: () => setDlgState(() => showResults = true),
                    ),
                    
                    // Results List
                    if (showResults && filtered.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF424242) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Material(
                            color: Colors.transparent,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final cat = filtered[index];
                                return ListTile(
                                  dense: true,
                                  leading: CatAvatar(imagePath: cat.imagePath, size: 36),
                                  title: Text(cat.catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Owner: ${cat.ownerName}'),
                                  onTap: () {
                                    setDlgState(() {
                                      selectedCat = cat;
                                      searchController.text = '${cat.catName} (${cat.ownerName})';
                                      showResults = false;
                                    });
                                    // Clear focus to dismiss keyboard
                                    FocusScope.of(context).unfocus();
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                    const SizedBox(height: 16),

                    // 2. Quick Add Cat Button (Secondary Action)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Kucing belum terdaftar?', 
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setDlgState(() => showQuickAdd = !showQuickAdd),
                          icon: Icon(showQuickAdd ? Icons.close : Icons.add_circle_outline),
                          label: Text(showQuickAdd ? 'Batal Tambah' : 'Tambah Baru'),
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    
                    // Quick Add Form
                    if (showQuickAdd) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Data Kucing Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: quickNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Kucing',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: quickBreedController,
                              decoration: const InputDecoration(
                                labelText: 'Ras',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Autocomplete<String>(
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text.isEmpty) return ownerNames;
                                return ownerNames.where((o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (selection) => quickOwnerController.text = selection,
                              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                                quickOwnerController.text = controller.text;
                                controller.addListener(() => quickOwnerController.text = controller.text);
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Owner',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: quickPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'No. Telp Owner',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  if (quickNameController.text.trim().isNotEmpty) {
                                    hotelVm.quickAddCat(
                                      quickNameController.text.trim(),
                                      quickBreedController.text.trim(),
                                      quickOwnerController.text.trim(),
                                      PhoneNumberUtils.normalize(quickPhoneController.text.trim()),
                                    );
                                    setDlgState(() {
                                      showQuickAdd = false;
                                      quickNameController.clear();
                                      quickBreedController.clear();
                                      quickOwnerController.clear();
                                      quickPhoneController.clear();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kucing berhasil ditambahkan!')),
                                    );
                                  }
                                },
                                child: const Text('Simpan Kucing'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Date Picker
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: ctx,
                          firstDate: DateTime.now().subtract(const Duration(days: 7)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setDlgState(() => selectedRange = picked);
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(selectedRange == null 
                          ? 'Pilih Tanggal' 
                          : '${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        alignment: Alignment.centerLeft,
                      ),
                    ),

                    if (selectedCat != null && selectedRange != null) ...[
                       const SizedBox(height: 16),
                       Text('Total Biaya: ${app_date.formatCurrencyDouble(room.pricePerNight * (selectedRange!.duration.inDays > 0 ? selectedRange!.duration.inDays : 1))}', 
                           style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              FilledButton(
                onPressed: (selectedCat != null && selectedRange != null)
                    ? () {
                        // Recalculate duration to be safe
                        int days = selectedRange!.duration.inDays;
                        if (days < 1) days = 1;

                        final booking = HotelBooking(
                          roomId: room.id,
                          catId: selectedCat!.catId,
                          checkInDate: selectedRange!.start.millisecondsSinceEpoch,
                          checkOutDate: selectedRange!.end.millisecondsSinceEpoch,
                          status: BookingStatus.active,
                          totalCost: room.pricePerNight * days,
                        );
                        hotelVm.checkIn(booking);
                        Navigator.pop(ctx);
                      }
                    : null,
                child: const Text('Check In'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _checkOut(BuildContext context, HotelViewModel vm, HotelBooking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Check Out'),
        content: const Text('Selesaikan booking ini? Kamar akan menjadi kosong.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Check Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vm.checkOut(booking);
      if (context.mounted) Navigator.pop(context); // Go back to hotel list
    }
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;
  const _DateInfo(this.label, this.date);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
