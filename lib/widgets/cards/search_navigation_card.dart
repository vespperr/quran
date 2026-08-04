import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

class SearchNavigationCard extends StatelessWidget {
  /// The number of the page or juz
  final String? titleNumber;

  /// Card title
  final String title;

  /// Function onTap
  final Function() onTap;

  /// Constructor
  const SearchNavigationCard({super.key, this.titleNumber, required this.onTap, required this.title});

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
                Expanded(child: navigationTitle(context)),
                Icon(Icons.arrow_forward_ios, size: 14, color: DesignSystem.onSurface.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Number of juz or page
  Widget navigationTitle(BuildContext context) {
    return Text(
      titleNumber ?? '',
      overflow: TextOverflow.ellipsis,
      style: context.theme.textTheme.titleMedium?.copyWith(
        color: DesignSystem.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
