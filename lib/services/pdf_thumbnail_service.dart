import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';

import 'pdf_native_viewer.dart';

/// First page of a PDF as PNG bytes — Android uses [PdfRenderer] (Kotlin); other platforms return null (fallback UI).
class PdfThumbnailService {
  PdfThumbnailService._();

  static const MethodChannel _channel = MethodChannel('com.dya.azadalkrd/pdf_viewer');

  static final Map<String, Future<Uint8List?>> _inflight = {};

  /// PNG thumbnail of page 0, max width [maxWidth] px. Cached per [assetPath].
  static Future<Uint8List?> firstPagePng(
    String assetPath, {
    int maxWidth = 480,
  }) {
    return _inflight.putIfAbsent(
      '$assetPath|$maxWidth',
      () => _load(assetPath, maxWidth),
    );
  }

  static Future<Uint8List?> _load(String assetPath, int maxWidth) async {
    try {
      if (defaultTargetPlatform != TargetPlatform.android) {
        return null;
      }
      final file = await PdfNativeViewer.materializeAssetToCache(assetPath);
      final dynamic raw = await _channel.invokeMethod<dynamic>(
        'getPdfThumbnail',
        <String, dynamic>{
          'path': file.path,
          'maxWidth': maxWidth,
        },
      );
      if (raw == null) return null;
      if (raw is Uint8List) return raw;
      if (raw is List<int>) return Uint8List.fromList(raw);
      return null;
    } on PlatformException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
