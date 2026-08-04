/// Country row for prayer times (distinct `iso` in [KurdistanPrayerTimes.db] `cities` table).
class PrayerCountryModel {
  const PrayerCountryModel({
    required this.iso,
    required this.displayName,
  });

  final String iso;
  final String displayName;

  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.toLowerCase().trim();
    return iso.toLowerCase().contains(q) || displayName.toLowerCase().contains(q);
  }
}
