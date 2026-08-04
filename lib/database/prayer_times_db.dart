import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/iso_country_names.dart';
import '../models/prayer_city_model.dart';
import '../models/prayer_country_model.dart';
import '../models/prayer_time_model.dart';
import '../services/aladhan_prayer_times_service.dart';
import '../utils/prayer_time_parse.dart';
import 'dhikr_db.dart';

/// Copies bundled [kurdistandb.sqlite] into app documents (isolate).
Future<void> _writeKurdistanPrayerDbFile(List<dynamic> args) async {
  final path = args[0] as String;
  final bytes = args[1] as List<int>;
  await File(path).writeAsBytes(bytes);
}

/// Prayer times from bundled SQLite.
///
/// **Kurdistan-only** ([includeIraq] false): [kurdistandb.sqlite] — one table per city,
/// date column `D` (MM-DD), times: bayani, niwaro/nwaro, asr, eywara, esha (sunrise column not shown).
///
/// **Other regions** ([includeIraq] true): [KurdistanPrayerTimes.db] via [DhikrDb] —
/// Iraq & Iran cities only, excluding Kurdistan (`Jegir = 1`). Kurdistan uses [kurdistandb.sqlite].
///
/// **Adhan offset:** [adhanMinutesEarlier] minutes subtracted from each stored time for display
/// and notifications. Use `0` so UI matches the values in the database tables exactly.
class PrayerTimesDb {
  PrayerTimesDb._();

  /// Minutes to subtract from each stored prayer time (0 = show same times as in SQLite).
  static const int adhanMinutesEarlier = 0;

  /// Default city when none selected (matches azadalkrd).
  static const String defaultCity = 'Kalar';

  static const String _kurdistanAssetPath = 'lib/assets/kurdistandb.sqlite';
  static const String _kurdistanFileName = 'kurdistandb.sqlite';

  static Database? _kurdistanDbInstance;
  static Future<Database>? _kurdistanDbOpening;
  static bool _sqfliteFfiReady = false;

  static void _ensureSqfliteFfi() {
    if (_sqfliteFfiReady) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _sqfliteFfiReady = true;
  }

  static Future<Database> _kurdistanDatabase() async {
    if (_kurdistanDbInstance != null && _kurdistanDbInstance!.isOpen) {
      return _kurdistanDbInstance!;
    }
    _kurdistanDbOpening ??= _openKurdistanDatabaseOnce();
    return _kurdistanDbOpening!;
  }

  static Future<Database> _openKurdistanDatabaseOnce() async {
    _ensureSqfliteFfi();
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/$_kurdistanFileName';
    if (!await File(dbPath).exists()) {
      final byteData = await rootBundle.load(_kurdistanAssetPath);
      final bytes = byteData.buffer.asUint8List().toList();
      await compute(_writeKurdistanPrayerDbFile, [dbPath, bytes]);
    }
    _kurdistanDbInstance = await openDatabase(dbPath, readOnly: true);
    return _kurdistanDbInstance!;
  }

  static Set<String>? _kurdistanTableNameCache;

  /// Tables in [KurdistanPrayerTimes.db] that are not per-city prayer tables (never treat as cities).
  static const Set<String> _kurdistanSqliteExcludedTablesLower = {
    'android_metadata',
    'cities',
    'countries',
    'dhikr',
    'dhikrname',
    'prayertimesforkurdistantable',
    'sqlite_sequence',
  };

  static Future<Set<String>> _kurdistanTableNames(Database db) async {
    if (_kurdistanTableNameCache != null) return _kurdistanTableNameCache!;
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    final names = <String>{};
    for (final r in rows) {
      final n = (r['name'] as String?)?.trim();
      if (n == null || n.isEmpty) continue;
      if (_kurdistanSqliteExcludedTablesLower.contains(n.toLowerCase())) {
        continue;
      }
      names.add(n);
    }
    _kurdistanTableNameCache = names;
    return names;
  }

  /// Friendly labels for UI; [id] remains the SQLite table name (e.g. Slemany).
  static const Map<String, String> _kurdistanTableToDisplayName = {
    'Slemany': 'Slemani',
    'Hewler': 'Hawler',
    'Penjwin': 'Penjwen',
  };

  /// Maps legacy big-DB / UI city keys to [kurdistandb.sqlite] table names.
  static const Map<String, String> _legacyKeyToKurdistanTable = {
    'Slemani': 'Slemany',
    'Sulaymaniyah': 'Slemany',
    'Suleimaniyah': 'Slemany',
    'Sulaimaniyah': 'Slemany',
    'Hawler': 'Hewler',
    'Erbil': 'Hewler',
    'Penjuin': 'Penjwin',
    'Penjwen': 'Penjwin',
    'Zakho': 'Zaxo',
    'SaidSadq': 'SaidSadiq',
    'Dwz': 'tuzxurmatu',
    'Mosul': 'mosul',
    'ئاکرێ': 'Amedi',
  };

  static String? _resolveKurdistanTableName(String city, Set<String> tables) {
    final t = city.trim();
    if (t.isEmpty) return null;
    if (tables.contains(t)) return t;
    final mapped = _legacyKeyToKurdistanTable[t];
    if (mapped != null && tables.contains(mapped)) return mapped;
    final normalized = _normalizeCity(city);
    final mapped2 = _legacyKeyToKurdistanTable[normalized];
    if (mapped2 != null && tables.contains(mapped2)) return mapped2;
    if (tables.contains(normalized)) return normalized;
    final lower = t.toLowerCase();
    for (final name in tables) {
      if (name.toLowerCase() == lower) return name;
    }
    return null;
  }

  /// City name replacements for big-DB query (from azadalkrd MydbClass.readAllDate).
  static const Map<String, String> _cityReplacements = {
    'Amedi': 'ئاکرێ',
    'Arbat': 'سلێمانی',
    'Barznja': 'بەرزنجە',
    'Bazyan': 'قالادەزە',
    'Chamchamal': 'چمچمال(کۆن)',
    'Darbandixan': 'دەربەندیخان',
    'HajiAwa': 'چمچمال',
    'HalabjaN': 'هەڵەبجە',
    'Kfri': 'کیفری',
    'Penjuin': ' پێنجوێن',
    'Penjwen': ' پێنجوێن',
    'Piramagrun': 'Dukan',
    'Ranya': 'Chamchamal',
    'SaidSadiq': 'SaidSadq',
    'Slemany': 'Slemani',
    'Sulaymaniyah': 'Slemani',
    'Suleimaniyah': 'Slemani',
    'Sulaimaniyah': 'Slemani',
    'Takya': 'Chamchamal(Kon)',
    'TaqTaq': 'Chamchamal',
    'Tasluja': 'Qaladze',
    'Xalakan': 'Chamchamal',
    'Zaxo': 'Zakho',
    'mosul': 'Mosul',
    'tuzxurmatu': 'Dwz',
  };

  static String _normalizeCity(String city) {
    var c = city;
    for (final e in _cityReplacements.entries) {
      c = c.replaceAll(e.key, e.value);
    }
    return c;
  }

  /// Fajr, Dhuhr, Asr, Maghrib, Isha.
  static const List<String> _prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  /// Column names per prayer; Kurdish DBs may use `nwaro` instead of `niwaro`.
  static const List<List<String>> _timeColumnAliases = [
    ['bayani'],
    ['niwaro', 'nwaro'],
    ['asr'],
    ['eywara'],
    ['esha'],
  ];

  static String _rawTimeFromRow(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      final v = row[k];
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty && s != '--:--') return s;
      }
    }
    return '--:--';
  }

  static Future<bool> _citiesTableHasColumn(Database db, String column) async {
    final rows = await db.rawQuery('PRAGMA table_info(cities)');
    final lower = column.toLowerCase();
    for (final r in rows) {
      final name = (r['name'] as String?)?.toLowerCase();
      if (name == lower) return true;
    }
    return false;
  }

  /// Column to use for `ORDER BY` when listing cities (schema differs between DB exports).
  static Future<String?> _citySortColumnName(Database db) async {
    final rows = await db.rawQuery('PRAGMA table_info(cities)');
    final names = <String>[];
    for (final r in rows) {
      final n = r['name'] as String?;
      if (n != null && n.isNotEmpty) names.add(n);
    }
    const preferred = ['cities', 'name', 'city', 'dbname', 'NameKurdish'];
    for (final pref in preferred) {
      for (final n in names) {
        if (n.toLowerCase() == pref.toLowerCase()) return n;
      }
    }
    return null;
  }

  static String _quoteSqlIdent(String id) => '"${id.replaceAll('"', '""')}"';

  /// Optional `Countries` table: map ISO → display name (best-effort column detection).
  static Future<Map<String, String>> _countryNamesFromCountriesTable(
      Database db) async {
    final t = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='Countries'",
    );
    if (t.isEmpty) return {};
    final rows = await db.rawQuery('SELECT * FROM Countries');
    final map = <String, String>{};
    for (final row in rows) {
      String? iso;
      String? label;
      for (final e in row.entries) {
        final k = e.key.toLowerCase();
        final v = e.value;
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isEmpty) continue;
        if (k == 'iso' || k == 'code' || k == 'country_code' || k == 'iso2') {
          iso = s.toUpperCase();
        } else if (k == 'name' ||
            k == 'name_en' ||
            k == 'english' ||
            k == 'country_name' ||
            k == 'label') {
          label = s;
        }
      }
      if (iso != null && label != null) {
        map[iso] = label;
      }
    }
    return map;
  }

  /// Distinct countries in [KurdistanPrayerTimes.db] (non–Kurdistan rows only when `Jegir` exists).
  static Future<List<PrayerCountryModel>> getPrayerCountries() async {
    final db = await DhikrDb.database;
    final hasTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='cities'",
    );
    if (hasTable.isEmpty) return [];
    final hasJegir = await _citiesTableHasColumn(db, 'Jegir');
    final sql = hasJegir
        ? "SELECT DISTINCT TRIM(iso) AS iso FROM cities WHERE COALESCE(Jegir, 0) != 1 AND iso IS NOT NULL AND TRIM(iso) != '' ORDER BY iso ASC"
        : "SELECT DISTINCT TRIM(iso) AS iso FROM cities WHERE iso IS NOT NULL AND TRIM(iso) != '' ORDER BY iso ASC";
    final rows = await db.rawQuery(sql);
    final fromDb = await _countryNamesFromCountriesTable(db);
    final list = <PrayerCountryModel>[];
    for (final r in rows) {
      final iso = (r['iso'] ?? '').toString().trim().toUpperCase();
      if (iso.isEmpty) continue;
      final label = fromDb[iso] ?? IsoCountryNames.nameOf(iso);
      list.add(PrayerCountryModel(iso: iso, displayName: label));
    }
    list.sort((a, b) {
      const first = ['IQ', 'IR'];
      final ia = first.indexOf(a.iso);
      final ib = first.indexOf(b.iso);
      if (ia != -1 && ib != -1) return ia.compareTo(ib);
      if (ia != -1) return -1;
      if (ib != -1) return 1;
      return a.displayName.compareTo(b.displayName);
    });
    return list;
  }

  /// Cities in [KurdistanPrayerTimes.db] for one ISO country (excludes Kurdistan rows when `Jegir` exists).
  static Future<List<PrayerCityModel>> getCitiesForCountryIso(
      String iso) async {
    final db = await DhikrDb.database;
    final hasTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='cities'",
    );
    if (hasTable.isEmpty) {
      return [PrayerCityModel(id: defaultCity, name: defaultCity)];
    }
    final safeIso = iso.trim().toUpperCase();
    if (safeIso.isEmpty) {
      return [PrayerCityModel(id: defaultCity, name: defaultCity)];
    }
    final hasJegir = await _citiesTableHasColumn(db, 'Jegir');
    final sortCol = await _citySortColumnName(db);
    final orderBy = sortCol != null
        ? ' ORDER BY ${_quoteSqlIdent(sortCol)} COLLATE NOCASE ASC'
        : '';
    final sql = hasJegir
        ? 'SELECT * FROM cities WHERE iso = ? AND COALESCE(Jegir, 0) != 1$orderBy'
        : 'SELECT * FROM cities WHERE iso = ?$orderBy';
    final rows = await db.rawQuery(sql, [safeIso]);
    if (rows.isEmpty) {
      return [PrayerCityModel(id: defaultCity, name: defaultCity)];
    }
    final seen = <String>{};
    final list = <PrayerCityModel>[];
    for (final r in rows) {
      final name = (r['cities'] ?? r['name'] ?? r['city'] ?? r['DbName'] ?? '')
          .toString()
          .trim();
      if (name.isEmpty || seen.contains(name)) continue;
      seen.add(name);
      final key = name.split(RegExp(r'\s*[,(]')).first.trim();
      final variants = _cityNameVariants[name] ?? _cityNameVariants[key];
      list.add(PrayerCityModel(
        id: name,
        name: name,
        nameCkb: variants?[0],
        nameAr: variants?[1],
        nameEn: variants?[2],
      ));
    }
    if (list.isEmpty) {
      list.add(PrayerCityModel(id: defaultCity, name: defaultCity));
    }
    return list;
  }

  /// [includeIraq] false: [kurdistandb.sqlite] (Kurdistan). True: legacy — use [getCitiesForCountryIso].
  static Future<List<PrayerCityModel>> getCities(
      {bool includeIraq = false}) async {
    if (!includeIraq) {
      final db = await _kurdistanDatabase();
      final tables = (await _kurdistanTableNames(db)).toList()..sort();
      if (tables.isEmpty) {
        return [PrayerCityModel(id: defaultCity, name: defaultCity)];
      }
      final list = <PrayerCityModel>[];
      for (final table in tables) {
        final display = _kurdistanTableToDisplayName[table] ?? table;
        final key = display.split(RegExp(r'\s*[,(]')).first.trim();
        final variants = _cityNameVariants[display] ??
            _cityNameVariants[table] ??
            _cityNameVariants[key];
        list.add(PrayerCityModel(
          id: table,
          name: display,
          nameCkb: variants?[0],
          nameAr: variants?[1],
          nameEn: variants?[2],
        ));
      }
      if (list.isEmpty) {
        list.add(PrayerCityModel(id: defaultCity, name: defaultCity));
      }
      return list;
    }

    return getCitiesForCountryIso('IQ');
  }

  /// Optional CKB (Kurdish), AR (Arabic), EN (English) names for search. Key = DB city name (or part).
  static const Map<String, List<String>> _cityNameVariants = {
    'Kalar': ['کالار', 'كalar', 'Kalar'],
    'کالار': ['کالار', 'كalar', 'Kalar'],
    'Slemani': ['سلێمانی', 'السليمانية', 'Sulaymaniyah'],
    'Slemany': ['سلێمانی', 'السليمانية', 'Sulaymaniyah'],
    'سلێمانی': ['سلێمانی', 'السليمانية', 'Sulaymaniyah'],
    'Sulaymaniyah': ['سلێمانی', 'السليمانية', 'Sulaymaniyah'],
    'Hawler': ['هەولێر', 'أربيل', 'Erbil'],
    'Hewler': ['هەولێر', 'أربيل', 'Erbil'],
    'هەولێر': ['هەولێر', 'أربيل', 'Erbil'],
    'Erbil': ['هەولێر', 'أربيل', 'Erbil'],
    'Duhok': ['دهۆک', 'دهوك', 'Duhok'],
    'دهۆک': ['دهۆک', 'دهوك', 'Duhok'],
    'Zakho': ['زاخۆ', 'زاخو', 'Zakho'],
    'زاخۆ': ['زاخۆ', 'زاخو', 'Zakho'],
    'Zaxo': ['زاخۆ', 'زاخو', 'Zakho'],
    'Halabja': ['هەڵەبجە', 'حلبجة', 'Halabja'],
    'هەڵەبجە': ['هەڵەبجە', 'حلبجة', 'Halabja'],
    'HalabjaN': ['هەڵەبجە', 'حلبجة', 'Halabja'],
    'Kirkuk': ['کەرکووك', 'كركوك', 'Kirkuk'],
    'کەرکووك': ['کەرکووك', 'كركوك', 'Kirkuk'],
    'Kfri': ['کەرکووك', 'كركوك', 'Kirkuk'],
    'Mosul': ['موسڵ', 'الموصل', 'Mosul'],
    'موسڵ': ['موسڵ', 'الموصل', 'Mosul'],
    'mosul': ['موسڵ', 'الموصل', 'Mosul'],
    'ئاکرێ': ['ئاکرێ', 'العمادية', 'Amedi'],
    'Amedi': ['ئاکرێ', 'العمادية', 'Amedi'],
    'Dukan': ['دوکان', 'دوكان', 'Dukan'],
    'دوکان': ['دوکان', 'دوكان', 'Dukan'],
    'Piramagrun': ['دوکان', 'دوكان', 'Dukan'],
    'Ranya': ['ڕانیه', 'رانية', 'Ranya'],
    'ڕانیه': ['ڕانیه', 'رانية', 'Ranya'],
    'Chamchamal': ['چمچمال', 'چمچمال', 'Chamchamal'],
    'چمچمال': ['چمچمال', 'چمچمال', 'Chamchamal'],
    'Qaladze': ['قەلادزێ', 'قلادزة', 'Qaladze'],
    'قەلادزێ': ['قەلادزێ', 'قلادزة', 'Qaladze'],
    'Tasluja': ['قەلادزێ', 'قلادزة', 'Qaladze'],
    'بەرزنجە': ['بەرزنجە', 'برزنجة', 'Barzanja'],
    'Barznja': ['بەرزنجە', 'برزنجة', 'Barzanja'],
    'دەربەندیخان': ['دەربەندیخان', 'دربنديخان', 'Darbandikhan'],
    'Darbandixan': ['دەربەندیخان', 'دربنديخان', 'Darbandikhan'],
    'پێنجوێن': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Penjwen': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Penjuin': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Penjwin': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Dwz': ['دوز', 'طوز', 'Tuz'],
    'tuzxurmatu': ['دوز', 'طوز', 'Tuz Khurmatu'],
    'SaidSadiq': ['سەید سادق', 'السيد صادق', 'Said Sadiq'],
    'SaidSadq': ['سەید سادق', 'السيد صادق', 'Said Sadiq'],
  };

  /// Today's date: try common formats (MM-dd, dd-MM, yyyy-MM-dd).
  static List<String> _dateStrVariants(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return ['$m-$d', '$d-$m', '$y-$m-$d'];
  }

  /// Prayer times for a city and date. Returns 5 prayers (Fajr, Dhuhr, Asr, Maghrib, Isha).
  /// [date] defaults to today.
  ///
  /// When [includeIraq] is true (world / non-Kurdistan DB), [countryIso] (ISO 3166-1 alpha-2) is
  /// used to fetch from Aladhan if the bundled table has no row for that city/date.
  static Future<List<PrayerTimeModel>> getPrayerTimesForDate({
    required String city,
    String? dateStr,
    DateTime? date,
    bool includeIraq = false,
    String? countryIso,
  }) async {
    final useDate = date ?? DateTime.now();
    final dateVariants =
        dateStr != null ? [dateStr] : _dateStrVariants(useDate);

    if (!includeIraq) {
      final db = await _kurdistanDatabase();
      final tables = await _kurdistanTableNames(db);
      final tableName = _resolveKurdistanTableName(city, tables);
      if (tableName == null) return _emptyPrayerList();

      for (final dateVariant in dateVariants) {
        final rows = await db.rawQuery(
          'SELECT * FROM "$tableName" WHERE "D" = ?',
          [dateVariant],
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          return _rowsToPrayerList(row);
        }
      }
      return _emptyPrayerList();
    }

    final db = await DhikrDb.database;
    final hasTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='PrayerTimesforKurdistantable'",
    );
    if (hasTable.isEmpty) {
      return _worldPrayerTimesFallback(
          city: city.trim(), countryIso: countryIso, useDate: useDate);
    }

    final normalizedCity = _normalizeCity(city);
    final cityVariants = normalizedCity != city.trim()
        ? [normalizedCity, city.trim()]
        : [normalizedCity];

    for (final cityKey in cityVariants) {
      for (final dateVariant in dateVariants) {
        final rows = await db.rawQuery(
          "SELECT * FROM PrayerTimesforKurdistantable WHERE cities = ? AND date = ?",
          [cityKey, dateVariant],
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          final parsed = _rowsToPrayerList(row);
          if (_allPrayerTimesMissing(parsed)) continue;
          return parsed;
        }
      }
    }
    return _worldPrayerTimesFallback(
        city: city.trim(), countryIso: countryIso, useDate: useDate);
  }

  static bool _allPrayerTimesMissing(List<PrayerTimeModel> list) {
    if (list.isEmpty) return true;
    for (final t in list) {
      final s = t.timeString.trim();
      if (s.isNotEmpty && s != '--:--') return false;
    }
    return true;
  }

  static Future<List<PrayerTimeModel>> _worldPrayerTimesFallback({
    required String city,
    String? countryIso,
    required DateTime useDate,
  }) async {
    final iso = (countryIso ?? 'IQ').trim().toUpperCase();
    if (iso.length != 2 || city.isEmpty) return _emptyPrayerList();
    final api = await AladhanPrayerTimesService.fetchTimingsByCity(
      city: city,
      countryIso: iso,
      date: useDate,
    );
    if (api != null && !_allPrayerTimesMissing(api)) return api;
    return _emptyPrayerList();
  }

  static List<PrayerTimeModel> _rowsToPrayerList(Map<String, dynamic> row) {
    final list = <PrayerTimeModel>[];
    for (var i = 0; i < _timeColumnAliases.length; i++) {
      final timeStr = _rawTimeFromRow(row, _timeColumnAliases[i]);
      final adjustedStr =
          _timeStringSubtractMinutes(timeStr, adhanMinutesEarlier);
      list.add(PrayerTimeModel(
        name: _prayerNames[i],
        timeString: adjustedStr,
      ));
    }
    return list;
  }

  /// Returns "HH:mm" minus [minutes] (for adhan offset). Handles day wrap. Invalid input returns original.
  static String _timeStringSubtractMinutes(String timeString, int minutes) {
    if (minutes == 0) return timeString;
    final total = _parseMinutes(timeString);
    if (total == null) return timeString;
    var result = total - minutes;
    while (result < 0) {
      result += 24 * 60;
    }
    result = result % (24 * 60);
    final h = result ~/ 60;
    final m = result % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static List<PrayerTimeModel> _emptyPrayerList() {
    return _prayerNames
        .map((n) => PrayerTimeModel(name: n, timeString: '--:--'))
        .toList();
  }

  /// Fetches **today’s** prayer times for [cityName] from the bundled DB (or API fallback).
  ///
  /// **Kurdistan** (`includeIraq: false`, default for “Kurdistan” mode in the app):
  /// resolves the city table (e.g. `Sulaymaniyah` / `Slemani` → `Slemany`) and reads the
  /// row whose date column `D` matches **today’s** calendar date. Matching tries
  /// `MM-dd`, `dd-MM`, and `yyyy-MM-dd` against [DateTime.now] (see [_dateStrVariants]).
  ///
  /// **Iraq / world** (`includeIraq: true`): uses [PrayerTimesforKurdistantable] or Aladhan
  /// fallback with [countryIso].
  static Future<List<PrayerTimeModel>> fetchTodayPrayerTimesForCity(
    String cityName, {
    bool includeIraq = false,
    String? countryIso,
  }) async {
    return getPrayerTimesForDate(
      city: cityName,
      date: DateTime.now(),
      includeIraq: includeIraq,
      countryIso: countryIso,
    );
  }

  /// Today’s prayer times for the given city (same as [fetchTodayPrayerTimesForCity]).
  static Future<List<PrayerTimeModel>> getTodayPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  }) =>
      fetchTodayPrayerTimesForCity(
        city,
        includeIraq: includeIraq,
        countryIso: countryIso,
      );

  /// Tomorrow's prayer times for the given city (for scheduling next day's alarms).
  static Future<List<PrayerTimeModel>> getTomorrowPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  }) async {
    return getPrayerTimesForDate(
      city: city,
      date: DateTime.now().add(const Duration(days: 1)),
      includeIraq: includeIraq,
      countryIso: countryIso,
    );
  }

  /// Index of the next prayer (first whose time is after [now]).
  /// Times are parsed as HH:mm. If all are past, returns 0 (next is Fajr tomorrow).
  static int getNextPrayerIndex(List<PrayerTimeModel> times, DateTime now) {
    if (times.isEmpty) return 0;
    final nowMinutes = now.hour * 60 + now.minute;
    for (var i = 0; i < times.length; i++) {
      final m = _parseMinutes(times[i].timeString);
      if (m != null && m > nowMinutes) return i;
    }
    return 0;
  }

  /// Next prayer and duration until it. If all today's prayers are past, next is Fajr tomorrow.
  static NextPrayerInfo getNextPrayerWithDuration(
    List<PrayerTimeModel> times,
    DateTime now,
  ) {
    if (times.isEmpty) {
      return NextPrayerInfo(
        next: const PrayerTimeModel(name: '', timeString: '--:--'),
        until: Duration.zero,
        isTomorrow: false,
      );
    }
    final nextIndex = getNextPrayerIndex(times, now);
    final next = times[nextIndex];
    final nextMinutes = _parseMinutes(next.timeString);
    if (nextMinutes == null) {
      return NextPrayerInfo(
          next: next, until: Duration.zero, isTomorrow: false);
    }
    var nextDt = DateTime(
        now.year, now.month, now.day, nextMinutes ~/ 60, nextMinutes % 60);
    final isTomorrow = !nextDt.isAfter(now);
    if (isTomorrow) {
      nextDt = nextDt.add(const Duration(days: 1));
    }
    final until = nextDt.difference(now);
    return NextPrayerInfo(next: next, until: until, isTomorrow: isTomorrow);
  }

  static int? _parseMinutes(String timeString) =>
      parsePrayerTimeMinutes(timeString);
}
