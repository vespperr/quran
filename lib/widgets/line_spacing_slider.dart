import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/widgets/title.dart';

class LineSpacingSlider extends StatelessWidget {
  const LineSpacingSlider({
    super.key,
    required this.lineHeight,
    required this.onChanged,
    this.isPopUp = false,
  });

  final double lineHeight;
  final Function(double value) onChanged;
  final bool isPopUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitle(titleText: context.translate.lineSpacing),
        Container(
          margin: EdgeInsets.only(
            top: Utils.isSmallPhone(context) ? 10 : kSizeM,
            bottom: Utils.isSmallPhone(context) ? 10 : kSizeL,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          height: isPopUp && Utils.isSmallPhone(context)
              ? 40
              : Utils.isMediumPhone(context) && isPopUp
                  ? 45
                  : 50,
          child: Padding(
            padding: const EdgeInsets.all(kSizeL),
            child: Row(
              children: [
                Expanded(
                  flex: 10,
                  child: SliderTheme(
                    data: context.theme.sliderTheme.copyWith(
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius:
                            Utils.isSmallPhone(context) ? 10 : 10,
                      ),
                    ),
                    child: Slider(
                      value: lineHeight.clamp(1.0, 2.5),
                      min: 1.0,
                      max: 2.5,
                      onChanged: onChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  lineHeight.toStringAsFixed(1),
                  style: context.theme.textTheme.labelSmall?.copyWith(
                    color: DesignSystem.onSurface.withValues(alpha: 0.8),
                    fontSize: Utils.isSmallPhone(context) ? 10 : 12,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
