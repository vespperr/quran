/// Adhan (prayer call) audio files.
///
/// **Android:** The list of adhan options and in-app playback are handled in Kotlin
/// ([AdhanOptions.kt], [AdhanPlayer.kt]). This file is not used for the dropdown or play on Android.
///
/// **iOS:** This file defines [options] (labels + asset paths) and is used for the adhan dropdown
/// and for in-app playback via [AdhanAudioService]. Add entries when you add new audio files to lib/assets/bang/.
class AdhanAssets {
  AdhanAssets._();

  static const String _basePath = 'lib/assets/bang';

  /// Display label and asset path. Add your files here.
  static const List<Map<String, String>> options = [
    {'label': 'اذان رست ', 'path': '$_basePath/bang_1.mp3'},
    {'label': 'اذان رست٢', 'path': '$_basePath/bang_2.mp3'},
    {'label': 'اذان عراقي جديد', 'path': '$_basePath/bang_3.mp3'},
    {'label': 'اذان کورد ٢', 'path': '$_basePath/bang_4.mp3'},
    {'label': 'اذان بيلالي حبشي', 'path': '$_basePath/bang_5.mp3'},
    {'label': 'اذان حزيني کورد', 'path': '$_basePath/bang_6.mp3'},
    {'label': 'اذان رەست ٢', 'path': '$_basePath/bang_7.mp3'},
    {'label': 'اذان کورد', 'path': '$_basePath/bang_8.mp3'},
    {'label': 'اذان مککي', 'path': '$_basePath/bang_9.mp3'},
    {'label': 'اذان صبا', 'path': '$_basePath/bang_10.mp3'},
    {'label': 'اذان رمزان شکور', 'path': '$_basePath/bang_11.mp3'},
    {'label': 'اذان مدينة', 'path': '$_basePath/bang_12.mp3'},
    {'label': 'اذان لامي عێراقي ئازاد', 'path': '$_basePath/bang_13.mp3'},
    {'label': 'اذان هومايون', 'path': '$_basePath/bang_14.mp3'},
  ];

  /// Android res/raw/ resource names for notification sound (no extension).
  /// Order must match [options]: index 0 = Adhan 1, … 13 = Adhan 14.
  /// Files go in: android/app/src/main/res/raw/ as adhan1.mp3, adhan_5.mp3, etc. (via copyAdhanToRaw in build.gradle)
  static const List<String> rawResourceNames = [
    'adhan1',
    'adhan2',
    'adhan3',
    'adhan4',
    'adhan_5',
    'adhan_6',
    'adhan_7',
    'adhan_8',
    'adhan_9',
    'adhan_10',
    'adhan_11',
    'adhan_12',
    'adhan_13',
    'adhan_14',
  ];

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
