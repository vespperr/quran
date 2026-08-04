import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/surah_model.dart';
import '../surah_name_svg.dart';

class SurahCard extends StatelessWidget {
  final SurahModel surahModel;
  final Function() onTap;

  const SurahCard({super.key, required this.surahModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: DesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
          boxShadow: DesignSystem.softGlowShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.screenPadding),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              _SurahNumberBadge(number: surahModel.id!),
              const SizedBox(width: kSizeL),
              Expanded(child: buildSurahNames(context)),
              const SizedBox(width: kSizeL),
              buildVersesCount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSurahNames(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurahNameSvg(
          surahId: surahModel.id!,
          color: DesignSystem.textForest,
          height: 26,
          fallbackText: surahModel.nameArabic ?? surahModel.nameSimple ?? '',
        ),
        const SizedBox(height: kSizeS),
        Text(
          surahModel.nameTranslated ?? "",
          style: context.theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 0.04,
            color: DesignSystem.textForest,
          ),
        ),
      ],
    );
  }

  Widget buildVersesCount(BuildContext context) {
    return Text(
      "${surahModel.verses.length} ${context.translate.ayat}",
      style: context.theme.textTheme.labelMedium?.copyWith(
        letterSpacing: 0.04,
        color: DesignSystem.textForest,
      ),
    );
  }
}

/// Decorative circular frame (shapenumb.png) with surah number in the center.
class _SurahNumberBadge extends StatelessWidget {
  const _SurahNumberBadge({required this.number});

  final int number;

  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Image.asset(
            ImageConstants.surahNumberShape,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(width: size, height: size),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: size * 0.85,
                height: size * 0.5,
                child: Text(
                  '$number',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DesignSystem.iconGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
