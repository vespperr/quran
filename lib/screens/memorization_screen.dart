import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/constants.dart';
import '../constants/non_quran_style.dart';
import '../database/local_db.dart';
import '../managers/surah_detail_navigation_manager.dart';
import '../models/memorization_plan_model.dart';
import '../widgets/app_bars/primary_app_bar.dart';

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  List<MemorizationPlanModel> _plans = [];
  DateTime _focusedDay = DateTime.now();

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isDayInAnyPlan(DateTime day) {
    final n = _normalize(day);
    for (final plan in _plans) {
      final start = _normalize(plan.startDate);
      final end = _normalize(plan.endDate);
      if ((n.isAtSameMomentAs(start) || n.isAfter(start)) &&
          (n.isAtSameMomentAs(end) || n.isBefore(end))) {
        return true;
      }
    }
    return false;
  }

  void _loadPlans() {
    setState(() => _plans = LocalDb.getMemorizationPlans);
  }

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(
        title: context.translate.memorizationProgram,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignSystem.gradientLuxuryBackground,
        ),
        child: RefreshIndicator(
          onRefresh: () async => _loadPlans(),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: NonQuranStyle.screenPaddingH,
              vertical: NonQuranStyle.screenPaddingV,
            ),
            children: [
            Container(
              decoration: NonQuranStyle.sectionCardDecoration(),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                onDaySelected: (_, __) {},
                onPageChanged: (day) => setState(() => _focusedDay = day),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final isInPlan = _isDayInAnyPlan(day);
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isInPlan
                            ? DesignSystem.primary.withValues(alpha: 0.2)
                            : null,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          color: isInPlan
                              ? DesignSystem.primary
                              : DesignSystem.textForest,
                          fontWeight:
                              isInPlan ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.translate.ayat,
              style: context.theme.textTheme.headlineMedium?.copyWith(
                color: NonQuranStyle.sectionTitleColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (_plans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No memorization plans yet.\nLong-press a verse → Memorize → pick dates.',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: NonQuranStyle.sectionSubtitleColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              )
            else
              ..._plans.map((plan) => _PlanTile(
                    plan: plan,
                    onTap: () {
                      final surahId = plan.verse.surahId;
                      final verseId = plan.verse.verseNumber;
                      if (surahId != null && verseId != null) {
                        SurahDetailNavigationManager.goToSurah(
                          context,
                          surahId,
                          verseId: verseId,
                        );
                      }
                    },
                    onMarkMemorized: () async {
                      await LocalDb.setPlanMemorized(plan, !plan.isMemorized);
                      _loadPlans();
                    },
                    onRemove: () async {
                      await LocalDb.removeMemorizationPlan(plan);
                      _loadPlans();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.onTap,
    required this.onMarkMemorized,
    required this.onRemove,
  });

  final MemorizationPlanModel plan;
  final VoidCallback onTap;
  final VoidCallback onMarkMemorized;
  final VoidCallback onRemove;

  static const int _maxAyahPreviewLength = 120;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    final ayahText = plan.verse.text ?? '';
    final preview = ayahText.length > _maxAyahPreviewLength
        ? '${ayahText.substring(0, _maxAyahPreviewLength)}…'
        : ayahText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: NonQuranStyle.listItemCardDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NonQuranStyle.cardRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.verse.verseKey ?? '—',
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            color: NonQuranStyle.sectionTitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          plan.isMemorized ? Icons.check_circle : Icons.check_circle_outline,
                          color: plan.isMemorized
                              ? DesignSystem.primary
                              : DesignSystem.textForest.withValues(alpha: 0.64),
                        ),
                        onPressed: onMarkMemorized,
                        tooltip: plan.isMemorized ? context.translate.memorized : context.translate.markAsMemorized,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onRemove,
                        color: DesignSystem.textForest.withValues(alpha: 0.64),
                        tooltip: context.translate.removePlan,
                      ),
                    ],
                  ),
                  if (preview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: NonQuranStyle.sectionSubtitleColor,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${fmt.format(plan.startDate)} – ${fmt.format(plan.endDate)} · ${plan.daysCount} days',
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: NonQuranStyle.sectionSubtitleColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
