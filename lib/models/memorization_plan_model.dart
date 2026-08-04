import 'verse_model.dart';

/// A plan to memorize a verse over a date range.
class MemorizationPlanModel {
  MemorizationPlanModel({
    required this.verse,
    required this.startDate,
    required this.endDate,
    this.isMemorized = false,
  });

  final VerseModel verse;
  final DateTime startDate;
  final DateTime endDate;
  final bool isMemorized;

  MemorizationPlanModel.fromJson(Map<String, dynamic> json)
      : verse = VerseModel.fromJson(
            Map<String, dynamic>.from((json['verse'] as Map?) ?? {})),
        startDate = DateTime.parse(json['startDate'] as String? ?? ''),
        endDate = DateTime.parse(json['endDate'] as String? ?? ''),
        isMemorized = json['isMemorized'] as bool? ?? false;

  Map<String, dynamic> toJson() => {
        'verse': verse.toJson(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isMemorized': isMemorized,
      };

  MemorizationPlanModel copyWith({bool? isMemorized}) =>
      MemorizationPlanModel(
        verse: verse,
        startDate: startDate,
        endDate: endDate,
        isMemorized: isMemorized ?? this.isMemorized,
      );

  /// Unique key for this plan (verse + range) for deduplication.
  String get key =>
      '${verse.verseKey}_${startDate.toIso8601String()}_${endDate.toIso8601String()}';

  int get daysCount => endDate.difference(startDate).inDays + 1;
}
