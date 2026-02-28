import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Web implementation: generates a deterministic fingerprint from browser properties.
/// Same device + same browser = same fingerprint, even after clearing data.
String getBrowserFingerprint() {
  final nav = web.window.navigator;
  final screen = web.window.screen;

  final parts = [
    nav.userAgent,
    '${screen.width}x${screen.height}',
    nav.language,
    nav.platform,
    '${screen.colorDepth}',
    '${nav.hardwareConcurrency}',
  ];

  return parts.join('|');
}
