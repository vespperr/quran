import 'package:flutter/material.dart';

import '../database/local_db.dart';
import '../models/calendar-popup.dart';
import '../models/memorization_plan_model.dart';
import '../models/verse_model.dart';

/// Shows the calendar popup to pick a date range for memorizing [verse].
/// On apply, saves the plan and pops.
void showMemorizationCalendar(BuildContext context, VerseModel verse) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  Navigator.of(context).push<void>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => CalendarPopupView(
        minimumDate: today,
        initialStartDate: today,
        initialEndDate: today,
        barrierDismissible: true,
        onApplyClick: (start, end) {
          final plan = MemorizationPlanModel(
            verse: verse,
            startDate: start,
            endDate: end,
          );
          LocalDb.addMemorizationPlan(plan);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${verse.verseKey} added to memorization plan (${plan.daysCount} days)',
              ),
              behavior: SnackBarBehavior.fixed,
            ),
          );
        },
      ),
    ),
  );
}
