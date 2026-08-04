import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/surah_model.dart';
import '../../providers/search_provider.dart';

class SearchCard extends StatelessWidget {
  /// [SurahModel]
  final SurahModel surahModel;

  /// Function onTap
  final Function() onTap;

  const SearchCard({super.key, required this.surahModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kSizeL),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
              color: DesignSystem.surface,
              border: Border.all(color: DesignSystem.outline.withValues(alpha: 0.4)),
              boxShadow: DesignSystem.shadowSoft,
            ),
            child: Row(
              children: [
                Expanded(child: searchFor(context)),
                Icon(Icons.arrow_forward_ios, size: 14, color: DesignSystem.onSurface.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Search for input text
  Widget searchFor(BuildContext context) {
    return Text(
      "${context.translate.searchFor} \"${context.watch<SearchProvider>().textEditingController.text}\"",
      overflow: TextOverflow.ellipsis,
      style: context.theme.textTheme.titleMedium?.copyWith(
        color: DesignSystem.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
