import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../util/image_utils.dart';
import '../theme/theme.dart';

// Conditional import for web blob URL support
import 'cat_avatar_image_stub.dart'
    if (dart.library.js_interop) 'cat_avatar_image_web.dart' as platform_image;

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
        if (kIsWeb) {
          // Web: use Blob URL to bypass data URI size limits on mobile browsers
          avatar = ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: platform_image.buildWebImage(
              base64String: imagePath!,
              width: size,
              height: size,
              fallback: _fallback(isDark),
            ),
          );
        } else {
          // Native: use Image.memory as before
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
        }
      } else {
        // Non-Base64 path (legacy) — show fallback
        avatar = _fallback(isDark);
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
