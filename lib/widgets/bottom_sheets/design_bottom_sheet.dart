import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

/// Bottom sheet styled per design system: 60% height, 40px green grab handle, 20px radius.
class DesignBottomSheet {
  DesignBottomSheet._();

  /// Shows a modal bottom sheet with optional grab handle and 60% height.
  /// When [showHandle] is false (e.g. for Athkars), the child draws its own handle.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool showHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.sizeOf(context).height * DesignSystem.bottomSheetHeightFraction,
        decoration: BoxDecoration(
          color: DesignSystem.cardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignSystem.cornerRadius),
          ),
          boxShadow: DesignSystem.softGlowShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle) const _SheetHandleBar(),
            if (showHandle) const SizedBox(height: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignSystem.screenPadding),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandleBar extends StatelessWidget {
  const _SheetHandleBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: DesignSystem.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
