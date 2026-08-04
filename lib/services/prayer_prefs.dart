import 'package:get_storage/get_storage.dart';

/// Persisted preferences for prayer notifications and adhan sound.
class PrayerPrefs {
  PrayerPrefs._();

  static const String _storageKeyPrefix = 'prayer_notify_';
  static const String _adhanKey = 'prayer_adhan_asset';
  static const String _adhanRawKey = 'prayer_adhan_raw';
  static const String _box = 'FabrikodQuran';

  /// True if user has ever set at least one prayer notification preference.
  static bool _hasAnyNotificationPrefSet() {
    const names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final box = GetStorage(_box);
    for (final n in names) {
      if (box.hasData('$_storageKeyPrefix$n')) return true;
    }
    return false;
  }

  static bool isNotificationEnabled(String prayerName) {
    final box = GetStorage(_box);
    final key = '$_storageKeyPrefix$prayerName';
    // First run: no prefs set → default all to true so auto-schedule works.
    if (!_hasAnyNotificationPrefSet()) return true;
    return box.read(key) ?? false;
  }

  static Future<void> setNotificationEnabled(String prayerName, bool value) async {
    await GetStorage(_box).write('$_storageKeyPrefix$prayerName', value);
  }

  /// Selected adhan asset path (iOS) or empty. On Android use [adhanRawName].
  static String get adhanAsset =>
      GetStorage(_box).read(_adhanKey) as String? ?? '';

  /// Selected adhan raw resource name (Android only). Empty = no sound.
  static String get adhanRawName =>
      GetStorage(_box).read(_adhanRawKey) as String? ?? '';

  static Future<void> setAdhanAsset(String path) async {
    await GetStorage(_box).write(_adhanKey, path);
  }

  static Future<void> setAdhanRawName(String rawName) async {
    await GetStorage(_box).write(_adhanRawKey, rawName);
  }

  static const String _adhanDurationKey = 'prayer_adhan_duration_ms';

  /// Selected adhan playback duration in milliseconds. -1 means full duration.
  static int get adhanDurationMs =>
      GetStorage(_box).read(_adhanDurationKey) as int? ?? 3000;

  static Future<void> setAdhanDurationMs(int duration) async {
    await GetStorage(_box).write(_adhanDurationKey, duration);
  }

  static Map<String, bool> getAllNotificationPrefs() {
    const names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final map = <String, bool>{};
    for (final n in names) {
      map[n] = isNotificationEnabled(n);
    }
    return map;
  }

  // --- Adhkar reminders (morning / evening windows, local time) ---
  static const String _adhkarMorningKey = 'adhkar_reminder_morning';
  static const String _adhkarEveningKey = 'adhkar_reminder_evening';
  static const String _adhkarMorningHKey = 'adhkar_reminder_morning_h';
  static const String _adhkarMorningMKey = 'adhkar_reminder_morning_m';
  static const String _adhkarEveningHKey = 'adhkar_reminder_evening_h';
  static const String _adhkarEveningMKey = 'adhkar_reminder_evening_m';

  static bool get adhkarMorningReminderEnabled =>
      GetStorage(_box).read(_adhkarMorningKey) as bool? ?? false;

  static bool get adhkarEveningReminderEnabled =>
      GetStorage(_box).read(_adhkarEveningKey) as bool? ?? false;

  static int get adhkarMorningHour =>
      GetStorage(_box).read(_adhkarMorningHKey) as int? ?? 6;

  static int get adhkarMorningMinute =>
      GetStorage(_box).read(_adhkarMorningMKey) as int? ?? 0;

  static int get adhkarEveningHour =>
      GetStorage(_box).read(_adhkarEveningHKey) as int? ?? 17;

  static int get adhkarEveningMinute =>
      GetStorage(_box).read(_adhkarEveningMKey) as int? ?? 0;

  static Future<void> setAdhkarMorningReminderEnabled(bool v) async =>
      GetStorage(_box).write(_adhkarMorningKey, v);

  static Future<void> setAdhkarEveningReminderEnabled(bool v) async =>
      GetStorage(_box).write(_adhkarEveningKey, v);

  static Future<void> setAdhkarMorningTime(int hour, int minute) async {
    final box = GetStorage(_box);
    await box.write(_adhkarMorningHKey, hour);
    await box.write(_adhkarMorningMKey, minute);
  }

  static Future<void> setAdhkarEveningTime(int hour, int minute) async {
    final box = GetStorage(_box);
    await box.write(_adhkarEveningHKey, hour);
    await box.write(_adhkarEveningMKey, minute);
  }

  // --- Sunnah fasting reminders ---
  static const String _fastMonThuKey = 'fasting_rem_mon_thu';
  static const String _fastWhiteKey = 'fasting_rem_white_days';

  static bool get fastingMondayThursdayEnabled =>
      GetStorage(_box).read(_fastMonThuKey) as bool? ?? false;

  static bool get fastingWhiteDaysEnabled =>
      GetStorage(_box).read(_fastWhiteKey) as bool? ?? false;

  static Future<void> setFastingMondayThursdayEnabled(bool v) async =>
      GetStorage(_box).write(_fastMonThuKey, v);

  static Future<void> setFastingWhiteDaysEnabled(bool v) async =>
      GetStorage(_box).write(_fastWhiteKey, v);
}
