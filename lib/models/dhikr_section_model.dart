import 'dhikr_model.dart';

/// A section of dhikrs (e.g. Morning, Evening, Bedtime) with a title and icon.
class DhikrSectionModel {
  DhikrSectionModel({
    required this.sectionId,
    required this.title,
    this.subtitle,
    required this.iconIndex,
    required this.dhikrs,
  });

  final String sectionId;
  final String title;
  final String? subtitle;
  final int iconIndex;
  final List<DhikrModel> dhikrs;
}
