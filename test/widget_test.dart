import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:the_open_quran/database/prayer_times_db.dart';
import 'package:the_open_quran/l10n/app_localizations.dart';

void main() {
  test('PrayerTimesDb loads Kurdistan cities from KurdistanPrayerTimes.db',
      () async {
    sqfliteFfiInit();
    final dbPath = File('lib/assets/KurdistanPrayerTimes.db').absolute.path;
    final db = await databaseFactoryFfi.openDatabase(dbPath,
        options: OpenDatabaseOptions(readOnly: true));

    final rows = await db.rawQuery(
        "SELECT * FROM PrayerTimesforKurdistantable WHERE cities = 'Kalar' AND date = '08-18'");
    expect(rows.isNotEmpty, true);
    expect(rows.first['bayani'], isNotNull);

    final cities = await PrayerTimesDb.getCities(includeIraq: false);
    expect(cities.isNotEmpty, true);
    expect(cities.any((c) => c.name == 'Kalar'), true);
    expect(cities.any((c) => c.name == 'Slemani'), true);
    expect(cities.any((c) => c.name == 'Hawler'), true);

    await db.close();
  });

  test(
      'AppLocalizations loads new worship guide and duha strings across all 3 languages',
      () async {
    final locEn = await AppLocalizations.delegate.load(const Locale('en'));
    final locAr = await AppLocalizations.delegate.load(const Locale('ar'));
    final locKu = await AppLocalizations.delegate.load(const Locale('ku'));

    // English checks
    expect(locEn.sunrise, 'Sunrise');
    expect(locEn.duhaPrayer, 'Duha Prayer');
    expect(locEn.worshipGuideTitle, 'Prayer & Sunnah Guide');
    expect(locEn.howToPray, 'How to Pray');
    expect(locEn.sunnahPrayers, 'Sunnah Prayers');
    expect(locEn.prohibitedTimes, 'Prohibited Times');
    expect(locEn.congregationalMistakes, 'Congregational Mistakes');

    // Arabic checks
    expect(locAr.sunrise, 'الشروق');
    expect(locAr.duhaPrayer, 'صلاة الضحى');
    expect(locAr.worshipGuideTitle, 'دليل الصلاة والسنن');
    expect(locAr.howToPray, 'صفة الصلاة');
    expect(locAr.sunnahPrayers, 'السنن والنوافل');
    expect(locAr.prohibitedTimes, 'أوقات النهي');
    expect(locAr.congregationalMistakes, 'أخطاء الجماعة');

    // Kurdish checks
    expect(locKu.sunrise, 'خۆرهەڵاتن');
    expect(locKu.duhaPrayer, 'نوێژی چێشتەنگاو (الضحى)');
    expect(locKu.worshipGuideTitle, 'ڕێبەری نوێژ و سوننەتەکان');
    expect(locKu.howToPray, 'شێوازی نوێژکردن');
    expect(locKu.sunnahPrayers, 'نوێژە سوننەتەکان');
    expect(locKu.prohibitedTimes, 'کاتەکانی نەهی');
    expect(locKu.congregationalMistakes, 'هەڵەکانی جەماعەت');
  });
}
