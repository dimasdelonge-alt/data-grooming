import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web implementation: creates a Blob URL from Base64 data and uses Image.network().
/// This bypasses the data URI size limit that causes Image.memory() to fail on
/// mobile browsers (Safari iOS, Chrome Android PWA).
Widget buildWebImage({
  required String base64String,
  required double width,
  required double height,
  required Widget fallback,
}) {
  try {
    final bytes = base64Decode(base64String);
    final blobUrl = _createBlobUrl(Uint8List.fromList(bytes));

    return _BlobImage(
      blobUrl: blobUrl,
      width: width,
      height: height,
      fallback: fallback,
    );
  } catch (e) {
    return fallback;
  }
}

String _createBlobUrl(Uint8List bytes) {
  final jsArray = bytes.toJS;
  final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'image/jpeg'));
  return web.URL.createObjectURL(blob);
}

/// StatefulWidget that manages the lifecycle of a Blob URL.
/// Revokes the URL on dispose to prevent memory leaks.
class _BlobImage extends StatefulWidget {
  final String blobUrl;
  final double width;
  final double height;
  final Widget fallback;

  const _BlobImage({
    required this.blobUrl,
    required this.width,
    required this.height,
    required this.fallback,
  });

  @override
  State<_BlobImage> createState() => _BlobImageState();
}

class _BlobImageState extends State<_BlobImage> {
  @override
  void dispose() {
    try {
      web.URL.revokeObjectURL(widget.blobUrl);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.blobUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => widget.fallback,
    );
  }
}
