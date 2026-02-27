import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  /// Compresses an image from the given path and returns it as a Base64 encoded string.
  /// This optimizes storage space and allows the image to be easily saved in
  /// local database or Firebase RTD as text, supporting offline cross-platform (Web & App) loading.
  static Future<String?> compressAndEncodeImage(String imagePath, {int minWidth = 400, int minHeight = 400, int quality = 65}) async {
    try {
      if (kIsWeb) {
         // In Flutter Web, image_picker usually returns a blob URL which cannot be read as a File by flutter_image_compress directly.
         // Web images are often already low size or we rely on XHR to load them as bytes.
         // For now, if we receive a path on web, we must warn that web requires picking image as bytes.
         print('Warning: Web requires bytes for compression. Use XFile.readAsBytes() instead.');
         return null; 
      }

      final file = File(imagePath);
      if (!file.existsSync()) return null;

      final resultBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
      );

      if (resultBytes == null) return null;

      // Encode the compressed bytes to Base64 String
      return base64Encode(resultBytes);

    } catch (e) {
      debugPrint("Error compressing image: $e");
      return null;
    }
  }

  /// Compresses image directly from bytes (Useful for Web platform).
  static Future<String?> compressAndEncodeFromBytes(Uint8List bytes, {int minWidth = 400, int minHeight = 400, int quality = 65}) async {
    try {
      final resultBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
      );

      return base64Encode(resultBytes);
    } catch (e) {
      debugPrint("Error compressing bytes: $e");
      // Fallback: If compression fails (e.g., unsupported format on some web browsers), just encode raw bytes.
      return base64Encode(bytes);
    }
  }

  /// Checks if a given string is likely a Base64 encoded image string
  /// rather than a traditional local file path.
  static bool isBase64Image(String path) {
    // Base64 strings are usually long, and local paths often contain '/' or '\'
    // Exception: Base64 won't contain standard path separators.
    if (path.isEmpty) return false;
    if (path.contains('/') || path.contains('\\')) {
       // It's likely an absolute path like /data/user/0/... or C:\Users\...
       // Or even a web blob URL blob:http://...
       return false;
    }
    // Very likely a Base64 string if it doesn't contain path separators and is somewhat long
    return path.length > 100;
  }
}
