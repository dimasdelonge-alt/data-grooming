import '../entity/cat.dart';
import '../entity/session.dart';
import '../entity/session_photo.dart';
import '../entity/booking.dart';
import '../entity/grooming_service.dart';

class BackupData {
  final int version;
  final int timestamp;
  final List<Cat> cats;
  final List<Session> sessions;
  final List<SessionPhoto> photos;
  final List<Booking> bookings;
  final List<GroomingService> services;

  const BackupData({
    this.version = 1,
    int? timestamp,
    required this.cats,
    required this.sessions,
    this.photos = const [],
    required this.bookings,
    required this.services,
  }) : timestamp = timestamp ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'timestamp': timestamp,
      'cats': cats.map((e) => e.toMap()).toList(),
      'sessions': sessions.map((e) => e.toMap()).toList(),
      'photos': photos.map((e) => e.toMap()).toList(),
      'bookings': bookings.map((e) => e.toMap()).toList(),
      'services': services.map((e) => e.toMap()).toList(),
    };
  }

  factory BackupData.fromMap(Map<String, dynamic> map) {
    return BackupData(
      version: map['version'] as int? ?? 1,
      timestamp: map['timestamp'] as int? ?? 0,
      cats: (map['cats'] as List<dynamic>?)
              ?.map((e) => Cat.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      sessions: (map['sessions'] as List<dynamic>?)
              ?.map((e) => Session.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      photos: (map['photos'] as List<dynamic>?)
              ?.map((e) => SessionPhoto.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      bookings: (map['bookings'] as List<dynamic>?)
              ?.map((e) => Booking.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      services: (map['services'] as List<dynamic>?)
              ?.map((e) => GroomingService.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
