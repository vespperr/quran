import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:the_open_quran/database/prayer_times_db.dart';

void main() {
  test('PrayerTimesDb loads Kurdistan cities from KurdistanPrayerTimes.db', () async {
    sqfliteFfiInit();
    final dbPath = File('lib/assets/KurdistanPrayerTimes.db').absolute.path;
    final db = await databaseFactoryFfi.openDatabase(dbPath, options: OpenDatabaseOptions(readOnly: true));

    final rows = await db.rawQuery("SELECT * FROM PrayerTimesforKurdistantable WHERE cities = 'Kalar' AND date = '08-18'");
    expect(rows.isNotEmpty, true);
    expect(rows.first['bayani'], isNotNull);

    final cities = await PrayerTimesDb.getCities(includeIraq: false);
    expect(cities.isNotEmpty, true);
    expect(cities.any((c) => c.name == 'Kalar'), true);
    expect(cities.any((c) => c.name == 'Slemani'), true);
    expect(cities.any((c) => c.name == 'Hawler'), true);

    await db.close();
  });
}
