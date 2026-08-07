import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// Manages persistent state for Friday Sunnahs checklist and Salawat counter.
class FridaySunnahService {
  FridaySunnahService._();

  static const String boxName = 'friday_sunnah_box';
  static const String _keyGhusl = 'sunnah_ghusl';
  static const String _keySiwak = 'sunnah_siwak';
  static const String _keyCleanClothes = 'sunnah_clean_clothes';
  static const String _keyEarlyMosque = 'sunnah_early_mosque';
  static const String _keyReadKahf = 'sunnah_read_kahf';
  static const String _keyDuaHour = 'sunnah_dua_hour';
  static const String _keySalawatCount = 'salawat_count';
  static const String _keyLastFridayId = 'last_friday_id';

  static final ValueNotifier<int> salawatCountNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<Map<String, bool>> checklistNotifier =
      ValueNotifier<Map<String, bool>>({});

  /// Initializes GetStorage and performs weekly reset check if a new Friday has arrived.
  static Future<void> init() async {
    await GetStorage.init(boxName);
    _checkWeeklyReset();
    _loadState();
  }

  /// Calculates a unique string ID for the Friday of the current week.
  static String _getCurrentFridayId() {
    final now = DateTime.now();
    final daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    final targetFriday = now.add(Duration(days: daysUntilFriday));
    return '${targetFriday.year}-${targetFriday.month}-${targetFriday.day}';
  }

  static void _checkWeeklyReset() {
    final box = GetStorage(boxName);
    final currentFridayId = _getCurrentFridayId();
    final lastFridayId = box.read<String>(_keyLastFridayId);

    if (lastFridayId != currentFridayId) {
      box.write(_keyLastFridayId, currentFridayId);
      box.write(_keyGhusl, false);
      box.write(_keySiwak, false);
      box.write(_keyCleanClothes, false);
      box.write(_keyEarlyMosque, false);
      box.write(_keyReadKahf, false);
      box.write(_keyDuaHour, false);
      box.write(_keySalawatCount, 0);
    }
  }

  static void _loadState() {
    final box = GetStorage(boxName);
    checklistNotifier.value = {
      'ghusl': box.read<bool>(_keyGhusl) ?? false,
      'siwak': box.read<bool>(_keySiwak) ?? false,
      'clean_clothes': box.read<bool>(_keyCleanClothes) ?? false,
      'early_mosque': box.read<bool>(_keyEarlyMosque) ?? false,
      'read_kahf': box.read<bool>(_keyReadKahf) ?? false,
      'dua_hour': box.read<bool>(_keyDuaHour) ?? false,
    };
    salawatCountNotifier.value = box.read<int>(_keySalawatCount) ?? 0;
  }

  static bool isChecked(String key) {
    return checklistNotifier.value[key] ?? false;
  }

  static void toggleCheck(String key) {
    final box = GetStorage(boxName);
    final current = isChecked(key);
    final newValue = !current;
    
    final map = Map<String, bool>.from(checklistNotifier.value);
    map[key] = newValue;
    checklistNotifier.value = map;

    switch (key) {
      case 'ghusl':
        box.write(_keyGhusl, newValue);
        break;
      case 'siwak':
        box.write(_keySiwak, newValue);
        break;
      case 'clean_clothes':
        box.write(_keyCleanClothes, newValue);
        break;
      case 'early_mosque':
        box.write(_keyEarlyMosque, newValue);
        break;
      case 'read_kahf':
        box.write(_keyReadKahf, newValue);
        break;
      case 'dua_hour':
        box.write(_keyDuaHour, newValue);
        break;
    }
  }

  static void incrementSalawat() {
    final box = GetStorage(boxName);
    final newCount = salawatCountNotifier.value + 1;
    salawatCountNotifier.value = newCount;
    box.write(_keySalawatCount, newCount);
  }

  static void resetSalawat() {
    final box = GetStorage(boxName);
    salawatCountNotifier.value = 0;
    box.write(_keySalawatCount, 0);
  }

  /// Returns true if today is Friday.
  static bool get isTodayFriday {
    return DateTime.now().weekday == DateTime.friday;
  }
}
