import 'package:flutter/material.dart';

import '../constants/enums.dart';

class HomeProvider extends ChangeNotifier {
  /// Home Screen Context
  // ignore: unused_field
  final BuildContext _context;

  /// Juz List Type [EJuzListType]
  EJuzListType juzListType = EJuzListType.list;

  /// Home juz and surah toggle buttons (default: show surah list)
  EJuzSurahToggleOptions juzSurahToggleOptionType = EJuzSurahToggleOptions.surah;

  /// Change type Juz, Surah or Search
  void changeJuzOrSurahToggleOptionType(EJuzSurahToggleOptions newOptionType) {
    juzSurahToggleOptionType = newOptionType;
    notifyListeners();
  }

  /// Change type Grid or List
  void changeJuzListType(EJuzListType newListType) {
    juzListType = newListType;
    notifyListeners();
  }

  /// Class Constructor
  HomeProvider(this._context);
}
