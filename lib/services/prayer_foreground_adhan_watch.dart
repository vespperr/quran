import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/prayer_time_model.dart';
import '../utils/prayer_time_datetime.dart';

/// **Foreground-only** prayer-time watcher. Runs a 1 Hz tick and invokes
/// [onPrayerWindowStart] once per prayer when [DateTime.now] enters the first
/// second of that prayer’s minute (see [isWithinFirstSecondAfterPrayer]).
///
/// Why this exists alongside [PrayerNotificationService]:
/// - **Background / killed / locked screen:** `Timer` and `Stream` do **not**
///   run reliably. This app uses **AlarmManager** (Android) + **scheduled**
///   notifications (iOS) with exact wall-clock times; that is the supported
///   path for “adhan when the app is not open”.
/// - **Foreground (app visible):** this class can reinforce the same instant,
///   drive UI countdowns, or play in-app audio without waiting for the OS alarm.
///
/// Call [start] when the prayer screen becomes visible and [stop] in [dispose].
/// When the calendar day changes, refresh [times] via [updatePrayerTimes].
class PrayerForegroundAdhanWatch {
  PrayerForegroundAdhanWatch({
    required this.times,
    required this.onPrayerWindowStart,
  });

  /// Today’s prayer rows (same strings as SQLite / UI).
  List<PrayerTimeModel> times;

  /// Called at most once per prayer name per local calendar day when the
  /// current time falls in `[prayerAt, prayerAt + 1s)`.
  final void Function(String prayerName, DateTime prayerAt) onPrayerWindowStart;

  Timer? _timer;
  final Set<String> _firedToday = {};
  DateTime? _lastDay;

  void updatePrayerTimes(List<PrayerTimeModel> newTimes) {
    times = newTimes;
    _firedToday.clear();
  }

  /// Starts the periodic check (1 Hz). Idempotent: restarts if already running.
  void start() {
    stop();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  /// Stops the periodic check (call from [State.dispose]).
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastDay == null || _lastDay != today) {
      _firedToday.clear();
      _lastDay = today;
    }

    for (final t in times) {
      if (_firedToday.contains(t.name)) continue;
      final at = prayerTimeStringToLocalDateTime(t.name, t.timeString, today);
      if (at == null) continue;
      if (isWithinFirstSecondAfterPrayer(now, at)) {
        _firedToday.add(t.name);
        if (kDebugMode) {
          print('[PrayerForegroundAdhanWatch] ${t.name} at $at (now=$now)');
        }
        onPrayerWindowStart(t.name, at);
      }
    }
  }
}
