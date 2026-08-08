import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plays adhan (prayer call) from app assets.
class AdhanAudioService {
  AdhanAudioService._();

  static final AudioPlayer _player = AudioPlayer();
  static Timer? _stopTimer;
  static bool _disposed = false;

  /// [assetPath] = full asset path as in pubspec (e.g. assets/audio/bang_bilali_habashi_fajr.mp3).
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
        _stopTimer = Timer(Duration(milliseconds: durationMs), () {
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
    _stopTimer?.cancel();
    _stopTimer = null;
    try {
      await _player.stop();
    } catch (_) {}
  }

  static void dispose() {
    _stopTimer?.cancel();
    _stopTimer = null;
    if (!_disposed) {
      _disposed = true;
      _player.dispose();
    }
  }
}
