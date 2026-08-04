/// Parses prayer time strings from SQLite / UI (24h "HH:mm", optional 12h with AM/PM).
///
/// Returns minutes since midnight `[0, 24*60)`, or null if invalid / placeholder.
int? parsePrayerTimeMinutes(String timeString) {
  var s = timeString.trim();
  if (s.isEmpty || s == '--:--') return null;

  var isPm = false;
  var isAm = false;
  final upper = s.toUpperCase();
  if (upper.endsWith('PM') || upper.endsWith('P.M.')) {
    isPm = true;
    s = s.substring(0, s.length - (upper.endsWith('P.M.') ? 4 : 2)).trim();
  } else if (upper.endsWith('AM') || upper.endsWith('A.M.')) {
    isAm = true;
    s = s.substring(0, s.length - (upper.endsWith('A.M.') ? 4 : 2)).trim();
  }

  final parts = s.split(RegExp(r'[:\s]+'));
  if (parts.length < 2) return null;

  var h = int.tryParse(parts[0].trim());
  var m = int.tryParse(parts[1].trim());
  if (h == null || m == null) return null;

  if (isAm || isPm) {
    if (isAm) {
      if (h == 12) h = 0;
    } else if (isPm) {
      if (h != 12) h += 12;
    }
  }

  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return h * 60 + m;
}

/// Parses a DB time string into minutes since midnight, with a prayer-aware fix for
/// legacy tables that store *evening* prayers as `6:42` (meaning `18:42`) without a `PM` suffix.
///
/// Rule:
/// - If the original string contains an AM/PM marker (English `AM/PM` or `A.M./P.M.`),
///   we trust [parsePrayerTimeMinutes] as-is.
/// - Otherwise, if [prayerName] is `Asr`, `Maghrib`, or `Isha` and the parsed hour is `< 12`,
///   we treat it as PM by adding 12 hours.
int? parsePrayerTimeMinutesForPrayer(String prayerName, String timeString) {
  final raw = timeString.trim();
  final mins = parsePrayerTimeMinutes(raw);
  if (mins == null) return null;

  final upper = raw.toUpperCase();
  final hasAmPm = upper.contains('AM') || upper.contains('PM') || upper.contains('A.M.') || upper.contains('P.M.');
  if (hasAmPm) return mins;

  const pmPrayers = {'ASR', 'MAGHRIB', 'ISHA'};
  if (!pmPrayers.contains(prayerName.toUpperCase())) return mins;

  if (mins < 12 * 60) return mins + 12 * 60;
  return mins;
}
