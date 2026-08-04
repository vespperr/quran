import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Provides [MaterialLocalizations] for locale `ku` (Kurdish) by loading
/// English, since Flutter does not ship Material localizations for Kurdish.
/// App strings still use [AppLocalizations] in Kurdish.
class KuMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KuMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}
