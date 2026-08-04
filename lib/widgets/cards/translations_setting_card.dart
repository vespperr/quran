import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/providers/quran_provider.dart';
import 'package:the_open_quran/widgets/buttons/delete_downloaded_translations_button.dart';
import 'package:the_open_quran/widgets/cards/slidable_verse_card/slidable_player.dart';

import '../../models/translation.dart';

class TranslationsSettingCard extends StatefulWidget {
  const TranslationsSettingCard({
    super.key,
    required this.translationAuthor,
    required this.onTap,
    required this.isDownloaded,
  });

  final TranslationAuthor translationAuthor;
  final Function(TranslationAuthor translationAuthor) onTap;
  final bool isDownloaded;

  @override
  State<TranslationsSettingCard> createState() => _TranslationsSettingCardState();
}

class _TranslationsSettingCardState extends State<TranslationsSettingCard> with SingleTickerProviderStateMixin {
  /// Animation controller for the [SlidablePlayer]
  AnimationController? animationController;

  @override
  void initState() {
    /// Animate delete button
    animationController =
        AnimationController(vsync: this, upperBound: 0.5, duration: const Duration(microseconds: 2000));
    super.initState();
  }

  /// Returns number of all translations
  int isDownloadedListEmpty() {
    int numberOfTranslations = 0;
    context.watch<QuranProvider>().translationService.allTranslationCountry.forEach((element) {
      numberOfTranslations += element.downloadedList.length;
    });
    return numberOfTranslations;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isDownloaded && isDownloadedListEmpty() > 1
        ? SlidablePlayer(
            animation: animationController,
            child: Slidable(
              key: UniqueKey(),
              endActionPane: ActionPane(
                extentRatio: 0.25,
                motion: const ScrollMotion(),
                children: [
                  DeleteDownloadedTranslationsButton(onTap: () {
                    context.read<QuranProvider>().deleteTranslationAuthor(widget.translationAuthor);
                  })
                ],
              ),
              child: buildTranslationsSettingCard(context),
            ),
          )
        : buildTranslationsSettingCard(context);
  }

  InkWell buildTranslationsSettingCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? AppColors.black3
        : theme.cardColor;

    final textColor = isDark
        ? Colors.white
        : theme.colorScheme.onSurface;

    final iconColor = isDark
        ? Colors.white
        : theme.primaryColor;

    return InkWell(
      onTap: () => widget.onTap(widget.translationAuthor),
      borderRadius: BorderRadius.circular(kSizeM),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(kSizeM),
          border: Border.all(
            color: isDark ? Colors.white10 : theme.dividerColor,
            width: 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSizeM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.translationAuthor.translationName ?? "",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              getIcon(iconColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget getIcon(Color iconColor) {
    switch (widget.translationAuthor.verseTranslationState) {
      case EVerseTranslationState.download:
        return SvgPicture.asset(
          ImageConstants.icTranslationDownload,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      case EVerseTranslationState.downloading:
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: iconColor,
            strokeWidth: 2,
          ),
        );
      case EVerseTranslationState.downloaded:
        return widget.translationAuthor.isTranslationSelected
            ? SvgPicture.asset(
                ImageConstants.ticIcon,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              )
            : const SizedBox();
    }
  }
}
