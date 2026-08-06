import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:hijri/hijri_calendar.dart';

import '../constants/prayer_times_storage.dart';
import '../models/prayer_time_model.dart';
import 'adhan_audio_service.dart';
import 'prayer_foreground_adhan_watch.dart';
import 'prayer_prefs.dart';
import 'prayer_times_source.dart';
import '../utils/prayer_time_parse.dart';

/// Schedules and cancels prayer-time local notifications.
///
/// **Background / locked screen:** Do **not** rely on `Timer.periodic` or `Stream.periodic`
/// for adhan — they stop when the OS suspends the app. This service uses **exact
/// scheduled** alarms (native `AlarmManager` on Android, `zonedSchedule` on iOS) with
/// wall-clock times derived from **local** `DateTime`. For an optional **in-app** 1 Hz check
/// while the UI is visible, see
/// [PrayerForegroundAdhanWatch].
///
/// **Automated Athan notification logic:**
/// 1. Data: Location = selected city (from DB). User picks adhan sound in settings.
/// 2. Daily coverage: We schedule alarms for *today* (remaining times) and *tomorrow* (full day)
///    so the next day is always covered without a midnight job. When the user opens the app or
///    after boot we reschedule (today + tomorrow).
/// 3. Trigger: AlarmManager fires at exact prayer time. No background time observer (low power).
/// 4. At trigger: Native code plays ~3s of selected adhan (STREAM_ALARM), shows notification
///    with prayer name and a Stop action. User can stop/dismiss from lock screen.
///
/// Notification sound uses the currently selected adhan from preferences.
/// Notification body is trilingual (Kurdish, Arabic, English).
///
/// **Android raw resources (for notification sound):**
/// Copied from `lib/assets/bang/` via `copyAdhanToRaw` in `android/app/build.gradle`
/// to `adhan1.mp3` … `adhan_14.mp3` in `android/app/src/main/res/raw/`.
class PrayerNotificationService {
  PrayerNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Trilingual names for each prayer: [Kurdish, Arabic, English].
  static const Map<String, List<String>> _prayerNames = {
    'Fajr': ['بەیانی', 'الفجر', 'Fajr'],
    'Dhuhr': ['نیوەڕۆ', 'الظهر', 'Dhuhr'],
    'Asr': ['عەسر', 'العصر', 'Asr'],
    'Maghrib': ['ئێوارە', 'المغرب', 'Maghrib'],
    'Isha': ['خەوتنان', 'العشاء', 'Isha'],
  };

  /// Returns trilingual body for "It is time for {Prayer} prayer".
  /// Format: Kurdish line \n Arabic line \n English line.
  static String trilingualBodyForPrayerTime(String prayerName) {
    final names = _prayerNames[prayerName] ?? [prayerName, prayerName, prayerName];
    const kuPrefix = 'کاتی نوێژی ';
    const kuSuffix = ' هات';
    const arPrefix = 'حان الآن موعد صلاة ';
    const enPrefix = 'It is time for ';
    const enSuffix = ' prayer';
    return '$kuPrefix${names[0]}$kuSuffix\n$arPrefix${names[1]}\n$enPrefix${names[2]}$enSuffix';
  }

  /// Notification details for a specific prayer.
  /// Uses sound: null (system default) so the notification always shows on all devices.
  static NotificationDetails _detailsForPrayer(String? prayerName) {
    const channelId = 'prayer_times_channel';
    final adhanAsset = PrayerPrefs.adhanAsset;
    String? iosSoundName;
    if (Platform.isIOS && adhanAsset.isNotEmpty) {
      iosSoundName = adhanAsset.split('/').last;
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      'Prayer Times',
      channelDescription: 'Notifications at prayer times',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: null, // System default on Android; native AlarmManager plays Adhan audio
    );
    return NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        sound: iosSoundName,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  /// When user taps a prayer notification, play selected adhan if any.
  static void _onNotificationTapped(NotificationResponse response) {
    final id = response.id;
    if (id == null || id == 0) return;
    _playAdhanAfterNotificationTap();
  }

  static void _playAdhanAfterNotificationTap() {
    Future.delayed(const Duration(milliseconds: 600), () async {
      if (Platform.isAndroid) {
        try {
          await MethodChannel(_prayerAlarmsChannel).invokeMethod<void>('playAdhan', {'rawName': PrayerPrefs.adhanRawName});
        } catch (_) {}
      } else {
        final adhan = PrayerPrefs.adhanAsset;
        if (adhan.isNotEmpty) {
          AdhanAudioService.play(adhan, durationMs: PrayerPrefs.adhanDurationMs);
        }
      }
    });
  }

  /// Call from root widget when app starts. If launched by tapping a notification, plays the selected adhan.
  static Future<void> handleLaunchFromNotification() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return;
      final response = details.notificationResponse;
      if (response?.id == null || response!.id == 0) return;
      _playAdhanAfterNotificationTap();
    } catch (_) {}
  }

  /// Call once at app startup (e.g. after GetStorage.init).
  static Future<void> init() async {
    if (_initialized) return;
    if (kDebugMode) {
      print('[PrayerNotificationService] init: initializing timezone...');
    }
    tz_data.initializeTimeZones();
    // Prayer alarms use [DateTime] wall-clock + epoch millis. Do not use
    // [DateTime.timeZoneName] with [tz.getLocation] — it is not a reliable IANA id on Android.
    if (kDebugMode) {
      print('[PrayerNotificationService] init: device local DateTime ${DateTime.now()}');
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
    );
    if (Platform.isAndroid || Platform.isIOS) {
      await _plugin.initialize(
        settings: InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    }
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      // Create a high-importance channel so scheduled notifications can wake the device
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          'prayer_times_channel',
          'Prayer Times',
          description: 'Notifications at prayer times',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(channel);
        if (kDebugMode) {
          print('[PrayerNotificationService] init: created Android channel ${channel.id} with Importance.max');
        }
      }
    }
    _initialized = true;
    if (kDebugMode) {
      print('[PrayerNotificationService] init: done');
    }
  }

  /// Ensures notification permission and (on Android 12+) exact alarm permission are granted.
  /// Call before scheduling. Returns true if notification permission is granted.
  static Future<bool> ensurePermissions() async {
    // 1. Notification permission
    var status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.notification.request();
    }
    if (!status.isGranted) {
      if (kDebugMode) {
        print('[PrayerNotificationService] ensurePermissions: notification permission not granted');
      }
      return false;
    }
    if (kDebugMode) {
      print('[PrayerNotificationService] ensurePermissions: notification granted');
    }
    // 2. On Android 12+, exact alarm must be allowed: Settings > Apps > This app > Alarms & reminders.
    // permission_handler does not expose SCHEDULE_EXACT_ALARM; ensure it is in AndroidManifest.xml.
    if (Platform.isAndroid && kDebugMode) {
      print('[PrayerNotificationService] ensurePermissions: on Android 12+, enable Alarms & reminders in app settings if notifications do not fire.');
    }
    return true;
  }

  static const String _prayerAlarmsChannel = 'com.dya.azadalkrd/prayer_alarms';

  /// Raw resource name for selected adhan (for native Android). Null if none.
  static String? _getAdhanRawName() {
    if (!Platform.isAndroid) return null;
    final raw = PrayerPrefs.adhanRawName;
    return raw.isEmpty ? null : raw;
  }

  /// Call once at app start so reminders are scheduled even if user never opens Prayer tab.
  static Future<void> rescheduleFromStoredPrefs() async {
    if (!_initialized) await init();
    final granted = await ensurePermissions();
    if (!granted) {
      if (kDebugMode) {
        print('[PrayerNotificationService] rescheduleFromStoredPrefs: notification permission not granted, skipping schedule');
      }
      return;
    }
    final city = GetStorage(PrayerTimesStorage.boxName).read(PrayerTimesStorage.keyCity) as String? ??
        PrayerTimesSourceRegistry.instance.defaultCity;
    final includeIraq = PrayerTimesStorage.readIncludeIraq();
    final countryIso = PrayerTimesStorage.readCountryIso();
    try {
      final times = await PrayerTimesSourceRegistry.instance.getTodayPrayerTimes(
        city,
        includeIraq: includeIraq,
        countryIso: countryIso,
      );
      final notifyEnabled = PrayerPrefs.getAllNotificationPrefs();
      final count = await schedule(
        city: city,
        times: times,
        notifyEnabled: notifyEnabled,
        includeIraq: includeIraq,
        countryIso: countryIso,
      );
      if (kDebugMode && count != null) {
        print('[PrayerNotificationService] rescheduleFromStoredPrefs: scheduled $count notification(s) for city=$city');
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('[PrayerNotificationService] rescheduleFromStoredPrefs failed: $e');
        print(st);
      }
    }
    await scheduleAuxiliaryReminders();
  }

  /// Unique id per prayer (Fajr=1, Dhuhr=2, ...).
  static int _idForPrayer(String name) {
    const ids = {
      'Fajr': 1,
      'Dhuhr': 2,
      'Asr': 3,
      'Maghrib': 4,
      'Isha': 5,
    };
    return ids[name] ?? 0;
  }

  /// Build list of alarm maps for native Android: today's remaining + tomorrow's full day.
  /// Uses ids 1-5 for today, 6-10 for tomorrow (Fajr=1/6, Dhuhr=2/7, ...).
  ///
  /// Uses [DateTime] (device local wall clock) for trigger millis so alarms match the same
  /// times shown in the UI; [tz.local] from [DateTime.timeZoneName] is unreliable on Android.
  static Future<List<Map<String, dynamic>>> _buildAlarmListTwoDays(
    String city,
    List<PrayerTimeModel> timesToday,
    Map<String, bool> notifyEnabled, {
    required bool includeIraq,
    String? countryIso,
  }) async {
    final list = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var i = 0; i < timesToday.length; i++) {
      final model = timesToday[i];
      if (!(notifyEnabled[model.name] ?? false)) continue;
      final minutes = parsePrayerTimeMinutesForPrayer(model.name, model.timeString);
      if (minutes == null) continue;
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      final offsetMinutes = PrayerPrefs.getNotificationOffset(model.name);
      var scheduled = DateTime(today.year, today.month, today.day, hour, minute);
      if (offsetMinutes != 0) {
        scheduled = scheduled.add(Duration(minutes: offsetMinutes));
      }
      if (scheduled.isBefore(now)) continue;
      list.add({
        'id': _idForPrayer(model.name),
        'triggerAtMillis': scheduled.millisecondsSinceEpoch,
        'title': 'Prayer: ${model.name}',
        'body': trilingualBodyForPrayerTime(model.name),
        'prayerName': model.name,
      });
    }

    final timesTomorrow =
        await PrayerTimesSourceRegistry.instance.getTomorrowPrayerTimes(
      city,
      includeIraq: includeIraq,
      countryIso: countryIso,
    );
    final tomorrow = today.add(const Duration(days: 1));
    const tomorrowIdOffset = 5;
    for (var i = 0; i < timesTomorrow.length; i++) {
      final model = timesTomorrow[i];
      if (!(notifyEnabled[model.name] ?? false)) continue;
      final minutes = parsePrayerTimeMinutesForPrayer(model.name, model.timeString);
      if (minutes == null) continue;
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      final offsetMinutes = PrayerPrefs.getNotificationOffset(model.name);
      var scheduled = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);
      if (offsetMinutes != 0) {
        scheduled = scheduled.add(Duration(minutes: offsetMinutes));
      }
      list.add({
        'id': _idForPrayer(model.name) + tomorrowIdOffset,
        'triggerAtMillis': scheduled.millisecondsSinceEpoch,
        'title': 'Prayer: ${model.name}',
        'body': trilingualBodyForPrayerTime(model.name),
        'prayerName': model.name,
      });
    }

    return list;
  }

  /// Schedule notifications for today and tomorrow (daily coverage without midnight job).
  /// On Android uses native AlarmManager; on iOS uses flutter_local_notifications.
  /// Returns the number of notifications scheduled.
  static Future<int?> schedule({
    required String city,
    required List<PrayerTimeModel> times,
    required Map<String, bool> notifyEnabled,
    bool includeIraq = false,
    String? countryIso,
  }) async {
    if (!_initialized) await init();

    final enabledCount = notifyEnabled.values.where((v) => v == true).length;
    if (enabledCount == 0) {
      if (kDebugMode) {
        print('[PrayerNotificationService] schedule: no prayers enabled for notifications, nothing scheduled');
      }
      return 0;
    }

    if (Platform.isAndroid) {
      try {
        final channel = MethodChannel(_prayerAlarmsChannel);
        await channel.invokeMethod<void>('cancelPrayerAlarms');
        final alarms = await _buildAlarmListTwoDays(
          city,
          times,
          notifyEnabled,
          includeIraq: includeIraq,
          countryIso: countryIso,
        );
        final adhanRaw = _getAdhanRawName();
        final displayTimes = times
            .where((t) => t.timeString.isNotEmpty && t.timeString != '--:--')
            .map((t) => '${t.name}|${t.timeString}')
            .join(';');
        await channel.invokeMethod<void>('schedulePrayerAlarms', {
          'alarms': alarms,
          'adhanRawName': adhanRaw,
          'adhanDurationMs': PrayerPrefs.adhanDurationMs,
          'displayTimes': displayTimes,
          'widgetCity': city,
        });
        if (kDebugMode) {
          print('[PrayerNotificationService] schedule (native): ${alarms.length} alarms (today + tomorrow)');
        }
        return alarms.length;
      } catch (e) {
        if (kDebugMode) print('[PrayerNotificationService] schedule native failed: $e');
        return 0;
      }
    }

    await cancelAll();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var scheduledCount = 0;

    for (var i = 0; i < times.length; i++) {
      final model = times[i];
      if (!(notifyEnabled[model.name] ?? false)) continue;
      final minutes = parsePrayerTimeMinutesForPrayer(model.name, model.timeString);
      if (minutes == null) continue;
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      final offsetMinutes = PrayerPrefs.getNotificationOffset(model.name);
      var scheduled = DateTime(today.year, today.month, today.day, hour, minute);
      if (offsetMinutes != 0) {
        scheduled = scheduled.add(Duration(minutes: offsetMinutes));
      }
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final scheduledTz = tz.TZDateTime.from(scheduled, tz.local);

      await _scheduleOne(
        id: _idForPrayer(model.name),
        prayerName: model.name,
        title: 'Prayer: ${model.name}',
        body: trilingualBodyForPrayerTime(model.name),
        scheduledDate: scheduledTz,
      );
      scheduledCount++;
      if (kDebugMode) {
        print('[PrayerNotificationService] scheduled ${model.name} at $scheduled (local)');
      }
    }

    if (Platform.isIOS) {
      try {
        final displayTimes = times
            .where((t) => t.timeString.isNotEmpty && t.timeString != '--:--')
            .map((t) => '${t.name}|${t.timeString}')
            .join(';');
        const MethodChannel('com.dya.azadalkrd/prayer_widget').invokeMethod<void>(
          'updateWidgetData',
          {
            'widgetCity': city,
            'displayTimes': displayTimes,
          },
        );
      } catch (_) {}
    }

    return scheduledCount;
  }

  static Future<void> _scheduleOne({
    required int id,
    required String? prayerName,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    final details = _detailsForPrayer(prayerName);
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (_) {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelAll() async {
    if (!_initialized) return;
    if (Platform.isAndroid) {
      try {
        await MethodChannel(_prayerAlarmsChannel).invokeMethod<void>('cancelPrayerAlarms');
      } catch (_) {}
      return;
    }
    for (var id = 1; id <= 10; id++) {
      await _plugin.cancel(id: id);
    }
  }

  static const int _idAdhkarMorning = 201;
  static const int _idAdhkarEvening = 202;
  static const int _idFastingBase = 300;

  /// Schedules morning/evening adhkar reminders (daily) and optional fasting one-shots.
  /// Call after [init] (e.g. from app start). Uses local timezone.
  static Future<void> scheduleAuxiliaryReminders() async {
    if (!_initialized) await init();
    await _cancelAuxiliaryNotificationIds();
    if (PrayerPrefs.adhkarMorningReminderEnabled) {
      await _scheduleDailyRepeating(
        id: _idAdhkarMorning,
        title: 'Morning adhkar',
        body:
            'کاتی ئەذکاری بەیانی\nوقت أذكار الصباح\nTime for morning adhkar',
        hour: PrayerPrefs.adhkarMorningHour,
        minute: PrayerPrefs.adhkarMorningMinute,
      );
    }
    if (PrayerPrefs.adhkarEveningReminderEnabled) {
      await _scheduleDailyRepeating(
        id: _idAdhkarEvening,
        title: 'Evening adhkar',
        body:
            'کاتی ئەذکاری ئێواران\nوقت أذكار المساء\nTime for evening adhkar',
        hour: PrayerPrefs.adhkarEveningHour,
        minute: PrayerPrefs.adhkarEveningMinute,
      );
    }
    if (PrayerPrefs.fastingMondayThursdayEnabled) {
      await _scheduleNextMondayThursdayFasts();
    }
    if (PrayerPrefs.fastingWhiteDaysEnabled) {
      await _scheduleNextWhiteDayFasts();
    }
  }

  static Future<void> _cancelAuxiliaryNotificationIds() async {
    await _plugin.cancel(id: _idAdhkarMorning);
    await _plugin.cancel(id: _idAdhkarEvening);
    for (var id = _idFastingBase; id < _idFastingBase + 20; id++) {
      await _plugin.cancel(id: id);
    }
  }

  static tz.TZDateTime _nextInstanceOfLocalTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.UTC,
      scheduled.millisecondsSinceEpoch,
    );
  }

  static Future<void> _scheduleDailyRepeating({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduled = _nextInstanceOfLocalTime(hour, minute);
    final details = _detailsForPrayer(null);
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (_) {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> _scheduleNextMondayThursdayFasts() async {
    var id = _idFastingBase;
    var d = DateTime.now();
    d = DateTime(d.year, d.month, d.day);
    const maxSlots = 8;
    var count = 0;
    var guard = 0;
    while (count < maxSlots && id < _idFastingBase + 16 && guard < 500) {
      guard++;
      if (d.weekday == DateTime.monday || d.weekday == DateTime.thursday) {
        final at = DateTime(d.year, d.month, d.day, 5, 45);
        final now = DateTime.now();
        if (at.isAfter(now)) {
          final details = _detailsForPrayer(null);
          final atTz = tz.TZDateTime.fromMillisecondsSinceEpoch(
            tz.UTC,
            at.millisecondsSinceEpoch,
          );
          try {
            await _plugin.zonedSchedule(
              id: id,
              title: 'Sunnah fast (Mon/Thu)',
              body:
                  'یادکردنەوەی ڕۆژوو\nتذكير صيام السنة\nOptional sunnah fast reminder',
              scheduledDate: atTz,
              notificationDetails: details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          } on PlatformException catch (_) {
            await _plugin.zonedSchedule(
              id: id,
              title: 'Sunnah fast (Mon/Thu)',
              body:
                  'یادکردنەوەی ڕۆژوو\nتذكير صيام السنة\nOptional sunnah fast reminder',
              scheduledDate: atTz,
              notificationDetails: details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          }
          id++;
          count++;
        }
      }
      d = d.add(const Duration(days: 1));
    }
  }

  static Future<void> _scheduleNextWhiteDayFasts() async {
    var id = _idFastingBase + 10;
    if (id > _idFastingBase + 19) return;
    var d = DateTime.now();
    d = DateTime(d.year, d.month, d.day);
    for (var i = 0; i < 120 && id <= _idFastingBase + 19; i++) {
      final h = HijriCalendar.fromDate(d);
      if (h.hDay >= 13 && h.hDay <= 15) {
        final at = DateTime(d.year, d.month, d.day, 5, 30);
        final now = DateTime.now();
        if (at.isAfter(now)) {
          final details = _detailsForPrayer(null);
          final atTz = tz.TZDateTime.fromMillisecondsSinceEpoch(
            tz.UTC,
            at.millisecondsSinceEpoch,
          );
          try {
            await _plugin.zonedSchedule(
              id: id,
              title: 'White days fasting',
              body:
                  'ڕۆژووەی ڕۆژە سپییەکان\nصيام الأيام البيض\nSunnah fast (white days)',
              scheduledDate: atTz,
              notificationDetails: details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          } on PlatformException catch (_) {
            await _plugin.zonedSchedule(
              id: id,
              title: 'White days fasting',
              body:
                  'ڕۆژووەی ڕۆژە سپییەکان\nصيام الأيام البيض\nSunnah fast (white days)',
              scheduledDate: atTz,
              notificationDetails: details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          }
          id++;
        }
      }
      d = d.add(const Duration(days: 1));
    }
  }
}
