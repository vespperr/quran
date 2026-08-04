import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/enums.dart';
import '../routes/app_routes.dart';
import '../providers/quran_provider.dart';
import '../database/local_db.dart';
import '../models/reading_settings_model.dart';
import '../models/recent_model.dart';
import '../providers/surah_details_provider.dart';
import '../screens/surah_details/surah_details_screen.dart';

class SurahDetailNavigationManager {
  SurahDetailNavigationManager._();

  /// Navigation to the surah details from surah list
  static Future<void> goToSurah(
    BuildContext context,
    int surahId, {
    int verseId = 1,
    EQuranType? quranType,
  }) async {
    final quranProvider = context.read<QuranProvider>();
    final type = quranType ?? quranProvider.localSetting.quranType;
    int mushafPageNumber = 1;
    if (type == EQuranType.reading &&
        surahId >= 1 &&
        surahId <= 114 &&
        quranProvider.surahs.isNotEmpty) {
      final surah = quranProvider.surahs[surahId - 1];
      final verseIndex = (verseId - 1).clamp(0, surah.verses.length - 1);
      if (surah.verses.isNotEmpty) {
        mushafPageNumber = surah.verses[verseIndex].pageNumber ?? 1;
      }
    }
    await _goToSurahDetail(
      context,
      ReadingSettingsModel(
        surahDetailScreenMode: ESurahDetailScreenMode.surah,
        surahId: surahId,
        verseId: verseId,
        mushafPageNumber: mushafPageNumber,
      ),
      quranType: type,
    );
    LocalDb.addRecent(RecentModel(
        eRecentVisitedType: ERecentVisitedType.surah, index: surahId));
  }

  /// Navigation to the surah details from juz list
  static Future<void> goToJuz(BuildContext context, int juzId) async{
    await _goToSurahDetail(
      context,
      ReadingSettingsModel(
        surahDetailScreenMode: ESurahDetailScreenMode.juz,
        juzId: juzId,
      ),
    );
    LocalDb.addRecent(RecentModel(
        eRecentVisitedType: ERecentVisitedType.juz, index: juzId));
  }

  /// Navigation to the reading/mushaf surah details
  static Future<void> goToMushaf(BuildContext context, int pageNumber) async {
   await _goToSurahDetail(
      context,
      ReadingSettingsModel(mushafPageNumber: pageNumber),
      quranType: EQuranType.reading,
    );
    LocalDb.addRecent(RecentModel(
        eRecentVisitedType: ERecentVisitedType.page, index: pageNumber));
  }

  /// Navigation to the surah details
  static Future<void> _goToSurahDetail(
    BuildContext context,
    ReadingSettingsModel readingModel, {
    EQuranType quranType = EQuranType.translation,
  }) async {
   await Navigator.push(
      context,
      AppRoutes.fadeSlideRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) =>
              SurahDetailsProvider(context, readingModel, quranType),
          child: const SurahDetailsScreen(),
        ),
      ),
    );
  }
}
