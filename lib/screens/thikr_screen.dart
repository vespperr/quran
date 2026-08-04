
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../constants/adhkar_repeat_targets.dart';
import '../constants/non_quran_style.dart';
import '../database/dhikr_db.dart';
import '../models/dhikr_model.dart';
import '../models/dhikr_section_model.dart';
import '../services/adhkar_counter_storage.dart';
import '../services/copy_and_share_service.dart';
import '../services/thikr_audio_service.dart';
import '../widgets/app_bars/primary_app_bar.dart';

/// Screen for Athkars / Thikr (remembrance) from KurdistanPrayerTimes.db.
class ThikrScreen extends StatefulWidget {
  const ThikrScreen({super.key, this.selected = false, this.inSheet = false});

  final bool selected;
  /// When true, shown inside the bottom sheet; draws green handle and swipe-up opens full screen.
  final bool inSheet;

  @override
  State<ThikrScreen> createState() => _ThikrScreenState();
}

class _ThikrScreenState extends State<ThikrScreen> {
  List<DhikrSectionModel> _sections = [];
  final Set<String> _expandedSectionIds = {};
  bool _loading = false;
  String? _error;
  bool _hasStartedLoad = false;

  void _toggleSection(String sectionId) {
    setState(() {
      if (_expandedSectionIds.contains(sectionId)) {
        _expandedSectionIds.remove(sectionId);
      } else {
        _expandedSectionIds.add(sectionId);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.selected) _loadSections();
  }

  @override
  void didUpdateWidget(covariant ThikrScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !_hasStartedLoad) _loadSections();
  }

  Future<void> _loadSections() async {
    if (_hasStartedLoad && _error == null && !_loading) return;
    _hasStartedLoad = true;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await DhikrDb.getDhikrSections();
      if (mounted) {
        setState(() {
          _sections = list;
          _loading = false;
          // Keep all sections collapsed by default (do not expand first)
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Athkars',
        actions: [
          if (_sections.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () => _openFullScreen(context),
              tooltip: 'Expand to full screen',
            ),
        ],
      ),
      body: widget.inSheet
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AthkarsSheetHandle(
                  onSwipeUp: _goFullScreenFromSheet,
                  onTap: _goFullScreenFromSheet,
                ),
                Expanded(child: _buildBody()),
              ],
            )
          : _buildBody(),
    );
  }

  void _goFullScreenFromSheet() {
    if (_sections.isEmpty) return;
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(
      MaterialPageRoute<void>(
        builder: (context) => _ThikrFullScreen(sections: _sections),
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ThikrFullScreen(sections: _sections),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kSizeXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load dhikrs',
                style: context.theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSizeM),
              Text(
                _error!,
                style: context.theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSizeL),
              TextButton(
                onPressed: _loadSections,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_sections.isEmpty) {
      return Center(
        child: Text(
          'No dhikrs found.',
          style: context.theme.textTheme.bodyLarge,
        ),
      );
    }
    final firstExpandedIndex = _sections.indexWhere((s) => _expandedSectionIds.contains(s.sectionId));
    final nextSection = firstExpandedIndex >= 0 && firstExpandedIndex < _sections.length - 1
        ? _sections[firstExpandedIndex + 1]
        : null;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              NonQuranStyle.screenPaddingH,
              NonQuranStyle.screenPaddingV,
              NonQuranStyle.screenPaddingH,
              kSizeM,
            ),
            itemCount: _sections.length,
            itemBuilder: (context, sectionIndex) {
              final section = _sections[sectionIndex];
              final isExpanded = _expandedSectionIds.contains(section.sectionId);
              final totalInSection = section.dhikrs.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: kSizeL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHeader(
                      section: section,
                      isExpanded: isExpanded,
                      totalCount: totalInSection,
                      onTap: () => _toggleSection(section.sectionId),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: kSizeM),
                      if (thikrSectionAudioAssets.containsKey(section.sectionId))
                        Padding(
                          padding: const EdgeInsets.only(bottom: kSizeM),
                          child: _SectionAudioBar(
                            sectionId: section.sectionId,
                            dhikrIds: section.dhikrs.map((d) => d.id).toList(),
                            onResetDefaults: () => setState(() {}),
                          ),
                        ),
                      ...section.dhikrs.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: kSizeS),
                            child: _DhikrItemCard(
                              sectionId: section.sectionId,
                              dhikr: e.value,
                              index: e.key + 1,
                              total: totalInSection,
                            ),
                          )),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        if (!widget.inSheet)
          _SwipeUpBar(
            nextSectionTitle: nextSection?.title,
            onSwipeUp: () => _openFullScreen(context),
          ),
      ],
    );
  }
}

/// Green handle at top of Athkars sheet; swipe up or tap opens full screen.
class _AthkarsSheetHandle extends StatefulWidget {
  const _AthkarsSheetHandle({required this.onSwipeUp, required this.onTap});

  final VoidCallback onSwipeUp;
  final VoidCallback onTap;

  @override
  State<_AthkarsSheetHandle> createState() => _AthkarsSheetHandleState();
}

class _AthkarsSheetHandleState extends State<_AthkarsSheetHandle> {
  double _dragTotal = 0;
  static const double _swipeThreshold = 40;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) => setState(() => _dragTotal += details.delta.dy),
      onVerticalDragEnd: (_) {
        if (_dragTotal < -_swipeThreshold) widget.onSwipeUp();
        setState(() => _dragTotal = 0);
      },
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Swipe up for full screen',
              style: context.theme.textTheme.labelSmall?.copyWith(
                color: NonQuranStyle.sectionSubtitleColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen Athkars view: one section per page; swipe between sections.
class _ThikrFullScreen extends StatefulWidget {
  const _ThikrFullScreen({required this.sections});

  final List<DhikrSectionModel> sections;

  @override
  State<_ThikrFullScreen> createState() => _ThikrFullScreenState();
}

class _ThikrFullScreenState extends State<_ThikrFullScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.sections;
    if (sections.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Athkars'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ),
        body: const Center(child: Text('No sections.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Athkars',
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${_currentPage + 1} / ${sections.length}',
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            Text(
              sections[_currentPage].title,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).appBarTheme.foregroundColor?.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sections.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentPage ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentPage
                            ? NonQuranStyle.sectionAccentColor
                            : NonQuranStyle.sectionAccentColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: sections.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NonQuranStyle.screenPaddingH,
              NonQuranStyle.screenPaddingV,
              NonQuranStyle.screenPaddingH,
              kSizeXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeaderStatic(section: section, totalCount: section.dhikrs.length),
                const SizedBox(height: kSizeM),
                if (thikrSectionAudioAssets.containsKey(section.sectionId))
                  Padding(
                    padding: const EdgeInsets.only(bottom: kSizeM),
                    child: _SectionAudioBar(
                      sectionId: section.sectionId,
                      dhikrIds: section.dhikrs.map((d) => d.id).toList(),
                      onResetDefaults: () => setState(() {}),
                    ),
                  ),
                ...section.dhikrs.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: kSizeS),
                      child: _DhikrItemCard(
                        sectionId: section.sectionId,
                        dhikr: e.value,
                        index: e.key + 1,
                        total: section.dhikrs.length,
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Bottom bar: "Swipe up for full screen" + optional "Next: [section]". Swipe-up opens full screen.
class _SwipeUpBar extends StatefulWidget {
  const _SwipeUpBar({
    this.nextSectionTitle,
    required this.onSwipeUp,
  });

  final String? nextSectionTitle;
  final VoidCallback onSwipeUp;

  @override
  State<_SwipeUpBar> createState() => _SwipeUpBarState();
}

class _SwipeUpBarState extends State<_SwipeUpBar> {
  double _dragTotal = 0;

  static const double _swipeThreshold = 50;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() => _dragTotal += details.delta.dy);
      },
      onVerticalDragEnd: (details) {
        if (_dragTotal < -_swipeThreshold) widget.onSwipeUp();
        setState(() => _dragTotal = 0);
      },
      onTap: () => widget.onSwipeUp(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: NonQuranStyle.screenPaddingH, vertical: kSizeM),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          border: Border(
            top: BorderSide(
              color: NonQuranStyle.sectionAccentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 28,
                color: NonQuranStyle.sectionAccentColor,
              ),
              const SizedBox(height: 4),
              Text(
                'Swipe up for full screen',
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: NonQuranStyle.sectionSubtitleColor,
                  fontSize: 12,
                ),
              ),
              if (widget.nextSectionTitle != null && widget.nextSectionTitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Next: ${widget.nextSectionTitle!}',
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: NonQuranStyle.sectionAccentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Audio player bar for a section (play/pause, stop, progress) + reset adhkar targets for the section.
class _SectionAudioBar extends StatefulWidget {
  const _SectionAudioBar({
    required this.sectionId,
    required this.dhikrIds,
    required this.onResetDefaults,
  });

  final String sectionId;
  final List<int> dhikrIds;
  final VoidCallback onResetDefaults;

  @override
  State<_SectionAudioBar> createState() => _SectionAudioBarState();
}

class _SectionAudioBarState extends State<_SectionAudioBar> {
  Future<void> _resetTargetsToDefault() async {
    await AdhkarTargetStorage.clearTargetsForSection(widget.sectionId, widget.dhikrIds);
    widget.onResetDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final sectionId = widget.sectionId;
    return ValueListenableBuilder<String?>(
      valueListenable: ThikrAudioService.currentSectionId,
      builder: (context, currentId, _) {
        final isThisSection = currentId == sectionId;
        return ValueListenableBuilder<PlayerState>(
          valueListenable: ThikrAudioService.state,
          builder: (context, playerState, _) {
            final isPlaying = isThisSection && playerState == PlayerState.playing;
            return ValueListenableBuilder<Duration>(
              valueListenable: ThikrAudioService.position,
              builder: (context, position, _) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: ThikrAudioService.duration,
                  builder: (context, duration, _) {
                    final pos = isThisSection ? position : Duration.zero;
                    final dur = isThisSection ? duration : Duration.zero;
                    final sec = dur.inSeconds > 0 ? dur.inSeconds : 1;
                    final progress = dur.inSeconds > 0 ? pos.inSeconds / sec : 0.0;
                    return Container(
                      decoration: BoxDecoration(
                        color: DesignSystem.surface,
                        borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusMedium),
                        boxShadow: DesignSystem.shadowSoft,
                        border: Border.all(
                          color: NonQuranStyle.sectionAccentColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: kSizeM, vertical: kSizeS),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                                      iconSize: 44,
                                      color: NonQuranStyle.sectionAccentColor,
                                      onPressed: () {
                                        if (isPlaying) {
                                          ThikrAudioService.pause();
                                        } else if (isThisSection) {
                                          ThikrAudioService.resume(sectionId);
                                        } else {
                                          ThikrAudioService.play(sectionId);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.stop_circle_outlined),
                                      iconSize: 36,
                                      color: DesignSystem.onSurface.withValues(alpha: 0.7),
                                      onPressed: () => ThikrAudioService.stop(),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: TextButton.icon(
                                  onPressed: _resetTargetsToDefault,
                                  icon: Icon(
                                    Icons.restore_outlined,
                                    size: 18,
                                    color: NonQuranStyle.sectionAccentColor,
                                  ),
                                  label: Text(
                                    context.translate.adhkarResetTarget,
                                    style: context.theme.textTheme.labelSmall?.copyWith(
                                      color: NonQuranStyle.sectionAccentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (dur.inSeconds > 0) ...[
                            const SizedBox(height: 4),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: NonQuranStyle.sectionAccentColor,
                                inactiveTrackColor: NonQuranStyle.sectionAccentColor.withValues(alpha: 0.2),
                                thumbColor: NonQuranStyle.sectionAccentColor,
                                overlayColor: NonQuranStyle.sectionAccentColor.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: isThisSection
                                    ? (v) => ThikrAudioService.seek(Duration(seconds: (v * sec).round()))
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Section title block for full-screen view (no expand/collapse).
class _SectionHeaderStatic extends StatelessWidget {
  const _SectionHeaderStatic({required this.section, this.totalCount = 0});

  final DhikrSectionModel section;
  final int totalCount;

  static const double _iconSize = 48;

  IconData get _icon {
    switch (section.iconIndex % 3) {
      case 0:
        return Icons.wb_sunny_outlined;
      case 1:
        return Icons.wb_twilight_outlined;
      case 2:
        return Icons.nightlight_round_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NonQuranStyle.sectionCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSizeL, vertical: kSizeL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    section.title,
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      color: NonQuranStyle.sectionTitleColor,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                  ),
                  if (section.subtitle != null && section.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle!,
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: NonQuranStyle.sectionSubtitleColor,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (totalCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$totalCount athkars',
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: NonQuranStyle.sectionSubtitleColor.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: kSizeS),
            Icon(_icon, size: _iconSize, color: NonQuranStyle.sectionAccentColor),
          ],
        ),
      ),
    );
  }
}

/// Section header: collapsible folder-style card with icon, title, and chevron.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.section,
    required this.isExpanded,
    required this.onTap,
    this.totalCount = 0,
  });

  final DhikrSectionModel section;
  final bool isExpanded;
  final VoidCallback onTap;
  final int totalCount;

  static const double _iconSize = 48;

  IconData get _icon {
    switch (section.iconIndex % 3) {
      case 0:
        return Icons.wb_sunny_outlined;
      case 1:
        return Icons.wb_twilight_outlined;
      case 2:
        return Icons.nightlight_round_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusLarge),
        child: Container(
          decoration: NonQuranStyle.sectionCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSizeL, vertical: kSizeL),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        section.title,
                        style: context.theme.textTheme.titleLarge?.copyWith(
                          color: NonQuranStyle.sectionTitleColor,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          fontSize: 18,
                        ),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                      ),
                      if (section.subtitle != null && section.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          section.subtitle!,
                          style: context.theme.textTheme.bodyMedium?.copyWith(
                            color: NonQuranStyle.sectionSubtitleColor,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (totalCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$totalCount athkars',
                          style: context.theme.textTheme.bodySmall?.copyWith(
                            color: NonQuranStyle.sectionSubtitleColor.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: kSizeS),
                Icon(_icon, size: _iconSize, color: NonQuranStyle.sectionAccentColor),
                const SizedBox(width: kSizeS),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: NonQuranStyle.expandableIconSize,
                    color: NonQuranStyle.sectionAccentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Single dhikr item: tap increments count until target; long-press to copy/share/reset.
class _DhikrItemCard extends StatefulWidget {
  const _DhikrItemCard({
    required this.sectionId,
    required this.dhikr,
    this.index,
    this.total,
  });

  final String sectionId;
  final DhikrModel dhikr;
  final int? index;
  final int? total;

  @override
  State<_DhikrItemCard> createState() => _DhikrItemCardState();
}

class _DhikrItemCardState extends State<_DhikrItemCard> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = AdhkarCounterStorage.readCount(widget.sectionId, widget.dhikr.id);
  }

  int get _target {
    final custom = AdhkarTargetStorage.readTarget(widget.sectionId, widget.dhikr.id);
    if (custom != null && custom > 0) return custom;
    return AdhkarRepeatTargets.targetFor(widget.dhikr);
  }

  bool get _done => _count >= _target;

  Future<void> _applyTarget(int t) async {
    final clamped = t < 1 ? 1 : t;
    await AdhkarTargetStorage.setTarget(widget.sectionId, widget.dhikr.id, clamped);
    if (_count > clamped) {
      await AdhkarCounterStorage.setCount(widget.sectionId, widget.dhikr.id, clamped);
      if (mounted) setState(() => _count = clamped);
    } else if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showRepetitionsSheet() async {
    const presets = [1, 3, 7, 10, 33, 100];
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(kSizeM, kSizeM, kSizeM, kSizeS),
                  child: Text(
                    context.translate.adhkarRepetitionsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                for (final n in presets)
                  ListTile(
                    title: Text('×$n'),
                    trailing: _target == n
                        ? Icon(Icons.check, color: DesignSystem.primary)
                        : null,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _applyTarget(n);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(context.translate.adhkarCustomRepetitions),
                  onTap: () {
                    Navigator.pop(ctx);
                    Future<void>.microtask(() async {
                      if (mounted) await _showCustomTargetDialog();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCustomTargetDialog() async {
    final ctrl = TextEditingController(text: '$_target');
    try {
      final result = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.translate.adhkarRepetitionsTitle),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: context.translate.adhkarEnterNumberHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.translate.cancel),
            ),
            TextButton(
              onPressed: () {
                final n = int.tryParse(ctrl.text.trim());
                if (n != null && n >= 1) Navigator.pop(ctx, n);
              },
              child: Text(context.translate.apply),
            ),
          ],
        ),
      );
      if (result != null) await _applyTarget(result);
    } finally {
      ctrl.dispose();
    }
  }

  String _textForCopyShare() {
    if (widget.dhikr.ardhikr != null && widget.dhikr.ardhikr!.trim().isNotEmpty) {
      return widget.dhikr.ardhikr!.trim();
    }
    return widget.dhikr.dhikrid ?? '';
  }

  Future<void> _increment() async {
    if (_done) return;
    final next = _count + 1;
    setState(() => _count = next);
    await AdhkarCounterStorage.setCount(widget.sectionId, widget.dhikr.id, next);
  }

  Future<void> _reset() async {
    await AdhkarCounterStorage.reset(widget.sectionId, widget.dhikr.id);
    if (mounted) setState(() => _count = 0);
  }

  Future<void> _showCopyShareMenu(BuildContext context) async {
    final text = _textForCopyShare();
    final hasText = text.isNotEmpty;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.sizeOf(context);
    final choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        (position.dy - 100).clamp(0.0, screen.height - 120),
        position.dx + size.width,
        position.dy + size.height,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'repetitions',
          child: Row(
            children: [
              Icon(Icons.repeat_rounded, size: 22, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 12),
              Text(context.translate.adhkarRepetitionsMenu),
            ],
          ),
        ),
        if (hasText)
          PopupMenuItem<String>(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy_outlined, size: 22, color: Theme.of(context).iconTheme.color),
                const SizedBox(width: 12),
                Text(context.translate.copy),
              ],
            ),
          ),
        if (hasText)
          PopupMenuItem<String>(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_outlined, size: 22, color: Theme.of(context).iconTheme.color),
                const SizedBox(width: 12),
                Text(context.translate.share),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'reset',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 22, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 12),
              Text(context.translate.adhkarResetCounter),
            ],
          ),
        ),
      ],
    );
    if (!mounted) return;
    switch (choice) {
      case 'repetitions':
        await _showRepetitionsSheet();
        break;
      case 'copy':
        await CopyAndShareService.copyRaw(context, text);
        break;
      case 'share':
        await Share.share(text);
        break;
      case 'reset':
        await _reset();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showIndex = widget.index != null && widget.total != null && widget.total! > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _increment,
        onLongPress: () => _showCopyShareMenu(context),
        borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusLarge),
        child: Container(
            decoration: BoxDecoration(
              color: NonQuranStyle.sectionCardBackground,
              borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusLarge),
              boxShadow: DesignSystem.shadowSoft,
              border: Border.all(
                color: NonQuranStyle.sectionAccentColor.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSizeM, vertical: kSizeS + 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_done) ...[
                    Row(
                      children: [
                        Expanded(
                          child: showIndex
                              ? Text(
                                  '${widget.index} of ${widget.total}',
                                  style: context.theme.textTheme.titleMedium?.copyWith(
                                    color: NonQuranStyle.sectionAccentColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    height: 1.2,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: NonQuranStyle.sectionAccentColor,
                          ),
                          tooltip: context.translate.adhkarRepetitionsMenu,
                          onPressed: _showRepetitionsSheet,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NonQuranStyle.sectionAccentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.translate.adhkarRepeatProgress(
                              _count.clamp(0, _target),
                              _target,
                            ),
                            style: context.theme.textTheme.titleLarge?.copyWith(
                              color: NonQuranStyle.sectionAccentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.translate.adhkarTapHint,
                      style: context.theme.textTheme.labelSmall?.copyWith(
                        color: NonQuranStyle.sectionSubtitleColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ] else if (showIndex) ...[
                    Row(
                      children: [
                        Text(
                          '${widget.index} of ${widget.total}',
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            color: NonQuranStyle.sectionAccentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (widget.dhikr.ardhikr != null && widget.dhikr.ardhikr!.isNotEmpty)
                    Text(
                      widget.dhikr.ardhikr!,
                      style: context.theme.textTheme.bodyLarge?.copyWith(
                        color: NonQuranStyle.sectionTitleColor,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        fontSize: 18,
                        fontFamily: Fonts.naskh,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}