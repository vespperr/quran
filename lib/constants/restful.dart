class RestfulConstants {
  /// Quran.com API end-point for the verse translations
  static String verseTranslation(int resourceId) =>
      "https://api.quran.com/api/v4/quran/translations/$resourceId";
}
