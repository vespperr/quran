import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../constants/padding.dart';
import '../../providers/quran_provider.dart';
import '../../providers/surah_details_provider.dart';
import '../../widgets/bars/reading_page_bottom_bar.dart';
import '../../widgets/pop_up/verse_pop_up_menu.dart';
import '../../widgets/quran/quran_page_widget.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  /// Scroll Controller for Verse List
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Item position listener of Verse list
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      itemScrollController.jumpTo(index: context.read<SurahDetailsProvider>().jumpToMushafPageListIndex);
      itemPositionsListener.itemPositions.addListener(scrollListener);
    });
  }

  /// Scroll Listener
  void scrollListener() {
    var first = itemPositionsListener.itemPositions.value.first.index;
    var last = itemPositionsListener.itemPositions.value.last.index;
    var index = first <= last ? first : last;
    context.read<SurahDetailsProvider>().listenToReadingScreenList(index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentMaxWidth = screenWidth * 0.92;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScrollablePositionedList.separated(
        itemCount: context.watch<SurahDetailsProvider>().mushafPageList.length,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        padding: const EdgeInsets.symmetric(horizontal: kSizeL),
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          var versesOfPage = context.watch<SurahDetailsProvider>().mushafPageList[index];
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  QuranPageWidget(
                    versesOfPage: versesOfPage,
                    layoutOptions: context.watch<QuranProvider>().localSetting.layoutOptions,
                    fontTypeArabic: context.watch<QuranProvider>().localSetting.fontTypeArabic,
                    textScaleFactor: context.watch<QuranProvider>().localSetting.textScaleFactor,
                    lineHeight: context.watch<QuranProvider>().localSetting.lineHeight,
                    onTap: context.read<SurahDetailsProvider>().changeReadingMode,
                    onVerseLongPress: (ctx, verse, position, size) {
                      VersePopUpMenu.showVerseMenuAt(
                        context,
                        verse: verse,
                        position: position,
                        menuSourceSize: size,
                      );
                    },
                    surahDetailsPageTheme: context.watch<QuranProvider>().surahDetailsPageThemeColor,
                  ),
                  Visibility(
                    visible: index == context.read<SurahDetailsProvider>().mushafPageList.length - 1,
                    child: const ReadingPageBottomBar(),
                  ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: kSizeXL),
      ),
    );
  }
}
