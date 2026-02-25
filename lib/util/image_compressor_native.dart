import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> compressImage(
  String path, {
  int maxDimension = 200,
  int quality = 50,
}) async {
  try {
    final file = File(path);
    if (!await file.exists()) return null;

    final bytes = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
    );

    if (bytes == null) return null;
    return base64Encode(bytes);
  } catch (e) {
    debugPrint('compressImage error: $e');
    return null;
  }
}

Future<String?> saveImageFromBase64(String base64Str, String fileName) async {
  try {
    final Uint8List bytes = base64Decode(base64Str);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  } catch (e) {
    debugPrint('saveImageFromBase64 error: $e');
    return null;
  }
}
