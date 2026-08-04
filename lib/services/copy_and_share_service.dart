import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_open_quran/constants/constants.dart';

/// Attribution line appended to copied/shared ayah text (copyright).
const String kAyahAttribution = 'م. ئازاد پێنجوێنی';

class CopyAndShareService {
  CopyAndShareService._();

  /// Returns [text] with attribution appended for copy/share.
  static String textWithAttribution(String text) =>
      text.trim().isEmpty ? kAyahAttribution : '$text\n\n$kAyahAttribution';

  static Future<void> share(String text) async {
    await Share.share(textWithAttribution(text));
  }

  static Future<void> copy(BuildContext context, String text) async {
    final withAttribution = textWithAttribution(text);
    await Clipboard.setData(ClipboardData(text: withAttribution));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.translate.copied),
              const SizedBox(height: 4),
              Text(
                kAyahAttribution,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Legacy: copy raw text without attribution (e.g. for non-ayah content).
  static Future<void> copyRaw(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate.copied)),
      );
    }
  }
}
