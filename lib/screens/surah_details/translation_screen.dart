import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../constants/constants.dart';
import '../../models/bookmark_model.dart';
import '../../models/verse_model.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/surah_details_provider.dart';
import '../../services/quran_recitation_service.dart';
import '../../widgets/bars/reading_page_bottom_bar.dart';
import '../../widgets/basmala_title.dart';
import '../../widgets/cards/new_verse_card.dart';
import '../../widgets/memorization_calendar_dialog.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  /// Scroll Controller for Verse List
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Item position listener of Verse list
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      itemScrollController.jumpTo(index: context.read<SurahDetailsProvider>().jumpToVerseIndex);
      itemPositionsListener.itemPositions.addListener(scrollListener);
    });
  }

  /// Scroll Listener
  void scrollListener() {
    var first = itemPositionsListener.itemPositions.value.first.index;
    var last = itemPositionsListener.itemPositions.value.last.index;
    var index = first <= last ? first : last;
    context.read<SurahDetailsProvider>().listenToTranslationScreenList(index);
  }

  @override
  Widget build(BuildContext context) {
    var verses = context.watch<SurahDetailsProvider>().displayedVerses;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        onTap: context.read<SurahDetailsProvider>().changeReadingMode,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: ScrollablePositionedList.separated(
          itemCount: verses.length,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          padding: const EdgeInsets.only(
            left: kSizeM,
            right: kSizeL,
            bottom: kSizeXL,
          ),
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final verse = verses[index];
            return _TranslationVerseHoverWrapper(
              child: Column(
                children: [
                  BasmalaTitle(verseKey: verse.verseKey ?? ""),
                  buildVerseCard(index, verse, context),
                  Visibility(
                    visible: index == verses.length - 1,
                    child: const ReadingPageBottomBar(),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: kSizeM),
        ),
      ),
    );
  }

  Widget buildVerseCard(int index, VerseModel verse, BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: QuranRecitationService.currentVerseKey,
      builder: (context, playingKey, _) {
        return ValueListenableBuilder<PlayerState>(
          valueListenable: QuranRecitationService.playerState,
          builder: (context, playerState, _) {
            final isPlaying =
                playingKey == verse.verseKey && playerState == PlayerState.playing;
            return VerseCard(
      verseModel: verse,
      arabicFontFamily: Fonts.uthmanicIcon,
      verseTranslations: context.watch<QuranProvider>().translationService.translationsOfVerse(verse.id!),
      readOptions: context.watch<QuranProvider>().localSetting.readOptions,
      textScaleFactor: context.watch<QuranProvider>().localSetting.textScaleFactor,
      translationFontFamily: Fonts.getTranslationFont(context.watch<QuranProvider>().localSetting.fontType),
      isPlaying: isPlaying,
      playFunction: (v, playing) {
        context.read<SurahDetailsProvider>().onTapVerseCardPlayOrPause(index, playing);
      },
      isFavorite: context.watch<FavoritesProvider>().isFavoriteVerse(verse),
      favoriteFunction: context.read<FavoritesProvider>().onTapFavoriteButton,
      isBookmark: context.watch<BookmarkProvider>().isBookmark(
            BookMarkModel(bookmarkType: EBookMarkType.verse, verseModel: verse),
          ),
      bookmarkFunction: context.read<BookmarkProvider>().onTapBookMarkButton,
      copyFunction: (verseModel) {
        context.read<SurahDetailsProvider>().copyVerse(verseModel, index);
      },
      shareFunction: (verseModel) {
        context.read<SurahDetailsProvider>().shareVerse(verseModel, index);
      },
      memorizeFunction: (verseModel) {
        showMemorizationCalendar(context, verseModel);
      },
      selectedVerseKey: context.watch<SurahDetailsProvider>().selectedVerseKey,
      changeSelectedVerseKey: context.read<SurahDetailsProvider>().changeSelectedVerseKey,
            );
          },
        );
      },
    );
  }
}

/// Wraps a translation verse row so only this ayah shows hover highlight.
class _TranslationVerseHoverWrapper extends StatefulWidget {
  const _TranslationVerseHoverWrapper({required this.child});

  final Widget child;

  @override
  State<_TranslationVerseHoverWrapper> createState() =>
      _TranslationVerseHoverWrapperState();
}

class _TranslationVerseHoverWrapperState
    extends State<_TranslationVerseHoverWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = DesignSystem.primary.withValues(alpha: 0.08);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered ? hoverColor : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: widget.child,
      ),
    );
  }
}
