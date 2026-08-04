import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/widgets/cards/verse_menu_item.dart';
import 'package:the_open_quran/widgets/memorization_calendar_dialog.dart';

import '../../models/bookmark_model.dart';
import '../../models/verse_model.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/surah_details_provider.dart';

/// CustomGestureDetector takes globalKey to identify child
class VersePopUpMenu extends StatelessWidget {
  const VersePopUpMenu({
    super.key,
    required this.child,
    required this.globalKey,
    required this.verseModel,
    required this.playFunction,
    required this.favoriteFunction,
    required this.bookmarkFunction,
    required this.copyFunction,
    required this.shareFunction,
    this.memorizeFunction,
    this.isPlaying = false,
    this.isFavorite = false,
    this.isBookmark = false,
    required this.changeSelectedVerseKey,
  });
  final Widget child;
  final GlobalKey globalKey;
  final VerseModel verseModel;
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
  final Function(String? selectedVerseKey) changeSelectedVerseKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        changeSelectedVerseKey(verseModel.verseKey);
        RenderBox box =
            globalKey.currentContext?.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);
        await showMenu(
          context: context,
          color: AppColors.black9,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColors.white.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          position: RelativeRect.fromRect(
            Rect.fromLTWH(
                position.dx + kSizeM,
                position.dy + (box.paintBounds.size.height - 200 - kSizeM),
                0,
                0),
            Rect.fromLTWH(
                0, 0, box.paintBounds.size.width, box.paintBounds.size.height),
          ),
          items: [
            PopupMenuItem(
              onTap: () => playFunction(verseModel, isPlaying),
              child: VerseMenuItem(
                iconPath:
                    isPlaying ? ImageConstants.pauseIcon : ImageConstants.play,
                buttonName: isPlaying
                    ? context.translate.pause
                    : context.translate.play,
              ),
            ),
            PopupMenuItem(
              onTap: () => favoriteFunction(verseModel, isFavorite),
              child: VerseMenuItem(
                iconPath: isFavorite
                    ? ImageConstants.favoriteActiveIcon
                    : ImageConstants.favoriteInactiveIcon,
                buttonName: context.translate.favorite,
              ),
            ),
            PopupMenuItem(
              onTap: () =>
                  bookmarkFunction(EBookMarkType.verse, verseModel, isBookmark),
              child: VerseMenuItem(
                iconPath: isBookmark
                    ? ImageConstants.bookmarkActiveIcon
                    : ImageConstants.bookmarkInactiveIcon,
                buttonName: context.translate.bookmark,
              ),
            ),
            if (memorizeFunction != null)
              PopupMenuItem(
                onTap: () => memorizeFunction!(verseModel),
                child: VerseMenuItem(
                  buttonName: context.translate.memorize,
                  iconData: Icons.calendar_month,
                ),
              ),
            PopupMenuItem(
              onTap: () => copyFunction(verseModel),
              child: VerseMenuItem(
                iconPath: ImageConstants.shareAppIcon,
                buttonName: context.translate.copy,
                iconData: Icons.copy_outlined,
              ),
            ),
            PopupMenuItem(
              onTap: () => shareFunction(verseModel),
              child: VerseMenuItem(
                iconPath: ImageConstants.shareAppIcon,
                buttonName: context.translate.share,
              ),
            ),
          ],
        );
        changeSelectedVerseKey(null);
      },
      child: child,
    );
  }

  /// Show the same verse context menu at [position] (e.g. from long-press in reading mode).
  static Future<void> showVerseMenuAt(
    BuildContext context, {
    required VerseModel verse,
    required Offset position,
    Size menuSourceSize = const Size(1, 1),
  }) async {
    final bookmarkProvider = context.read<BookmarkProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    final surahDetailsProvider = context.read<SurahDetailsProvider>();
    final isFavorite = favoritesProvider.isFavoriteVerse(verse);
    final isBookmark = bookmarkProvider.isBookmark(
      BookMarkModel(bookmarkType: EBookMarkType.verse, verseModel: verse),
    );
    surahDetailsProvider.changeSelectedVerseKey(verse.verseKey);
    final screen = MediaQuery.sizeOf(context);
    await showMenu<void>(
      context: context,
      color: AppColors.black9,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: AppColors.white.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          position.dx + kSizeM,
          position.dy + (menuSourceSize.height - 200 - kSizeM).clamp(0.0, double.infinity),
          0,
          0,
        ),
        Rect.fromLTWH(0, 0, screen.width, screen.height),
      ),
      items: [
        PopupMenuItem(
          onTap: () {},
          child: VerseMenuItem(
            iconPath: ImageConstants.play,
            buttonName: context.translate.play,
          ),
        ),
        PopupMenuItem(
          onTap: () => favoritesProvider.onTapFavoriteButton(verse, isFavorite),
          child: VerseMenuItem(
            iconPath: isFavorite
                ? ImageConstants.favoriteActiveIcon
                : ImageConstants.favoriteInactiveIcon,
            buttonName: context.translate.favorite,
          ),
        ),
        PopupMenuItem(
          onTap: () =>
              bookmarkProvider.onTapBookMarkButton(EBookMarkType.verse, verse, isBookmark),
          child: VerseMenuItem(
            iconPath: isBookmark
                ? ImageConstants.bookmarkActiveIcon
                : ImageConstants.bookmarkInactiveIcon,
            buttonName: context.translate.bookmark,
          ),
        ),
        PopupMenuItem(
          onTap: () => showMemorizationCalendar(context, verse),
          child: VerseMenuItem(
            buttonName: context.translate.memorize,
            iconData: Icons.calendar_month,
          ),
        ),
        PopupMenuItem(
          onTap: () => surahDetailsProvider.copyVerse(verse, 0),
          child: VerseMenuItem(
            iconPath: ImageConstants.shareAppIcon,
            buttonName: context.translate.copy,
            iconData: Icons.copy_outlined,
          ),
        ),
        PopupMenuItem(
          onTap: () => surahDetailsProvider.shareVerse(verse, 0),
          child: VerseMenuItem(
            iconPath: ImageConstants.shareAppIcon,
            buttonName: context.translate.share,
          ),
        ),
      ],
    );
    surahDetailsProvider.changeSelectedVerseKey(null);
  }
}
