import 'package:get_storage/get_storage.dart';

/// Keys for prayer city + which bundled DB to use (Kurdistan-only vs Iraq/Iran-wide).
class PrayerTimesStorage {
  PrayerTimesStorage._();

  static const String boxName = 'FabrikodQuran';
  static const String keyCity = 'prayer_times_city';

  /// When false: [kurdistandb.sqlite] (Kurdistan). When true: [KurdistanPrayerTimes.db] (country + city).
  static const String keyIncludeIraq = 'prayer_times_include_iraq';

  /// ISO 3166-1 alpha-2 for [KurdistanPrayerTimes.db] city list (when [keyIncludeIraq] is true).
  static const String keyCountryIso = 'prayer_times_country_iso';

  static bool readIncludeIraq() {
    final v = GetStorage(boxName).read(keyIncludeIraq);
    if (v is bool) return v;
    return false;
  }

  /// Last selected country for world DB; uppercased ISO code or null.
  static String? readCountryIso() {
    final v = GetStorage(boxName).read(keyCountryIso);
    if (v is String && v.trim().isNotEmpty) return v.trim().toUpperCase();
    return null;
  }
}
