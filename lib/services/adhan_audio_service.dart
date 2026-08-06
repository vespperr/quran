import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plays adhan (prayer call) from app assets.
/// Uses rootBundle because our assets are under lib/assets/bang/ and
/// audioplayers' AssetSource expects paths under assets/.
class AdhanAudioService {
  AdhanAudioService._();

  static final AudioPlayer _player = AudioPlayer();

  static bool _disposed = false;

  /// [assetPath] = full asset path as in pubspec (e.g. lib/assets/bang/bang_1.mp3).
  /// [durationMs] = playback duration in milliseconds. -1 means full duration.
  static Future<void> play(String assetPath, {int durationMs = -1}) async {
    if (assetPath.isEmpty) return;
    try {
      await stop();
      await _player.setReleaseMode(ReleaseMode.release);
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await _player.play(BytesSource(bytes, mimeType: 'audio/mpeg'));
      if (durationMs > 0) {
        Future.delayed(Duration(milliseconds: durationMs), () {
          stop();
        });
      }
    } catch (e) {
      assert(() {
        debugPrint('AdhanAudioService.play error: $e');
        return true;
      }());
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  static void dispose() {
    if (!_disposed) {
      _disposed = true;
      _player.dispose();
    }
  }
}
