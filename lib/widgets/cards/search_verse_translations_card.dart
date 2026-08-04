import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/translation.dart';

class SearchVerseTranslationCard extends StatelessWidget {
  /// [SurahModel]
  final VerseTranslation verseTranslationModel;

  /// Function onTap
  final Function() onTap;

  const SearchVerseTranslationCard(
      {super.key, required this.verseTranslationModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: kSizeL),
        padding: const EdgeInsets.all(kSizeL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
          color: DesignSystem.surface,
          border: Border.all(color: DesignSystem.outline.withValues(alpha: 0.4)),
          boxShadow: DesignSystem.shadowSoft,
        ),
        child: Column(
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Row(
            //       children: [
            //         verseSurahNameTranslated(context),
            //         verseNumber(context),
            //       ],
            //     ),
            //     verseSurahNameArabic(context),
            //   ],
            // ),
            Divider(
              thickness: 1,
              height: kSize3XL,
              color: DesignSystem.outline.withValues(alpha: 0.5),
            ),
            Row(
              children: [
                Visibility(child: Expanded(child: verseText(context))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Verse text in english
  Widget verseText(BuildContext context) {
    return Text(
      verseTranslationModel.text ?? "",
      textDirection: TextDirection.rtl,
      style: context.theme.textTheme.headlineMedium!.copyWith(
        height: 2,
        color: DesignSystem.onSurface,
      ),
    );
  }

  // /// Verse surah name in Arabic
  // Widget verseSurahNameArabic(BuildContext context) {
  //   return Text(
  //     verseTranslationModel.surahNameArabic ?? "",
  //     overflow: TextOverflow.ellipsis,
  //     textDirection: TextDirection.rtl,
  //     style: context.theme.textTheme.titleLarge!
  //         .copyWith(color: AppColors.white5),
  //   );
  // }

  // /// Verse surah name in english
  // Widget verseSurahNameTranslated(BuildContext context) {
  //   return Text(
  //     "${verseTranslationModel.surahNameTranslated},  " ?? "",
  //     overflow: TextOverflow.ellipsis,
  //     style: context.theme.textTheme.titleMedium!
  //         .copyWith(color: AppColors.white5),
  //   );
  // }
  //
  // /// Verse number
  // Widget verseNumber(BuildContext context) {
  //   return Text(
  //     "${context.translate.ayat} ${verseTranslationModel.verseNumber ?? ""}",
  //     overflow: TextOverflow.ellipsis,
  //     style: context.theme.textTheme.titleMedium!
  //         .copyWith(color: AppColors.white5),
  //   );
  // }
}
