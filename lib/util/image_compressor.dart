
// Conditional imports: dart:io is not available on web
import 'image_compressor_native.dart'
    if (dart.library.js_interop) 'image_compressor_web.dart' as platform;

class ImageCompressor {
  /// Compress an image at [path] and return Base64-encoded JPEG string.
  static Future<String?> compressImage(
    String path, {
    int maxDimension = 200,
    int quality = 50,
  }) async {
    return platform.compressImage(path, maxDimension: maxDimension, quality: quality);
  }

  /// Save a Base64-encoded image to app files directory and return the path.
  static Future<String?> saveImageFromBase64(
      String base64Str, String fileName) async {
    return platform.saveImageFromBase64(base64Str, fileName);
  }
}
