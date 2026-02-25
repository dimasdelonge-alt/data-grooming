import 'package:flutter/material.dart';
import '../theme/theme.dart';

// Conditional import for dart:io File
import 'cat_avatar_native.dart' if (dart.library.js_interop) 'cat_avatar_web.dart' as platform;

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
      avatar = platform.buildFileImage(
        imagePath: imagePath!,
        size: size,
        fallback: _fallback(isDark),
      );
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
