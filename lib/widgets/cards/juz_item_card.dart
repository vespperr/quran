import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/surah_model.dart';
import '../scale_tap_widget.dart';
import '../surah_name_svg.dart';

/// Juz card in list style: shows Juz number and surah name SVGs for that Juz.
/// [compact] true in grid: surah list is height-limited and scrollable to avoid overflow.
class JuzItemCard extends StatelessWidget {
  const JuzItemCard({
    super.key,
    required this.juzId,
    required this.surahs,
    required this.onTap,
    this.compact = false,
  });

  final int juzId;
  final List<SurahModel> surahs;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.screenPadding,
          vertical: DesignSystem.space12,
        ),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          decoration: BoxDecoration(
            color: DesignSystem.surface,
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
            boxShadow: DesignSystem.shadowSoft,
            border: Border.all(
              color: DesignSystem.outline.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _JuzNumberBadge(number: juzId),
                  const SizedBox(width: DesignSystem.space12),
                  Expanded(
                    child: Text(
                      '${context.translate.juz} $juzId',
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        color: DesignSystem.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.space8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: DesignSystem.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
              if (surahs.isNotEmpty) ...[
                const SizedBox(height: DesignSystem.space12),
                _buildSurahList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const double _surahChipHeight = 22.0;
  static const int _compactMaxLines = 3;
  static const double _compactMaxHeight =
      _surahChipHeight * _compactMaxLines + DesignSystem.space8 * (_compactMaxLines - 1);

  Widget _buildSurahList() {
    final wrap = Wrap(
      spacing: DesignSystem.space8,
      runSpacing: DesignSystem.space8,
      alignment: WrapAlignment.start,
      children: surahs.map((s) {
        return SizedBox(
          height: _surahChipHeight,
          child: SurahNameSvg(
            surahId: s.id ?? 1,
            color: DesignSystem.onSurface.withValues(alpha: 0.85),
            height: _surahChipHeight,
            fallbackText: s.nameArabic ?? s.nameSimple ?? '',
          ),
        );
      }).toList(),
    );
    if (compact) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: _compactMaxHeight),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: wrap,
        ),
      );
    }
    return wrap;
  }
}

class _JuzNumberBadge extends StatelessWidget {
  const _JuzNumberBadge({required this.number});

  final int number;

  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: DesignSystem.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: context.theme.textTheme.titleMedium?.copyWith(
          color: DesignSystem.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
