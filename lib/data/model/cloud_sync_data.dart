import '../entity/cat.dart';
import '../entity/session.dart';
import '../entity/hotel_entities.dart';
import '../entity/grooming_service.dart';
import '../entity/expense.dart';

import '../entity/chip_option.dart';
import '../entity/booking.dart';
import '../entity/deposit_entities.dart';

// ─── TrackingData ───────────────────────────────────────────────────────────

class TrackingData {
  final String status;
  final int updatedAt;
  final String catName;
  final String treatment;
  final int estimatedCost;
  final String? trackingToken;

  const TrackingData({
    required this.status,
    required this.updatedAt,
    required this.catName,
    required this.treatment,
    required this.estimatedCost,
    this.trackingToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'updatedAt': updatedAt,
      'catName': catName,
      'treatment': treatment,
      'estimatedCost': estimatedCost,
      'trackingToken': trackingToken,
    };
  }

  factory TrackingData.fromMap(Map<String, dynamic> map) {
    return TrackingData(
      status: map['status'] as String? ?? '',
      updatedAt: map['updatedAt'] as int? ?? 0,
      catName: map['catName'] as String? ?? '',
      treatment: map['treatment'] as String? ?? '',
      estimatedCost: map['estimatedCost'] as int? ?? 0,
      trackingToken: map['trackingToken'] as String?,
    );
  }
}

// ─── ShopIdentity ───────────────────────────────────────────────────────────

class ShopIdentity {
  final String shopName;
  final String shopPhone;

  const ShopIdentity({
    this.shopName = '',
    this.shopPhone = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'shopPhone': shopPhone,
    };
  }

  factory ShopIdentity.fromMap(Map<String, dynamic> map) {
    return ShopIdentity(
      shopName: map['shopName'] as String? ?? '',
      shopPhone: map['shopPhone'] as String? ?? '',
    );
  }
}

// ─── DeviceInfo ─────────────────────────────────────────────────────────────

class DeviceInfo {
  final String deviceName;
  final int registeredAt;

  const DeviceInfo({
    this.deviceName = '',
    this.registeredAt = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'registeredAt': registeredAt,
    };
  }

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceName: map['deviceName'] as String? ?? '',
      registeredAt: map['registeredAt'] as int? ?? 0,
    );
  }
}

// ─── SubscriptionStatus ─────────────────────────────────────────────────────

class SubscriptionStatus {
  final String plan;
  final int validUntil;
  final int maxDevices;

  const SubscriptionStatus({
    this.plan = 'starter',
    this.validUntil = 0,
    this.maxDevices = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'validUntil': validUntil,
      'maxDevices': maxDevices,
    };
  }

  factory SubscriptionStatus.fromMap(Map<String, dynamic> map) {
    return SubscriptionStatus(
      plan: map['plan'] as String? ?? 'starter',
      validUntil: map['validUntil'] as int? ?? 0,
      maxDevices: map['maxDevices'] as int? ?? 1,
    );
  }
}

// ─── ShopCredentials ────────────────────────────────────────────────────────

class ShopCredentials {
  final ShopIdentity? identity;
  final SubscriptionStatus? subscription;
  final Map<String, DeviceInfo>? devices;
  final String? secretKey;

  const ShopCredentials({
    this.identity,
    this.subscription,
    this.devices,
    this.secretKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'identity': identity?.toMap(),
      'subscription': subscription?.toMap(),
      'devices': devices?.map((k, v) => MapEntry(k, v.toMap())),
      'secretKey': secretKey,
    };
  }

  factory ShopCredentials.fromMap(Map<String, dynamic> map) {
    return ShopCredentials(
      identity: map['identity'] != null
          ? ShopIdentity.fromMap(map['identity'] as Map<String, dynamic>)
          : null,
      subscription: map['subscription'] != null
          ? SubscriptionStatus.fromMap(
              map['subscription'] as Map<String, dynamic>)
          : null,
      devices: (map['devices'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, DeviceInfo.fromMap(v as Map<String, dynamic>)),
      ),
      secretKey: map['secretKey'] as String?,
    );
  }
}

// ─── CloudSyncData ──────────────────────────────────────────────────────────
// Firebase may return arrays when keys are sequential integers.
// _safeMapFromDynamic handles both Map and List inputs.

class CloudSyncData {
  final Map<String, Cat> cats;
  final Map<String, String> catPhotos; // CatId -> Base64
  final Map<String, Session> sessions;
  final Map<String, HotelRoom> hotelRooms;
  final Map<String, HotelBooking> hotelBookings;
  final Map<String, GroomingService> services;
  final Map<String, Expense> expenses;
  final Map<String, ChipOption> chipOptions;
  final Map<String, Booking> bookings;
  final Map<String, HotelAddOn> hotelAdds;
  final Map<String, OwnerDeposit> ownerDeposits;
  final Map<String, DepositTransaction> depositTransactions;

  const CloudSyncData({
    this.cats = const {},
    this.catPhotos = const {},
    this.sessions = const {},
    this.hotelRooms = const {},
    this.hotelBookings = const {},
    this.services = const {},
    this.expenses = const {},
    this.chipOptions = const {},
    this.bookings = const {},
    this.hotelAdds = const {},
    this.ownerDeposits = const {},
    this.depositTransactions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'cats': cats.map((k, v) => MapEntry(k, v.toMap())),
      'cat_photos': catPhotos,
      'sessions': sessions.map((k, v) => MapEntry(k, v.toMap())),
      'hotel_rooms': hotelRooms.map((k, v) => MapEntry(k, v.toMap())),
      'hotel_bookings': hotelBookings.map((k, v) => MapEntry(k, v.toMap())),
      'services': services.map((k, v) => MapEntry(k, v.toMap())),
      'expenses': expenses.map((k, v) => MapEntry(k, v.toMap())),
      'chip_options': chipOptions.map((k, v) => MapEntry(k, v.toMap())),
      'bookings': bookings.map((k, v) => MapEntry(k, v.toMap())),
      'hotel_adds': hotelAdds.map((k, v) => MapEntry(k, v.toMap())),
      'owner_deposits': ownerDeposits.map((k, v) => MapEntry(k, v.toMap())),
      'deposit_transactions': depositTransactions.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  factory CloudSyncData.fromMap(Map<String, dynamic> map) {
    return CloudSyncData(
      cats: _safeMapFromDynamic(
        map['cats'],
        (v) => Cat.fromMap(v as Map<String, dynamic>),
      ),
      catPhotos: _safeMapFromDynamic<String>(
        map['cat_photos'],
        (v) => v as String,
      ),
      sessions: _safeMapFromDynamic(
        map['sessions'],
        (v) => Session.fromMap(v as Map<String, dynamic>),
      ),
      hotelRooms: _safeMapFromDynamic(
        map['hotel_rooms'],
        (v) => HotelRoom.fromMap(v as Map<String, dynamic>),
      ),
      hotelBookings: _safeMapFromDynamic(
        map['hotel_bookings'],
        (v) => HotelBooking.fromMap(v as Map<String, dynamic>),
      ),
      services: _safeMapFromDynamic(
        map['services'],
        (v) => GroomingService.fromMap(v as Map<String, dynamic>),
      ),
      expenses: _safeMapFromDynamic(
        map['expenses'],
        (v) => Expense.fromMap(v as Map<String, dynamic>),
      ),
      chipOptions: _safeMapFromDynamic(
        map['chip_options'],
        (v) => ChipOption.fromMap(v as Map<String, dynamic>),
      ),
      bookings: _safeMapFromDynamic(
        map['bookings'],
        (v) => Booking.fromMap(v as Map<String, dynamic>),
      ),
      hotelAdds: _safeMapFromDynamic(
        map['hotel_adds'],
        (v) => HotelAddOn.fromMap(v as Map<String, dynamic>),
      ),
      ownerDeposits: _safeMapFromDynamic(
        map['owner_deposits'],
        (v) => OwnerDeposit.fromMap(v as Map<String, dynamic>),
      ),
      depositTransactions: _safeMapFromDynamic(
        map['deposit_transactions'],
        (v) => DepositTransaction.fromMap(v as Map<String, dynamic>),
      ),
    );
  }

  /// Handles Firebase returning either a Map or an Array for indexed data.
  static Map<String, T> _safeMapFromDynamic<T>(
    dynamic data,
    T Function(dynamic) convert,
  ) {
    if (data == null) return {};
    
    // Safety check: Firebase might return "true" or "1" for some nodes if they were used as flags
    if (data is bool || data is num || data is String) return {};

    if (data is Map) {
      final result = <String, T>{};
      data.forEach((key, value) {
        if (value != null) {
          try {
             result[key.toString()] = convert(value);
          } catch (e) {
             // Skip malformed items instead of crashing entire sync
             print('Skipping malformed item in sync: $key, error: $e');
          }
        }
      });
      return result;
    }

    if (data is List) {
      final result = <String, T>{};
      for (int i = 0; i < data.length; i++) {
        if (data[i] != null) {
          try {
             result[i.toString()] = convert(data[i]);
          } catch (e) {
             print('Skipping malformed item in sync list index: $i, error: $e');
          }
        }
      }
      return result;
    }

    return {};
  }
}
