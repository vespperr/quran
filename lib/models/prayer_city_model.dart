/// City option for prayer times (from cities table).
/// [name] is primary display; [nameCkb], [nameAr], [nameEn] used for search (CKB/AR/EN).
class PrayerCityModel {
  const PrayerCityModel({
    required this.id,
    required this.name,
    this.nameCkb,
    this.nameAr,
    this.nameEn,
  });

  final String id;
  final String name;
  final String? nameCkb;
  final String? nameAr;
  final String? nameEn;

  /// True if [query] matches this city in CKB (Kurdish), Arabic, or English.
  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    final q = _normalizeForSearch(query.trim());
    final targets = [
      name,
      nameCkb,
      nameAr,
      nameEn,
    ].whereType<String>().map(_normalizeForSearch).toList();
    for (final t in targets) {
      if (t.contains(q)) return true;
    }
    return false;
  }

  static String _normalizeForSearch(String s) {
    return s.toLowerCase().trim();
  }
}
