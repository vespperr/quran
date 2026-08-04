import 'prayer_time_parse.dart';

/// Converts a DB time string (e.g. `12:45`, optional `12:45 PM`) into a **local**
/// [DateTime] on [day] with second, millisecond, and microsecond set to **0**.
///
/// Dart's unnamed [DateTime] constructor always uses the **device's local** zone
/// (equivalent to “isLocal: true” in other APIs). Do **not** use [DateTime.utc] for
/// prayer wall times from the database.
///
/// Returns `null` for invalid or placeholder values (`--:--`).
DateTime? prayerTimeStringToLocalDateTime(String prayerName, String timeString, DateTime day) {
  final mins = parsePrayerTimeMinutesForPrayer(prayerName, timeString);
  if (mins == null) return null;
  final h = mins ~/ 60;
  final m = mins % 60;
  return DateTime(day.year, day.month, day.day, h, m, 0, 0, 0);
}

/// Strips sub-minute components for comparisons that should ignore seconds and ms.
DateTime truncateToMinute(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
}

/// True if [a] and [b] fall in the same calendar minute (local).
bool isSameCalendarMinute(DateTime a, DateTime b) {
  return truncateToMinute(a) == truncateToMinute(b);
}

/// True while [now] is in the **first wall-clock second** starting at [prayerAt]
/// (i.e. `[prayerAt, prayerAt + 1s)`). Use this with a 1 Hz tick so the adhan
/// fires on the first second of the prayer minute, not a random second within it.
///
/// [prayerAt] should be built with [prayerTimeStringToLocalDateTime] (seconds = 0).
bool isWithinFirstSecondAfterPrayer(DateTime now, DateTime prayerAt) {
  return !now.isBefore(prayerAt) && now.isBefore(prayerAt.add(const Duration(seconds: 1)));
}
