import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/mushaf_backgrund_model.dart';
import '../../models/translation.dart';
import '../../models/verse_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/surah_details_provider.dart';
import '../pop_up/verse_pop_up_menu.dart';

class VerseCard extends StatelessWidget {
  const VerseCard({
    super.key,
    required this.verseModel,
    required this.verseTranslations,
    required this.arabicFontFamily,
    required this.translationFontFamily,
    required this.textScaleFactor,
    required this.playFunction,
    required this.favoriteFunction,
    required this.bookmarkFunction,
    required this.copyFunction,
    required this.shareFunction,
    this.memorizeFunction,
    this.isPlaying = false,
    this.isFavorite = false,
    this.isBookmark = false,
    required this.readOptions,
    required this.selectedVerseKey,
    required this.changeSelectedVerseKey,
  });

  final VerseModel verseModel;
  final EReadOptions readOptions;
  final List<VerseTranslation> verseTranslations;
  final String? arabicFontFamily;
  final String? translationFontFamily;
  final double textScaleFactor;
  final bool isPlaying;
  final bool isFavorite;
  final bool isBookmark;
  final Function(VerseModel verseModel, bool isPlaying) playFunction;
  final Function(VerseModel verseModel, bool isFavorite) favoriteFunction;
  final Function(
          EBookMarkType bookMarkType, VerseModel verseModel, bool isBookmark)
      bookmarkFunction;
  final Function(VerseModel) copyFunction;
  final Function(VerseModel) shareFunction;
  final void Function(VerseModel verseModel)? memorizeFunction;
  final String? selectedVerseKey;
  final Function(String? selectedVerseKey) changeSelectedVerseKey;

  @override
  Widget build(BuildContext context) {
    GlobalKey globalKey = GlobalKey();
    return VersePopUpMenu(
      globalKey: globalKey,
      verseModel: verseModel,
      isPlaying: isPlaying,
      playFunction: playFunction,
      isFavorite: isFavorite,
      favoriteFunction: favoriteFunction,
      isBookmark: isBookmark,
      bookmarkFunction: bookmarkFunction,
      copyFunction: copyFunction,
      shareFunction: shareFunction,
      memorizeFunction: memorizeFunction,
      changeSelectedVerseKey: changeSelectedVerseKey,
      child: Builder(
        builder: (context) {
          final themeColor =
              context.watch<QuranProvider>().surahDetailsPageThemeColor;
          final isSelectedOrPlaying =
              selectedVerseKey == verseModel.verseKey || isPlaying;

          final cardBg = isSelectedOrPlaying
              ? const Color(0xFF43A047).withValues(alpha: 0.08)
              : themeColor.backgroundColor.withValues(alpha: 0.7);

          final borderColor = isSelectedOrPlaying
              ? const Color(0xFF43A047).withValues(alpha: 0.5)
              : themeColor.titleVectorColor.withValues(alpha: 0.15);

          return Container(
            key: globalKey,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelectedOrPlaying ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelectedOrPlaying
                      ? const Color(0xFF43A047).withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelectedOrPlaying ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<SurahDetailsProvider>()
                              .changeAyahNumberStyle();
                        },
                        child: _verseNumberBadge(context, themeColor),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBookmark)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SvgPicture.asset(
                              ImageConstants.bookmarkActiveIcon,
                              height: 17,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFD4AF37),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_outline_rounded,
                            color: isPlaying
                                ? const Color(0xFF43A047)
                                : themeColor.titleVectorColor
                                    .withValues(alpha: 0.7),
                            size: 20,
                          ),
                          onPressed: () => playFunction(verseModel, isPlaying),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildVerseCardArabic(readOptions, context),
                _buildVerseCardTranslation(readOptions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _verseNumberBadge(
      BuildContext context, SurahDetailsPageThemeModel themeColor) {
    final isLatin = context.read<SurahDetailsProvider>().isLatinNumber;
    final verseNumStr = isLatin
        ? verseModel.verseNumber.toString()
        : Utils.getArabicVerseNo(verseModel.verseNumber.toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: themeColor.titleVectorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeColor.titleVectorColor.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 12,
            color: themeColor.titleVectorColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              verseModel.verseKey ?? verseNumStr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: themeColor.textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic Text
  Widget _buildVerseCardArabic(EReadOptions readOptions, BuildContext context) {
    return Visibility(
      visible: readOptions != EReadOptions.translation,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: isPlaying
                ? BoxDecoration(
                    color: const Color(0xFF43A047).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: context.theme.textTheme.headlineLarge?.copyWith(
                  height:
                      context.watch<QuranProvider>().localSetting.lineHeight,
                  fontSize: 21,
                  fontFamily: Fonts.getArabicFont(context
                      .watch<QuranProvider>()
                      .localSetting
                      .fontTypeArabic),
                  fontFamilyFallback: [Fonts.amiri],
                  color: context
                      .watch<QuranProvider>()
                      .surahDetailsPageThemeColor
                      .textColor,
                ),
                children: context.watch<QuranProvider>().getVerseDisplaySpans(
                      verseModel,
                      context.theme.textTheme.headlineLarge!.copyWith(
                        height: context
                            .watch<QuranProvider>()
                            .localSetting
                            .lineHeight,
                        fontSize: 21,
                        fontFamily: Fonts.getArabicFont(context
                            .watch<QuranProvider>()
                            .localSetting
                            .fontTypeArabic),
                        fontFamilyFallback: [
                          Fonts.naskh,
                          Fonts.uthmanic,
                          Fonts.amiri,
                        ],
                        color: context
                            .watch<QuranProvider>()
                            .surahDetailsPageThemeColor
                            .textColor,
                      ),
                    ),
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
              textScaler: TextScaler.linear(textScaleFactor),
            ),
          ),
          Visibility(
              visible: readOptions == EReadOptions.surahAndTranslation,
              child: buildVerseCardDivider(context)),
        ],
      ),
    );
  }

  /// Translation Text
  Widget _buildVerseCardTranslation(EReadOptions readOptions) {
    return Visibility(
      visible: readOptions != EReadOptions.surah,
      child: Padding(
        padding: readOptions == EReadOptions.translation
            ? const EdgeInsets.only(top: 8)
            : EdgeInsets.zero,
        child: ListView.separated(
          itemCount: verseTranslations.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 6),
          separatorBuilder: (context, index) => buildVerseCardDivider(context),
          itemBuilder: (context, index) {
            final verseTranslation = verseTranslations[index];
            final quran = context.watch<QuranProvider>();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: quran.surahDetailsPageThemeColor.titleVectorColor
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                verseTranslation.text ?? "",
                textAlign: TextAlign.start,
                textDirection: TextDirection.rtl,
                textScaler: TextScaler.linear(textScaleFactor),
                style: context.theme.textTheme.titleSmall?.copyWith(
                  fontFamily: translationFontFamily,
                  color: quran.surahDetailsPageThemeColor.textColor
                      .withValues(alpha: 0.88),
                  height: 1.55,
                  fontSize: 14.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Divider Line between arabic verse and its translation
  Widget buildVerseCardDivider(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: kSizeS),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context
                .watch<QuranProvider>()
                .surahDetailsPageThemeColor
                .transparentVectorColor
                .withValues(alpha: 0),
            context
                .watch<QuranProvider>()
                .surahDetailsPageThemeColor
                .textColor
                .withValues(alpha: 0.24),
          ],
        ),
      ),
    );
  }
}
