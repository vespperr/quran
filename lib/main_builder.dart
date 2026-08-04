import 'package:flutter/material.dart';

class MainBuilder {
  static Widget builder(BuildContext context, Widget? child) {
    final locale = Localizations.localeOf(context);
    final isRtl = locale.languageCode == 'ar' || locale.languageCode == 'ku';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: child ?? const SizedBox(),
    );
  }
}
