/// Adhan (prayer call) audio files.
///
/// **Android:** The list of adhan options and in-app playback are handled in Kotlin
/// ([AdhanOptions.kt], [AdhanPlayer.kt]). This file is not used for the dropdown or play on Android.
///
/// **iOS:** This file defines [options] (labels + asset paths) and is used for the adhan dropdown
/// and for in-app playback via [AdhanAudioService]. Add entries when you add new audio files to lib/assets/bang/.
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
    AdhanAudioOption(label: 'بانگی ڕاست خام — نێوەرەوی عصر', rawName: 'bang_rast_nawrozh_asr'),
    AdhanAudioOption(label: 'أذان الحجاز ٢', rawName: 'adhan_hijaz_2'),
    AdhanAudioOption(label: 'أذان العراقي جديد', rawName: 'adhan_iraqi_new'),
    AdhanAudioOption(label: 'أذان کورد ٢', rawName: 'adhan_kurd_2'),
    AdhanAudioOption(label: 'بانگی بیلالی حەبەشی — بەیانیان', rawName: 'bang_bilali_habashi_fajr'),
    AdhanAudioOption(label: 'بانگی حەزینی کورد — عیشایان', rawName: 'bang_hazini_kurd_isha'),
    AdhanAudioOption(label: 'بانگی ڕاست ٢ — نێوەرەوی عصر', rawName: 'bang_rast_2_nawrozh_asr'),
    AdhanAudioOption(label: 'بانگی کورد — بەیانی', rawName: 'bang_kurd_fajr'),
    AdhanAudioOption(label: 'بانگی مەککی — حجاز (مغربان و عشایان)', rawName: 'bang_hijaz_maghrib_isha'),
    AdhanAudioOption(label: 'بانگی صبا — مغربان و عیشایان', rawName: 'bang_saba_maghrib_isha_asr'),
    AdhanAudioOption(label: 'م.رمزان شکور — بەیانی و مغربان', rawName: 'bang_ramazan_shakur_fajr_maghrib'),
    AdhanAudioOption(label: 'بانگی مەدینە — مغرب و عیشایان', rawName: 'bang_madinah_maghrib_isha'),
    AdhanAudioOption(label: 'بانگی لامی عێراقی ئازاد', rawName: 'bang_lami_iraqi_azad'),
    AdhanAudioOption(label: 'هۆمایۆن', rawName: 'bang_homayoun_hazin'),
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
