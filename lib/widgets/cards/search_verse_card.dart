import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/verse_model.dart';

class SearchVerseCard extends StatelessWidget {
  /// [SurahModel]
  final VerseModel verseModel;

  /// Function onTap
  final Function() onTap;

  const SearchVerseCard(
      {super.key, required this.verseModel, required this.onTap});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    verseSurahNameTranslated(context),
                    verseNumber(context),
                  ],
                ),
                verseSurahNameArabic(context),
              ],
            ),
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
      verseModel.text ?? "",
      textDirection: TextDirection.rtl,
      style: context.theme.textTheme.headlineMedium!.copyWith(
        height: 2,
        color: DesignSystem.onSurface,
      ),
    );
  }

  /// Verse surah name in Arabic
  Widget verseSurahNameArabic(BuildContext context) {
    return Text(
      verseModel.surahNameArabic ?? "",
      overflow: TextOverflow.ellipsis,
      textDirection: TextDirection.rtl,
      style: context.theme.textTheme.titleLarge!
          .copyWith(color: DesignSystem.onSurface),
    );
  }

  /// Verse surah name in english
  Widget verseSurahNameTranslated(BuildContext context) {
    return Text(
      "${verseModel.surahNameTranslated},  ",
      overflow: TextOverflow.ellipsis,
      style: context.theme.textTheme.titleMedium!
          .copyWith(color: DesignSystem.onSurface),
    );
  }

  /// Verse number
  Widget verseNumber(BuildContext context) {
    return Text(
      "${context.translate.ayat} ${verseModel.verseNumber ?? ""}",
      overflow: TextOverflow.ellipsis,
      style: context.theme.textTheme.titleMedium!
          .copyWith(color: DesignSystem.onSurface),
    );
  }
}
