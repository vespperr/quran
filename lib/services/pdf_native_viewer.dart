import 'dart:io' show Directory, File;

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/pdf_viewer_screen.dart';

/// Opens PDFs using Android [PdfRenderer] via [MethodChannel] — no Flutter pdfium/pdfx.
class PdfNativeViewer {
  PdfNativeViewer._();

  static const MethodChannel _channel = MethodChannel('com.dya.azadalkrd/pdf_viewer');

  static final Map<String, File> _materializedFiles = {};
  static final Map<String, Future<File>> _materializeInflight = {};

  /// Writes the Flutter asset to app cache and returns the absolute path (Android-safe).
  /// Concurrent requests for the same [assetPath] share one write and cached [File].
  static Future<File> materializeAssetToCache(String assetPath) async {
    final done = _materializedFiles[assetPath];
    if (done != null) return done;
    return _materializeInflight.putIfAbsent(assetPath, () async {
      try {
        final data = await rootBundle.load(assetPath);
        final base = await getTemporaryDirectory();
        final dir = Directory('${base.path}/pdf_cache');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final name = '${assetPath.hashCode.abs()}.pdf';
        final file = File('${dir.path}/$name');
        await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
        _materializedFiles[assetPath] = file;
        return file;
      } finally {
        _materializeInflight.remove(assetPath);
      }
    });
  }

  /// Android: Kotlin [PdfViewerActivity] + [PdfRenderer] (no Flutter PDFium).
  /// Other platforms: materialize asset and open with the **system** default PDF app when possible.
  static Future<void> open(
    BuildContext context, {
    required String assetPath,
    required String title,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final file = await materializeAssetToCache(assetPath);
      try {
        await _channel.invokeMethod<void>('openPdf', <String, dynamic>{
          'path': file.path,
          'title': title,
        });
      } on PlatformException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? e.code)),
          );
        }
      }
      return;
    }

    // Windows / macOS / Linux / iOS: embedded Kotlin viewer N/A — open OS viewer (still no pdfx/pdfium).
    try {
      final file = await materializeAssetToCache(assetPath);
      final uri = Uri.file(file.path);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {
      // Fall through to stub.
    }
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => PdfViewerScreen(assetPath: assetPath, title: title),
      ),
    );
  }
}
