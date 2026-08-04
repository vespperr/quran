import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../scale_tap_widget.dart';

class RecentCard extends StatelessWidget {
  final String text;
  final Function()? onTap;

  const RecentCard({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          boxShadow: DesignSystem.shadowSoft,
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: DesignSystem.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
