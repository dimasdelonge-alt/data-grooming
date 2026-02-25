import 'package:flutter/foundation.dart';

/// Web stub: image compression is not supported on web.
Future<String?> compressImage(
  String path, {
  int maxDimension = 200,
  int quality = 50,
}) async {
  debugPrint('compressImage: not supported on web');
  return null;
}

/// Web stub: file saving is not supported on web.
Future<String?> saveImageFromBase64(String base64Str, String fileName) async {
  debugPrint('saveImageFromBase64: not supported on web');
  return null;
}
