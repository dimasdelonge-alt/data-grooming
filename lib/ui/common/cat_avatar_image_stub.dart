import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms.
/// This file is never used on web — cat_avatar_image_web.dart is used instead.
Widget buildWebImage({
  required String base64String,
  required double width,
  required double height,
  required Widget fallback,
}) {
  // Should never be called on non-web platforms
  return fallback;
}
