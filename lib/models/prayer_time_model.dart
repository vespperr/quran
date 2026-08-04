/// One prayer slot (e.g. Fajr, Dhuhr) with display name and time string.
class PrayerTimeModel {
  const PrayerTimeModel({
    required this.name,
    required this.timeString,
  });

  final String name;
  final String timeString;
}

/// Result of [PrayerTimesDb.getNextPrayerWithDuration].
class NextPrayerInfo {
  const NextPrayerInfo({
    required this.next,
    required this.until,
    required this.isTomorrow,
  });
  final PrayerTimeModel next;
  final Duration until;
  final bool isTomorrow;
}
