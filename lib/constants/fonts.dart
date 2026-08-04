import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

/// App Fonts
class Fonts {
  Fonts._();

  static final String nunitoW900 =
      GoogleFonts.nunito(fontWeight: FontWeight.w900).fontFamily ?? 'sans-serif';

  /// For Verse Signs
  static const String uthmanic = "Uthmani";
  static const String uthmanicIcon = "UthmaniIcon";
  static const String uthmanicBold = "Uthmanic Bold";
  static const String majeed = "Majeed";
  static const String me = "Me";
  static const String jameel = "Jameel";
  static const String kufamRegular = "Kufam Regular";
  static const String noore = "Noore";
  static const String naskh = "Naskh";
  static const String quranFont = "Quran Font";
  /// Arabic surah names (e.g. Al-Fatihah) — use with nameArabic
  static const String surahNames = "SurahNames";



  /// UI / app default (clean modern sans — Inter)
  static final String appSans = GoogleFonts.inter().fontFamily ?? 'sans-serif';

  /// Kurdish UI font (Uni QAIDAR OSMAN)
  static const String kurdish = 'UniQAIDAR_OSMAN';

  /// Translation Fonts (fallback to generic if Google Fonts unavailable, e.g. release Android)
  static final String robotoSlab = GoogleFonts.robotoSlab().fontFamily ?? 'sans-serif';
  static final String nunito = GoogleFonts.nunito().fontFamily ?? appSans;

  /// Arabic UI Font (Cairo)
  static final String cairo = GoogleFonts.cairo().fontFamily ?? 'sans-serif';

  /// Arabic Fonts
  static final String amiri = GoogleFonts.amiri().fontFamily ?? uthmanic;
  static final String lateef = GoogleFonts.lateef().fontFamily ?? uthmanic;
  static final String notoNaskhArabic =
      GoogleFonts.notoNaskhArabic().fontFamily ?? uthmanic;

  static const List<String> translationFontNames = ["Nunito", "Roboto Slab"];
  static const List<String> arabicFontNames = [
    "Uthmani",
    "Uthmanic Bold",
    "Majeed",
    "Me",
    "Jameel",
    "Kufam Regular",
    "Noore",
    "Naskh",
    "Quran Font",
  ];

  static String? getTranslationFont(String fontName) {
    if (fontName == translationFontNames[1]) return robotoSlab;
    return nunito;
  }

  static String? getArabicFont(String fontName) {
    if (fontName == arabicFontNames[1]) return uthmanicBold;
    if (fontName == arabicFontNames[2]) return majeed;
    if (fontName == arabicFontNames[3]) return me;
    if (fontName == arabicFontNames[4]) return jameel;
    if (fontName == arabicFontNames[5]) return kufamRegular;
    if (fontName == arabicFontNames[6]) return noore;
    if (fontName == arabicFontNames[7]) return naskh;
    if (fontName == arabicFontNames[8]) return quranFont;
    return uthmanic;
  }
}
