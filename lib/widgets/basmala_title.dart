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
    return Visibility(
      visible: isTitleVisible,
      child: Column(
        children: [
          buildTitle(context),
          Visibility(
            visible: isBasmalaVisible,
            child: Column(
              children: [
                const SizedBox(height: kSizeL),
                SvgPicture.asset(ImageConstants.basmalaIcon,
                    color: context
                        .watch<QuranProvider>()
                        .surahDetailsPageThemeColor
                        .textColor),
              ],
            ),
          ),
          const SizedBox(height: kSize3XL),
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
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SvgPicture.asset(ImageConstants.titleFrame,
            color: themeColor.titleVectorColor),
        SurahNameSvg(
          surahId: surahId,
          color: themeColor.textColor,
          height: 32,
          fallbackText: surah?.nameArabic,
        ),
      ],
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
