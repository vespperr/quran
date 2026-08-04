import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/surah_model.dart';
import '../scale_tap_widget.dart';

/// Small card for horizontal "Featured" surah strip (restaurant-details style).
class FeaturedSurahCard extends StatelessWidget {
  const FeaturedSurahCard({
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
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          width: 140,
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: DesignSystem.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                    ),
                    child: Center(
                      child: Text(
                        '${surahModel.id}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: DesignSystem.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                surahModel.nameTranslated ?? surahModel.nameSimple ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DesignSystem.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                "${surahModel.verses.length} ${context.translate.ayat}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: mutedStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

