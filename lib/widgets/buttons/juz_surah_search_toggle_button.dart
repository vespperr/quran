import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../providers/search_provider.dart';
import '../bars/custom_search_bar.dart';
import '../scale_tap_widget.dart';

class JuzSurahSearchToggleButton extends StatelessWidget {
  /// Toggle options Juz or Surah
  final EJuzSurahToggleOptions toggleListType;

  /// Changing toggles VoidCallBack
  /// Takes [EJuzSurahToggleOptions] and changes index
  final Function(EJuzSurahToggleOptions)? onChanged;

  /// Search button onTap
  final Function(EToggleSearchOptions)? onTapSearchButton;

  /// Index of juz/surah and search toggle buttons
  final int toggleSearchButtonIndex;

  const JuzSurahSearchToggleButton({
    super.key,
    required this.toggleListType,
    required this.onChanged,
    required this.toggleSearchButtonIndex,
    required this.onTapSearchButton,
  });

  static const _expandDuration = Duration(milliseconds: 240);
  static const _expandCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final controlWidth = screenWidth * 0.83;
    final isSearchExpanded = toggleSearchButtonIndex == 1;
    return SizedBox(
      width: controlWidth,
      child: AnimatedSwitcher(
        duration: _expandDuration,
        switchInCurve: _expandCurve,
        switchOutCurve: _expandCurve,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          );
        },
        child: isSearchExpanded
            ? SizedBox(
                key: const ValueKey<int>(1),
                width: controlWidth,
                child: CustomSearchBar(
                  onCollapse: () => context.read<SearchProvider>().changeToggleSearchOptions(EToggleSearchOptions.toggles),
                ),
              )
                       : Row(
                key: const ValueKey<int>(0),
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    // Subtract the extra space (e.g. 8) from the width so it doesn't overflow
                    width: controlWidth - 44 - 8, 
                    child: buildJuzAndSurahToggles(controlWidth - 44 - 8, context),
                  ),
                  // Add your desired space here!
                  const SizedBox(width: 8), 
                  buildSearchButton(context),
                ],
              ),

      ),
    );
  }

  /// Search button on the right side of home toggles
  Widget buildSearchButton(BuildContext context) {
    return ScaleTapWidget(
      onTap: () {
        onTapSearchButton!(EToggleSearchOptions.searchField);
        context.read<SearchProvider>().searchBarFocusNode.requestFocus();
      },
      child: Container(
        height: 44,
        width: 44,
        padding: const EdgeInsets.all(kSizeM),
        decoration: BoxDecoration(
          color: DesignSystem.primary,
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
        ),
        child: SvgPicture.asset(
          ImageConstants.searchIcon,
          colorFilter: const ColorFilter.mode(DesignSystem.onPrimary, BlendMode.srcIn),
        ),
      ),
    );
  }

  /// Juz and Surah toggles — segmented control style (todo 8 will refine).
  Widget buildJuzAndSurahToggles(double controlWidth, BuildContext context) {
    final bool isJuz = toggleListType.index == 0;
    
    return Container(
      width: controlWidth,
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: DesignSystem.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: isJuz ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: DesignSystem.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged!(EJuzSurahToggleOptions.juz),
                  child: Center(
                    child: Text(
                      context.translate.juz,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: isJuz
                            ? DesignSystem.primary
                            : DesignSystem.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged!(EJuzSurahToggleOptions.surah),
                  child: Center(
                    child: Text(
                      context.translate.surah,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: !isJuz
                            ? DesignSystem.primary
                            : DesignSystem.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
