import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/image_utils.dart';
import '../theme/theme.dart';

class CatAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  final VoidCallback? onTap;

  const CatAvatar({
    super.key,
    this.imagePath,
    this.size = 64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatar;

    if (imagePath != null && imagePath!.isNotEmpty) {
      if (ImageUtils.isBase64Image(imagePath!)) {
        try {
          final bytes = base64Decode(imagePath!);
          avatar = ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(isDark),
            ),
          );
        } catch (e) {
          avatar = _fallback(isDark);
        }
      } else {
        // Fallback for old local file paths
        if (!kIsWeb) {
          final file = File(imagePath!);
          if (file.existsSync()) {
            avatar = ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.file(
                file,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(isDark),
              ),
            );
          } else {
            avatar = _fallback(isDark);
          }
        } else {
           // On web, traditional file paths from Android won't work anyway
           avatar = _fallback(isDark);
        }
      }
    } else {
      avatar = _fallback(isDark);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _fallback(bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.accentPurple, AppColors.accentBlue]
              : [AppColors.lightPrimary, AppColors.lightPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.pets_rounded,
        size: size * 0.45,
        color: Colors.white,
      ),
    );
  }
}
