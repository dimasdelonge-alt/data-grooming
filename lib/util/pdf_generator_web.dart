import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Web stub: no file system access, return null for logo.
pw.MemoryImage? loadLogoImage(String logoPath) {
  return null;
}

/// Web: use Printing.sharePdf directly (no temp file needed).
Future<void> shareDocument(Uint8List bytes, String filename) async {
  await Printing.sharePdf(bytes: bytes, filename: '$filename.pdf');
}
