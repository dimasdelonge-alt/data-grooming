import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

// Conditional import for web fingerprint
import 'device_id_stub.dart'
    if (dart.library.js_interop) 'device_id_web.dart' as platform_id;

class DeviceIdHelper {
  /// Returns a device ID.
  /// - Web: deterministic from browser fingerprint (survives clear data)
  /// - Native: timestamp-based (stable in native storage)
  static String generateDeviceId() {
    if (kIsWeb) {
      final fingerprint = platform_id.getBrowserFingerprint();
      final hash = sha256.convert(utf8.encode(fingerprint)).toString();
      return 'WEB-${hash.substring(0, 8)}';
    }
    return 'DEV-${DateTime.now().millisecondsSinceEpoch}';
  }
}
