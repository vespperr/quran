import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../providers/quran_provider.dart';
import '../title.dart';

class TranslationBox extends StatelessWidget {
  final Function() onTap;

  const TranslationBox({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitle(
          titleText: context.translate.translation,
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: Utils.isSmallPhone(context) ? 45 : 50,
            margin: const EdgeInsets.only(top: kSizeM, bottom: kSizeXXL),
            padding: const EdgeInsets.all(kSizeM),
            decoration: BoxDecoration(
              color: DesignSystem.surface,
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context
                            .watch<QuranProvider>()
                            .translationService
                            .translationButtonName ??
                        context.translate.translation,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: DesignSystem.onSurface,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  ImageConstants.dropDownIcon,
                  colorFilter: ColorFilter.mode(
                    DesignSystem.onSurface.withValues(alpha: 0.7),
                    BlendMode.srcIn,
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
