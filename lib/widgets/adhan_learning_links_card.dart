import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/adhan_links.dart';

/// External links for learning the adhan (Bilal Academy, lessons, videos).
/// Used from Prayer times and Library so teaching stays discoverable in both places.
class AdhanLearningLinksCard extends StatelessWidget {
  const AdhanLearningLinksCard({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.translate.openExternalLink)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSystem.space16),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        border: Border.all(color: DesignSystem.outline.withValues(alpha: 0.5)),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate.adhanLearnSectionTitle,
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: DesignSystem.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.space8),
          _tile(
            context,
            icon: Icons.menu_book_outlined,
            label: context.translate.adhanLearnBookLink,
            onTap: () => _launch(context, AdhanLinks.adhanBookOrLesson),
          ),
          _tile(
            context,
            icon: Icons.play_circle_outline,
            label: context.translate.adhanLearnVideosLink,
            onTap: () => _launch(context, AdhanLinks.adhanVideoPlaylist),
          ),
          _tile(
            context,
            icon: Icons.telegram,
            label: context.translate.bilalAcademyTelegram,
            onTap: () => _launch(context, AdhanLinks.bilalAcademyTelegram),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space8),
      child: Material(
        color: DesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.space12,
              vertical: DesignSystem.space8,
            ),
            child: Row(
              children: [
                Icon(icon, color: DesignSystem.primary, size: 22),
                const SizedBox(width: DesignSystem.space12),
                Expanded(
                  child: Text(
                    label,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: DesignSystem.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: DesignSystem.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
