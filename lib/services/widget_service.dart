import 'dart:convert';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String _appGroupId = 'group.com.dya.azadalkrd';
  static const List<String> _androidWidgetProviders = [
    'PrayerTimesWidgetProvider',
    'PrayerTimesWidgetSmallProvider',
    'PrayerTimesWidgetMediumProvider',
    'PrayerTimesWidgetLargeProvider',
  ];

  static Future<void> _ensureAppGroup() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (_) {}
  }

  /// Initializes default values when the app launches for the first time
  static Future<void> initializeDefaults() async {
    await _ensureAppGroup();
    await HomeWidget.saveWidgetData<String>('fajr', '--:--');
    await HomeWidget.saveWidgetData<String>('dhuhr', '--:--');
    await HomeWidget.saveWidgetData<String>('asr', '--:--');
    await HomeWidget.saveWidgetData<String>('maghrib', '--:--');
    await HomeWidget.saveWidgetData<String>('isha', '--:--');
    await HomeWidget.saveWidgetData<String>('next_prayer', 'Next: --:--');
    for (final provider in _androidWidgetProviders) {
      await HomeWidget.updateWidget(name: provider);
    }
    await HomeWidget.updateWidget(name: 'PrayerWidget');
  }

  /// Saves prayer times, city, and next prayer to home_widget and triggers UI update
  static Future<void> updatePrayerWidget({
    required Map<String, String> prayerTimes,
    String? nextPrayer,
    String? city,
  }) async {
    await _ensureAppGroup();

    if (city != null && city.isNotEmpty) {
      await HomeWidget.saveWidgetData<String>('widget_city', city);
    }

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

    final displayList = <String>[];
    if (prayerTimes['fajr'] != null) displayList.add('Fajr|${prayerTimes['fajr']}');
    if (prayerTimes['dhuhr'] != null) displayList.add('Dhuhr|${prayerTimes['dhuhr']}');
    if (prayerTimes['asr'] != null) displayList.add('Asr|${prayerTimes['asr']}');
    if (prayerTimes['maghrib'] != null) displayList.add('Maghrib|${prayerTimes['maghrib']}');
    if (prayerTimes['isha'] != null) displayList.add('Isha|${prayerTimes['isha']}');
    final displayTimesStr = displayList.join(';');
    if (displayList.isNotEmpty) {
      await HomeWidget.saveWidgetData<String>('display_times', displayTimesStr);
    }

    final jsonMap = {
      'city': city ?? '',
      'displayTimes': displayTimesStr,
      'fajr': prayerTimes['fajr'] ?? '',
      'dhuhr': prayerTimes['dhuhr'] ?? '',
      'asr': prayerTimes['asr'] ?? '',
      'maghrib': prayerTimes['maghrib'] ?? '',
      'isha': prayerTimes['isha'] ?? '',
      'nextPrayer': nextPrayer ?? '',
      'lastUpdated': DateTime.now().millisecondsSinceEpoch / 1000.0,
    };
    await HomeWidget.saveWidgetData<String>('widget_prayer_data_v1', jsonEncode(jsonMap));

    for (final provider in _androidWidgetProviders) {
      await HomeWidget.updateWidget(name: provider);
    }
    await HomeWidget.updateWidget(
      name: 'PrayerWidget',
      iOSName: 'PrayerWidget',
    );
  }
}
