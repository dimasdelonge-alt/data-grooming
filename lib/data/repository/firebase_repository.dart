import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entity/cat.dart';
import '../entity/session.dart';
import '../entity/hotel_entities.dart';
import '../entity/booking.dart';
import '../entity/grooming_service.dart';
import '../entity/expense.dart';
import '../entity/chip_option.dart';
import '../entity/deposit_entities.dart';
import '../model/cloud_sync_data.dart';

class FirebaseRepository {
  static const String _baseUrl =
      'https://smartgroomer-track-default-rtdb.asia-southeast1.firebasedatabase.app';

  // ═══════════════════════════════════════════════════════════════════════════
  // TRACKING STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateTrackingStatus(
    String shopId,
    Session session,
    String catName, {
    List<MapEntry<String, int>> missedHistory = const [],
  }) async {
    if (shopId.isEmpty || session.trackingToken == null) return;

    final trackingData = {
      'status': session.status,
      'updatedAt': session.updatedAt,
      'catName': catName,
      'treatment': session.treatment.join(', '),
      'estimatedCost': session.totalCost,
      'trackingToken': session.trackingToken,
    };

    try {
      // 1. Insert missed history items first
      for (final entry in missedHistory) {
        final historyItem = {
          'status': entry.key,
          'updatedAt': entry.value,
        };
        await http.post(
          Uri.parse(
              '$_baseUrl/$shopId/${session.trackingToken}/history.json'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(historyItem),
        );
      }

      // 2. Update current status (PATCH to avoid overwriting history)
      await http.patch(
        Uri.parse('$_baseUrl/$shopId/${session.trackingToken}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(trackingData),
      );

      // 3. Add current status to history
      final historyItem = {
        'status': session.status,
        'updatedAt': session.updatedAt,
      };
      await http.post(
        Uri.parse(
            '$_baseUrl/$shopId/${session.trackingToken}/history.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(historyItem),
      );
    } catch (e) {
      print('updateTrackingStatus error: $e');
    }
  }

  Future<void> deleteTrackingStatus(
      String shopId, String? trackingToken) async {
    if (shopId.isEmpty || trackingToken == null) return;

    try {
      await http.delete(
        Uri.parse('$_baseUrl/$shopId/$trackingToken.json'),
      );
    } catch (e) {
      print('deleteTrackingStatus error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SYNC METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String?> getSecretKey(String shopId) async {
    if (shopId.isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/credentials/$shopId/secretKey.json'),
      );
      if (response.statusCode == 200) {
        final body = response.body;
        if (body == 'null') return null;
        return body.replaceAll('"', '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setSecretKey(String shopId, String key) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/credentials/$shopId/secretKey.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(key),
      );
    } catch (e) {
      print('setSecretKey error: $e');
    }
  }

  Future<void> syncCat(String shopId, Cat cat) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/cats/${cat.catId}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cat.toMap()),
      );
    } catch (e) {
      print('syncCat error: $e');
    }
  }

  Future<void> syncSession(String shopId, Session session) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse(
            '$_baseUrl/sync/$shopId/sessions/${session.sessionId}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(session.toMap()),
      );
    } catch (e) {
      print('syncSession error: $e');
    }
  }

  Future<void> syncHotelBooking(
      String shopId, HotelBooking booking) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse(
            '$_baseUrl/sync/$shopId/hotel_bookings/${booking.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(booking.toMap()),
      );
    } catch (e) {
      print('syncHotelBooking error: $e');
    }
  }

  Future<void> syncGroomingBooking(
      String shopId, Booking booking) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse(
            '$_baseUrl/sync/$shopId/bookings/${booking.bookingId}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(booking.toMap()),
      );
    } catch (e) {
      print('syncGroomingBooking error: $e');
    }
  }

  Future<void> syncHotelRoom(
      String shopId, HotelRoom room) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/hotel_rooms/${room.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(room.toMap()),
      );
    } catch (e) {
      print('syncHotelRoom error: $e');
    }
  }

  Future<void> syncService(
      String shopId, GroomingService service) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/services/${service.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(service.toMap()),
      );
    } catch (e) {
      print('syncService error: $e');
    }
  }

  Future<void> syncExpense(
      String shopId, Expense expense) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/expenses/${expense.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expense.toMap()),
      );
    } catch (e) {
      print('syncExpense error: $e');
    }
  }

  Future<void> syncHotelAddOn(
      String shopId, HotelAddOn addOn) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/hotel_adds/${addOn.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(addOn.toMap()),
      );
    } catch (e) {
      print('syncHotelAddOn error: $e');
    }
  }

  Future<void> syncChipOption(
      String shopId, ChipOption option) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/chip_options/${option.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(option.toMap()),
      );
    } catch (e) {
      print('syncChipOption error: $e');
    }
  }

  Future<void> syncOwnerDeposit(
      String shopId, OwnerDeposit deposit) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/owner_deposits/${deposit.ownerPhone}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(deposit.toMap()),
      );
    } catch (e) {
      print('syncOwnerDeposit error: $e');
    }
  }

  Future<void> syncDepositTransaction(
      String shopId, DepositTransaction txn) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId/deposit_transactions/${txn.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(txn.toMap()),
      );
    } catch (e) {
      print('syncDepositTransaction error: $e');
    }
  }

  Future<void> deleteFromSync(
      String shopId, String category, String id) async {
    if (shopId.isEmpty) return;
    try {
      await http.delete(
        Uri.parse('$_baseUrl/sync/$shopId/$category/$id.json'),
      );
    } catch (e) {
      print('deleteFromSync error: $e');
    }
  }

  Future<CloudSyncData?> fetchAllSyncData(String shopId) async {
    if (shopId.isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sync/$shopId.json'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null) return null;
        return CloudSyncData.fromMap(decoded as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('fetchAllSyncData error: $e');
      return null;
    }
  }

  Future<void> uploadAllData(
      String shopId, CloudSyncData data) async {
    if (shopId.isEmpty) return;
    try {
      await http.put(
        Uri.parse('$_baseUrl/sync/$shopId.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toMap()),
      );
    } catch (e) {
      print('uploadAllData error: $e');
    }
  }

  Future<void> syncShopIdentity(
      String shopId, String name, String phone, String address) async {
    if (shopId.isEmpty) return;
    try {
      final identity = {
        'shopName': name,
        'shopPhone': phone,
        'shopAddress': address
      };
      await http.put(
        Uri.parse('$_baseUrl/credentials/$shopId/identity.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(identity),
      );
    } catch (e) {
      print('syncShopIdentity error: $e');
    }
  }

  Future<Map<String, String>?> getShopIdentity(String shopId) async {
    if (shopId.isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/credentials/$shopId/identity.json'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null) return null;
        return Map<String, String>.from(decoded as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTION & DEVICE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<SubscriptionStatus> checkSubscriptionStatus(
      String shopId) async {
    const defaultStatus = SubscriptionStatus(
        plan: 'starter', validUntil: 0, maxDevices: 1);
    if (shopId.isEmpty) return defaultStatus;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/credentials/$shopId/subscription.json'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null) return defaultStatus;
        final status = SubscriptionStatus.fromMap(
            decoded as Map<String, dynamic>);
        // Check if expired
        final now = DateTime.now().millisecondsSinceEpoch;
        if (status.validUntil > 0 && now > status.validUntil) {
          return defaultStatus;
        }
        return status;
      }
      return defaultStatus;
    } catch (e) {
      print('checkSubscriptionStatus error: $e');
      return defaultStatus;
    }
  }

  Future<bool> registerDevice(String shopId, String deviceId,
      String deviceName, int maxDevices) async {
    if (shopId.isEmpty || deviceId.isEmpty) return false;

    try {
      // 1. Check if this device is already registered
      final checkResponse = await http.get(
        Uri.parse(
            '$_baseUrl/credentials/$shopId/devices/$deviceId.json'),
      );
      if (checkResponse.statusCode == 200 &&
          checkResponse.body != 'null') {
        // Already registered — still clean up old web entries
        if (deviceId.startsWith('WEB-')) {
          await _cleanupOldWebDevices(shopId, deviceId);
        }
        return true;
      }

      // 2. Clean up old web device entries first (DEV-xxx with 'Web Browser')
      if (deviceId.startsWith('WEB-')) {
        await _cleanupOldWebDevices(shopId, deviceId);
      }

      // 3. Check current device count (after cleanup)
      final devicesResponse = await http.get(
        Uri.parse('$_baseUrl/credentials/$shopId/devices.json'),
      );
      int currentCount = 0;
      if (devicesResponse.statusCode == 200) {
        final decoded = jsonDecode(devicesResponse.body);
        if (decoded is Map) {
          currentCount = decoded.length;
        }
      }

      // 4. Register if under limit
      if (currentCount < maxDevices) {
        final deviceData = {
          'deviceName': deviceName,
          'registeredAt': DateTime.now().millisecondsSinceEpoch,
        };
        await http.put(
          Uri.parse(
              '$_baseUrl/credentials/$shopId/devices/$deviceId.json'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(deviceData),
        );
        return true;
      }
      return false; // Limit reached
    } catch (e) {
      print('registerDevice error: $e');
      return false;
    }
  }

  /// Removes old timestamp-based web device entries (DEV-xxx with deviceName 'Web Browser')
  /// that were created before fingerprint-based IDs (WEB-xxx).
  /// Does NOT remove other WEB- entries, allowing multiple web devices (PC + mobile).
  Future<void> _cleanupOldWebDevices(String shopId, String currentDeviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/credentials/$shopId/devices.json'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final id = entry.key as String;
            final data = entry.value;
            // Only remove old DEV- entries that were web browsers
            if (id != currentDeviceId &&
                id.startsWith('DEV-') &&
                data is Map &&
                data['deviceName'] == 'Web Browser') {
              await http.delete(
                Uri.parse('$_baseUrl/credentials/$shopId/devices/$id.json'),
              );
              print('[DeviceCleanup] Removed old web device: $id');
            }
          }
        }
      }
    } catch (e) {
      print('[DeviceCleanup] Error: $e');
    }
  }

  /// Removes a specific device from Firebase (used on logout/disconnect).
  Future<void> removeDevice(String shopId, String deviceId) async {
    if (shopId.isEmpty || deviceId.isEmpty) return;
    try {
      await http.delete(
        Uri.parse('$_baseUrl/credentials/$shopId/devices/$deviceId.json'),
      );
      print('[Device] Removed device: $deviceId');
    } catch (e) {
      print('[Device] removeDevice error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADMIN PANEL METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> verifyAdminPin(String pin) async {
    if (pin.isEmpty) return false;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin_access/codes/$pin.json'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded == true;
      }
      return false;
    } catch (e) {
      print('verifyAdminPin error: $e');
      return false;
    }
  }

  Future<Map<String, ShopCredentials>?> getAllShopsCredentials() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/credentials.json'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null) return null;
        final map = decoded as Map<String, dynamic>;
        return map.map((key, value) => MapEntry(
            key,
            ShopCredentials.fromMap(value as Map<String, dynamic>)));
      }
      return null;
    } catch (e) {
      print('getAllShopsCredentials error: $e');
      return null;
    }
  }

  Future<bool> updateSubscription(
      String shopId, SubscriptionStatus status) async {
    if (shopId.isEmpty) return false;
    try {
      await http.patch(
        Uri.parse('$_baseUrl/credentials/$shopId/subscription.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(status.toMap()),
      );
      return true;
    } catch (e) {
      print('updateSubscription error: $e');
      return false;
    }
  }
}
