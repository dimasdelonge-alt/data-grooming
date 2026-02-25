import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:web/web.dart' as web;

/// Web stub: no file system access, return null for logo.
pw.MemoryImage? loadLogoImage(String logoPath) {
  return null;
}

/// Check if Web Share API with file sharing is available.
bool _canShareFiles() {
  try {
    final nav = web.window.navigator as JSObject;
    return nav.has('share');
  } catch (_) {
    return false;
  }
}

/// Try sharing via Web Share API (shows native share sheet on PWA).
Future<bool> _tryWebShare(Uint8List pngBytes, String filename) async {
  try {
    final file = web.File(
      [pngBytes.toJS].toJS,
      '$filename.png',
      web.FilePropertyBag(type: 'image/png'),
    );
    final shareData = web.ShareData(
      files: [file].toJS,
    );
    await web.window.navigator.share(shareData).toDart;
    return true;
  } catch (e) {
    debugPrint('Web Share API failed: $e');
    return false;
  }
}

/// Fallback: trigger browser download for the given blob.
void _downloadBlob(web.Blob blob, String downloadName) {
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = downloadName;
  anchor.style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  web.document.body?.removeChild(anchor);
  web.URL.revokeObjectURL(url);
}

/// Web: rasterize PDF to PNG, then share via Web Share API or download.
Future<void> shareDocument(Uint8List bytes, String filename) async {
  try {
    // Rasterize first page to PNG
    await for (final page in Printing.raster(bytes, pages: [0], dpi: 200)) {
      final pngBytes = await page.toPng();

      // Try Web Share API first (native share sheet on PWA)
      if (_canShareFiles()) {
        final shared = await _tryWebShare(pngBytes, filename);
        if (shared) return;
      }

      // Fallback: download as PNG
      final blob = web.Blob(
        [pngBytes.toJS].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );
      _downloadBlob(blob, '$filename.png');
      return;
    }
    // If raster stream was empty, fall through to PDF fallback
    debugPrint('Raster stream empty, falling back to PDF');
  } catch (e) {
    debugPrint('PNG rasterization failed: $e');
  }

  // Final fallback: download as PDF
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  _downloadBlob(blob, '$filename.pdf');
}

