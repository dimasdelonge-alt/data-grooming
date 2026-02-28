import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Web implementation: Compresses and resizes images using HTML Canvas API.
/// Converts any image format (HEIC, PNG, WebP) to JPEG at the specified quality.
Future<String?> compressImageOnWeb(
  Uint8List bytes, {
  int maxWidth = 400,
  int maxHeight = 400,
  double quality = 0.65,
}) async {
  try {
    // 1. Create a Blob from the raw bytes
    final jsArray = bytes.toJS;
    final blob = web.Blob([jsArray].toJS);
    final blobUrl = web.URL.createObjectURL(blob);

    // 2. Load into an HTMLImageElement
    final img = web.HTMLImageElement();
    final completer = Completer<void>();

    img.onLoad.first.then((_) => completer.complete());
    img.onError.first.then((_) => completer.completeError('Failed to load image'));
    img.src = blobUrl;

    await completer.future;

    // 3. Calculate target dimensions (maintain aspect ratio)
    int srcWidth = img.naturalWidth;
    int srcHeight = img.naturalHeight;

    double scale = 1.0;
    if (srcWidth > maxWidth || srcHeight > maxHeight) {
      scale = (maxWidth / srcWidth).clamp(0.0, 1.0);
      final scaleH = (maxHeight / srcHeight).clamp(0.0, 1.0);
      if (scaleH < scale) scale = scaleH;
    }

    final targetWidth = (srcWidth * scale).round();
    final targetHeight = (srcHeight * scale).round();

    // 4. Draw onto a Canvas
    final canvas = web.HTMLCanvasElement();
    canvas.width = targetWidth;
    canvas.height = targetHeight;

    final ctx = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
    ctx.drawImage(img, 0, 0, targetWidth.toDouble(), targetHeight.toDouble());

    // 5. Export as JPEG with quality
    final dataUrl = canvas.toDataURL('image/jpeg', quality.toJS);

    // 6. Clean up
    web.URL.revokeObjectURL(blobUrl);

    // 7. Extract Base64 from data URL (remove "data:image/jpeg;base64," prefix)
    final base64Data = dataUrl.split(',').last;
    return base64Data;
  } catch (e) {
    debugPrint('Web image compression error: $e');
    // Fallback: encode raw bytes
    return base64Encode(bytes);
  }
}
