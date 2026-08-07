/// Adhan (prayer call) audio files.
///
/// **Android:** Handled natively via [AdhanPlayer.kt] reading raw resources.
/// **iOS:** Defined via [options] reading asset paths in [AdhanAudioService].
class AdhanAudioOption {
  final String label;
  final String rawName;

  const AdhanAudioOption({required this.label, required this.rawName});

  String get path => 'assets/audio/$rawName.mp3';

  Map<String, String> toMap() => {
        'label': label,
        'rawName': rawName,
        'path': path,
      };
}

/// Adhan (prayer call) audio files. Single unified source of truth for all platforms.
class AdhanAssets {
  AdhanAssets._();

  /// Unified options list for all platforms (iOS & Android)
  static const List<AdhanAudioOption> allOptions = [
    AdhanAudioOption(label: 'أذان المكي - حجازي', rawName: 'bang_hijaz_maghrib_isha'),
    AdhanAudioOption(label: 'أذان حزين', rawName: 'adhan_kurd_2'),
    AdhanAudioOption(label: 'أذان رست ٢', rawName: 'bang_rast_2_nawrozh_asr'),
    AdhanAudioOption(label: 'أذان سنتى - بلال الحبشي', rawName: 'bang_bilali_habashi_fajr'),
    AdhanAudioOption(label: 'أذان م. رمضان شكور', rawName: 'bang_ramazan_shakur_fajr_maghrib'),
    AdhanAudioOption(label: 'أذان العراقي ٢', rawName: 'adhan_iraqi_new'),
    AdhanAudioOption(label: 'أذان صبا - السريحي', rawName: 'bang_saba_maghrib_isha_asr'),
    AdhanAudioOption(label: 'أذان مدينة', rawName: 'bang_madinah_maghrib_isha'),
    AdhanAudioOption(label: 'أذان هومايون', rawName: 'bang_homayoun_hazin'),
    AdhanAudioOption(label: 'أذان كرد (خۆم)', rawName: 'adhan_kurd_xom'),
    AdhanAudioOption(label: 'أذان رست ١', rawName: 'bang_rast_nawrozh_asr'),
    AdhanAudioOption(label: 'أذان العراقي ١', rawName: 'bang_lami_iraqi_azad'),
    AdhanAudioOption(label: 'أذان كرد - آزاد الكردي', rawName: 'bang_kurd_fajr'),
  ];

  /// Legacy map options getter (backwards compatible)
  static List<Map<String, String>> get options =>
      allOptions.map((o) => o.toMap()).toList();

  /// Raw resource names list
  static List<String> get rawResourceNames =>
      allOptions.map((o) => o.rawName).toList();

  /// Key for "No sound".
  static const String none = '';

  /// Returns the asset path to use for [prayerName]. All prayers use [standardPath].
  static String pathForPrayer(String prayerName, String standardPath) {
    return standardPath;
  }

  static String? pathForValue(String? value) {
    if (value == null || value == none) return null;
    for (final o in options) {
      if (o['path'] == value) return value;
    }
    return null;
  }
}
