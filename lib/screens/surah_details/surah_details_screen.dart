import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/screens/surah_details/reading_screen.dart';
import 'package:the_open_quran/screens/surah_details/translation_screen.dart';

import '../../providers/quran_provider.dart';
import '../../providers/surah_details_provider.dart';
import '../../services/quran_recitation_service.dart';
import '../../widgets/animation/fade_indexed_stack.dart';
import '../../widgets/app_bars/secondary_app_bar.dart';

class SurahDetailsScreen extends StatefulWidget {
  const SurahDetailsScreen({super.key});

  @override
  State<SurahDetailsScreen> createState() => _SurahDetailsScreenState();
}

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeIndex = context.watch<QuranProvider>().localSetting.surahDetailsPageThemeIndex;
    final themeColor = context.watch<QuranProvider>().surahDetailsPageThemeColor;
    final useLuxuryGradient = themeIndex == 0;

    return Scaffold(
      appBar: buildAppBar(),
      body: useLuxuryGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: DesignSystem.gradientLuxuryBackground,
              ),
              child: buildBody,
            )
          : buildBody,
      backgroundColor: useLuxuryGradient ? null : themeColor.backgroundColor,
    );
  }

  PreferredSizeWidget buildAppBar() => PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: ValueListenableBuilder<String?>(
          valueListenable: QuranRecitationService.currentVerseKey,
          builder: (context, playingKey, _) {
            return ValueListenableBuilder<PlayerState>(
              valueListenable: QuranRecitationService.playerState,
              builder: (context, state, _) {
                final soundActive =
                    playingKey != null && state == PlayerState.playing;
                return SecondaryAppBar(
                  title: context.watch<SurahDetailsProvider>().appBarTitle,
                  subTitle:
                      context.watch<SurahDetailsProvider>().appBarDescription,
                  showSoundButton: true,
                  isActiveSoundIcon: soundActive,
                  onTapSound: (_) =>
                      context.read<SurahDetailsProvider>().onTapSoundIcon(false),
                  isBookmarked:
                      context.watch<SurahDetailsProvider>().appBarBookmarkActive,
                  onTapBookmark: context
                      .read<SurahDetailsProvider>()
                      .onTapAppBarBookmarkIcon,
                  pageTheme:
                      context.watch<QuranProvider>().surahDetailsPageThemeColor,
                  titleFontFamily: Fonts.surahNames,
                );
              },
            );
          },
        ),
      );

  Widget get buildBody {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(child: buildTranslationOrReading),
        ],
      ),
    );
  }



  /// Switch toggles
  /// [EQuranType.translation] and [EQuranType.reading]
  Widget get buildTranslationOrReading {
    return FadeIndexedStack(
      index: context.watch<QuranProvider>().localSetting.quranType.index,
      children: const [
        TranslationScreen(),
        ReadingScreen(),
      ],
    );
  }
}
