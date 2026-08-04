import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/mushaf_backgrund_model.dart';
import '../../models/surah_model.dart';
import '../../models/verse_model.dart';
import '../../providers/quran_provider.dart';
import '../basmala_title.dart';

class QuranPageWidget extends StatelessWidget {
  const QuranPageWidget({
    super.key,
    required this.versesOfPage,
    this.onTap,
    this.onVerseLongPress,
    this.textScaleFactor = 1.0,
    this.lineHeight = 1.7,
    required this.fontTypeArabic,
    required this.layoutOptions,
    required this.surahDetailsPageTheme,
  });

  final List<SurahModel> versesOfPage;
  final Function()? onTap;
  /// When set, long-pressing a verse shows the verse context menu (reading mode).
  /// Called with (context, verse, globalPosition, verseRowSize).
  final void Function(BuildContext context, VerseModel verse, Offset position, Size size)? onVerseLongPress;
  final double textScaleFactor;
  final double lineHeight;
  final String fontTypeArabic;
  final ELayoutOptions layoutOptions;
  final SurahDetailsPageThemeModel surahDetailsPageTheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        children: [
          buildSurahCard(context),
          const SizedBox(height: kSize3XL),
          buildBottomBorder(context, versesOfPage.last.verses.last)
        ],
      ),
    );
  }

  Widget buildSurahCard(BuildContext context) {
    return ListView.builder(
      itemCount: versesOfPage.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final verses = versesOfPage.elementAt(index).verses;
        return Column(
          children: [
            BasmalaTitle(verseKey: verses.first.verseKey ?? ""),
            buildVersesText(context, verses, textScaleFactor, lineHeight,
                layoutOptions, fontTypeArabic),
          ],
        );
      },
    );
  }

  Widget buildVersesText(
    BuildContext context,
    List<VerseModel> verses,
    double textScaleFactor,
    double lineHeight,
    ELayoutOptions layoutOptions,
    String fontTypeArabic,
  ) {
    final hasLongPress = onVerseLongPress != null;
    if (!hasLongPress) {
      final quran = context.watch<QuranProvider>();
      final baseStyle = context.theme.textTheme.headlineLarge?.copyWith(
            height: lineHeight,
            fontSize: 20,
            fontFamily: Fonts.getArabicFont(fontTypeArabic),
            color: quran.surahDetailsPageThemeColor.textColor,
            letterSpacing: -0.7,
          ) ?? const TextStyle();
      return SizedBox(
        width: double.infinity,
        child: RichText(
          textDirection: TextDirection.rtl,
          textAlign: layoutOptions == ELayoutOptions.justify
              ? TextAlign.justify
              : TextAlign.right,
          text: TextSpan(
          style: baseStyle,
          children: verses
              .map(
                (e) {
                  final verseSpans = quran.getVerseDisplaySpans(e, baseStyle);
                  return TextSpan(
                    children: [
                      ...verseSpans,
                      TextSpan(
                        text: Utils.getArabicVerseNo(e.verseNumber.toString()),
                        style: context.theme.textTheme.headlineLarge?.copyWith(
                          fontFamily: Fonts.uthmanicIcon,
                          fontSize: 16,
                          letterSpacing: -2.5,
                          height: 1.2,
                          color: context
                              .watch<QuranProvider>()
                              .surahDetailsPageThemeColor
                              .textColor,
                        ),
                      ),
                    ],
                  );
                },
              )
              .toList(),
          ),
          textScaler: TextScaler.linear(textScaleFactor),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: verses.map((verse) {
        return _VerseHoverWrapper(
          verse: verse,
          onVerseLongPress: onVerseLongPress!,
          child: buildSingleVerseText(context, verse, textScaleFactor,
              lineHeight, layoutOptions, fontTypeArabic),
        );
      }).toList(),
    );
  }

  Widget buildSingleVerseText(
    BuildContext context,
    VerseModel verse,
    double textScaleFactor,
    double lineHeight,
    ELayoutOptions layoutOptions,
    String fontTypeArabic,
  ) {
    final quran = context.watch<QuranProvider>();
    final baseStyle = context.theme.textTheme.headlineLarge?.copyWith(
          height: lineHeight,
          fontSize: 20,
          fontFamily: Fonts.getArabicFont(fontTypeArabic),
          color: quran.surahDetailsPageThemeColor.textColor,
          letterSpacing: -0.7,
        ) ?? const TextStyle();
    final verseSpans = quran.getVerseDisplaySpans(verse, baseStyle);
    return SizedBox(
      width: double.infinity,
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: layoutOptions == ELayoutOptions.justify
            ? TextAlign.justify
            : TextAlign.right,
        textScaler: TextScaler.linear(textScaleFactor),
        text: TextSpan(
          style: baseStyle,
          children: [
            ...verseSpans,
            TextSpan(
              text: Utils.getArabicVerseNo(verse.verseNumber.toString()),
              style: context.theme.textTheme.headlineLarge?.copyWith(
                fontFamily: Fonts.uthmanicIcon,
                fontSize: 16,
                letterSpacing: -2.5,
                height: 1.2,
                color: context
                    .watch<QuranProvider>()
                    .surahDetailsPageThemeColor
                    .textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomBorder(BuildContext context, VerseModel verse) {
    return Container(
      padding: const EdgeInsets.only(bottom: kSizeS),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(color: surahDetailsPageTheme.transparentVectorColor),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${context.translate.juz} ${verse.juzNumber} | ${context.translate.hizb} ${verse.hizbNumber} - ${context.translate.page} ${verse.pageNumber}",
            style: context.theme.textTheme.bodySmall?.copyWith(
                color: surahDetailsPageTheme.transparentTextColor,
                letterSpacing: 0.15),
          ),
          Text(
            verse.pageNumber?.quranPageNumber ?? "",
            style: context.theme.textTheme.bodyMedium?.copyWith(
                color: surahDetailsPageTheme.transparentVectorColor,
                letterSpacing: 0.04),
          ),
        ],
      ),
    );
  }
}

/// Wraps a single verse so only this ayah shows hover highlight in reading mode.
class _VerseHoverWrapper extends StatefulWidget {
  const _VerseHoverWrapper({
    required this.verse,
    required this.onVerseLongPress,
    required this.child,
  });

  final VerseModel verse;
  final void Function(BuildContext context, VerseModel verse, Offset position, Size size) onVerseLongPress;
  final Widget child;

  @override
  State<_VerseHoverWrapper> createState() => _VerseHoverWrapperState();
}

class _VerseHoverWrapperState extends State<_VerseHoverWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = DesignSystem.primary.withValues(alpha: 0.08);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onLongPress: () {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final position = box.localToGlobal(Offset.zero);
            final size = box.paintBounds.size;
            widget.onVerseLongPress(context, widget.verse, position, size);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
