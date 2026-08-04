import 'package:flutter/material.dart';

import '../constants/enums.dart';
import '../database/local_db.dart';

class AppSettingsProvider extends ChangeNotifier {
  /// Class constructor
  AppSettingsProvider() {
    var stored = LocalDb.getLocale;
    if (stored?.languageCode == 'tr') {
      appLocale = const Locale('en');
      LocalDb.setLocale('en');
    } else {
      appLocale = stored;
    }
    appThemeMode = LocalDb.getThemeMode;
  }

  /// App Locale
  Locale? appLocale;

  /// App Theme Mode
  late EThemeModes appThemeMode;

  /// Change App Language
  Future<void> changeAppLanguage(String languageCode) async {
    appLocale = await LocalDb.setLocale(languageCode);
    notifyListeners();
  }

  /// Change App Theme
  Future<void> changeAppTheme(EThemeModes themeMode) async {
    appThemeMode = await LocalDb.setThemeMode(themeMode);
    notifyListeners();
  }

  /// Resolved locale for the framework. Use en for tr.
  static Locale? _effectiveLocale(Locale? locale) {
    if (locale == null) return null;
    if (locale.languageCode == 'tr') return const Locale('en');
    return locale;
  }

  /// Get language from device if [null] default to [en]
  Locale? localeResolutionCallback(
      Locale? deviceLocale, Iterable<Locale> supportedLocales) {
    if (appLocale != null) return _effectiveLocale(appLocale);
    if (deviceLocale == null) {
      appLocale = const Locale('en');
      return appLocale;
    }
    for (var locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        appLocale = deviceLocale;
        return _effectiveLocale(deviceLocale);
      }
    }
    appLocale = const Locale('en');
    return appLocale;
  }
}
