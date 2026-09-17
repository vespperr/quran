import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/iso_country_names.dart';
import '../models/prayer_city_model.dart';
import '../models/prayer_country_model.dart';
import '../models/prayer_time_model.dart';
import '../services/aladhan_prayer_times_service.dart';
import '../utils/prayer_time_parse.dart';
import 'dhikr_db.dart';

/// Prayer times from bundled SQLite database (KurdistanPrayerTimes.db).
///
/// Precomputed times from [PrayerTimesforKurdistantable] for Kurdistan, Iraq, and world cities.
///
/// **Adhan offset:** [adhanMinutesEarlier] minutes subtracted from each stored time for display
/// and notifications. Use `0` so UI matches the values in the database tables exactly.
class PrayerTimesDb {
  PrayerTimesDb._();

  /// Minutes to subtract from each stored prayer time (0 = show same times as in SQLite).
  static const int adhanMinutesEarlier = 0;

  /// Default city when none selected.
  static const String defaultCity = 'Slemani';

  /// Primary Kurdistan cities list
  static const List<String> _kurdistanPrimaryCities = [
    'Kalar',
    'Slemani',
    'Hawler',
    'Duhok',
    'Zakho',
    'Halabja',
    'Akre',
    'Chamchamal',
    'Darbandikhan',
    'Dukan',
    'Dwz',
    'Khurmal',
    'Kifri',
    'Kirkuk',
    'Koya',
    'Qaladze',
    'SaidSadq',
    'Soran',
    'Taqtaq',
    'Bardarash',
    'Khanaqin',
    'Qasrok',
    'Shekhan',
    'Sinjar',
    'Mosul',
  ];

  /// City name replacements for big-DB query (from azadalkrd / KurdistanPrayerTimes.db).
  static const Map<String, String> _cityReplacements = {
    'Amedi': 'Akre',
    'Arbat': 'Slemani',
    'Barznja': 'Slemani',
    'Bazyan': 'Slemani',
    'Chamchamal(Kon)': 'Chamchamal',
    'Darbandixan': 'Darbandikhan',
    'HajiAwa': 'Ranya(Kon)',
    'HalabjaN': 'Halabja',
    'Halabja2': 'Halabja',
    'Kfri': 'Kifri',
    'Penjuin': 'Slemani',
    'Penjwen': 'Slemani',
    'Piramagrun': 'Dukan',
    'Ranya': 'Ranya(Kon)',
    'SaidSadiq': 'SaidSadq',
    'Slemany': 'Slemani',
    'Sulaymaniyah': 'Slemani',
    'Suleimaniyah': 'Slemani',
    'Sulaimaniyah': 'Slemani',
    'Takya': 'Chamchamal',
    'TaqTaq': 'Taqtaq',
    'Tasluja': 'Slemani',
    'Xalakan': 'Dukan',
    'Zaxo': 'Zakho',
    'mosul': 'Mosul',
    'tuzxurmatu': 'Dwz',
    'Tuz': 'Dwz',
    'Hewler': 'Hawler',
    'Erbil': 'Hawler',
    'سلێمانی': 'Slemani',
    'السليمانية': 'Slemani',
    'هەولێر': 'Hawler',
    'أربيل': 'Hawler',
    'دهۆک': 'Duhok',
    'دهوك': 'Duhok',
    'زاخۆ': 'Zakho',
    'زاخو': 'Zakho',
    'هەڵەبجە': 'Halabja',
    'حلبجة': 'Halabja',
    'کالار': 'Kalar',
    'كalar': 'Kalar',
    'کەرکووك': 'Kirkuk',
    'كركوك': 'Kirkuk',
    'موسڵ': 'Mosul',
    'الموصل': 'Mosul',
    'ئاکرێ': 'Akre',
    'العمادية': 'Akre',
    'دوکان': 'Dukan',
    'دوكان': 'Dukan',
    'ڕانیه': 'Ranya(Kon)',
    'رانية': 'Ranya(Kon)',
    'چمچمال': 'Chamchamal',
    'قەلادزێ': 'Qaladze',
    'قلادزة': 'Qaladze',
    'دەربەندیخان': 'Darbandikhan',
    'دربنديخان': 'Darbandikhan',
    'سەید سادق': 'SaidSadq',
    'السيد صادق': 'SaidSadq',
    'دوز': 'Dwz',
    'طوز': 'Dwz',
    'پێنجوێن': 'Slemani',
    'بنجوين': 'Slemani',
  };

  static String _normalizeCity(String city) {
    var c = city.trim();
    final direct = _cityReplacements[c];
    if (direct != null) return direct;
    for (final e in _cityReplacements.entries) {
      if (c.contains(e.key)) {
        return e.value;
      }
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

  /// [includeIraq] false: Primary Kurdistan cities. True: cities from [KurdistanPrayerTimes.db] by country.
  static Future<List<PrayerCityModel>> getCities(
      {bool includeIraq = false}) async {
    if (!includeIraq) {
      final list = <PrayerCityModel>[];
      for (final table in _kurdistanPrimaryCities) {
        final variants = _cityNameVariants[table];
        list.add(PrayerCityModel(
          id: table,
          name: table,
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
    'Kalar': ['کالار', 'كلار', 'Kalar'],
    'کالار': ['کالار', 'كلار', 'Kalar'],
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
    'Kfri': ['کفری', 'كفري', 'Kifri'],
    'Kifri': ['کفری', 'كفري', 'Kifri'],
    'Mosul': ['موسڵ', 'الموصل', 'Mosul'],
    'موسڵ': ['موسڵ', 'الموصل', 'Mosul'],
    'mosul': ['موسڵ', 'الموصل', 'Mosul'],
    'ئاکرێ': ['ئاکرێ', 'العمادية', 'Akre'],
    'Amedi': ['ئاکرێ', 'العمادية', 'Akre'],
    'Akre': ['ئاکرێ', 'عقرة', 'Akre'],
    'Dukan': ['دوکان', 'دوكان', 'Dukan'],
    'دوکان': ['دوکان', 'دوكان', 'Dukan'],
    'Piramagrun': ['پیرەمەگروون', 'بيرمكرون', 'Piramagrun'],
    'Ranya': ['ڕانیە', 'رانية', 'Ranya'],
    'Ranya(Kon)': ['ڕانیە', 'رانية', 'Ranya'],
    'ڕانیە': ['ڕانیە', 'رانية', 'Ranya'],
    'ڕانیه': ['ڕانیە', 'رانية', 'Ranya'],
    'Chamchamal': ['چەمچەماڵ', 'جمجمال', 'Chamchamal'],
    'چەمچەماڵ': ['چەمچەماڵ', 'جمجمال', 'Chamchamal'],
    'چمچمال': ['چەمچەماڵ', 'جمجمال', 'Chamchamal'],
    'Qaladze': ['قەڵادزێ', 'قلعة دزة', 'Qaladze'],
    'قەڵادزێ': ['قەڵادزێ', 'قلعة دزة', 'Qaladze'],
    'قەلادزێ': ['قەڵادزێ', 'قلعة دزة', 'Qaladze'],
    'Tasluja': ['تاسڵوجە', 'طاسلوجة', 'Tasluja'],
    'بەرزنجە': ['بەرزنجە', 'برزنجة', 'Barzanja'],
    'Barznja': ['بەرزنجە', 'برزنجة', 'Barzanja'],
    'دەربەندیخان': ['دەربەندیخان', 'دربنديخان', 'Darbandikhan'],
    'Darbandikhan': ['دەربەندیخان', 'دربنديخان', 'Darbandikhan'],
    'Darbandixan': ['دەربەندیخان', 'دربنديخان', 'Darbandikhan'],
    'پێنجوێن': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Penjwen': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Penjuin': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Penjwin': ['پێنجوێن', 'بنجوين', 'Penjwin'],
    'Dwz': ['دووزخورماتوو', 'طوزخورماتو', 'Tuz Khurmatu'],
    'tuzxurmatu': ['دووزخورماتوو', 'طوزخورماتو', 'Tuz Khurmatu'],
    'Tuz': ['دووزخورماتوو', 'طوزخورماتو', 'Tuz Khurmatu'],
    'SaidSadiq': ['سەید سادق', 'سيد صادق', 'Said Sadiq'],
    'SaidSadq': ['سەید سادق', 'سيد صادق', 'Said Sadiq'],
    'سەید سادق': ['سەید سادق', 'سيد صادق', 'Said Sadiq'],
    'Khurmal': ['خورماڵ', 'خورمال', 'Khurmal'],
    'Koya': ['کۆیە', 'كوية', 'Koya'],
    'Soran': ['سۆران', 'سوران', 'Soran'],
    'Taqtaq': ['تەق تەق', 'طقطق', 'Taqtaq'],
    'Bardarash': ['بەردەڕەش', 'بردرش', 'Bardarash'],
    'Khanaqin': ['خانەقین', 'خانقين', 'Khanaqin'],
    'Qasrok': ['قەسرۆک', 'قصروك', 'Qasrok'],
    'Shekhan': ['شێخان', 'شيخان', 'Shekhan'],
    'Sinjar': ['شنگال', 'سنجار', 'Sinjar'],
  };

  /// Today's date: try common formats (MM-dd, dd-MM, yyyy-MM-dd).
  static List<String> _dateStrVariants(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return ['$m-$d', '$d-$m', '$y-$m-$d'];
  }

  /// Prayer times for a city and date from [KurdistanPrayerTimes.db] (or API fallback).
  /// Returns 5 prayers (Fajr, Dhuhr, Asr, Maghrib, Isha).
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
          "SELECT * FROM PrayerTimesforKurdistantable WHERE (cities = ? OR cities = ?) AND (date = ? OR date = ?)",
          [cityKey, city.trim(), dateVariant, dateVariant],
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
    final total = parsePrayerTimeMinutes(timeString);
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

  /// Fetches Sunrise (Xorhalatn) and calculates Duha prayer time (starts ~20 mins after sunrise).
  /// Returns a map with 'sunrise' and 'duha' strings, or '--:--' if unavailable.
  static Future<Map<String, String>> getSunriseAndDuhaTimes({
    required String city,
    DateTime? date,
  }) async {
    final useDate = date ?? DateTime.now();
    final dateVariants = _dateStrVariants(useDate);
    final db = await DhikrDb.database;
    final hasTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='PrayerTimesforKurdistantable'",
    );
    if (hasTable.isEmpty) return {'sunrise': '--:--', 'duha': '--:--'};

    final normalizedCity = _normalizeCity(city);
    final cityVariants = normalizedCity != city.trim()
        ? [normalizedCity, city.trim()]
        : [normalizedCity];

    for (final cityKey in cityVariants) {
      for (final dateVariant in dateVariants) {
        final rows = await db.rawQuery(
          "SELECT xorhalatn FROM PrayerTimesforKurdistantable WHERE (cities = ? OR cities = ?) AND (date = ? OR date = ?)",
          [cityKey, city.trim(), dateVariant, dateVariant],
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          final sunrise = (row['xorhalatn'] ?? '').toString().trim();
          if (sunrise.isNotEmpty && sunrise != '--:--') {
            final sunriseMin = parsePrayerTimeMinutes(sunrise);
            if (sunriseMin != null) {
              final duhaMin = (sunriseMin + 20) % (24 * 60);
              final dh = (duhaMin ~/ 60).toString().padLeft(2, '0');
              final dm = (duhaMin % 60).toString().padLeft(2, '0');
              final duhaTime = '$dh:$dm';
              return {'sunrise': sunrise, 'duha': duhaTime};
            }
          }
        }
      }
    }
    return {'sunrise': '--:--', 'duha': '--:--'};
  }

  /// Index of the next prayer (first whose time is after [now]).
  /// Times are parsed as HH:mm (prayer-aware). If all are past, returns 0 (next is Fajr tomorrow).
  static int getNextPrayerIndex(List<PrayerTimeModel> times, DateTime now) {
    if (times.isEmpty) return 0;
    final nowMinutes = now.hour * 60 + now.minute;
    for (var i = 0; i < times.length; i++) {
      final m = _parseMinutes(times[i].name, times[i].timeString);
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
    final nextMinutes = _parseMinutes(next.name, next.timeString);
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

  static int? _parseMinutes(String prayerName, String timeString) =>
      parsePrayerTimeMinutesForPrayer(prayerName, timeString);
}
