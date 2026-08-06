import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/routes/app_routes.dart';
import 'package:the_open_quran/screens/search_result_screen.dart';

import '../constants/prayer_times_storage.dart';
import '../database/local_db.dart';
import '../database/prayer_times_db.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_times_source.dart';
import '../providers/favorites_provider.dart';
import '../providers/home_provider.dart';
import '../providers/search_provider.dart';
import 'favorites_screen.dart';
import 'memorization_screen.dart';
import 'permissions_screen.dart';
import 'prayer_times_screen.dart';
import '../widgets/animation/fade_indexed_stack.dart';
import '../widgets/buttons/juz_surah_search_toggle_button.dart';
import '../widgets/cards/recent_card.dart';
import '../widgets/lists/juz_list.dart';
import '../widgets/lists/surah_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Utils.unFocus,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHomeHeader(context),
              _buildPermissionsAndMemorizationRow(context),
              Padding(
                padding: const EdgeInsets.all(DesignSystem.screenPadding),
                child: Column(
                  children: [
                    const _HomePrayerTimesCard(),
                    const SizedBox(height: kSizeL),
                    JuzSurahSearchToggleButton(
                      toggleSearchButtonIndex: context.read<SearchProvider>().toggleSearchOptions.index,
                      onChanged: context.watch<HomeProvider>().changeJuzOrSurahToggleOptionType,
                      onTapSearchButton: context.read<SearchProvider>().changeToggleSearchOptions,
                      toggleListType: context.watch<HomeProvider>().juzSurahToggleOptionType,
                    ),
                    FadeIndexedStack(
                      index: context.watch<SearchProvider>().toggleSearchOptions.index,
                      children: [
                        buildToggleSearchPages(context),
                        const SearchResultScreen(isHome: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader(BuildContext context) {
    final hasFavorites = context.watch<FavoritesProvider>().favoriteVerses.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.screenPadding,
        vertical: DesignSystem.space24,
      ),
      color: DesignSystem.surface,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.translate.theOpenQuran,
                style: context.theme.textTheme.displayMedium?.copyWith(
                  color: DesignSystem.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                hasFavorites
                    ? ImageConstants.favoriteActiveIcon
                    : ImageConstants.favoriteInactiveIcon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  hasFavorites ? DesignSystem.secondary : DesignSystem.onSurface.withValues(alpha: 0.6),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  AppRoutes.fadeSlideRoute<void>(
                    builder: (_) => const FavoritesScreen(showBackButton: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsAndMemorizationRow(BuildContext context) {
    final padding = const EdgeInsets.fromLTRB(
      DesignSystem.screenPadding,
      DesignSystem.space12,
      DesignSystem.screenPadding,
      0,
    );
    return Padding(
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildNavCard(
              context: context,
              icon: Icons.notifications_outlined,
              label: context.translate.permissions,
              onTap: () {
                Navigator.of(context).push(
                  AppRoutes.fadeSlideRoute<void>(builder: (_) => const PermissionsScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: DesignSystem.space12),
          Expanded(
            child: _buildNavCard(
              context: context,
              icon: Icons.calendar_month,
              label: context.translate.memorizationProgram,
              onTap: () {
                Navigator.of(context).push(
                  AppRoutes.fadeSlideRoute<void>(builder: (_) => const MemorizationScreen()),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: DesignSystem.surface,
      borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space16,
            vertical: DesignSystem.space12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
            border: Border.all(color: DesignSystem.outline, width: 1),
            boxShadow: DesignSystem.shadowSoft,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: DesignSystem.primary),
              const SizedBox(width: DesignSystem.space12),
              Expanded(
                child: Text(
                  label,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: DesignSystem.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: DesignSystem.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Juz/Translation and Search pages
  FadeIndexedStack buildToggleSearchPages(BuildContext context) {
    return FadeIndexedStack(
      index: context.watch<HomeProvider>().juzSurahToggleOptionType.index,
      children: [
        buildRecentAndJuzCategoryList(),
        SurahList(onTap: (surahId) {
          context.read<SearchProvider>().goToSurah(context, surahId, true);
        }),
      ],
    );
  }

  /// Recent visited Surah, Juz or Page
  Widget buildRecentAndJuzCategoryList() {
    return Column(
      children: [
        buildRecent(),
        JuzList(
          changeListType: context.read<HomeProvider>().changeJuzListType,
          juzListType: context.watch<HomeProvider>().juzListType,
          onTapJuzCard: (juzId) {
            context.read<SearchProvider>().goToJuz(context, juzId, true);
          },
          onTapSurahCard: (surahId) {
            context.read<SearchProvider>().goToSurah(context, surahId, true);
          },
        )
      ],
    );
  }

  /// Build recent visited paged
  Widget buildRecent() {
    var reversedList = LocalDb.getRecents.reversed.take(8).toList();
    return Visibility(
      visible: LocalDb.getRecents.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.only(bottom: kSizeL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSizeL),
              child: Text(
                context.translate.recent,
                style: context.theme.textTheme.displayLarge?.copyWith(letterSpacing: 0.04),
              ),
            ),
            const SizedBox(height: kSizeL),
            SizedBox(
              height: 90,
              child: GridView.builder(
                itemCount: reversedList.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: kSizeM),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: kSizeS,
                ),
                itemBuilder: (context, index) {
                  return RecentCard(
                    text: reversedList[index].name(context),
                    onTap: () {
                      reversedList[index].navigationToSurahDetails(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Format [Duration] for countdown: includes seconds when under one day.
String _formatCountdown(Duration d) {
  if (d.inDays > 0) {
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    if (hours > 0) return '${d.inDays}d ${hours}h ${mins}m';
    return '${d.inDays}d ${mins}m';
  }
  if (d.inHours > 0) {
    final mins = d.inMinutes % 60;
    final secs = d.inSeconds % 60;
    return '${d.inHours}h ${mins}m ${secs}s';
  }
  if (d.inMinutes > 0) {
    final secs = d.inSeconds % 60;
    return '${d.inMinutes}m ${secs}s';
  }
  if (d.inSeconds > 0) return '${d.inSeconds}s';
  return '0s';
}

String _formatWallClock(DateTime t) {
  return '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';
}

class _HomePrayerTimesCard extends StatefulWidget {
  const _HomePrayerTimesCard();

  @override
  State<_HomePrayerTimesCard> createState() => _HomePrayerTimesCardState();
}

class _HomePrayerTimesCardState extends State<_HomePrayerTimesCard> {
  List<PrayerTimeModel>? _times;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = GetStorage(PrayerTimesStorage.boxName).read(PrayerTimesStorage.keyCity) ??
        PrayerTimesSourceRegistry.instance.defaultCity;
    final includeIraq = PrayerTimesStorage.readIncludeIraq();
    final countryIso = PrayerTimesStorage.readCountryIso();
    return FutureBuilder<List<PrayerTimeModel>>(
      future: PrayerTimesSourceRegistry.instance.getTodayPrayerTimes(
        city,
        includeIraq: includeIraq,
        countryIso: countryIso,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final times = snapshot.data!;
        _times ??= times;
        if (_times != times) _times = times;
        final info = PrayerTimesDb.getNextPrayerWithDuration(times, _now);
        if (info.next.name.isEmpty) return const SizedBox.shrink();
        final countdownText = info.isTomorrow
            ? '${context.translate.nextPrayerTomorrowAt(info.next.timeString)} (${context.translate.nextPrayerIn(_formatCountdown(info.until))})'
            : context.translate.nextPrayerIn(_formatCountdown(info.until));
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                AppRoutes.fadeSlideRoute(builder: (_) => const PrayerTimesScreen(selected: true)),
              );
            },
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                DesignSystem.space20,
                DesignSystem.space16,
                DesignSystem.space20,
                DesignSystem.space12,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
                boxShadow: DesignSystem.shadowSoft,
              ),
              child: Row(
                children: [
                  Icon(
                    info.next.name == 'Fajr' || info.next.name == 'Dhuhr' || info.next.name == 'Asr'
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round_outlined,
                    color: DesignSystem.primary,
                    size: 28,
                  ),
                  const SizedBox(width: DesignSystem.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.translate.nextPrayer,
                          style: context.theme.textTheme.titleSmall?.copyWith(
                            color: DesignSystem.onSurface.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          info.next.name.translatedPrayerName(context),
                          style: context.theme.textTheme.headlineSmall?.copyWith(
                            color: DesignSystem.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _formatWallClock(_now),
                          style: context.theme.textTheme.labelLarge?.copyWith(
                            color: DesignSystem.onSurface.withValues(alpha: 0.8),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          countdownText,
                          style: context.theme.textTheme.bodyMedium?.copyWith(
                            color: DesignSystem.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: DesignSystem.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
