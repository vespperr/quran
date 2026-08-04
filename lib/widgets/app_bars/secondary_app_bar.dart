import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/widgets/bottom_sheets/surah_detail_settings_bottom_sheet.dart';

import '../../models/mushaf_backgrund_model.dart';
import '../../providers/search_provider.dart';
import '../../screens/search_result_screen.dart';
import '../animation/fade_indexed_stack.dart';
import '../buttons/juz_surah_search_toggle_button.dart';
import '../lists/juz_list.dart';
import '../lists/surah_list.dart';

class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String title;
  final String subTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool isBookmarked;
  final bool showSoundButton;
  final bool isActiveSoundIcon;
  final Function(bool) onTapBookmark;
  final Function(bool isPlaying)? onTapSound;
  final double? bottomHeight;
  final double? elevation;
  /// When set, app bar and title pill use these colors for consistent contrast with the page.
  final SurahDetailsPageThemeModel? pageTheme;
  /// Font family for the title (e.g. Arabic surah names).
  final String? titleFontFamily;

  const SecondaryAppBar({
    super.key,
    required this.title,
    required this.subTitle,
    this.actions,
    this.leading,
    this.isBookmarked = false,
    this.showSoundButton = false,
    this.isActiveSoundIcon = false,
    this.bottomHeight,
    this.elevation,
    this.pageTheme,
    this.titleFontFamily,
    required this.onTapBookmark,
    this.onTapSound,
  })  : preferredSize = const Size.fromHeight(75.0);

  @override
  Widget build(BuildContext context) {
    final bgColor = pageTheme?.backgroundColor;
    final iconColor = pageTheme?.textColor;
    final pillColor = pageTheme?.switchSelectColor;
    return AppBar(
      toolbarHeight: Platform.isIOS ? 60 : 70,
      centerTitle: true,
      titleSpacing: 5,
      backgroundColor: bgColor,
      foregroundColor: iconColor,
      iconTheme: IconThemeData(color: iconColor),
      title: buildAppBarTitle(context, pillColor: pillColor, iconColor: iconColor, fontFamily: titleFontFamily),
      leading: Row(
        children: [buildBackIconButton(context, iconColor), buildBookmarkButton(iconColor)],
      ),
      leadingWidth: 100,
      actions: [
        if (showSoundButton && onTapSound != null) buildSoundButton(iconColor),
        buildSettingsButton(context, iconColor),
      ],
      automaticallyImplyLeading: false,
    );
  }

  /// Settings button
  IconButton buildSettingsButton(BuildContext context, Color? iconColor) {
    return IconButton(
      onPressed: () {
        SurahDetailSettingsBottomSheet.show(context);
      },
      icon: SvgPicture.asset(
        ImageConstants.settingsIcon,
        height: 20,
        colorFilter: iconColor != null ? ColorFilter.mode(iconColor, BlendMode.srcIn) : null,
      ),
    );
  }

  /// Sound button
  IconButton buildSoundButton(Color? iconColor) {
    return IconButton(
      onPressed: () => onTapSound!(isActiveSoundIcon),
      icon: SvgPicture.asset(
        isActiveSoundIcon ? ImageConstants.soundIcon : ImageConstants.soundInactiveIcon,
        height: 20,
        colorFilter: iconColor != null ? ColorFilter.mode(iconColor, BlendMode.srcIn) : null,
      ),
    );
  }

  /// Bookmark button
  IconButton buildBookmarkButton(Color? iconColor) {
    return IconButton(
      onPressed: () => onTapBookmark(isBookmarked),
      icon: SvgPicture.asset(
        isBookmarked ? ImageConstants.bookmarkActiveIcon : ImageConstants.bookmarkIcon,
        height: 20,
        colorFilter: iconColor != null ? ColorFilter.mode(iconColor, BlendMode.srcIn) : null,
      ),
    );
  }

  /// Surah and pages title
  GestureDetector buildAppBarTitle(BuildContext context, {Color? pillColor, Color? iconColor, String? fontFamily}) {
    final pillBg = pillColor ?? DesignSystem.primary;
    final textColor = DesignSystem.onPrimary;
    return GestureDetector(
        onTap: () {
          showMaterialModalBottomSheet(
              context: context,
              builder: (_) => Consumer<SearchProvider>(builder: (context, _, child) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.85,
                      padding: const EdgeInsets.only(top: kSizeL),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: kSizeS * 1.5,
                              width: kSize3XL * 5,
                              decoration: BoxDecoration(
                                  color: context.theme.cardColor, borderRadius: BorderRadius.circular(kSizeXXL)),
                            ),
                            JuzSurahSearchToggleButton(
                              toggleSearchButtonIndex: context.watch<SearchProvider>().toggleSearchOptions.index,
                              onChanged: context.read<SearchProvider>().changeJuzOrSurahToggleOptionType,
                              onTapSearchButton: context.read<SearchProvider>().changeToggleSearchOptions,
                              toggleListType: context.watch<SearchProvider>().juzSurahToggleOptionType,
                            ),
                            FadeIndexedStack(
                              index: context.watch<SearchProvider>().toggleSearchOptions.index,
                              children: [
                                buildToggleSearchPages(context),
                                const SearchResultScreen(isHome: false),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kSizeXL),
                ),
              ),
              backgroundColor: context.theme.scaffoldBackgroundColor);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: kSizeS + 3, horizontal: kSizeL),
          decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.theme.textTheme.headlineLarge!
                        .copyWith(color: textColor, fontFamily: fontFamily),
                  ),
                  Icon(Icons.arrow_drop_down_rounded, color: textColor),
                ],
              ),
              const Gap(5),
              Text(
                subTitle,
                style: context.theme.textTheme.bodyLarge!
                    .copyWith(color: textColor.withOpacity(0.9), letterSpacing: 0),


              ),
            ],
          ),
        ));
  }

  /// Back navigation button
  IconButton buildBackIconButton(BuildContext context, Color? iconColor) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: SvgPicture.asset(
        ImageConstants.arrowBack,
        height: 18,
        colorFilter: (iconColor ?? context.theme.appBarTheme.iconTheme?.color) != null
            ? ColorFilter.mode(iconColor ?? context.theme.appBarTheme.iconTheme!.color!, BlendMode.srcIn)
            : null,
      ),
    );
  }

  /// Juz/Translation and Search pages
  FadeIndexedStack buildToggleSearchPages(BuildContext context) {
    return FadeIndexedStack(
      index: context.watch<SearchProvider>().juzSurahToggleOptionType.index,
      children: [
        JuzList(
            changeListType: context.read<SearchProvider>().changeJuzListType,
            juzListType: context.watch<SearchProvider>().juzListType,
            onTapJuzCard: (juzId) {
              context.read<SearchProvider>().goToJuz(context, juzId, false);
            },
            onTapSurahCard: (surahId) {
              context.read<SearchProvider>().goToSurah(context, surahId, false);
            }),
        SurahList(onTap: (surahId) {
          context.read<SearchProvider>().goToSurah(context, surahId, false);
        }),
      ],
    );
  }
}
