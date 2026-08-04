import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/dhikr_model.dart';
import '../models/dhikr_section_model.dart';

/// Top-level for isolate: write [path, bytes] to avoid blocking UI.
Future<void> _writeDbFileInIsolate(List<dynamic> args) async {
  final path = args[0] as String;
  final bytes = args[1] as List<int>;
  await File(path).writeAsBytes(bytes);
}

/// Loads and queries the KurdistanPrayerTimes.db dhikr table.
class DhikrDb {
  DhikrDb._();

  static const String _assetPath = 'lib/assets/KurdistanPrayerTimes.db';
  static const String _dbFileName = 'KurdistanPrayerTimes.db';

  static Database? _db;
  static bool _ffiInitialized = false;

  static Future<Database> get database async {
    if (_db != null && (_db?.isOpen ?? false)) return _db!;
    _db = await _openDb();
    return _db!;
  }

  static void _initFfiIfNeeded() {
    if (_ffiInitialized) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiInitialized = true;
  }

  static Future<Database> _openDb() async {
    _initFfiIfNeeded();

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/$_dbFileName';

    if (!await File(dbPath).exists()) {
      final byteData = await rootBundle.load(_assetPath);
      final bytes = byteData.buffer.asUint8List().toList();
      // Copy file in background isolate so UI stays responsive
      await compute(_writeDbFileInIsolate, [dbPath, bytes]);
    }

    return openDatabase(dbPath, readOnly: true);
  }

  /// Fetches all rows from the dhikr table.
  static Future<List<DhikrModel>> getDhikrs() async {
    final db = await database;
    final list = await db.query('dhikr', orderBy: 'id ASC');
    return list.map((row) => DhikrModel(
      id: row['id'] as int,
      dhikrid: row['dhikrid'] as String?,
      ardhikr: row['ardhikr'] as String?,
      krdhikr: row['krdhikr'] as String?,
    )).toList();
  }

  /// Three folders only: Morning, Evening, Bedtime. dhikrid → folder key.
  static const String _folderMorning = 'morning';
  static const String _folderEvening = 'evening';
  static const String _folderBedtime = 'bedtime';

  static const Map<String, String> _dhikridToFolder = {
    '1': _folderMorning,
    '27': _folderMorning,
    '2': _folderEvening,
    '28': _folderEvening,
    '3': _folderBedtime,
    '29': _folderBedtime,
  };

  static const _folderOrder = [_folderMorning, _folderEvening, _folderBedtime];

  static const Map<String, String> _folderTitles = {
    _folderMorning: 'بەیانیان',   // Morning
    _folderEvening: 'ئێواران',   // Evening
    _folderBedtime: 'پێشخەوتن',  // Bedtime
  };

  static const Map<String, String> _folderSubtitles = {
    _folderMorning: 'With sound and writing',
    _folderEvening: 'With sound and writing',
    _folderBedtime: 'With sound and writing',
  };

  /// True if DB has dhikrname table (folder names like azadalkrd).
  static Future<bool> _hasDhikrnameTable(Database db) async {
    final r = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='dhikrname'",
    );
    return r.isNotEmpty;
  }

  /// Fetches from dhikrname, then merges into folders: Morning, Evening, Bedtime, Others.
  static Future<List<DhikrSectionModel>> getDhikrSectionsFromDhikrname() async {
    final db = await database;
    if (!await _hasDhikrnameTable(db)) return getDhikrSectionsFallback();

    final nameRows = await db.rawQuery('SELECT * FROM dhikrname');
    final byFolder = <String, List<DhikrModel>>{};
    for (final row in nameRows) {
      final id = (row['id'] ?? row.values.first)?.toString() ?? '';
      if (id.isEmpty) continue;
      final folder = _dhikridToFolder[id];
      if (folder == null) continue;
      final dhikrRows = await db.rawQuery(
        'SELECT * FROM dhikr WHERE dhikrid = ? ORDER BY id ASC',
        [id],
      );
      final dhikrs = dhikrRows.map((r) => DhikrModel(
        id: r['id'] as int,
        dhikrid: r['dhikrid'] as String?,
        ardhikr: r['ardhikr'] as String?,
        krdhikr: r['krdhikr'] as String?,
      )).toList();
      if (dhikrs.isEmpty) continue;
      byFolder.putIfAbsent(folder, () => []).addAll(dhikrs);
    }
    final sections = <DhikrSectionModel>[];
    var iconIndex = 0;
    for (final folder in _folderOrder) {
      final list = byFolder[folder];
      if (list == null || list.isEmpty) continue;
      sections.add(DhikrSectionModel(
        sectionId: folder,
        title: _folderTitles[folder] ?? folder,
        subtitle: _folderSubtitles[folder],
        iconIndex: iconIndex++ % 3,
        dhikrs: list,
      ));
    }
    return sections;
  }

  /// Fallback: group dhikrs into three folders (Morning, Evening, Bedtime) only.
  static Future<List<DhikrSectionModel>> getDhikrSectionsFallback() async {
    final all = await getDhikrs();
    final byFolder = <String, List<DhikrModel>>{};
    for (final d in all) {
      final folder = _dhikridToFolder[d.dhikrid ?? ''];
      if (folder == null) continue;
      byFolder.putIfAbsent(folder, () => []).add(d);
    }
    final sections = <DhikrSectionModel>[];
    var iconIndex = 0;
    for (final folder in _folderOrder) {
      final list = byFolder[folder];
      if (list == null || list.isEmpty) continue;
      sections.add(DhikrSectionModel(
        sectionId: folder,
        title: _folderTitles[folder] ?? folder,
        subtitle: _folderSubtitles[folder],
        iconIndex: iconIndex++ % 3,
        dhikrs: list,
      ));
    }
    return sections;
  }

  /// Fetches dhikrs grouped by section. Uses dhikrname table if present (azadalkrd style).
  static Future<List<DhikrSectionModel>> getDhikrSections() async {
    try {
      return await getDhikrSectionsFromDhikrname();
    } catch (_) {
      return getDhikrSectionsFallback();
    }
  }
}
