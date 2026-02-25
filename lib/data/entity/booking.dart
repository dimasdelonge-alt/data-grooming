class Booking {
  final int bookingId;
  final int catId;
  final String serviceType;
  final int bookingDate;
  final int durationMinutes;
  final String status; // SCHEDULED, CONFIRMED, COMPLETED, CANCELLED
  final String notes;

  const Booking({
    this.bookingId = 0,
    this.catId = 0,
    this.serviceType = '',
    this.bookingDate = 0,
    this.durationMinutes = 30,
    this.status = 'SCHEDULED',
    this.notes = '',
  });

  Booking copyWith({
    int? bookingId,
    int? catId,
    String? serviceType,
    int? bookingDate,
    int? durationMinutes,
    String? status,
    String? notes,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      catId: catId ?? this.catId,
      serviceType: serviceType ?? this.serviceType,
      bookingDate: bookingDate ?? this.bookingDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'catId': catId,
      'serviceType': serviceType,
      'bookingDate': bookingDate,
      'durationMinutes': durationMinutes,
      'status': status,
      'notes': notes,
    };
    if (bookingId != 0) {
      map['bookingId'] = bookingId;
    }
    return map;
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      bookingId: (map['bookingId'] as num?)?.toInt() ?? 0,
      catId: (map['catId'] as num?)?.toInt() ?? 0,
      serviceType: map['serviceType'] as String? ?? '',
      bookingDate: (map['bookingDate'] as num?)?.toInt() ?? 0,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      status: map['status'] as String? ?? 'SCHEDULED',
      notes: map['notes'] as String? ?? '',
    );
  }
}
