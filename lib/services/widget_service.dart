import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const List<String> _androidWidgetProviders = [
    'PrayerTimesWidgetProvider',
    'PrayerTimesWidgetSmallProvider',
    'PrayerTimesWidgetMediumProvider',
    'PrayerTimesWidgetLargeProvider',
  ];

  /// Initializes default values when the app launches for the first time
  static Future<void> initializeDefaults() async {
    await HomeWidget.saveWidgetData<String>('fajr', '--:--');
    await HomeWidget.saveWidgetData<String>('dhuhr', '--:--');
    await HomeWidget.saveWidgetData<String>('asr', '--:--');
    await HomeWidget.saveWidgetData<String>('maghrib', '--:--');
    await HomeWidget.saveWidgetData<String>('isha', '--:--');
    await HomeWidget.saveWidgetData<String>('next_prayer', 'Next: --:--');
    for (final provider in _androidWidgetProviders) {
      await HomeWidget.updateWidget(name: provider);
    }
  }

  /// Saves prayer times and next prayer to home_widget and triggers UI update
  static Future<void> updatePrayerWidget({
    required Map<String, String> prayerTimes,
    String? nextPrayer,
  }) async {
    if (prayerTimes.containsKey('fajr')) {
      await HomeWidget.saveWidgetData<String>('fajr', prayerTimes['fajr']);
    }
    if (prayerTimes.containsKey('dhuhr')) {
      await HomeWidget.saveWidgetData<String>('dhuhr', prayerTimes['dhuhr']);
    }
    if (prayerTimes.containsKey('asr')) {
      await HomeWidget.saveWidgetData<String>('asr', prayerTimes['asr']);
    }
    if (prayerTimes.containsKey('maghrib')) {
      await HomeWidget.saveWidgetData<String>('maghrib', prayerTimes['maghrib']);
    }
    if (prayerTimes.containsKey('isha')) {
      await HomeWidget.saveWidgetData<String>('isha', prayerTimes['isha']);
    }
    if (nextPrayer != null && nextPrayer.isNotEmpty) {
      await HomeWidget.saveWidgetData<String>('next_prayer', nextPrayer);
    }

    for (final provider in _androidWidgetProviders) {
      await HomeWidget.updateWidget(name: provider);
    }
  }
}
