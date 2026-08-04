import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/services/copy_and_share_service.dart';
import 'package:the_open_quran/services/quran_recitation_service.dart';
import 'package:the_open_quran/providers/quran_provider.dart';
import 'package:the_open_quran/providers/search_provider.dart';

import '../database/local_db.dart';
import '../managers/surah_detail_navigation_manager.dart';
import '../models/reading_settings_model.dart';
import '../models/surah_model.dart';
import '../models/verse_model.dart';
import 'app_settings_provider.dart';
import 'bookmark_provider.dart';

class SurahDetailsProvider extends ChangeNotifier {
  /// Class Constructor
  SurahDetailsProvider(this._context, this.readingSettings, EQuranType quranType) {
    quranProvider.changeQuranType(quranType.index);
    getDisplayedSurahs();
    getDisplayedVerses();
    getMushafPageList();
  }

  /// Detail Screen Context
  final BuildContext _context;

  /// Reading settings model
  late ReadingSettingsModel readingSettings;

  /// [bool] checking if latin numbers are displayed in ayah
  bool isLatinNumber = false;

  /// Surah Details page - juz and surah toggle buttons
  EJuzSurahToggleOptions juzSurahToggleOptionType = EJuzSurahToggleOptions.juz;

  /// Juz List Type [EJuzListType]
  EJuzListType juzListType = EJuzListType.list;

  /// Get [QuranProvider]
  QuranProvider get quranProvider => _context.read<QuranProvider>();

  /// Get [AppSettingsProvider]
  AppSettingsProvider get appSettingsProvider => _context.read<AppSettingsProvider>();

  /// List of surahs which are displayed in the [SurahDetailsScreen] in [TranslationScreen]
  List<SurahModel> displayedSurahs = [];

  /// List of verses which are displayed in the [SurahDetailsScreen] in [TranslationScreen]
  List<VerseModel> displayedVerses = [];

  /// List of verses which are displayed in the [SurahDetailsScreen] in [ReadingScreen]
  List<List<SurahModel>> mushafPageList = [];

  /// Key of selected verse which long pressed for showMenu
  String? selectedVerseKey;

  /// Change selectedVerseKey with another selected verse key or null
  void changeSelectedVerseKey(String? selectedVerseKey) {
    this.selectedVerseKey = selectedVerseKey;
    notifyListeners();
  }

  /// Change ayat number from latin to arabic
  void changeAyahNumberStyle() {
    isLatinNumber = !isLatinNumber;
    notifyListeners();
  }

  /// Navigation to the specific verse
  int get jumpToVerseIndex {
    int value = displayedVerses.indexWhere((element) {
      return element.surahId == readingSettings.surahId && element.verseNumber == readingSettings.verseId;
    });
    return value == -1 ? 0 : value;
  }

  /// Navigation to the specific page
  int get jumpToMushafPageListIndex {
    int value = mushafPageList.indexWhere((element) {
      return element.first.verses.first.pageNumber == readingSettings.mushafPageNumber;
    });
    return value == -1 ? 0 : value;
  }

  /// Filters surahs which are going to be displayed in the page
  void getDisplayedSurahs() {
    displayedSurahs = [];
    final surahs = quranProvider.surahs;
    if (surahs.isEmpty) return;
    switch (quranProvider.localSetting.quranType) {
      case EQuranType.translation:
        switch (readingSettings.surahDetailScreenMode) {
          case ESurahDetailScreenMode.surah:
            final index = readingSettings.surahIndex;
            if (index >= 0 && index < surahs.length) {
              displayedSurahs.add(surahs[index]);
            }
            break;
          case ESurahDetailScreenMode.juz:
            List<SurahModel> list = [];
            for (var element in quranProvider.surahs) {
              var surah = element.juzSurahs(readingSettings.juzId);
              if (surah != null) list.add(surah);
            }
            displayedSurahs = list;
        }
        break;
      case EQuranType.reading:
        // When we opened by surah (e.g. tap Al-Furqan), use that surah so we don't show the wrong one when the page is shared (e.g. 359 = end of An-Nur, start of Al-Furqan).
        if (readingSettings.surahDetailScreenMode == ESurahDetailScreenMode.surah &&
            readingSettings.surahId >= 1 &&
            readingSettings.surahId <= 114 &&
            readingSettings.surahId <= surahs.length) {
          displayedSurahs.add(surahs[readingSettings.surahId - 1]);
        } else {
          for (var surah in surahs) {
            for (var verse in surah.verses) {
              if (verse.pageNumber == readingSettings.mushafPageNumber) {
                displayedSurahs.add(surahs[verse.surahId! - 1]);
                return;
              }
            }
          }
        }
        break;
    }
  }

  /// Filters verses which are going to be displayed in the page
  void getDisplayedVerses() {
    List<VerseModel> verses = [];
    for (var element in displayedSurahs) {
      verses = verses + element.verses;
    }
    displayedVerses = verses;
  }

  /// Filters verses which are going to be displayed in the mushaf page
  void getMushafPageList() {
    List<List<SurahModel>> list = [];
    if (displayedVerses.isEmpty) {
      mushafPageList = list;
      return;
    }
    int pageNo = displayedVerses.first.pageNumber ?? 1;
    list.add(getSurahOfMushafPage(pageNo));
    for (var verse in displayedVerses) {
      final p = verse.pageNumber;
      if (p != null && p != pageNo) {
        pageNo = p;
        list.add(getSurahOfMushafPage(pageNo));
      }
    }
    mushafPageList = list;
  }

  /// Filters surahs which are going to be displayed in mushaf page
  List<SurahModel> getSurahOfMushafPage(int pageNo) {
    List<SurahModel> list = [];
    for (var surah in displayedSurahs) {
      var newSurah = surah.surahOfMushafPage(pageNo);
      if (newSurah != null) list.add(newSurah);
    }
    return list;
  }

  /// Listens for the scroll list of the surah details screen
  /// Declares scroll position when it stops on specific surah and ayat
  void listenToTranslationScreenList(int index) {
    var verse = displayedVerses[index];
    if (verse.verseNumber == readingSettings.verseId && verse.surahId == readingSettings.surahId) {
      return;
    }
    readingSettings.surahId = verse.surahId ?? 1;
    readingSettings.verseId = verse.verseNumber ?? 1;
    notifyListeners();
  }

  /// Listens for the scroll position of the surah details screen mushaf page
  /// Declares scroll position when it stops on specific surah and ayat
  void listenToReadingScreenList(int index) {
    var pageNumber = mushafPageList[index].first.verses.first.pageNumber;
    if (pageNumber == readingSettings.mushafPageNumber) {
      return;
    }
    readingSettings.mushafPageNumber = pageNumber ?? 1;
    notifyListeners();
  }

  /// [SurahDetailsScreen] app bar title (Arabic for display with SurahNames font)
  String get appBarTitle {
    switch (quranProvider.localSetting.quranType) {
      case EQuranType.translation:
        return quranProvider.surahs[readingSettings.surahIndex].nameArabic ?? "";
      case EQuranType.reading:
        var index = displayedVerses.indexWhere((element) => element.pageNumber == readingSettings.mushafPageNumber);
        if (index == -1) return "";
        return quranProvider.surahs[displayedVerses[index].surahId! - 1].nameArabic ?? "";
    }
  }

  /// [SurahDetailsScreen] app bar description
  String get appBarDescription {
    VerseModel verse;
    switch (quranProvider.localSetting.quranType) {
      case EQuranType.translation:
        verse = quranProvider.surahs[readingSettings.surahIndex].verses[readingSettings.verseIndex];
        break;
      case EQuranType.reading:
        var index = displayedVerses.indexWhere((element) => element.pageNumber == readingSettings.mushafPageNumber);
        if (index == -1) return "";
        verse = displayedVerses[index];
    }
    return "${_context.translate.juz} ${verse.juzNumber} | ${_context.translate.hizb} ${verse.hizbNumber} - ${_context.translate.page} ${verse.pageNumber}";
  }

  /// [SurahDetailsScreen] app Bar Bookmark is Active
  bool get appBarBookmarkActive {
    int? surahId;
    switch (quranProvider.localSetting.quranType) {
      case EQuranType.translation:
        surahId = quranProvider.surahs[readingSettings.surahIndex].id;
        break;
      case EQuranType.reading:
        var index = displayedVerses.indexWhere((element) => element.pageNumber == readingSettings.mushafPageNumber);
        if (index == -1) surahId = null;
        surahId = quranProvider.surahs[displayedVerses[index].surahId! - 1].id;
    }
    if (surahId == null) return false;
    var bookMarks = LocalDb.getBookmarks;
    var list = bookMarks.where((element) => element.bookmarkType == EBookMarkType.surah).toList();
    var index = list.indexWhere((element) => element.verseModel.surahId == surahId);
    return index == -1 ? false : true;
  }

  /// Change App Bar BookMark Icon State
  Future<void> onTapAppBarBookmarkIcon(bool isActive) async {
    VerseModel? verse;
    switch (quranProvider.localSetting.quranType) {
      case EQuranType.translation:
        verse = quranProvider.surahs[readingSettings.surahIndex].verses[readingSettings.verseIndex];
        break;
      case EQuranType.reading:
        var index = displayedVerses.indexWhere((element) => element.pageNumber == readingSettings.mushafPageNumber);
        if (index != -1) verse = displayedVerses[index];
        break;
    }
    if (verse == null) return;
    if (isActive) {
      await _context.read<BookmarkProvider>().deleteBookmark(verse, EBookMarkType.surah);
    } else {
      await _context.read<BookmarkProvider>().addBookmark(verse, EBookMarkType.surah);
    }
    notifyListeners();
  }

  void onTapSoundIcon(bool isPlaying) {
    QuranRecitationService.stop();
  }

  /// Play or pause verse audio (manifest-driven: bundled demo, cache, or stream).
  void onTapVerseCardPlayOrPause(int index, bool isPlaying) {
    if (index < 0 || index >= displayedVerses.length) return;
    QuranRecitationService.toggleVerse(displayedVerses[index]);
  }

  /// Play The Mushaf Page (no-op; audio removed)
  void playTheMushafPage(bool isPlaying, int surahId) {}

  /// Changing reading style in the home page
  /// EX: [Translation] or [Reading]
  void changeQuranType(int index) {
    quranProvider.changeQuranType(index);
    switch (quranProvider.localSetting.quranType) {
      case EQuranType.translation:
        int index = displayedVerses.indexWhere((element) => element.pageNumber == readingSettings.mushafPageNumber);
        if (index != -1) {
          readingSettings.surahId = displayedVerses[index].surahId ?? 1;
          readingSettings.verseId = displayedVerses[index].verseNumber ?? 1;
        }
        break;
      case EQuranType.reading:
        readingSettings.mushafPageNumber =
            quranProvider.surahs[readingSettings.surahIndex].verses[readingSettings.verseIndex].pageNumber!;
    }
    notifyListeners();
  }

  /// Changing reading mode
  void changeReadingMode() {
    readingSettings.isReadingMode = !readingSettings.isReadingMode;
    if (readingSettings.isReadingMode == true) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
    notifyListeners();
  }

  /// Change type juz, surah or search
  void changeJuzOrSurahToggleOptionType(EJuzSurahToggleOptions newOptionType) {
    juzSurahToggleOptionType = newOptionType;
    notifyListeners();
  }

  /// Change list type in [HomeScreen]
  /// Grid view or list view
  void changeJuzListType(EJuzListType newListType) {
    juzListType = newListType;
    notifyListeners();
  }

  /// Changing between toggle buttons and search bar
  void changeToggleSearchOptions(EToggleSearchOptions newOptionType) {
    _context.read<SearchProvider>().toggleSearchOptions = newOptionType;
    notifyListeners();
  }

  /// Builds verse text for share/copy (Arabic and/or translation per read options).
  /// Uses first available translation (index 0); [index] is only for API compatibility.
  String _verseTextForShareCopy(VerseModel verseModel, int index) {
    final translations = quranProvider.translationService.translationsOfVerse(verseModel.id!);
    String verseText = verseModel.text!;
    if (quranProvider.localSetting.readOptions == EReadOptions.translation) {
      if (translations.isNotEmpty) {
        verseText = translations[0].text ?? verseText;
      }
    } else if (quranProvider.localSetting.readOptions ==
        EReadOptions.surahAndTranslation) {
      if (translations.isNotEmpty) {
        verseText = "${verseModel.text!}\n${translations[0].text ?? ''}";
      }
    }
    return verseText;
  }

  /// Share verse (with copyright attribution).
  Future<void> shareVerse(VerseModel verseModel, int index) async {
    final verseText = _verseTextForShareCopy(verseModel, index);
    await CopyAndShareService.share(verseText);
  }

  /// Copy verse to clipboard (with copyright attribution) and show snackbar.
  Future<void> copyVerse(VerseModel verseModel, int index) async {
    final verseText = _verseTextForShareCopy(verseModel, index);
    await CopyAndShareService.copy(_context, verseText);
  }

  /// Bottom bar previous function
  void previousButtonOnTap() {
    if (readingSettings.surahId <= 1) return;
    _popThenNavigateToSurah(readingSettings.surahId - 1);
  }

  /// Bottom bar up arrow function
  void beggingOfSurahButtonOnTap() {
    _popThenNavigateToSurah(readingSettings.surahId);
  }

  /// Bottom bar next function
  void nextButtonOnTap() {
    if (readingSettings.surahId >= 114) return;
    _popThenNavigateToSurah(readingSettings.surahId + 1);
  }

  /// Pops current screen then navigates to the given surah (after frame so context is valid).
  void _popThenNavigateToSurah(int surahId) {
    final navigator = Navigator.of(_context);
    final type = quranProvider.localSetting.quranType;
    Navigator.pop(_context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted) {
        SurahDetailNavigationManager.goToSurah(
          navigator.context,
          surahId,
          quranType: type,
        );
      }
    });
    notifyListeners();
  }
}
