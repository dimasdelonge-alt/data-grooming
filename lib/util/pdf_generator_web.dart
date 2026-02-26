import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:web/web.dart' as web;

/// Web stub: no file system access, return null for logo.
pw.MemoryImage? loadLogoImage(String logoPath) {
  return null;
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

/// Web: rasterize PDF to PNG, then share or download.
Future<void> shareDocument(Uint8List bytes, String filename) async {
  try {
    // Rasterize first page to PNG
    await for (final page in Printing.raster(bytes, pages: [0], dpi: 200)) {
      final pngBytes = await page.toPng();

      try {
        // Try native share capability (WhatsApp, etc) via share_plus
        final xfile = XFile.fromData(
          pngBytes,
          name: '$filename.png',
          mimeType: 'image/png',
        );
        final result = await Share.shareXFiles([xfile], text: filename);
        if (result.status == ShareResultStatus.success) {
          return; // Share succeeded, do not download
        }
      } catch (e) {
        debugPrint('share_plus failed on web: $e');
        // fall through to download fallback if Web Share API isn't supported
      }

      // Download fallback
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

