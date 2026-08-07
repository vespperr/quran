import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/timezone.dart' as tz;
import 'friday_sunnah_service.dart';

/// Service to handle weekly Friday local notification reminders.
class FridayNotificationService {
  FridayNotificationService._();

  static const String _keyFridayRemindersEnabled = 'friday_reminders_enabled';
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int notificationIdKahf = 9001;
  static const int notificationIdDua = 9002;

  static bool isEnabled() => true;

  static Future<void> setEnabled(bool enabled) async {
    await scheduleFridayNotifications();
  }

  /// Calculates the next occurrence of Friday at the target hour & minute.
  static tz.TZDateTime _nextInstanceOfFriday(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != DateTime.friday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedules recurring Friday morning and afternoon notifications (always active).
  static Future<void> scheduleFridayNotifications() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          const channel = AndroidNotificationChannel(
            'friday_reminders_channel',
            'Friday Reminders',
            description: 'Notifications for Friday Sunnahs and Surah Al-Kahf',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          );
          await androidPlugin.createNotificationChannel(channel);
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'friday_reminders_channel',
        'Friday Reminders',
        channelDescription: 'Notifications for Friday Sunnahs and Surah Al-Kahf',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      );

      // Friday Morning Reminder (09:00 AM)
      final scheduledKahf = _nextInstanceOfFriday(9, 0);
      try {
        await _plugin.zonedSchedule(
          id: notificationIdKahf,
          title: 'سُنن يوم الجمعة | Friday Sunnahs',
          body:
              'خوێندنەوەی سورەتی الكهف و ناردنی سڵاوات لەبیر مەکە ✨\nDon\'t forget to read Surah Al-Kahf & send Salawat today!',
          scheduledDate: scheduledKahf,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
          id: notificationIdKahf,
          title: 'سُنن يوم الجمعة | Friday Sunnahs',
          body:
              'خوێندنەوەی سورەتی الكهف و ناردنی سڵاوات لەبیر مەکە ✨\nDon\'t forget to read Surah Al-Kahf & send Salawat today!',
          scheduledDate: scheduledKahf,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      // Friday Afternoon Dua Reminder (04:30 PM / 16:30)
      final scheduledDua = _nextInstanceOfFriday(16, 30);
      try {
        await _plugin.zonedSchedule(
          id: notificationIdDua,
          title: 'ساتی وەڵامدانەوەی دوعا | Hour of Response',
          body:
              'ساتی وەڵامدانەوەی دوعایە؛ دوعاو پاڕانەوەکانت ڕووبکەرەوە خوای میهرەبان 🤲\nAbundant Dua time; don\'t miss the hour of response on Friday!',
          scheduledDate: scheduledDua,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
          id: notificationIdDua,
          title: 'ساتی وەڵامدانەوەی دوعا | Hour of Response',
          body:
              'ساتی وەڵامدانەوەی دوعایە؛ دوعاو پاڕانەوەکانت ڕووبکەرەوە خوای میهرەبان 🤲\nAbundant Dua time; don\'t miss the hour of response on Friday!',
          scheduledDate: scheduledDua,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      if (kDebugMode) {
        print('[FridayNotificationService] Scheduled Friday notifications for $scheduledKahf and $scheduledDua');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FridayNotificationService] Error scheduling Friday notifications: $e');
      }
    }
  }

  /// Cancels scheduled Friday notifications.
  static Future<void> cancelFridayNotifications() async {
    try {
      await _plugin.cancel(id: notificationIdKahf);
      await _plugin.cancel(id: notificationIdDua);
    } catch (_) {}
  }
}
