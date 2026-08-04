import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../constants/non_quran_style.dart';

/// Expandable help item — com-folder style (ActivitySettings expandable sections).
class HelpGuideCard extends StatefulWidget {
  final String text;
  final String description;

  const HelpGuideCard({super.key, required this.text, required this.description});

  @override
  State<HelpGuideCard> createState() => _HelpGuideCardState();
}

class _HelpGuideCardState extends State<HelpGuideCard> {
  bool isExpanded = false;

  void changeExpanded(bool value) {
    setState(() => isExpanded = value);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: NonQuranStyle.sectionCardBackground.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: NonQuranStyle.sectionCardShadow.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusSmall),
          child: ExpansionTile(
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.text,
                    style: context.theme.textTheme.headlineSmall?.copyWith(
                      color: NonQuranStyle.sectionTitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: NonQuranStyle.expandableIconSize + 4,
              color: NonQuranStyle.expandableIconColor,
            ),
            onExpansionChanged: changeExpanded,
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            childrenPadding: const EdgeInsets.only(bottom: kSizeM, left: kSizeXL, right: kSizeXL),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  widget.description,
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: NonQuranStyle.sectionSubtitleColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
