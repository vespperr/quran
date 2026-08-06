import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// Helper service for multi-platform Adhan audio scheduling and playback
/// using standard Flutter assets (`assets/audio/...`).
class AdhanAudioSchedulerService {
  AdhanAudioSchedulerService._();

  static final AudioPlayer _player = AudioPlayer();
  static final GetStorage _box = GetStorage();

  // Storage Keys for per-prayer asset audio selections
  static const String _fajrAdhanKey = 'adhan_asset_fajr';
  static const String _dhuhrAdhanKey = 'adhan_asset_dhuhr';
  static const String _asrAdhanKey = 'adhan_asset_asr';
  static const String _maghribAdhanKey = 'adhan_asset_maghrib';
  static const String _ishaAdhanKey = 'adhan_asset_isha';

  /// Default asset audio fallback path
  static const String defaultAdhanAsset =
      'assets/audio/bang_rast_nawrozh_asr.mp3';

  /// Get selected asset audio path for a specific prayer time.
  static String getAdhanAssetForPrayer(String prayerName) {
    final key = _getKeyForPrayer(prayerName);
    if (key != null) {
      return _box.read(key) as String? ?? defaultAdhanAsset;
    }
    return defaultAdhanAsset;
  }

  /// Set selected asset audio path for a specific prayer time.
  static Future<void> setAdhanAssetForPrayer(
      String prayerName, String assetPath) async {
    final key = _getKeyForPrayer(prayerName);
    if (key != null) {
      await _box.write(key, assetPath);
    }
  }

  static String? _getKeyForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return _fajrAdhanKey;
      case 'dhuhr':
        return _dhuhrAdhanKey;
      case 'asr':
        return _asrAdhanKey;
      case 'maghrib':
        return _maghribAdhanKey;
      case 'isha':
        return _ishaAdhanKey;
      default:
        return null;
    }
  }

  /// Play preview or triggered Adhan directly from Flutter assets
  static Future<void> playAssetAdhan(String assetPath,
      {Duration? durationLimit}) async {
    try {
      await _player.stop();
      // Remove leading slash or prefix if present for AssetSource
      final cleanPath = assetPath.replaceFirst(RegExp(r'^(assets/|/)?'), '');
      await _player.play(AssetSource(cleanPath));

      if (durationLimit != null) {
        Future.delayed(durationLimit, () async {
          await _player.stop();
        });
      }
    } catch (e) {
      debugPrint('Error playing asset adhan: $e');
    }
  }

  /// Stop currently playing adhan audio
  static Future<void> stop() async {
    await _player.stop();
  }
}
