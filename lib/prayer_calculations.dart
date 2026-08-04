import 'package:the_open_quran/constants/prayer_times_storage.dart';
import 'package:the_open_quran/models/prayer_time_model.dart';
import 'package:the_open_quran/services/prayer_times_source.dart';

/// Prayer times calculation helper (uses [PrayerTimesSourceRegistry]).
class PrayerCalculations {
  PrayerCalculations._();

  /// Get today's prayer times for a city.
  /// When [countryIso] is null, uses the last selected country from storage (for world mode).
  static Future<List<PrayerTimeModel>> getPrayerTimes(
    String city, {
    bool includeIraq = false,
    String? countryIso,
  }) {
    return PrayerTimesSourceRegistry.instance.getTodayPrayerTimes(
      city,
      includeIraq: includeIraq,
      countryIso: countryIso ?? PrayerTimesStorage.readCountryIso(),
    );
  }
}
