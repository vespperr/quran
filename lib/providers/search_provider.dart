import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/enums.dart';
import '../managers/surah_detail_navigation_manager.dart';
import '../models/surah_model.dart';
import '../models/translation.dart';
import '../models/verse_model.dart';
import '../utils/utils.dart';
import '../widgets/tags/custom_tag_list.dart';
import 'quran_provider.dart';

class SearchProvider extends ChangeNotifier {
  /// Class constructor
  SearchProvider(this._context);

  /// Text controller
  TextEditingController textEditingController = TextEditingController();

  /// Focus node for search field in the home screen
  late FocusNode searchBarFocusNode = FocusNode();

  /// [BuildContext] of the page
  final BuildContext _context;

  /// The list of the [SurahModel]
  List<SurahModel> filteredSurahSearch = [];

  /// The list of the [VerseModel]
  List<VerseModel> filteredVerseSearch = [];

  /// The list of the [VerseTranslation]
  List<VerseTranslation> filteredVerseTranslationSearch = [];

  /// Storing search query, initially empty
  String query = '';

  /// Checks if search field is empty
  bool isFieldEmpty = true;

  /// Checks if search field is empty
  bool isSearchButtonTapped = false;

  /// Storing page number, initially null
  int? filterPageNumber;

  /// Storing juz number, initially null
  int? filterJuzNumber;

  /// Enum toggle search options
  EToggleSearchOptions toggleSearchOptions = EToggleSearchOptions.toggles;

  /// Juz List Type [EJuzListType]
  EJuzListType juzListType = EJuzListType.list;

  /// Surah Details page - juz and surah toggle buttons
  EJuzSurahToggleOptions juzSurahToggleOptionType = EJuzSurahToggleOptions.juz;

  /// OnTap search or Enter
  void handleSearchSubmitted(String query) {
    this.query = query.trim();
    onSearchFieldChanged();
  }

  /// Live search: run filters as user types so results appear immediately.
  void runLiveSearch(String text) {
    query = text.trim();
    if (query.isNotEmpty) {
      isFieldEmpty = false;
      filterSurahSearchResults(query);
      filterByPageAndJuzNumber(query);
      isSearchButtonTapped = true;
    } else {
      isFieldEmpty = true;
      filteredSurahSearch.clear();
      filterPageNumber = null;
      filterJuzNumber = null;
      isSearchButtonTapped = false;
    }
    notifyListeners();
  }

  /// List of tags under the search
  Widget get buildSearchTags {
    return CustomTagList(
      tags: const [
        "Al-Fatiha",
        "Al-Mulk",
        "Ya-sin",
        "Al-Kahf",
        "Maryam",
      ],
      selectedTag: selectedTag,
    );
  }

  /// Checking if search field is empty
  void onSearchFieldChanged() {
    if (query != "") {
      isFieldEmpty = false;
      filterSurahSearchResults(query);
      filterByPageAndJuzNumber(query);
      // filterSurahVerse(query);
      // filterSurahVerseTranslation(query);
      isSearchButtonTapped = true;
    } else {
      isFieldEmpty = true;
    }
    notifyListeners();
  }

  // /// Getting search result by surah name, id etc.
  // /// [VerseModel]
  // filterSurahVerseTranslation(String queryText) {
  //   queryText = queryText.toLowerCase();
  //   List<VerseTranslation> searchList =
  //       _context.read<QuranProvider>().translationService.getAllVerseTranslations;
  //   List<VerseTranslation> searchResult = [];
  //   for (var verse in searchList) {
  //     if (verse.text!.toLowerCase().contains(queryText)) {
  //       searchResult.add(verse);
  //     }
  //   }
  //   filteredVerseTranslationSearch.clear();
  //   filteredVerseTranslationSearch.addAll(searchResult);
  //   notifyListeners();
  // }

  /// Getting search result by surah name, id etc.
  /// [VerseModel]
  void filterSurahVerse(String queryText) {
    queryText = queryText.toLowerCase();
    List<VerseModel> searchList = _context.read<QuranProvider>().getAllVerses;
    List<SurahModel> searchListSurah = _context.read<QuranProvider>().surahs;
    List<VerseModel> searchResult = [];
    for (var verse in searchList) {
      if (verse.text!.toLowerCase().contains(queryText) ||
          searchListSurah[verse.surahId! - 1].nameTranslated!.toLowerCase().contains(queryText)) {
        if (searchListSurah[verse.surahId! - 1].id == (verse.surahId!)) {
          verse.surahNameTranslated = searchListSurah[verse.surahId! - 1].nameSimple;
          verse.surahNameArabic = searchListSurah[verse.surahId! - 1].nameArabic;
        }
        searchResult.add(verse);
      }
    }
    filteredVerseSearch = [];
    filteredVerseSearch.addAll(searchResult);
    notifyListeners();
  }

  /// Normalize Arabic for search: remove diacritics (tashkeel), normalize alef/ta-marbuta.
  static String normalizeArabicForSearch(String s) {
    if (s.isEmpty) return s;
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      final c = String.fromCharCode(rune);
      if (_isArabicDiacritic(rune)) continue;
      buffer.write(_normalizeArabicLetter(c, rune));
    }
    return buffer.toString();
  }

  static bool _isArabicDiacritic(int code) {
    return (code >= 0x064B && code <= 0x0652) ||
        (code >= 0x0670 && code <= 0x0670) ||
        (code >= 0x0617 && code <= 0x061A) ||
        (code >= 0x06D6 && code <= 0x06ED) ||
        (code >= 0xFE70 && code <= 0xFE7F);
  }

  static String _normalizeArabicLetter(String c, int code) {
    switch (code) {
      case 0x0623: // أ
      case 0x0625: // إ
      case 0x0622: // آ
      case 0x0671: // ٱ
        return '\u0627'; // ا
      case 0x0629: // ة
        return '\u062A'; // ت
      case 0x0649: // ى (alef maksura)
        return '\u064A'; // ي
      default:
        return c;
    }
  }

  /// Returns true if [haystack] contains [needle], supporting Arabic normalization.
  static bool containsNormalized(String haystack, String needle) {
    final nHay = normalizeArabicForSearch(haystack);
    final nNeedle = normalizeArabicForSearch(needle);
    return nHay.contains(nNeedle);
  }

  /// Getting search result by surah name, id etc. (Arabic-aware and live).
  /// [SurahModel]
  void filterSurahSearchResults(String queryText) {
    final trimmed = queryText.trim();
    if (trimmed.isEmpty) {
      filteredSurahSearch.clear();
      notifyListeners();
      return;
    }
    final queryLower = trimmed.toLowerCase();
    List<SurahModel> searchList = _context.read<QuranProvider>().surahs;
    List<SurahModel> searchResult = [];
    for (var surah in searchList) {
      final byId = surah.id.toString() == trimmed || surah.id.toString() == queryLower;
      final byTranslated = (surah.nameTranslated ?? '')
          .toLowerCase()
          .contains(queryLower);
      final bySimple = (surah.nameSimple ?? '').toLowerCase().contains(queryLower);
      final byComplex = (surah.nameComplex ?? '').toLowerCase().contains(queryLower);
      final byPlace = (surah.revelationPlace ?? '').toLowerCase().contains(queryLower);
      final byArabic = containsNormalized(surah.nameArabic ?? '', trimmed);
      final byTurkish = (surah.nameTurkish ?? '').toLowerCase().contains(queryLower);
      if (byId ||
          byTranslated ||
          bySimple ||
          byComplex ||
          byPlace ||
          byArabic ||
          byTurkish) {
        searchResult.add(surah);
      }
    }

    filteredSurahSearch.clear();
    filteredSurahSearch.addAll(searchResult);
    notifyListeners();
  }

  /// Getting search result by page number or juz number
  void filterByPageAndJuzNumber(String queryText) {
    filterPageNumber = null;
    filterJuzNumber = null;
    if (Utils.isNumeric(queryText) && int.parse(queryText) <= 604) {
      filterJuzNumber = int.parse(queryText);
      filterPageNumber = int.parse(queryText);
      if (filterJuzNumber! > 30) {
        filterJuzNumber = null;
      }
    }
  }

  void selectedTag(String selectedTag) {
    textEditingController.text = selectedTag;
    searchBarFocusNode.requestFocus();
  }

  /// If search bar is not empty, clear textField
  /// If search bar empty, show toggle buttons
  void clearSearchField(BuildContext context) {
    if (textEditingController.text.isNotEmpty) {
      textEditingController.clear();
      filterPageNumber = null;
      filterJuzNumber = null;
      filteredSurahSearch = [];
      filteredVerseSearch = [];
      searchBarFocusNode.requestFocus();
      isSearchButtonTapped = false;
      notifyListeners();
    } else {
      Utils.unFocus();
      changeToggleSearchOptions(EToggleSearchOptions.toggles);
    }
  }

  /// Changing between toggle buttons and search bar
  void changeToggleSearchOptions(EToggleSearchOptions newOptionType) {
    toggleSearchOptions = newOptionType;
    notifyListeners();
  }

  /// Checking when search result is empty
  bool get isSearchResultEmpty {
    return (filteredVerseSearch.isEmpty &&
            filteredSurahSearch.isEmpty &&
            filterPageNumber == null &&
            filterJuzNumber == null) &&
        isSearchButtonTapped;
  }

  /// Checking when search item is displayed
  bool get isSearchResultDisplayed {
    return filteredVerseSearch.isNotEmpty ||
        filteredSurahSearch.isNotEmpty ||
        filterPageNumber != null ||
        filterJuzNumber != null;
  }

  Future<void> goToSurah(BuildContext context, int surahId, bool isHome, {int verseId = 1}) async {
    if (!isHome) Navigator.pop(context);
    await SurahDetailNavigationManager.goToSurah(context, surahId, verseId: verseId);
    notifyListeners();
  }

  Future<void> goToJuz(BuildContext context, int juzId, bool isHome) async {
    if (!isHome) Navigator.pop(context);
    await SurahDetailNavigationManager.goToJuz(context, juzId);
    notifyListeners();
  }

  Future<void> goToMushaf(BuildContext context, int pageNumber, bool isHome) async {
    if (!isHome) Navigator.pop(context);
    await SurahDetailNavigationManager.goToMushaf(context, pageNumber);
    notifyListeners();
  }

  /// Change list type in [HomeScreen]
  /// Grid view or list view
  void changeJuzListType(EJuzListType newListType) {
    juzListType = newListType;
    notifyListeners();
  }

  /// Change type juz, surah or search
  void changeJuzOrSurahToggleOptionType(EJuzSurahToggleOptions newOptionType) {
    juzSurahToggleOptionType = newOptionType;
    notifyListeners();
  }
}
