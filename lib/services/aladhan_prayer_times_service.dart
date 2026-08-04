import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prayer_time_model.dart';

/// Fetches prayer times from [Aladhan](https://aladhan.com/prayer-times-api) when the bundled
/// SQLite has no row for a city/country (e.g. outside Iraq/Iran).
class AladhanPrayerTimesService {
  AladhanPrayerTimesService._();

  static const String _base = 'api.aladhan.com';
  static const List<String> _order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  /// Returns null on failure or empty response.
  static Future<List<PrayerTimeModel>?> fetchTimingsByCity({
    required String city,
    required String countryIso,
    required DateTime date,
  }) async {
    final iso = countryIso.trim().toUpperCase();
    if (iso.length != 2) return null;
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    final uri = Uri.https(_base, '/v1/timingsByCity', <String, String>{
      'city': city.trim(),
      'country': iso,
      'method': '2',
      'date': '$dd-$mm-$yyyy',
    });
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>?;
      if (data == null) return null;
      final inner = data['data'] as Map<String, dynamic>?;
      if (inner == null) return null;
      final timings = inner['timings'] as Map<String, dynamic>?;
      if (timings == null) return null;
      final list = <PrayerTimeModel>[];
      for (final name in _order) {
        final raw = timings[name];
        if (raw == null) {
          list.add(PrayerTimeModel(name: name, timeString: '--:--'));
          continue;
        }
        final s = _normalizeTimeString(raw.toString());
        list.add(PrayerTimeModel(name: name, timeString: s));
      }
      return list;
    } catch (_) {
      return null;
    }
  }

  /// Strip timezone suffixes like "(GMT+3)" from API strings.
  static String _normalizeTimeString(String s) {
    final t = s.trim();
    if (t.isEmpty) return '--:--';
    final head = t.split(RegExp(r'[\s(]')).first.trim();
    final parts = head.split(':');
    if (parts.length < 2) return '--:--';
    var h = int.tryParse(parts[0].trim());
    var m = int.tryParse(parts[1].trim());
    if (h == null || m == null) return '--:--';
    if (h < 0 || h > 23 || m < 0 || m > 59) return '--:--';
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
