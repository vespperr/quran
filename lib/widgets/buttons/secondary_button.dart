import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../constants/non_quran_style.dart';
import '../scale_tap_widget.dart';

/// Settings-style primary action button — solid primary, white text.
class SecondaryButton extends StatelessWidget {
  /// Button label [String]
  final String text;

  /// Button [onPressed] function
  final Function()? onPressed;

  /// Button [icon]
  final Widget icon;

  const SecondaryButton(
      {super.key, required this.text, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kSizeL),
      child: ScaleTapWidget(
        onTap: onPressed,
        child: Container(
            height: 65,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: kSizeXL),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusSmall),
              color: DesignSystem.primary,
              boxShadow: DesignSystem.softGlowShadow,
            ),
            child: Row(
              children: [
                const SizedBox(width: kSizeXXL),
                icon,
                const SizedBox(width: kSizeXXL),
                Text(
                  text,
                  style: context.theme.textTheme.headlineSmall
                      ?.copyWith(color: DesignSystem.onPrimary),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
        ),
      ),
    );
  }
}
