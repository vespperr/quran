import '../database/prayer_times_db.dart';
import '../models/prayer_city_model.dart';
import '../models/prayer_country_model.dart';
import '../models/prayer_time_model.dart';

/// Abstraction for prayer times data (bundled DB today; remote API in a later phase).
abstract class PrayerTimesSource {
  String get defaultCity;

  Future<List<PrayerCityModel>> getCities({bool includeIraq = false});

  /// Distinct countries (non-Kurdistan rows) in [KurdistanPrayerTimes.db].
  Future<List<PrayerCountryModel>> getPrayerCountries();

  /// Cities for one ISO country code in [KurdistanPrayerTimes.db].
  Future<List<PrayerCityModel>> getCitiesForCountryIso(String iso);

  Future<List<PrayerTimeModel>> getPrayerTimesForDate({
    required String city,
    String? dateStr,
    DateTime? date,
    bool includeIraq = false,
    String? countryIso,
  });

  Future<List<PrayerTimeModel>> getTodayPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  });

  Future<List<PrayerTimeModel>> getTomorrowPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  });
}

/// Precomputed times from [PrayerTimesDb]: Kurdistan uses [kurdistandb.sqlite]; other countries use
/// [KurdistanPrayerTimes.db] (pick country, then city; `Jegir != 1` when column exists).
///
/// City keys must match the `cities` column after [_normalizeCity] in the DB layer.
class LocalDbPrayerTimesSource implements PrayerTimesSource {
  @override
  String get defaultCity => PrayerTimesDb.defaultCity;

  @override
  Future<List<PrayerCityModel>> getCities({bool includeIraq = false}) =>
      PrayerTimesDb.getCities(includeIraq: includeIraq);

  @override
  Future<List<PrayerCountryModel>> getPrayerCountries() => PrayerTimesDb.getPrayerCountries();

  @override
  Future<List<PrayerCityModel>> getCitiesForCountryIso(String iso) =>
      PrayerTimesDb.getCitiesForCountryIso(iso);

  @override
  Future<List<PrayerTimeModel>> getPrayerTimesForDate({
    required String city,
    String? dateStr,
    DateTime? date,
    bool includeIraq = false,
    String? countryIso,
  }) =>
      PrayerTimesDb.getPrayerTimesForDate(
        city: city,
        dateStr: dateStr,
        date: date,
        includeIraq: includeIraq,
        countryIso: countryIso,
      );

  @override
  Future<List<PrayerTimeModel>> getTodayPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  }) =>
      PrayerTimesDb.getTodayPrayerTimes(city, includeIraq: includeIraq, countryIso: countryIso);

  /// See [PrayerTimesDb.fetchTodayPrayerTimesForCity] (explicit name for SQL “today + city” loads).
  Future<List<PrayerTimeModel>> fetchTodayPrayerTimesForCity(
    String cityName, {
    bool includeIraq = false,
    String? countryIso,
  }) =>
      PrayerTimesDb.fetchTodayPrayerTimesForCity(
        cityName,
        includeIraq: includeIraq,
        countryIso: countryIso,
      );

  @override
  Future<List<PrayerTimeModel>> getTomorrowPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  }) =>
      PrayerTimesDb.getTomorrowPrayerTimes(city, includeIraq: includeIraq, countryIso: countryIso);
}

/// Placeholder for future HTTP/API-backed regions (Phase C2).
class ApiPrayerTimesSource implements PrayerTimesSource {
  @override
  String get defaultCity => PrayerTimesDb.defaultCity;

  @override
  Future<List<PrayerCityModel>> getCities({bool includeIraq = false}) async {
    throw UnimplementedError('ApiPrayerTimesSource: wire preferred API + cache');
  }

  @override
  Future<List<PrayerCountryModel>> getPrayerCountries() async {
    throw UnimplementedError('ApiPrayerTimesSource: wire preferred API + cache');
  }

  @override
  Future<List<PrayerCityModel>> getCitiesForCountryIso(String iso) async {
    throw UnimplementedError('ApiPrayerTimesSource: wire preferred API + cache');
  }

  @override
  Future<List<PrayerTimeModel>> getPrayerTimesForDate({
    required String city,
    String? dateStr,
    DateTime? date,
    bool includeIraq = false,
    String? countryIso,
  }) async {
    throw UnimplementedError('ApiPrayerTimesSource: wire preferred API + cache');
  }

  @override
  Future<List<PrayerTimeModel>> getTodayPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  }) async {
    throw UnimplementedError('ApiPrayerTimesSource: wire preferred API + cache');
  }

  @override
  Future<List<PrayerTimeModel>> getTomorrowPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  }) async {
    throw UnimplementedError('ApiPrayerTimesSource: wire preferred API + cache');
  }
}

/// Global entry point: swap to [ApiPrayerTimesSource] when remote regions ship.
class PrayerTimesSourceRegistry {
  PrayerTimesSourceRegistry._();

  static PrayerTimesSource instance = LocalDbPrayerTimesSource();
}
