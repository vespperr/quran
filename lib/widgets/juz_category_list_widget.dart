import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../models/surah_model.dart';
import 'animation/fade_indexed_stack.dart';
import 'animation/staggered_fade_slide.dart';
import 'buttons/juz_list_toggle_button.dart';
import 'cards/juz_item_card.dart';

class JuzCategoryListWidget extends StatefulWidget {
  final List<List<SurahModel>> juzList;
  final EJuzListType listType;
  final Function(EJuzListType newListType) onChangedListType;
  final Function(int juzId) onTapGridCard;
  final Function(int surahId) onTapSurahCard;

  const JuzCategoryListWidget({
    super.key,
    required this.juzList,
    this.listType = EJuzListType.list,
    required this.onChangedListType,
    required this.onTapGridCard,
    required this.onTapSurahCard,
  });

  @override
  State<JuzCategoryListWidget> createState() => _JuzCategoryListWidgetState();
}

class _JuzCategoryListWidgetState extends State<JuzCategoryListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.translate.juz,
              style: context.theme.textTheme.displayLarge?.copyWith(letterSpacing: 0.4),
            ),
            JuzListToggleButton(
              listType: widget.listType,
              onChanged: widget.onChangedListType,
            )
          ],
        ),
        FadeIndexedStack(
          index: widget.listType.index,
          children: [
            buildJuzList(),
            buildJuzGridList(),
          ],
        ),
      ],
    );
  }

  /// Grid of Juz cards: 2 columns, each card height fits its content so all names are visible.
  Widget buildJuzGridList() {
    final count = widget.juzList.length;
    final rowCount = (count / 2).ceil();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: kSizeL),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = leftIndex + 1;
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rowCount - 1 ? DesignSystem.space12 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Expanded(
                  child: StaggeredFadeSlide(
                    index: leftIndex,
                    child: JuzItemCard(
                      juzId: leftIndex + 1,
                      surahs: widget.juzList[leftIndex],
                      onTap: () => widget.onTapGridCard(leftIndex + 1),
                    ),
                  ),
                ),
                if (rightIndex < count) ...[
                  const SizedBox(width: DesignSystem.space12),
                  Expanded(
                    child: StaggeredFadeSlide(
                      index: rightIndex,
                      child: JuzItemCard(
                        juzId: rightIndex + 1,
                        surahs: widget.juzList[rightIndex],
                        onTap: () => widget.onTapGridCard(rightIndex + 1),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        );
      },
    );
  }

  /// List of Juz cards with surah name SVGs.
  Widget buildJuzList() {
    return ListView.builder(
      itemCount: widget.juzList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: DesignSystem.space24),
      itemBuilder: (context, index) {
        final juzId = index + 1;
        final surahs = widget.juzList[index];
        return StaggeredFadeSlide(
          index: index,
          child: JuzItemCard(
            juzId: juzId,
            surahs: surahs,
            onTap: () => widget.onTapGridCard(juzId),
          ),
        );
      },
    );
  }
}
