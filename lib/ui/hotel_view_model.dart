import 'package:flutter/foundation.dart';
import '../data/repository/grooming_repository.dart';
import '../data/entity/cat.dart';
import '../data/entity/hotel_entities.dart';
import '../data/model/hotel_models.dart';
import '../util/phone_number_utils.dart';

class HotelViewModel extends ChangeNotifier {
  final GroomingRepository _repository;

  List<HotelRoom> _rooms = [];
  List<HotelBooking> _activeBookings = [];
  List<HotelBooking> _historyBookings = [];
  List<Cat> _cats = [];
  List<HotelAddOn> _allAddOns = [];
  bool _isLoading = true;

  HotelViewModel(this._repository) {
    _init();
  }

  List<HotelRoom> get rooms => _rooms;
  List<HotelBooking> get activeBookings => _activeBookings;
  List<HotelBooking> get historyBookings => _historyBookings;
  bool get isLoading => _isLoading;
  List<Cat> get allCats => _cats;
  List<HotelAddOn> get allAddOns => _allAddOns;



  void _init() {
    _loadRooms();
    _loadActiveBookings();
    _loadHistoryBookings();
    _loadCats();
    _loadAddOns();
  }

  void _loadAddOns() async {
    _allAddOns = await _repository.getAllAddOns();
    notifyListeners();
  }

  void _loadRooms() {
    _repository.getAllRooms().listen((list) {
      _rooms = list;
      _isLoading = false;
      notifyListeners();
    });
  }

  void _loadActiveBookings() {
    _repository.getActiveHotelBookings().listen((list) {
      _activeBookings = list;
      // Also refresh addOns when bookings change, just in case
      _loadAddOns();
      notifyListeners();
    });
  }

  void _loadHistoryBookings() {
    _repository.getAllCompletedHotelBookings().listen((list) {
      _historyBookings = list;
       _loadAddOns(); // Refresh add-ons for history items
      notifyListeners();
    });
  }

  void _loadCats() {
    _repository.getAllCats().listen((list) {
      _cats = list;
      notifyListeners();
    });
  }

  // ─── Getters for UI ────────────────────────────────────────────────────────

  List<BillingGroup> get billingGroups {
    if (_activeBookings.isEmpty || _cats.isEmpty) return [];

    final Map<String, List<HotelBooking>> byOwner = {};
    
    // Group active bookings by owner phone (unique logic)
    for (final booking in _activeBookings) {
      final cat = _cats.where((c) => c.catId == booking.catId).firstOrNull;
      if (cat != null) {
        final key = cat.ownerPhone.isNotEmpty ? cat.ownerPhone : cat.ownerName;
        byOwner.putIfAbsent(key, () => []).add(booking);
      }
    }

    return byOwner.values.map((bookings) {
      final firstCat = _cats.firstWhere((c) => c.catId == bookings.first.catId);
      final ownerName = firstCat.ownerName;
      final ownerPhone = firstCat.ownerPhone;
      
      final relatedCats = <Cat>[];
      final relatedRooms = <HotelRoom>[];
      final updatedBookings = <HotelBooking>[];
      final groupAddOns = <HotelAddOn>[];

      double groupTotalCost = 0.0;
      double groupTotalDp = 0.0;

      for (var b in bookings) {
        final cat = _cats.firstWhere((c) => c.catId == b.catId);
        final room = _rooms.firstWhere((r) => r.id == b.roomId, orElse: () => HotelRoom(name: 'Unknown'));
        
        relatedCats.add(cat);
        relatedRooms.add(room);

        // 1. Calculate Real-time Stay Cost
        final checkIn = DateTime.fromMillisecondsSinceEpoch(b.checkInDate);
        final now = DateTime.now();
        int days = now.difference(checkIn).inDays;
        if (days < 1) days = 1; // Minimum 1 day
        // Adjust logic: if checked in today, 1 day. If yesterday, 2 days? 
        // Usually hotel matches nights. If checking out today, it's 1 night?
        // Let's stick to: (diff in days) + 1 if we charge per day/night start. 
        // If checking in today (diff 0), charge 1.
        // If checking in yesterday (diff 1), charge 2? No, normally 1 night.
        // V2 might charge per day. Let's assume (diff + 1) for now based on "Running".
        // Actually, let's use standard logic: 
        // If today == checkin, 1 day. 
        final stayCost = days * room.pricePerNight;

        // 2. Fetch AddOns
        final addons = _allAddOns.where((a) => a.bookingId == b.id).toList();
        groupAddOns.addAll(addons);
        final addonCost = addons.fold(0.0, (sum, a) => sum + (a.price * a.qty));

        // 3. Update Booking Object for UI Display (Virtual Update)
        final currentTotal = stayCost + addonCost;
        updatedBookings.add(b.copyWith(totalCost: currentTotal));

        groupTotalCost += currentTotal;
        groupTotalDp += b.dpAmount;
      }
      
      final totalAddonsCost = groupAddOns.fold(0.0, (sum, a) => sum + (a.price * a.qty));
      
      return BillingGroup(
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        bookings: updatedBookings,
        rooms: relatedRooms,
        cats: relatedCats,
        addOns: groupAddOns,
        totalCost: groupTotalCost,
        totalAddOns: totalAddonsCost,
        totalDp: groupTotalDp,
        remaining: groupTotalCost - groupTotalDp,
      );
    }).toList();
  }

  // Refactored to return a flat list of groups (Session-based) instead of nested by Month
  List<BillingGroup> get historyGroups {
    if (_historyBookings.isEmpty) return [];

    // Group by Owner + CheckIn Date (Session)
    // Key: "OwnerPhone_CheckInDateString"
    final Map<String, List<HotelBooking>> bySession = {};
    
    for (final booking in _historyBookings) {
      final cat = _cats.where((c) => c.catId == booking.catId).firstOrNull;
      if (cat != null) {
        final ownerKey = cat.ownerPhone.isNotEmpty ? cat.ownerPhone : cat.ownerName;
        final dateKey = DateTime.fromMillisecondsSinceEpoch(booking.checkInDate).toIso8601String().split('T')[0];
        final key = "${ownerKey}_$dateKey";
        bySession.putIfAbsent(key, () => []).add(booking);
      }
    }


    final groups = bySession.entries.map((entry) {
        final bookings = entry.value;
        final firstCat = _cats.firstWhere((c) => c.catId == bookings.first.catId, orElse: () => const Cat(catName: 'Unknown'));
        final ownerName = firstCat.ownerName;
        final ownerPhone = firstCat.ownerPhone;
        
        final relatedCats = <Cat>[];
        final relatedRooms = <HotelRoom>[];
        final groupAddOns = <HotelAddOn>[];
        
        double groupTotalCost = 0.0;
        double groupTotalDp = 0.0;

        for (var b in bookings) {
           final cat = _cats.firstWhere((c) => c.catId == b.catId, orElse: () => const Cat(catName: 'Unknown'));
           final room = _rooms.firstWhere((r) => r.id == b.roomId, orElse: () => HotelRoom(name: 'Unknown'));
           relatedCats.add(cat);
           relatedRooms.add(room);
           
           final addons = _allAddOns.where((a) => a.bookingId == b.id).toList();
           groupAddOns.addAll(addons);
           
           groupTotalCost += b.totalCost; // History uses stored totalCost
           groupTotalDp += b.dpAmount;
        }
        
        final totalAddonsCost = groupAddOns.fold(0.0, (sum, a) => sum + (a.price * a.qty));

        return BillingGroup(
          ownerName: ownerName,
          ownerPhone: ownerPhone,
          bookings: bookings,
          rooms: relatedRooms,
          cats: relatedCats,
          addOns: groupAddOns,
          totalCost: groupTotalCost,
          totalAddOns: totalAddonsCost,
          totalDp: groupTotalDp,
          remaining: groupTotalCost - groupTotalDp,
        );
    }).toList();
    
    // Sort by latest check-in date
    groups.sort((a, b) {
       final aDate = a.bookings.isNotEmpty ? a.bookings.first.checkInDate : 0;
       final bDate = b.bookings.isNotEmpty ? b.bookings.first.checkInDate : 0;
       return bDate.compareTo(aDate);
    });

    return groups;
  }

  Future<void> addRoom(String name, double price, int capacity, String notes) async {
    final room = HotelRoom(
      name: name,
      pricePerNight: price,
      capacity: capacity,
      notes: notes,
    );
    await _repository.insertRoom(room);
    _loadRooms();
  }

  Future<void> updateRoom(HotelRoom room) async {
    await _repository.updateRoom(room);
    _loadRooms();
  }

  Future<void> deleteRoom(HotelRoom room) async {
    await _repository.deleteRoom(room);
    _loadRooms();
  }

  // ─── Booking Management ────────────────────────────────────────────────────

  Future<void> checkIn(HotelBooking booking) async {
    await _repository.insertHotelBooking(booking);
    _loadActiveBookings();
    _loadRooms(); // Rooms might appear occupied? UI handles this via booking mapping.
  }

  Future<void> checkOut(HotelBooking booking) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final total = _calculateCurrentTotal(booking);
    
    await _repository.updateHotelBooking(
      booking.copyWith(
        status: BookingStatus.completed,
        checkOutDate: now,
        totalCost: total,
      ),
    );
    _loadActiveBookings();
  }

  double _calculateCurrentTotal(HotelBooking booking) {
    final room = _rooms.firstWhere((r) => r.id == booking.roomId, orElse: () => HotelRoom(name: 'Unknown', pricePerNight: 0));
    final checkIn = DateTime.fromMillisecondsSinceEpoch(booking.checkInDate);
    final now = DateTime.now();
    
    int days = now.difference(checkIn).inDays;
    if (days < 1) days = 1;
    
    final roomCost = days * room.pricePerNight;
    
    final bookingAddOns = _allAddOns.where((a) => a.bookingId == booking.id);
    final addOnsCost = bookingAddOns.fold(0.0, (sum, a) => sum + (a.price * a.qty));
    
    return roomCost + addOnsCost;
  }

  Future<void> cancelBooking(HotelBooking booking) async {
    await _repository.updateHotelBooking(
      booking.copyWith(status: BookingStatus.cancelled),
    );
    _loadActiveBookings();
  }

  Future<void> updateBooking(HotelBooking booking) async {
    await _repository.updateHotelBooking(booking);
    _loadActiveBookings();
  }

  Future<void> updateBookingDates(HotelBooking booking, int newCheckIn, int newCheckOut, Function(String) onError) async {
    if (newCheckOut <= newCheckIn) {
      onError("Tanggal keluar harus lebih besar dari tanggal masuk!");
      return;
    }

    // Check conflicts
    final conflicts = await _repository.checkRoomAvailabilityExcluding(
      booking.roomId, newCheckIn, newCheckOut, booking.id
    );

    if (conflicts.isNotEmpty) {
      onError("Gagal: Kamar sudah terisi pada tanggal tersebut.");
      return;
    }

    // Recalculate Cost
    final room = _rooms.firstWhere((r) => r.id == booking.roomId, orElse: () => HotelRoom(name: 'Unknown', pricePerNight: 0));
    
    // Calculate days active
    final durationMillis = newCheckOut - newCheckIn;
    final durationDays = (durationMillis / (1000 * 60 * 60 * 24)).ceil(); // Simple ceil for days
    final actualDays = durationDays < 1 ? 1 : durationDays;
    
    final roomCost = actualDays * room.pricePerNight;

    // Get AddOns to preserve their cost in total
    // We already have _allAddOns loaded
    final bookingAddOns = _allAddOns.where((a) => a.bookingId == booking.id);
    final addOnsCost = bookingAddOns.fold(0.0, (sum, a) => sum + (a.price * a.qty));

    final newTotal = roomCost + addOnsCost;

    final updated = booking.copyWith(
      checkInDate: newCheckIn,
      checkOutDate: newCheckOut,
      totalCost: newTotal
    );

    await _repository.updateHotelBooking(updated);
    _loadActiveBookings();
  }

  Future<void> deleteBooking(HotelBooking booking) async {
     await _repository.deleteHotelBookingById(booking.id);
     _loadActiveBookings();
     // Should also refresh history if we support deleting history
     _loadHistoryBookings();
  }

  Future<List<HotelBooking>> checkAvailability(
      int roomId, DateTime start, DateTime end) async {
    return _repository.checkRoomAvailability(
      roomId,
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
  }

  Future<List<HotelBooking>> checkAvailabilityExcluding(
      int roomId, DateTime start, DateTime end, int excludeId) async {
    return _repository.checkRoomAvailabilityExcluding(
      roomId,
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
      excludeId,
    );
  }

  // ─── Add-Ons ───────────────────────────────────────────────────────────────

  Stream<List<HotelAddOn>> getAddOns(int bookingId) {
    return _repository.getAddOnsForBooking(bookingId);
  }

  Future<void> addAddOn(HotelAddOn addOn) async {
    await _repository.insertAddOn(addOn);
    _loadAddOns();
  }

  Future<void> deleteAddOn(HotelAddOn addOn) async {
    await _repository.deleteAddOn(addOn);
    _loadAddOns();
  }

  // ─── Bulk Actions ──────────────────────────────────────────────────────────

  Future<void> checkoutGroup(List<HotelBooking> bookings) async {
    for (final booking in bookings) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final total = _calculateCurrentTotal(booking);

      await _repository.updateHotelBooking(
        booking.copyWith(
          status: BookingStatus.completed,
          checkOutDate: now,
          totalCost: total,
        ),
      );
    }
    _loadActiveBookings();
    _loadHistoryBookings();
  }

  Future<void> distributeDp(String ownerIdentifier, double totalAmount) async {
    // ownerIdentifier can be Name or Phone. We filtered by this in billingGroups.
    // Re-find bookings for this owner.
    final bookings = _activeBookings.where((b) {
      final cat = _cats.where((c) => c.catId == b.catId).firstOrNull;
      if (cat == null) return false;
      return cat.ownerName == ownerIdentifier || cat.ownerPhone == ownerIdentifier;
    }).toList();

    if (bookings.isEmpty) return;

    final count = bookings.length;
    final amountPerBooking = totalAmount / count;

    for (final booking in bookings) {
      await _repository.updateHotelBooking(
        booking.copyWith(dpAmount: amountPerBooking),
      );
    }
    _loadActiveBookings();
  }

  Future<void> updateBookingDp(HotelBooking booking, double amount) async {
    await _repository.updateHotelBooking(
      booking.copyWith(dpAmount: amount),
    );
    _loadActiveBookings();
  }

  /// Distribute DP across specific booking IDs (used for history DP update)
  Future<void> distributeDpByIds(List<int> bookingIds, double totalAmount) async {
    if (bookingIds.isEmpty) return;
    final amountPerBooking = totalAmount / bookingIds.length;

    // Search in both active and history bookings
    final allBookings = [..._activeBookings, ..._historyBookings];
    for (final id in bookingIds) {
      final booking = allBookings.where((b) => b.id == id).firstOrNull;
      if (booking != null) {
        await _repository.updateHotelBooking(
          booking.copyWith(dpAmount: amountPerBooking),
        );
      }
    }
    _loadActiveBookings();
    _loadHistoryBookings();
  }

  /// Quick-add a cat from the check-in dialog
  Future<void> quickAddCat(String name, String breed, String ownerName, String ownerPhone) async {
    final cat = Cat(
      catName: name,
      breed: breed,
      ownerName: ownerName,
      ownerPhone: PhoneNumberUtils.normalize(ownerPhone),
      gender: 'Male',
      dob: 0,
      profilePhotoPath: '',
      permanentAlert: '',
      furColor: '',
      eyeColor: '',
      weight: 0.0,
      isSterile: false,
    );
    await _repository.insertCat(cat);
    _loadCats();
  }
}
