import 'dart:js_interop';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:web/web.dart' as web;
import 'dart:convert';
import '../util/image_utils.dart';

/// Web: load logo from Base64 string.
pw.MemoryImage? loadLogoImage(String logoPath) {
  if (logoPath.isEmpty) return null;
  if (ImageUtils.isBase64Image(logoPath)) {
    try {
      final bytes = base64Decode(logoPath);
      return pw.MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }
  return null;
}

/// Web: rasterize PDF to PNG, then trigger browser download as image.
Future<void> shareDocument(Uint8List bytes, String filename) async {
  try {
    // Rasterize first page to PNG (same as native)
    await for (final page in Printing.raster(bytes, pages: [0], dpi: 200)) {
      final pngBytes = await page.toPng();

      // Create a Blob from the PNG bytes and trigger download
      final blob = web.Blob(
        [pngBytes.toJS].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );
      final url = web.URL.createObjectURL(blob);

      // Create a temporary anchor element to trigger download
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = '$filename.png';
      anchor.style.display = 'none';
      web.document.body?.appendChild(anchor);
      anchor.click();

      // Cleanup
      web.document.body?.removeChild(anchor);
      web.URL.revokeObjectURL(url);
      break; // Only first page
    }
  } catch (e) {
    // Fallback: download as PDF if rasterization fails
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = '$filename.pdf';
    anchor.style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    web.document.body?.removeChild(anchor);
    web.URL.revokeObjectURL(url);
  }
}
