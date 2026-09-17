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
  final void Function(
          BuildContext context, VerseModel verse, Offset position, Size size)?
      onVerseLongPress;
  final double textScaleFactor;
  final double lineHeight;
  final String fontTypeArabic;
  final ELayoutOptions layoutOptions;
  final SurahDetailsPageThemeModel surahDetailsPageTheme;

  @override
  Widget build(BuildContext context) {
    final firstVerse = versesOfPage.first.verses.first;
    final lastVerse = versesOfPage.last.verses.last;
    final surahName = versesOfPage.first.nameArabic ?? '';
    final juzNumber = firstVerse.juzNumber ?? 1;
    final hasSajda = versesOfPage.any((s) => s.isSajdaVerse);

    final borderColor =
        surahDetailsPageTheme.titleVectorColor.withValues(alpha: 0.2);
    final cardBg = surahDetailsPageTheme.backgroundColor;

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMushafPageHeader(context, surahName, juzNumber),
            const SizedBox(height: 10),
            buildSurahCard(context),
            const SizedBox(height: 14),
            _buildMushafPageFooter(context, lastVerse, hasSajda),
          ],
        ),
      ),
    );
  }

  Widget _buildMushafPageHeader(
    BuildContext context,
    String surahName,
    int juzNumber,
  ) {
    final textColor = surahDetailsPageTheme.textColor.withValues(alpha: 0.65);
    final accentColor =
        surahDetailsPageTheme.titleVectorColor.withValues(alpha: 0.25);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 13,
                      color: surahDetailsPageTheme.titleVectorColor
                          .withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        surahName.isNotEmpty ? surahName : '',
                        style: TextStyle(
                          fontFamily: Fonts.surahNames,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '۞',
                style: TextStyle(
                  fontSize: 14,
                  color: surahDetailsPageTheme.titleVectorColor
                      .withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'الجُزْءُ ${Utils.getArabicVerseNo(juzNumber.toString())}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Divider(
          height: 1,
          thickness: 0.8,
          color: accentColor,
        ),
      ],
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
          ) ??
          const TextStyle();
      return SizedBox(
        width: double.infinity,
        child: RichText(
          textDirection: TextDirection.rtl,
          textAlign: layoutOptions == ELayoutOptions.justify
              ? TextAlign.justify
              : TextAlign.right,
          text: TextSpan(
            style: baseStyle,
            children: verses.map(
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
                        height: 1.2,
                        color: quran.surahDetailsPageThemeColor.titleVectorColor
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
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
        ) ??
        const TextStyle();
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
                height: 1.2,
                color: quran.surahDetailsPageThemeColor.titleVectorColor
                    .withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMushafPageFooter(
    BuildContext context,
    VerseModel verse,
    bool hasSajda,
  ) {
    final dividerColor =
        surahDetailsPageTheme.titleVectorColor.withValues(alpha: 0.25);
    final subColor = surahDetailsPageTheme.textColor.withValues(alpha: 0.6);
    final pageNoArabic =
        Utils.getArabicVerseNo(verse.pageNumber?.toString() ?? '1');

    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 0.8,
          color: dividerColor,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'حِزْبُ ${Utils.getArabicVerseNo(verse.hizbNumber?.toString() ?? '1')}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: subColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2.5),
              decoration: BoxDecoration(
                color: surahDetailsPageTheme.titleVectorColor
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: surahDetailsPageTheme.titleVectorColor
                      .withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Text(
                '— $pageNoArabic —',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: surahDetailsPageTheme.textColor,
                ),
              ),
            ),
            hasSajda
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('۩ ',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFD4AF37))),
                        Text(
                          context.translate.sajda,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  )
                : Flexible(
                    child: Text(
                      '${context.translate.page} ${verse.pageNumber ?? ""}',
                      style: TextStyle(
                        fontSize: 11,
                        color: subColor.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          ],
        ),
      ],
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
  final void Function(
          BuildContext context, VerseModel verse, Offset position, Size size)
      onVerseLongPress;
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
