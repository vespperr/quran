import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/surah_model.dart';
import '../scale_tap_widget.dart';
import '../surah_name_svg.dart';

/// Restaurant-details style card: leading badge, title, description, metadata row.
class SurahItemCard extends StatelessWidget {
  const SurahItemCard({
    super.key,
    required this.surahModel,
    required this.onTap,
  });

  final SurahModel surahModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mutedStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: DesignSystem.onSurface.withValues(alpha: 0.64),
          fontWeight: FontWeight.normal,
        );

    return ScaleTapWidget(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.space16,
          vertical: DesignSystem.space12,
        ),
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: 88,
            child: Row(
              children: [
                _SurahNumberBadge(number: surahModel.id!),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surahModel.nameTranslated ?? surahModel.nameSimple ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              color: DesignSystem.onSurface,
                            ),
                      ),
                      SurahNameSvg(
                        surahId: surahModel.id!,
                        color: DesignSystem.onSurface.withValues(alpha: 0.8),
                        height: 20,
                        fallbackText: surahModel.nameArabic ?? surahModel.nameSimple ?? '',
                      ),
                      Row(
                      children: [
                        Text(
                          _revelationLabel(surahModel.revelationPlace),
                          style: mutedStyle,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: _SmallDot(),
                        ),
                        Text(
                          "${surahModel.verses.length} ${context.translate.ayat}",
                          style: mutedStyle,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 14,
                  color: DesignSystem.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _revelationLabel(String? place) {
    if (place == null) return '';
    final lower = place.toLowerCase();
    if (lower == 'makkah' || lower == 'mecca') return 'Meccan';
    if (lower == 'madinah' || lower == 'medina') return 'Medinan';
    return place;
  }
}

class _SurahNumberBadge extends StatelessWidget {
  const _SurahNumberBadge({required this.number});

  final int number;

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Image.asset(
            ImageConstants.surahNumberShape,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: DesignSystem.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DesignSystem.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallDot extends StatelessWidget {
  const _SmallDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: 4,
      decoration: BoxDecoration(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4) ??
            DesignSystem.onSurface.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}
