enum BookingStatus {
  active,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case BookingStatus.active:
        return 'ACTIVE';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static BookingStatus fromString(String? value) {
    switch (value) {
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'ACTIVE':
      default:
        return BookingStatus.active;
    }
  }
}

// ─── HotelRoom ──────────────────────────────────────────────────────────────

class HotelRoom {
  final int id;
  final String name;
  final double pricePerNight;
  final int capacity;
  final String notes;

  const HotelRoom({
    this.id = 0,
    this.name = '',
    this.pricePerNight = 0.0,
    this.capacity = 1,
    this.notes = '',
  });

  HotelRoom copyWith({
    int? id,
    String? name,
    double? pricePerNight,
    int? capacity,
    String? notes,
  }) {
    return HotelRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      capacity: capacity ?? this.capacity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'notes': notes,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory HotelRoom.fromMap(Map<String, dynamic> map) {
    return HotelRoom(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      pricePerNight: (map['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      capacity: map['capacity'] as int? ?? 1,
      notes: map['notes'] as String? ?? '',
    );
  }
}

// ─── HotelBooking ───────────────────────────────────────────────────────────

class HotelBooking {
  final int id;
  final int roomId;
  final int catId;
  final int checkInDate;
  final int checkOutDate;
  final BookingStatus status;
  final double totalCost;
  final double dpAmount;
  final String notes;

  const HotelBooking({
    this.id = 0,
    this.roomId = 0,
    this.catId = 0,
    this.checkInDate = 0,
    this.checkOutDate = 0,
    this.status = BookingStatus.active,
    this.totalCost = 0.0,
    this.dpAmount = 0.0,
    this.notes = '',
  });

  HotelBooking copyWith({
    int? id,
    int? roomId,
    int? catId,
    int? checkInDate,
    int? checkOutDate,
    BookingStatus? status,
    double? totalCost,
    double? dpAmount,
    String? notes,
  }) {
    return HotelBooking(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      catId: catId ?? this.catId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      totalCost: totalCost ?? this.totalCost,
      dpAmount: dpAmount ?? this.dpAmount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'roomId': roomId,
      'catId': catId,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'status': status.value,
      'totalCost': totalCost,
      'dpAmount': dpAmount,
      'notes': notes,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory HotelBooking.fromMap(Map<String, dynamic> map) {
    return HotelBooking(
      id: (map['id'] as num?)?.toInt() ?? 0,
      roomId: (map['roomId'] as num?)?.toInt() ?? 0,
      catId: (map['catId'] as num?)?.toInt() ?? 0,
      checkInDate: (map['checkInDate'] as num?)?.toInt() ?? 0,
      checkOutDate: (map['checkOutDate'] as num?)?.toInt() ?? 0,
      status: BookingStatus.fromString(map['status'] as String?),
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      dpAmount: (map['dpAmount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
    );
  }
}

// ─── HotelAddOn ─────────────────────────────────────────────────────────────

class HotelAddOn {
  final int id;
  final int bookingId;
  final String itemName;
  final double price;
  final int qty;
  final int date;

  const HotelAddOn({
    this.id = 0,
    this.bookingId = 0,
    this.itemName = '',
    this.price = 0.0,
    this.qty = 1,
    this.date = 0,
  });

  HotelAddOn copyWith({
    int? id,
    int? bookingId,
    String? itemName,
    double? price,
    int? qty,
    int? date,
  }) {
    return HotelAddOn(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bookingId': bookingId,
      'itemName': itemName,
      'price': price,
      'qty': qty,
      'date': date,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory HotelAddOn.fromMap(Map<String, dynamic> map) {
    return HotelAddOn(
      id: (map['id'] as num?)?.toInt() ?? 0,
      bookingId: (map['bookingId'] as num?)?.toInt() ?? 0,
      itemName: map['itemName'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      qty: (map['qty'] as num?)?.toInt() ?? 1,
      date: (map['date'] as num?)?.toInt() ?? 0,
    );
  }
}
