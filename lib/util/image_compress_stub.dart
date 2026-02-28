import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Stub implementation for non-web platforms.
/// Never called — flutter_image_compress handles native compression.
Future<String?> compressImageOnWeb(
  Uint8List bytes, {
  int maxWidth = 400,
  int maxHeight = 400,
  double quality = 0.65,
}) async {
  return base64Encode(bytes);
}
