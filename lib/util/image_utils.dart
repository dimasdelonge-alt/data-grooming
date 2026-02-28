import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// Conditional import for web compression
import 'image_compress_stub.dart'
    if (dart.library.js_interop) 'image_compress_web.dart' as web_compress;

class ImageUtils {

  /// Compresses image from bytes and returns Base64 string.
  /// On Web: uses HTML Canvas to resize & convert to JPEG.
  /// On Native: uses flutter_image_compress.
  static Future<String?> compressAndEncodeFromBytes(Uint8List bytes, {int minWidth = 400, int minHeight = 400, int quality = 65}) async {
    try {
      if (kIsWeb) {
        // Use Canvas-based compression on web
        return await web_compress.compressImageOnWeb(
          bytes,
          maxWidth: minWidth,
          maxHeight: minHeight,
          quality: quality / 100.0,
        );
      }

      // Native: compress then encode
      final resultBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
      );

      return base64Encode(resultBytes);
    } catch (e) {
      debugPrint("Error compressing bytes: $e");
      // Fallback: encode raw bytes
      return base64Encode(bytes);
    }
  }

  /// Checks if a given string is likely a Base64 encoded image string
  /// rather than a traditional local file path.
  static bool isBase64Image(String path) {
    if (path.isEmpty) return false;
    // Check if it looks like a file path or URL
    if (path.startsWith('/') ||           // Unix absolute path: /data/user/...
        path.startsWith('file:') ||       // file:// URI
        path.startsWith('blob:') ||       // Web blob URL
        path.startsWith('http') ||        // http or https URL
        RegExp(r'^[A-Za-z]:\\').hasMatch(path)) {  // Windows path: C:\Users\...
      return false;
    }
    // If it's long and doesn't look like a path, it's likely base64
    return path.length > 100;
  }
}
