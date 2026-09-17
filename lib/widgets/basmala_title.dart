import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../providers/quran_provider.dart';
import 'surah_name_svg.dart';

class BasmalaTitle extends StatelessWidget {
  final String verseKey;

  const BasmalaTitle({super.key, required this.verseKey});

  @override
  Widget build(BuildContext context) {
    final themeColor =
        context.watch<QuranProvider>().surahDetailsPageThemeColor;
    return Visibility(
      visible: isTitleVisible,
      child: Column(
        children: [
          const SizedBox(height: 8),
          buildTitle(context),
          Visibility(
            visible: isBasmalaVisible,
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 10),
              child: SvgPicture.asset(
                ImageConstants.basmalaIcon,
                height: 40,
                colorFilter: ColorFilter.mode(
                  themeColor.textColor.withValues(alpha: 0.9),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    final themeColor = quranProvider.surahDetailsPageThemeColor;
    final surahId = int.parse(verseKey.split(':').first);
    final surah = surahId >= 1 && surahId <= quranProvider.surahs.length
        ? quranProvider.surahs[surahId - 1]
        : null;

    final isMakkah = surah?.revelationPlace?.toLowerCase() == 'makkah';
    final revelationText = isMakkah ? 'مَكِّيَّة' : 'مَدَنِيَّة';
    final versesCount = surah?.verses.length ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: themeColor.titleVectorColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.titleVectorColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SvgPicture.asset(
                ImageConstants.titleFrame,
                colorFilter: ColorFilter.mode(
                  themeColor.titleVectorColor,
                  BlendMode.srcIn,
                ),
                height: 48,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: SurahNameSvg(
                  surahId: surahId,
                  color: themeColor.textColor,
                  height: 30,
                  fallbackText: surah?.nameArabic,
                ),
              ),
            ],
          ),
          if (surah != null && versesCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: themeColor.titleVectorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$revelationText • آيَاتُهَا ${Utils.getArabicVerseNo(versesCount.toString())}',
                style: TextStyle(
                  fontFamily: Fonts.naskh,
                  fontFamilyFallback: const [Fonts.uthmanic],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: themeColor.textColor.withValues(alpha: 0.75),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// İs Title Visible
  bool get isTitleVisible {
    var list = verseKey.split(':');
    if (list[1] == "1") return true;
    return false;
  }

  /// Remove basmala title from some surahs ex: surah Tawbah
  bool get isBasmalaVisible {
    var list = verseKey.split(':');
    if (list[1] == "1" && verseKey != "9:1" && verseKey != "1:1") return true;
    return false;
  }
}
