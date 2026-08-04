import 'package:get_storage/get_storage.dart';

/// Selected reciter and download index for Quran audio pipeline.
class RecitationPrefs {
  RecitationPrefs._();

  static const String _box = 'FabrikodQuran';
  static const String _reciterKey = 'recitation_reciter_id';

  static String get selectedReciterId =>
      GetStorage(_box).read(_reciterKey) as String? ?? '';

  static Future<void> setSelectedReciterId(String id) async {
    await GetStorage(_box).write(_reciterKey, id);
  }
}
