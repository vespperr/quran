import 'package:flutter/material.dart';

import '../models/mushaf_backgrund_model.dart';

/// App Colors
class AppColors {
  AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color white2 = Color(0xFFFCF6E5);
  static const Color white3 = Color(0xFFF1F2F5);
  static const Color pink = Color(0xFFFCE9E9);
  static const Color white5 = Color(0xFFD9D9D9);
  static const Color grey = Color(0xFFD1D1D1);
  static const Color grey2 = Color(0xFFB4B4B4);
  static const Color grey3 = Color(0xFFA5A5A5);
  static const Color grey4 = Color(0xFFBDBDBD);
  static const Color grey5 = Color(0xFF9A9A9A);
  static const Color grey6 = Color(0xFF797979);
  static const Color grey7 = Color(0xFF707070);
  static const Color grey8 = Color(0xFF6B6B6B);
  static const Color grey9 = Color(0xFF4D4D4D);
  static const Color grey10 = Color(0xFF353535);
  static const Color grey11 = Color(0xFF666666);
  static const Color grey12 = Color(0xFFB6B9C3);
  static const Color grey13 = Color(0xFFD9DADD);
  static const Color greyText = Color(0xFF323640);
  static const Color black11 = Color(0xFF262626);
  static const Color black10 = Color(0xFF1D1D1D);
  static const Color black9 = Color(0xFF424242);
  static const Color black8 = Color(0xFF393939);
  static const Color black7 = Color(0xFF363636);
  static const Color black6 = Color(0xFF2E2E2E);
  static const Color black5 = Color(0xFF232323);
  static const Color black4 = Color(0xFF202020);
  static const Color black3 = Color(0xFF1A1A1A);
  static const Color black2 = Color(0xFF181818);
  static const Color black1 = Color(0xFF111111);
  static const Color black = Color(0xFF010101);
  static const Color oasis = Color(0xFFFFF1CA);
  static const Color oil = Color(0xFF261A1A);
  static const Color reddish = Color(0xFFC84646);
  static const Color zeus = Color(0xFF26211A);
  static const Color brandy = Color(0xFFE3BE92);
  static const Color redOrange = Color(0xFFFF3B30);
  static const Color redDark = Color(0xFF923131);

  // ---- Premium design system (Material green 600) ----
  /// Primary — headers, primary actions, selected tab (#43A047)
  static const Color primary = Color(0xFF43A047);
  /// Primary variant — pressed / darker states (#2E7D32)
  static const Color primaryVariant = Color(0xFF2E7D32);
  /// Secondary — accents only: search, favorite when active (#4F46E5)
  static const Color secondary = Color(0xFF4F46E5);
  /// Background — scaffold / canvas (#FAFAF9)
  static const Color background = Color(0xFFFAFAF9);
  /// Surface — cards, app bar, bottom nav (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);
  /// On background — primary UI text (#1C1917)
  static const Color onBackground = Color(0xFF1C1917);
  /// On surface — text on cards (#1C1917)
  static const Color onSurface = Color(0xFF1C1917);
  /// On primary — text on primary buttons (#FFFFFF)
  static const Color onPrimary = Color(0xFFFFFFFF);
  /// Outline — dividers, light borders (#E7E5E4)
  static const Color outline = Color(0xFFE7E5E4);
  /// Outline variant — disabled borders (#D6D3D1)
  static const Color outlineVariant = Color(0xFFD6D3D1);
  /// Error — errors only (#B91C1C)
  static const Color error = Color(0xFFB91C1C);

  // ---- Legacy aliases (design system uses these; point to premium tokens) ----
  static const Color canvasBackground = background;
  static const Color primaryGreen = primary;
  static const Color warningRed = error;
  static const Color cardBackground = surface;
  static const Color textForest = onSurface;
  static const Color iconGreen = primary;
  /// For mushaf / theme options only
  static const Color palettePrimary = Color(0xFF4E56C0);
  static const Color paletteSecondary = Color(0xFF9B5DE0);
  static const Color paletteTertiary = Color(0xFFD78FEE);
  static const Color paletteSurface = Color(0xFFFDCFFA);

  // Light theme — mint green palette (legacy; aligns with [primary])
  /// Very light mint green background (#F0FCF0)
  static const Color surfaceCream = Color(0xFFF0FCF0);
  /// Primary green accents (#43A047)
  static const Color accentGreen = Color(0xFF43A047);
  /// Header / title green (same family)
  static const Color accentGreenTitle = Color(0xFF43A047);
  /// Lighter green for subtitles (#66BB6A)
  static const Color accentGreenSecondary = Color(0xFF66BB6A);
  /// Dark gray for body text (#333333)
  static const Color textDark = Color(0xFF333333);

  // Thikr / Dhikr card style (mint green cards)
  static const Color thikrCardBackground = Color(0xFFE8F5E9);
  static const Color thikrTitleGreen = Color(0xFF43A047);
  static const Color thikrSubtitleGreen = Color(0xFF66BB6A);
  static const Color thikrIconGreen = Color(0xFF43A047);

  /// Royal palette — settings panel / bottom sheets (deep purple-indigo)
  static const Color royalSurface = Color(0xFF252038);
  static const Color royalAccent = Color(0xFF6B5B95);
  /// Lighter surface for cards/buttons on royal so they stand out
  static const Color royalCard = Color(0xFF3D3552);
  static const Color royalOnSurface = Color(0xFFE8E6ED);

  /// Surah details page theme model list (first = app design system primary)
  static List<SurahDetailsPageThemeModel> mushafColors = [
    SurahDetailsPageThemeModel(
      backgroundColor: surfaceCream,
      switchSelectColor: primary,
      switchUnselectTextColor: accentGreenSecondary,
      switchBackgroundColor: const Color(0xFFE0F2E4),
      titleVectorColor: textDark,
      textColor: textDark,
      transparentVectorColor: accentGreenSecondary,
      transparentTextColor: accentGreenSecondary,
    ),
    SurahDetailsPageThemeModel(
      backgroundColor: const Color(0xFFFFF1CA),
      switchSelectColor: const Color(0xFFE0CCA8),
      switchUnselectTextColor: const Color(0xFFB39B74),
      switchBackgroundColor: const Color(0xFFF2E0C1),
      titleVectorColor: const Color(0xFF4D4D4D),
      textColor: const Color(0xFF2B1F0D),
      transparentVectorColor: const Color(0xFFE0CCA8),
      transparentTextColor: const Color(0xFFE0CCA8),
    ),
    SurahDetailsPageThemeModel(
      backgroundColor: const Color(0xFFF1F2F5),
      switchSelectColor: const Color(0xFFB6B9C3),
      switchUnselectTextColor: const Color(0xFF93959A),
      switchBackgroundColor: const Color(0xFFD9DADD),
      titleVectorColor: const Color(0xFF4D4D4D),
      textColor: const Color(0xFF323640),
      transparentVectorColor: const Color(0xFFBCC1D0),
      transparentTextColor: const Color(0xFFBCC1D0),
    ),
    SurahDetailsPageThemeModel(
      backgroundColor: const Color(0xFF111111),
      switchSelectColor: const Color(0xFF1A1A1A),
      switchUnselectTextColor: const Color(0xFFA5A5A5),
      switchBackgroundColor: const Color(0xFF010101),
      titleVectorColor: const Color(0xFF4D4D4D),
      textColor: const Color(0xFFD1D1D1),
      transparentVectorColor: const Color(0xFFA8A2A2),
      transparentTextColor: const Color(0xFFA8A2A2),
    ),
    SurahDetailsPageThemeModel(
      backgroundColor: const Color(0xFFFCE9E9),
      switchSelectColor: const Color(0xFFC0AFAF),
      switchUnselectTextColor: const Color(0xFF9D9595),
      switchBackgroundColor: const Color(0xFFE2D3D3),
      titleVectorColor: const Color(0xFF4D4D4D),
      textColor: const Color(0xFF4D4141),
      transparentVectorColor: const Color(0xFFA8A2A2),
      transparentTextColor: const Color(0xFFA8A2A2),
    )
  ];
}
