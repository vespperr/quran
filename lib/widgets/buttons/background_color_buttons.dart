import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/images.dart';

class BackgroundColorsButton extends StatelessWidget {
  const BackgroundColorsButton(
      {super.key,
      required this.backgroundColor,
      required this.isSelected,
      required this.onTap});
  final Color backgroundColor;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isSelected
          ? ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(width: 1, color: backgroundColor),
              ),
            )
          : null,
      child: MaterialButton(
        color: backgroundColor,
        onPressed: onTap,
        shape: const CircleBorder(),
        height: 38,
        child:
            isSelected ? SvgPicture.asset(ImageConstants.onSelectLetter) : null,
      ),
    );
  }
}
