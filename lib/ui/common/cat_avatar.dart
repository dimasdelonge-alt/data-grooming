import 'dart:convert';
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
          print('[CatAvatar] Decoded ${bytes.length} bytes from base64 (length=${imagePath!.length})');
          avatar = ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.memory(
              Uint8List.fromList(bytes),
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, error, ___) {
                print('[CatAvatar] ❌ Image.memory error: $error');
                return _fallback(isDark);
              },
            ),
          );
        } catch (e) {
          print('[CatAvatar] ❌ base64Decode error: $e');
          avatar = _fallback(isDark);
        }
      } else {
        print('[CatAvatar] Not base64, imagePath starts with: ${imagePath!.substring(0, imagePath!.length > 30 ? 30 : imagePath!.length)}');
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
