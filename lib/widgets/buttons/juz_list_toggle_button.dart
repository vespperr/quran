import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:the_open_quran/constants/constants.dart';

class JuzListToggleButton extends StatelessWidget {
  final EJuzListType listType;
  final Function(EJuzListType)? onChanged;

  const JuzListToggleButton(
      {super.key, required this.listType, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<int>(
      backgroundColor: DesignSystem.primary.withValues(alpha: 0.15),
      thumbColor: DesignSystem.primary,
      padding: const EdgeInsets.all(2),
      groupValue: listType.index,
      children: {
        0: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SvgPicture.asset(
            ImageConstants.listIcon,
            colorFilter: ColorFilter.mode(
              listType == EJuzListType.list
                  ? DesignSystem.onPrimary
                  : DesignSystem.primary.withValues(alpha: 0.5),
              BlendMode.srcIn,
            ),
          ),
        ),
        1: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SvgPicture.asset(
            ImageConstants.gridIcon,
            colorFilter: ColorFilter.mode(
              listType == EJuzListType.grid
                  ? DesignSystem.onPrimary
                  : DesignSystem.primary.withValues(alpha: 0.5),
              BlendMode.srcIn,
            ),
          ),
        ),
      },
      onValueChanged: (value) {
        if (value == null || onChanged == null) return;
        var result = listType == EJuzListType.list
            ? EJuzListType.grid
            : EJuzListType.list;
        onChanged!(result);
      },
    );
  }
}
