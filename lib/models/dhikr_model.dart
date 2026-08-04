/// A single dhikr (athkar) from the dhikr table.
class DhikrModel {
  DhikrModel({
    required this.id,
    this.dhikrid,
    this.ardhikr,
    this.krdhikr,
  });

  final int id;
  final String? dhikrid;
  final String? ardhikr;
  final String? krdhikr;

  /// Arabic text (primary for display)
  String get arabic => ardhikr ?? '';

  /// Display text: prefer Arabic, then dhikrid.
  String get displayText => arabic.isNotEmpty ? arabic : (dhikrid ?? '');
}
