import 'package:get_storage/get_storage.dart';

/// Persists per-day tap counts for interactive athkar (morning / evening / bedtime).
class AdhkarCounterStorage {
  AdhkarCounterStorage._();

  static const String _boxName = 'FabrikodQuran';
  static const String _prefix = 'adhkar_count_v1_';

  static String _dateKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static String _key(String sectionId, int dhikrId) =>
      '$_prefix${_dateKey()}_${sectionId}_$dhikrId';

  static GetStorage get _box => GetStorage(_boxName);

  static int readCount(String sectionId, int dhikrId) {
    final v = _box.read(_key(sectionId, dhikrId));
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  static Future<void> setCount(String sectionId, int dhikrId, int count) async {
    await _box.write(_key(sectionId, dhikrId), count);
  }

  static Future<void> reset(String sectionId, int dhikrId) async {
    await _box.remove(_key(sectionId, dhikrId));
  }
}

/// User-chosen repeat target per dhikr (optional). If unset, app defaults apply.
class AdhkarTargetStorage {
  AdhkarTargetStorage._();

  static const String _boxName = 'FabrikodQuran';
  static const String _prefix = 'adhkar_target_v1_';

  static String _key(String sectionId, int dhikrId) =>
      '$_prefix${sectionId}_$dhikrId';

  static GetStorage get _box => GetStorage(_boxName);

  /// Null → use built-in defaults for this dhikr row.
  static int? readTarget(String sectionId, int dhikrId) {
    final v = _box.read(_key(sectionId, dhikrId));
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  static Future<void> setTarget(String sectionId, int dhikrId, int target) async {
    final t = target < 1 ? 1 : target;
    await _box.write(_key(sectionId, dhikrId), t);
  }

  static Future<void> clearTarget(String sectionId, int dhikrId) async {
    await _box.remove(_key(sectionId, dhikrId));
  }

  /// Clears custom repeat targets for every dhikr in a section (back to app defaults).
  static Future<void> clearTargetsForSection(
    String sectionId,
    Iterable<int> dhikrIds,
  ) async {
    for (final id in dhikrIds) {
      await clearTarget(sectionId, id);
    }
  }
}
