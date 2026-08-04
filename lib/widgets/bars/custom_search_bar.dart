import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../providers/search_provider.dart';

/// Single search bar matching app style: surface, rounded, soft shadow, search icon inside.
class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key, this.onCollapse});

  /// Called when user taps cancel (to collapse search).
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: DesignSystem.space20,
        left: DesignSystem.screenPadding,
        right: DesignSystem.screenPadding,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
          border: Border.all(
            color: DesignSystem.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: DesignSystem.shadowSoft,
        ),
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space12),
        child: buildSearchTextField(context),
      ),
    );
  }

  Widget buildSearchTextField(BuildContext context) {
    final controller = context.read<SearchProvider>().textEditingController;
    return TextField(
      onSubmitted: context.read<SearchProvider>().handleSearchSubmitted,
      onChanged: (value) => context.read<SearchProvider>().runLiveSearch(value),
      controller: controller,
      focusNode: context.read<SearchProvider>().searchBarFocusNode,
      decoration: InputDecoration(
        prefixIcon: IconButton(
          icon: const Icon(Icons.search, size: 22, color: DesignSystem.primary),
          onPressed: () {
            final query = controller.text.trim();
            if (query.isNotEmpty) {
              context.read<SearchProvider>().handleSearchSubmitted(query);
            }
            FocusScope.of(context).unfocus();
          },
          tooltip: context.translate.search,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        suffixIcon: CancelIcon(onCollapse: onCollapse),
        suffixIconColor: DesignSystem.onSurface.withValues(alpha: 0.7),
        suffixIconConstraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
        border: InputBorder.none,
        hintText: context.translate.searchSurahJuzOrPage,
        hintStyle: context.theme.textTheme.titleMedium?.copyWith(
          color: DesignSystem.onSurface.withValues(alpha: 0.6),
        ),
      ),
      cursorColor: DesignSystem.primary,
      style: context.theme.textTheme.titleMedium?.copyWith(
        color: DesignSystem.onSurface,
      ),
      textAlignVertical: TextAlignVertical.center,
    );
  }
}

/// Clear icon in search bar
class CancelIcon extends StatelessWidget {
  const CancelIcon({super.key, this.onCollapse});

  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close, size: 22),
      color: DesignSystem.onSurface.withValues(alpha: 0.7),
      onPressed: () {
        context.read<SearchProvider>().clearSearchField(context);
        onCollapse?.call();
      },
    );
  }
}
