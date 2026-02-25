import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// COLOR PALETTE
// ═══════════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ── Light Mode — Sky Blue ───────────────────────────────────────────────
  static const Color lightPrimary = Color(0xFF4FC3F7);
  static const Color lightPrimaryDark = Color(0xFF0288D1);
  static const Color lightGradientStart = Color(0xFF4FC3F7);
  static const Color lightGradientEnd = Color(0xFF81D4FA);
  static const Color lightIconBg = Color(0xFFE1F5FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF5F9FF);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightSecondary = Color(0xFF0288D1);
  static const Color lightSubtext = Color(0xFF6B7280);

  // ── Dark Mode — Colorful on Dark ───────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkDeepBackground = Color(0xFF0F0F1E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFE2E8F0);
  static const Color darkText = Color(0xFFE2E8F0);
  static const Color darkSubtext = Color(0xFF94A3B8);

  // ── Dark Mode Accent Colors ────────────────────────────────────────────
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentYellow = Color(0xFFFBBF24);

  /// Returns rotating accent color based on index (for dark mode grid icons)
  static Color accentByIndex(int index) {
    const accents = [accentPurple, accentBlue, accentGreen, accentYellow];
    return accents[index % accents.length];
  }

  /// Returns light variant of accent color (for icon backgrounds in dark mode)
  static Color accentBgByIndex(int index) {
    return accentByIndex(index).withValues(alpha: 0.15);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// THEME DATA
// ═══════════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: AppColors.lightPrimary,
        scaffoldBackgroundColor: AppColors.lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.lightPrimaryDark,
          unselectedItemColor: AppColors.lightSubtext,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightIconBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorSchemeSeed: AppColors.accentBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.accentBlue,
          unselectedItemColor: AppColors.darkSubtext,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );
}
