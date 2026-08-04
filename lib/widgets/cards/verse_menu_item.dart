import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_open_quran/constants/constants.dart';


class VerseMenuItem extends StatelessWidget {
  const VerseMenuItem({
    super.key,
    this.iconPath,
    required this.buttonName,
    this.iconData,
  });
  final String? iconPath;
  final String buttonName;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 45,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: iconData != null
                ? Icon(iconData, color: AppColors.white, size: kSizeXL)
                : (iconPath != null && iconPath!.isNotEmpty)
                    ? SvgPicture.asset(iconPath!,
                        color: AppColors.white, width: kSizeXL, height: kSizeXL)
                    : const SizedBox(width: kSizeXL, height: kSizeXL),
          ),
          const SizedBox(
            width: kSizeL,
          ),
          Expanded(
            flex: 3,
            child: Text(
              buttonName,
              style: context.theme.textTheme.titleMedium
                  ?.copyWith(color: AppColors.white),
            ),
          )
        ],
      ),
    );
  }
}
