import 'package:flutter/material.dart';

import 'colors.dart';
import 'design_system.dart';

/// Design tokens for non-Quran screens (Settings, Prayer Times, Thikr, Language,
/// Help, References) — design system: 20px radius, 16px padding, soft glow.
class NonQuranStyle {
  NonQuranStyle._();

  // ---- Card & layout ----
  static const double cardRadiusLarge = DesignSystem.cornerRadius;
  static const double cardRadiusMedium = 14.0;
  static const double cardRadiusSmall = 12.0;

  static const double screenPaddingH = DesignSystem.screenPadding;
  static const double screenPaddingV = DesignSystem.screenPadding;

  // ---- Active / done state ----
  static Color get activeBackground => DesignSystem.primaryGreen;
  static Color get activeText => AppColors.white;

  // ---- Unselected / secondary ----
  static Color get unselectedBackground => DesignSystem.canvasBackground;
  static Color get unselectedText => DesignSystem.textForest;

  // ---- Inactive ----
  static Color get inactiveBackground => AppColors.grey12.withValues(alpha: 0.5);
  static Color get inactiveText => AppColors.white;

  // ---- Section cards ----
  static Color get sectionCardBackground => DesignSystem.cardBackground;
  /// Shadow color for section cards (use with alpha, e.g. .withValues(alpha: 0.06)).
  static Color get sectionCardShadow => DesignSystem.textForest;
  static Color get sectionTitleColor => DesignSystem.primaryGreen;
  static Color get sectionSubtitleColor => DesignSystem.textForest;
  static Color get sectionAccentColor => DesignSystem.iconGreen;
  static Color get sectionAccentTertiary => AppColors.paletteTertiary;

  // ---- Expandable ----
  static Color get expandableIconColor => DesignSystem.primaryGreen;
  static const double expandableIconSize = 28.0;

  // ---- Shared decoration (soft glow on white cards) ----
  static BoxDecoration sectionCardDecoration() {
    return BoxDecoration(
      color: sectionCardBackground,
      borderRadius: BorderRadius.circular(cardRadiusLarge),
      boxShadow: DesignSystem.softGlowShadow,
    );
  }

  static BoxDecoration listItemCardDecoration() {
    return BoxDecoration(
      color: DesignSystem.cardBackground,
      borderRadius: BorderRadius.circular(cardRadiusMedium),
      boxShadow: DesignSystem.softGlowShadow,
      border: Border.all(
        color: sectionAccentColor.withValues(alpha: 0.15),
        width: 1,
      ),
    );
  }
}
