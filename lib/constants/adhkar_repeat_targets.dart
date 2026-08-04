import '../models/dhikr_model.dart';

/// Target repeat counts per dhikr row [DhikrModel.id] for morning/evening/bedtime athkar.
/// Keys not listed default to [defaultRepeatCount] (usually 1).
/// Extend this map as you verify counts from the Book of Remembrances / scholars.
class AdhkarRepeatTargets {
  AdhkarRepeatTargets._();

  /// When no override exists, user completes in one tap.
  static const int defaultRepeatCount = 1;

  /// Optional overrides: `dhikr.id` -> times to repeat (e.g. 3, 7, 100).
  static const Map<int, int> byDhikrRowId = {
    // Example: 42: 3,
  };

  static int targetFor(DhikrModel d) {
    final t = byDhikrRowId[d.id];
    if (t != null && t > 0) return t;
    return defaultRepeatCount;
  }
}
