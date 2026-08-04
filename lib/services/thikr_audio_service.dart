import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Asset paths for section audio (morning, evening, bedtime).
const Map<String, String> thikrSectionAudioAssets = {
  'morning': 'lib/assets/thikrs/zikry_bayanyan.mp3',
  'evening': 'lib/assets/thikrs/zikry_ewaran.mp3',
  'bedtime': 'lib/assets/thikrs/zikry_xawtnan.mp3',
};

/// Plays thikr section audio (morning, evening, bedtime). Single player; notifies for UI.
class ThikrAudioService {
  ThikrAudioService._();

  static final AudioPlayer _player = AudioPlayer();
  static final ValueNotifier<String?> currentSectionId = ValueNotifier<String?>(null);
  static final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  static final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  static final ValueNotifier<PlayerState> state = ValueNotifier(PlayerState.stopped);

  static bool _listenersAttached = false;

  static void _attachListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;
    _player.onPlayerStateChanged.listen((s) {
      state.value = s;
      if (s == PlayerState.stopped || s == PlayerState.completed) {
        currentSectionId.value = null;
        position.value = Duration.zero;
      }
    });
    _player.onDurationChanged.listen((d) => duration.value = d);
    _player.onPositionChanged.listen((p) => position.value = p);
  }

  /// Start or resume playback for a section. Stops any other section.
  static Future<void> play(String sectionId) async {
    final path = thikrSectionAudioAssets[sectionId];
    if (path == null || path.isEmpty) return;
    _attachListeners();
    try {
      await _player.stop();
      currentSectionId.value = sectionId;
      position.value = Duration.zero;
      duration.value = Duration.zero;
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();
      await _player.play(BytesSource(bytes, mimeType: 'audio/mpeg'));
    } catch (e) {
      if (kDebugMode) debugPrint('ThikrAudioService.play $sectionId: $e');
      currentSectionId.value = null;
    }
  }

  static Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  static Future<void> resume(String sectionId) async {
    if (currentSectionId.value == sectionId) {
      try {
        await _player.resume();
      } catch (_) {}
    } else {
      await play(sectionId);
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      currentSectionId.value = null;
      position.value = Duration.zero;
      duration.value = Duration.zero;
    } catch (_) {}
  }

  static Future<void> seek(Duration to) async {
    try {
      await _player.seek(to);
    } catch (_) {}
  }
}
