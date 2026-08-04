import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../constants/non_quran_style.dart';

/// Language selector — com-folder style (active = done green, unselected = light).
class CustomLanguageCard extends StatefulWidget {
  final Locale? defaultLocale;
  final Function(String newLocale) changedLocale;

  const CustomLanguageCard(
      {super.key, required this.defaultLocale, required this.changedLocale});

  @override
  State<CustomLanguageCard> createState() => _CustomLanguageCardState();
}

class _CustomLanguageCardState extends State<CustomLanguageCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: NonQuranStyle.sectionCardBackground.withValues(alpha: isDark ? 0.3 : 0.7),
        borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusSmall),
        border: Border.all(
          color: NonQuranStyle.sectionAccentColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          ...ESupportedLanguage.values.map(
            (e) => InkWell(
              onTap: () => widget.changedLocale(e.name.toLowerCase()),
              borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusSmall),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSizeL, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.title(context),
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        color: isDark ? AppColors.royalOnSurface : NonQuranStyle.unselectedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    widget.defaultLocale?.languageCode.toLowerCase() ==
                            e.name.toLowerCase()
                        ? Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NonQuranStyle.activeBackground,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                ImageConstants.onSelectLetter,
                                height: 16,
                                colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
