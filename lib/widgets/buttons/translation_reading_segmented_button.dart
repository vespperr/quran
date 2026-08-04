import 'package:flutter/cupertino.dart';
import 'package:the_open_quran/constants/constants.dart';

class TranslationReadingSegmentedButton extends StatelessWidget {
  const TranslationReadingSegmentedButton({
    super.key,
    required this.initialIndex,
    required this.onValueChanged,
  });

  final int initialIndex;
  final Function(int index) onValueChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<int>(
        backgroundColor: DesignSystem.outlineVariant,
        thumbColor: DesignSystem.primary,
        padding: const EdgeInsets.all(3),
        groupValue: initialIndex,
        children: {
          0: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                context.translate.translation,
                style: context.theme.textTheme.headlineSmall?.copyWith(
                  color: initialIndex == 0
                      ? DesignSystem.onPrimary
                      : DesignSystem.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          1: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                context.translate.reading,
                style: context.theme.textTheme.headlineSmall?.copyWith(
                  color: initialIndex == 1
                      ? DesignSystem.onPrimary
                      : DesignSystem.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        },
        onValueChanged: (value) {
          if (value == null) return;
          onValueChanged(value);
        },
      ),
    );
  }
}
