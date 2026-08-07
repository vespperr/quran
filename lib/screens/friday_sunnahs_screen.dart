import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/managers/surah_detail_navigation_manager.dart';
import 'package:the_open_quran/services/friday_notification_service.dart';
import 'package:the_open_quran/services/friday_sunnah_service.dart';
import 'package:the_open_quran/widgets/app_bars/secondary_app_bar.dart';

class FridaySunnahsScreen extends StatefulWidget {
  const FridaySunnahsScreen({super.key});

  @override
  State<FridaySunnahsScreen> createState() => _FridaySunnahsScreenState();
}

class _FridaySunnahsScreenState extends State<FridaySunnahsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: SecondaryAppBar(
          title: context.translate.fridaySunnahs,
          subTitle: context.translate.fridaySunnahsDesc,
          onTapBookmark: (_) {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroHeader(context),
            const SizedBox(height: DesignSystem.space16),
            _buildSurahKahfCard(context),
            const SizedBox(height: DesignSystem.space16),
            _buildSalawatCounterCard(context),
            const SizedBox(height: DesignSystem.space20),
            Text(
              context.translate.fridaySunnahs,
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignSystem.primary,
              ),
            ),
            const SizedBox(height: DesignSystem.space12),
            _buildSunnahChecklist(context),
            const SizedBox(height: DesignSystem.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final isFriday = FridaySunnahService.isTodayFriday;

    return Container(
      padding: const EdgeInsets.all(DesignSystem.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignSystem.primary,
            DesignSystem.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSystem.space12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Colors.amberAccent,
              size: 32,
            ),
          ),
          const SizedBox(width: DesignSystem.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate.fridaySunnahs,
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFriday
                      ? '✨ ${context.translate.fridaySunnahsDesc}'
                      : context.translate.fridaySunnahsDesc,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahKahfCard(BuildContext context) {
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: FridaySunnahService.checklistNotifier,
      builder: (context, checklist, _) {
        final isChecked = checklist['read_kahf'] ?? false;

        return Card(
          elevation: 0,
          color: DesignSystem.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
            side: BorderSide(
              color: isChecked ? DesignSystem.primary : DesignSystem.outline,
              width: isChecked ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DesignSystem.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: DesignSystem.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: DesignSystem.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate.readSurahKahf,
                            style: context.theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            context.translate.readSurahKahfDesc,
                            style: context.theme.textTheme.bodySmall?.copyWith(
                              color: DesignSystem.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isChecked,
                      activeColor: DesignSystem.primary,
                      onChanged: (_) {
                        HapticFeedback.selectionClick();
                        FridaySunnahService.toggleCheck('read_kahf');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.space12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      SurahDetailNavigationManager.goToSurah(context, 18);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                      ),
                    ),
                    icon: const Icon(Icons.auto_stories_rounded, size: 20),
                    label: Text(
                      context.translate.readSurahKahf,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalawatCounterCard(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: FridaySunnahService.salawatCountNotifier,
      builder: (context, count, _) {
        return Card(
          elevation: 0,
          color: DesignSystem.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
            side: const BorderSide(color: DesignSystem.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate.salawatCounter,
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          context.translate.salawatCounterDesc,
                          style: context.theme.textTheme.bodySmall?.copyWith(
                            color: DesignSystem.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                      tooltip: context.translate.resetCounter,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        FridaySunnahService.resetSalawat();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.space16),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    FridaySunnahService.incrementSalawat();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DesignSystem.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: DesignSystem.primary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DesignSystem.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$count',
                          style: context.theme.textTheme.headlineLarge?.copyWith(
                            color: DesignSystem.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          context.translate.tapToCount,
                          style: context.theme.textTheme.labelSmall?.copyWith(
                            color: DesignSystem.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSunnahChecklist(BuildContext context) {
    final sunnahItems = [
      {
        'key': 'ghusl',
        'title': context.translate.sunnahGhusl,
        'desc': context.translate.sunnahGhuslDesc,
        'icon': Icons.water_drop_rounded,
      },
      {
        'key': 'siwak',
        'title': context.translate.sunnahSiwak,
        'desc': context.translate.sunnahSiwakDesc,
        'icon': Icons.cleaning_services_rounded,
      },
      {
        'key': 'clean_clothes',
        'title': context.translate.sunnahCleanClothes,
        'desc': context.translate.sunnahCleanClothesDesc,
        'icon': Icons.checkroom_rounded,
      },
      {
        'key': 'early_mosque',
        'title': context.translate.sunnahEarlyMosque,
        'desc': context.translate.sunnahEarlyMosqueDesc,
        'icon': Icons.mosque_rounded,
      },
      {
        'key': 'dua_hour',
        'title': context.translate.sunnahDuaHour,
        'desc': context.translate.sunnahDuaHourDesc,
        'icon': Icons.volunteer_activism_rounded,
      },
    ];

    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: FridaySunnahService.checklistNotifier,
      builder: (context, checklist, _) {
        return Column(
          children: sunnahItems.map((item) {
            final key = item['key'] as String;
            final isChecked = checklist[key] ?? false;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: DesignSystem.space12),
              color: isChecked
                  ? DesignSystem.primary.withValues(alpha: 0.05)
                  : DesignSystem.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isChecked ? DesignSystem.primary : DesignSystem.outline,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? DesignSystem.primary
                        : DesignSystem.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: isChecked ? Colors.white : DesignSystem.primary,
                    size: 22,
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  item['desc'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Checkbox(
                  value: isChecked,
                  activeColor: DesignSystem.primary,
                  onChanged: (_) {
                    HapticFeedback.selectionClick();
                    FridaySunnahService.toggleCheck(key);
                  },
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  FridaySunnahService.toggleCheck(key);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
