import '../entity/hotel_entities.dart';
import '../entity/cat.dart';

class BillingGroup {
  final String ownerName;
  final String ownerPhone;
  final List<HotelBooking> bookings;
  final List<HotelRoom> rooms;
  final List<Cat> cats;
  final List<HotelAddOn> addOns;
  final double totalCost;
  final double totalAddOns;
  final double totalDp;
  final double remaining;

  BillingGroup({
    required this.ownerName,
    required this.ownerPhone,
    required this.bookings,
    required this.rooms,
    required this.cats,
    this.addOns = const [],
    required this.totalCost,
    required this.totalAddOns,
    required this.totalDp,
    required this.remaining,
  });

  BillingGroup copyWith({
    String? ownerName,
    String? ownerPhone,
    List<HotelBooking>? bookings,
    List<HotelRoom>? rooms,
    List<Cat>? cats,
    List<HotelAddOn>? addOns,
    double? totalCost,
    double? totalAddOns,
    double? totalDp,
    double? remaining,
  }) {
    return BillingGroup(
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      bookings: bookings ?? this.bookings,
      rooms: rooms ?? this.rooms,
      cats: cats ?? this.cats,
      addOns: addOns ?? this.addOns,
      totalCost: totalCost ?? this.totalCost,
      totalAddOns: totalAddOns ?? this.totalAddOns,
      totalDp: totalDp ?? this.totalDp,
      remaining: remaining ?? this.remaining,
    );
  }
}

class HistoryGroup {
  final String date; // e.g., "Nov 2023"
  final List<BillingGroup> groups;

  HistoryGroup({required this.date, required this.groups});
}
