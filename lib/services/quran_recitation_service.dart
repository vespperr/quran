import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:the_open_quran/models/recitation_manifest_model.dart';
import 'package:the_open_quran/models/verse_model.dart';

import 'recitation_prefs.dart';

/// Loads [RecitationManifest], plays ayah audio (bundled demo, remote stream, or cached file).
class QuranRecitationService {
  QuranRecitationService._();

  static RecitationManifest? _manifest;
  static final AudioPlayer _player = AudioPlayer();
  static bool _listenersAttached = false;

  static final ValueNotifier<String?> currentVerseKey = ValueNotifier<String?>(null);
  static final ValueNotifier<PlayerState> playerState =
      ValueNotifier<PlayerState>(PlayerState.stopped);
  static final ValueNotifier<double?> downloadProgress = ValueNotifier<double?>(null);

  static Future<RecitationManifest> loadManifest() async {
    if (_manifest != null) return _manifest!;
    final raw = await rootBundle.loadString('assets/json/recitations_manifest.json');
    _manifest = RecitationManifest.parse(raw);
    return _manifest!;
  }

  static Future<ReciterInfo> _resolvedReciter() async {
    final m = await loadManifest();
    final id = RecitationPrefs.selectedReciterId.isNotEmpty
        ? RecitationPrefs.selectedReciterId
        : m.defaultReciterId;
    final r = m.byId(id) ?? m.byId(m.defaultReciterId);
    if (r == null) {
      throw StateError('Recitation manifest has no reciters');
    }
    return r;
  }

  static void _attachListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;
    _player.onPlayerStateChanged.listen((s) {
      playerState.value = s;
      if (s == PlayerState.stopped || s == PlayerState.completed) {
        currentVerseKey.value = null;
      }
    });
  }

  static Future<File> _localAyahFile(String reciterId, int ayahId) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/recitations/$reciterId');
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    return File('${folder.path}/$ayahId.mp3');
  }

  static Future<bool> isAyahCached(String reciterId, int ayahId) async {
    final f = await _localAyahFile(reciterId, ayahId);
    return f.existsSync() && f.lengthSync() > 0;
  }

  /// Downloads one ayah to app documents (optional offline use).
  static Future<void> downloadAyah(ReciterInfo reciter, int ayahId) async {
    final template = reciter.remoteAyahUrlTemplate;
    if (template == null || !template.contains('{ayahId}')) return;
    final uri = Uri.parse(template.replaceAll('{ayahId}', '$ayahId'));
    final file = await _localAyahFile(reciter.id, ayahId);
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300 && res.bodyBytes.isNotEmpty) {
      await file.writeAsBytes(res.bodyBytes, flush: true);
    }
  }

  /// Caches all ayat of [surahId] using [verses] list (global ayah ids on each verse).
  static Future<void> downloadSurahAyahs({
    required ReciterInfo reciter,
    required List<VerseModel> verses,
  }) async {
    final total = verses.length;
    if (total == 0) return;
    downloadProgress.value = 0;
    var done = 0;
    for (final v in verses) {
      final id = v.id;
      if (id == null) continue;
      if (await isAyahCached(reciter.id, id)) {
        done++;
        downloadProgress.value = done / total;
        continue;
      }
      try {
        await downloadAyah(reciter, id);
      } catch (e) {
        if (kDebugMode) debugPrint('downloadAyah $id: $e');
      }
      done++;
      downloadProgress.value = done / total;
    }
    downloadProgress.value = null;
  }

  static Future<void> playVerse(VerseModel verse) async {
    final ayahId = verse.id;
    final key = verse.verseKey ?? '';
    if (ayahId == null || key.isEmpty) return;

    _attachListeners();
    final reciter = await _resolvedReciter();

    final cached = await _localAyahFile(reciter.id, ayahId);
    if (cached.existsSync() && cached.lengthSync() > 0) {
      await _player.stop();
      currentVerseKey.value = key;
      await _player.play(DeviceFileSource(cached.path));
      return;
    }

    if (reciter.bundledDemoAyahId == ayahId &&
        reciter.bundledDemoAssetPath != null &&
        reciter.bundledDemoAssetPath!.isNotEmpty) {
      await _player.stop();
      currentVerseKey.value = key;
      final data = await rootBundle.load(reciter.bundledDemoAssetPath!);
      await _player.play(BytesSource(data.buffer.asUint8List(), mimeType: 'audio/mpeg'));
      return;
    }

    final template = reciter.remoteAyahUrlTemplate;
    if (template == null || !template.contains('{ayahId}')) return;
    final url = template.replaceAll('{ayahId}', '$ayahId');
    await _player.stop();
    currentVerseKey.value = key;
    await _player.play(UrlSource(url));
  }

  static Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  static Future<void> resume() async {
    try {
      await _player.resume();
    } catch (_) {}
  }

  /// Toggle: same verse key → pause; else play that verse.
  static Future<void> toggleVerse(VerseModel verse) async {
    final key = verse.verseKey;
    if (key == null) return;
    if (currentVerseKey.value == key &&
        playerState.value == PlayerState.playing) {
      await pause();
      return;
    }
    if (currentVerseKey.value == key &&
        playerState.value == PlayerState.paused) {
      await resume();
      return;
    }
    await playVerse(verse);
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      currentVerseKey.value = null;
    } catch (_) {}
  }
}
