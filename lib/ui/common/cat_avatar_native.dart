import 'dart:io';
import 'package:flutter/material.dart';

Widget buildFileImage({
  required String imagePath,
  required double size,
  required Widget fallback,
}) {
  final file = File(imagePath);
  if (!file.existsSync()) return fallback;
  
  return ClipRRect(
    borderRadius: BorderRadius.circular(size / 2),
    child: Image.file(
      file,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    ),
  );
}
