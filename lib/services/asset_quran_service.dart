import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/json_path.dart';
import '../models/surah_model.dart';
import '../models/translation.dart';

class AssetQuranService {
  AssetQuranService._();

  /// Get all surahs and verses from assets
  static Future<List<SurahModel>> getAllOfSurahs() async {
    String data = await rootBundle.loadString(JsonPathConstants.quran);
    var result = json.decode(data) as List;
    final list = result
        .map((e) => SurahModel.fromJson(e))
        .toList()
        .cast<SurahModel>();
    // Ensure canonical order by id so surahs[index] always has id == index + 1 (fixes wrong surah opening, e.g. Al-Furqan -> An-Nur)
    list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return list;
  }

  static Future<List<VerseTranslation>> getVerseTranslationList(
      String languageCode) async {
    String data = await rootBundle
        .loadString(JsonPathConstants.verseTranslations(languageCode));
    var result = json.decode(data)["translations"];
    return result
        .map((e) => VerseTranslation.fromJson(e))
        .toList()
        .cast<VerseTranslation>();
  }

  static Future<List<TranslationCountry>> getTranslations() async {
    String data = await rootBundle.loadString(JsonPathConstants.translations);
    var result = json.decode(data);
    return result
        .map((e) => TranslationCountry.fromJson(e))
        .toList()
        .cast<TranslationCountry>();
  }
}
