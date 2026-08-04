import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../animation/staggered_fade_slide.dart';
import '../cards/featured_surah_card.dart';
import '../cards/surah_item_card.dart';

class SurahList extends StatefulWidget {
  const SurahList({super.key, required this.onTap});

  final Function(int) onTap;

  @override
  State<SurahList> createState() => _SurahListState();
}

class _SurahListState extends State<SurahList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const _SurahListInfo(),
            const SizedBox(height: 16),
            _FeaturedSurahs(onTap: widget.onTap),
            const SizedBox(height: 16),
            _SurahItems(
              tabController: _tabController,
              onTap: widget.onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahListInfo extends StatelessWidget {
  const _SurahListInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate.surahs,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: DesignSystem.primary,
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Text(
            context.translate.surahListStats,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignSystem.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSurahs extends StatelessWidget {
  const _FeaturedSurahs({required this.onTap});

  final Function(int) onTap;

  static const int _featuredCount = 6;

  @override
  Widget build(BuildContext context) {
    final surahs = context.watch<QuranProvider>().surahs;
    final featured = surahs.take(_featuredCount).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.translate.featured,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DesignSystem.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final surah = featured[index];
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FeaturedSurahCard(
                  surahModel: surah,
                  onTap: () => onTap(surah.id!),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// TabBar (All / Meccan / Medinan) + list of SurahItemCard (single scroll with parent).
class _SurahItems extends StatelessWidget {
  const _SurahItems({
    required this.tabController,
    required this.onTap,
  });

  final TabController tabController;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final surahs = context.watch<QuranProvider>().surahs;
    final index = tabController.index;
    final filtered = index == 0
        ? surahs
        : index == 1
            ? surahs.where((s) => _isMeccan(s.revelationPlace)).toList()
            : surahs.where((s) => _isMedinan(s.revelationPlace)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.screenPadding),
          child: Container(
            decoration: BoxDecoration(
              color: DesignSystem.surface,
              borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
              border: Border.all(color: DesignSystem.outline, width: 1),
              boxShadow: DesignSystem.shadowSoft,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _buildSegmentControl(context, tabController),
              ),
            ),
          ),
        ),
        _SurahListBody(surahs: filtered, onTap: onTap),
      ],
    );
  }

  static bool _isMeccan(String? place) {
    if (place == null) return false;
    final p = place.toLowerCase();
    return p == 'makkah' || p == 'mecca';
  }

  static bool _isMedinan(String? place) {
    if (place == null) return false;
    final p = place.toLowerCase();
    return p == 'madinah' || p == 'medina';
  }

  Widget _buildSegmentControl(BuildContext context, TabController controller) {
    final labels = [
      context.translate.all,
      context.translate.meccan,
      context.translate.medinan,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final segmentWidth = width / labels.length;
        final animation = controller.animation ??
            AlwaysStoppedAnimation(controller.index.toDouble());

        return Stack(
          children: [
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 249, 250, 249)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final value = animation.value.clamp(0.0, 2.0);
                final left = (value / 2) * (width - segmentWidth);
                return Positioned(
                  left: left,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              },
            ),
            Row(
              children: List.generate(labels.length, (index) {
                final selected = controller.index == index;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.animateTo(index),
                      child: Container(
                        height: 38,
                        alignment: Alignment.center,
                        child: Text(
                          labels[index],
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: selected
                                        ? DesignSystem.primary
                                        : DesignSystem.onSurface
                                            .withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _SurahListBody extends StatelessWidget {
  const _SurahListBody({
    required this.surahs,
    required this.onTap,
  });

  final List<SurahModel> surahs;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return StaggeredFadeSlide(
          index: index,
          child: SurahItemCard(
            surahModel: surah,
            onTap: () => onTap(surah.id!),
          ),
        );
      },
    );
  }
}
