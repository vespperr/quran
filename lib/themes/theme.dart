import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/design_system.dart';
import '../constants/fonts.dart';

/// Card theme data (premium: surface, soft shadow, radius 20).
CardThemeData get _cardThemeData => CardThemeData(
  color: DesignSystem.surface,
  elevation: 0,
  shadowColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
  ),
);

/// Theme — premium: primary #43A047, secondary #4F46E5, background #FAFAF9, surface white.
ThemeData get theme => themeForLocale(null);

/// Theme for [locale]: uses appropriate font families for Arabic (ar), Kurdish (ku), or English.
ThemeData themeForLocale(Locale? locale) {
  final lang = locale?.languageCode;
  final isKurdish = lang == 'ku';
  final isArabic = lang == 'ar';

  final String fontFamily = isKurdish
      ? Fonts.kurdish
      : isArabic
          ? Fonts.cairo
          : Fonts.appSans;

  return ThemeData(
    useMaterial3: true,
    appBarTheme: _appBarTheme,
    bottomNavigationBarTheme: _bottomNavigationBarThemeData,
    tabBarTheme: _tabBarThemeData,
    cardColor: DesignSystem.surface,
    cardTheme: _cardThemeData,
    sliderTheme: _sliderThemeData,
    toggleButtonsTheme: _toggleButtonsThemeData,
    drawerTheme: _drawerThemeData,
    primaryColor: DesignSystem.primary,
    colorScheme: ColorScheme.light(
      primary: DesignSystem.primary,
      onPrimary: DesignSystem.onPrimary,
      primaryContainer: DesignSystem.primaryVariant,
      surface: DesignSystem.surface,
      onSurface: DesignSystem.onSurface,
      surfaceContainerHighest: DesignSystem.background,
      error: DesignSystem.warningRed,
      onError: AppColors.white,
      outline: DesignSystem.outline,
      outlineVariant: DesignSystem.outlineVariant,
    ),
    scaffoldBackgroundColor: DesignSystem.background,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    fontFamily: fontFamily,
    dividerColor: DesignSystem.outline,
    textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: DesignSystem.onSurface,
    ),
    displayMedium: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: DesignSystem.primary,
    ),
    displaySmall: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: DesignSystem.onSurface,
    ),
    headlineLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: DesignSystem.onSurface,
    ),
    headlineMedium: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: DesignSystem.onSurface,
    ),
    headlineSmall: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: DesignSystem.onSurface,
    ),
    titleLarge: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: DesignSystem.onSurface,
    ),
    titleMedium: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: DesignSystem.onSurface,
    ),
    titleSmall: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w300,
      color: DesignSystem.onSurface,
    ),
    bodyLarge: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: DesignSystem.onSurface,
    ),
    bodyMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: DesignSystem.onSurface,
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: DesignSystem.onSurface,
    ),
    labelSmall: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: DesignSystem.onSurface,
    ),
    labelMedium: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: DesignSystem.onSurface,
    ),
    labelLarge: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w300,
      color: DesignSystem.onSurface,
    ),
  ).apply(fontFamily: fontFamily),
  );
}

/// [AppBarTheme] AppBar Theme — surface, no gradient
AppBarTheme get _appBarTheme {
  return const AppBarTheme(
    backgroundColor: DesignSystem.surface,
    foregroundColor: DesignSystem.onSurface,
    titleTextStyle: TextStyle(
      color: DesignSystem.primary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(
      color: DesignSystem.onSurface,
    ),
    elevation: 0,
    scrolledUnderElevation: 0,
  );
}

/// [SliderThemeData] Slider Theme Data
SliderThemeData get _sliderThemeData {
  return const SliderThemeData(
    trackHeight: 2,
    thumbColor: DesignSystem.primary,
    activeTrackColor: DesignSystem.primary,
    inactiveTrackColor: DesignSystem.outlineVariant,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 20),
    overlayShape: RoundSliderOverlayShape(
      overlayRadius: 0,
    ),
  );
}

/// [ToggleButtonsThemeData] Toggle Button Theme Data
ToggleButtonsThemeData get _toggleButtonsThemeData {
  return const ToggleButtonsThemeData(
      textStyle: TextStyle(
        color: DesignSystem.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      color: DesignSystem.background,
      selectedColor: DesignSystem.primary,
      disabledColor: DesignSystem.outlineVariant);
}

/// [BottomNavigationBarThemeData] Bottom Navigation Bar Theme Data
BottomNavigationBarThemeData get _bottomNavigationBarThemeData {
  return const BottomNavigationBarThemeData(
    backgroundColor: DesignSystem.surface,
    selectedItemColor: DesignSystem.primary,
    unselectedItemColor: DesignSystem.onSurface,
    elevation: 0,
  );
}

/// [TabBarThemeData] Tab Bar Theme Data
TabBarThemeData get _tabBarThemeData {
  return const TabBarThemeData(
    labelStyle: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: DesignSystem.onSurface),
    indicatorColor: DesignSystem.primary,
  );
}

/// [DrawerThemeData] Drawer Theme Data
DrawerThemeData get _drawerThemeData {
  return const DrawerThemeData(
      backgroundColor: DesignSystem.background,
      scrimColor: Colors.transparent,
      elevation: 0);
}
