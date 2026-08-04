import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({
    super.key,
    required this.titleText,
  });

  final String titleText;
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final onSurface = theme.brightness == Brightness.dark
        ? DesignSystem.onSurface
        : theme.colorScheme.onSurface;
    return Text(
      titleText,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
