import 'package:flutter/material.dart';

import 'colors.dart';

/// Design system: layout, shapes, and shared values for the app (Kurdish/Arabic).
class DesignSystem {
  DesignSystem._();

  // ---- Colors (convenience) ----
  static const Color canvasBackground = AppColors.canvasBackground;
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color warningRed = AppColors.warningRed;
  static const Color cardBackground = AppColors.cardBackground;
  static const Color textForest = AppColors.textForest;
  static const Color iconGreen = AppColors.iconGreen;

  // ---- Premium tokens (prefer these in new UI) ----
  static const Color primary = AppColors.primary;
  static const Color primaryVariant = AppColors.primaryVariant;
  static const Color secondary = AppColors.secondary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color onBackground = AppColors.onBackground;
  static const Color onSurface = AppColors.onSurface;
  static const Color onPrimary = AppColors.onPrimary;
  static const Color outline = AppColors.outline;
  static const Color outlineVariant = AppColors.outlineVariant;

  // ---- Spacing scale (4, 8, 12, 16, 20, 24, 32, 40, 48) ----
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // ---- Layout & shapes ----
  /// Corner radius for cards and bottom sheets (20px).
  static const double cornerRadius = 20.0;
  /// Corner radius for buttons and pills (12px).
  static const double radiusPill = 12.0;
  /// Standard padding for screen edges (20px).
  static const double screenPadding = 20.0;
  /// Bottom sheet height as fraction of screen (60%).
  static const double bottomSheetHeightFraction = 0.6;
  /// Grab handle bar height at top of bottom sheet (40px).
  static const double grabHandleHeight = 40.0;

  /// Soft shadow for cards: offset (0, 2), blur 8, opacity 0.06.
  static List<BoxShadow> get shadowSoft => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];
  /// Legacy alias.
  static List<BoxShadow> get softGlowShadow => shadowSoft;

  /// Legacy gradient (avoid for new UI; kept for compatibility).
  static const Color gradientStart = AppColors.palettePrimary;
  static const Color gradientEnd = AppColors.paletteSecondary;

  // ---- Luxury gradient backgrounds ----
  /// Soft luxury gradient: warm white → very light teal (for bottom sheets, overlays).
  static const Color gradientLuxuryStart = Color(0xFFFFFEFB);
  static const Color gradientLuxuryMid = Color(0xFFF7FAF7);
  static const Color gradientLuxuryEnd = Color(0xFFEEF7EE);

  /// Luxury background gradient (top to bottom).
  static const LinearGradient gradientLuxuryBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientLuxuryStart, gradientLuxuryMid, gradientLuxuryEnd],
    stops: [0.0, 0.45, 1.0],
  );

  /// Subtle diagonal luxury gradient (e.g. for screens).
  static const LinearGradient gradientLuxuryDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientLuxuryStart, gradientLuxuryEnd],
  );
}
