import 'package:flutter/material.dart';
import 'package:the_open_quran/l10n/app_localizations.dart';

import 'enums.dart';

extension EThemeModesExtension on EThemeModes {
  /// Getting [EThemeModes] names
  String name(BuildContext context) {
    switch (this) {
      case EThemeModes.light:
        return context.translate.lightMode;
      case EThemeModes.dark:
        return context.translate.darkMode;
      case EThemeModes.quran:
        return context.translate.quranMode;
      case EThemeModes.green:
        return context.translate.greenMode;
    }
  }
}

extension ESupportedLanguageExtension on ESupportedLanguage {
  /// Getting [ESupportedLanguage] titles
  String title(BuildContext context) {
    switch (this) {
      case ESupportedLanguage.en:
        return context.translate.english;
      case ESupportedLanguage.ar:
        return context.translate.arabic;
      case ESupportedLanguage.ku:
        return context.translate.kurdish;
    }
  }
}

extension BuildContextExtension on BuildContext {
  /// Helping function to translate the text
  AppLocalizations get translate {
    return AppLocalizations.of(this)!;
  }

  /// Helping function to get the [theme]
  ThemeData get theme {
    return Theme.of(this);
  }
}

/// Localized display name for prayer (Fajr, Dhuhr, Asr, Maghrib, Isha).
extension PrayerNameExtension on String {
  String translatedPrayerName(BuildContext context) {
    final t = context.translate;
    switch (this) {
      case 'Fajr':
        return t.prayerFajr;
      case 'Dhuhr':
        return t.prayerDhuhr;
      case 'Asr':
        return t.prayerAsr;
      case 'Maghrib':
        return t.prayerMaghrib;
      case 'Isha':
        return t.prayerIsha;
      default:
        return this;
    }
  }
}

extension IntExtension on int {
  String get quranPageNumber {
    if (toString().length > 1) return toString();
    return "0$this";
  }
}

extension BoolExtension on bool {
  int get getNumber {
    return this ? 1 : 0;
  }
}
