import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../util/image_utils.dart';

/// Load logo from Base64 string or file path (native only).
pw.MemoryImage? loadLogoImage(String logoPath) {
  if (logoPath.isEmpty) return null;

  // Try Base64 first
  if (ImageUtils.isBase64Image(logoPath)) {
    try {
      final bytes = base64Decode(logoPath);
      return pw.MemoryImage(bytes);
    } catch (_) {}
  }

  // Try file path
  final file = File(logoPath);
  if (file.existsSync()) {
    return pw.MemoryImage(file.readAsBytesSync());
  }

  return null;
}

/// Share document: save to temp, rasterize to PNG, share via SharePlus.
Future<void> shareDocument(Uint8List bytes, String filename) async {
  final tempDir = await getTemporaryDirectory();
  final pdfFile = File('${tempDir.path}/$filename.pdf');
  await pdfFile.writeAsBytes(bytes);

  // Rasterize for sharing as PNG
  final filesToShare = <XFile>[];
  await for (final page in Printing.raster(bytes, pages: [0], dpi: 200)) {
    final pngBytes = await page.toPng();
    final pngFile = File('${tempDir.path}/$filename.png');
    await pngFile.writeAsBytes(pngBytes);
    filesToShare.add(XFile(pngFile.path));
    break;
  }

  if (filesToShare.isNotEmpty) {
    await Share.shareXFiles(filesToShare, text: filename);
  } else {
    await Printing.sharePdf(bytes: bytes, filename: '$filename.pdf');
  }
}
