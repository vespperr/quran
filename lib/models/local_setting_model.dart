import '../constants/enums.dart';

class LocalSettingModel {
  EQuranType quranType;
  EReadOptions readOptions;
  ELayoutOptions layoutOptions;
  double textScaleFactor;
  double lineHeight;
  int surahDetailsPageThemeIndex;
  String fontType = "Nunito";
  String fontTypeArabic = "Uthmani";

  LocalSettingModel({
    this.quranType = EQuranType.translation,
    this.layoutOptions = ELayoutOptions.justify,
    this.readOptions = EReadOptions.surahAndTranslation,
    this.textScaleFactor = 1.5,
    this.lineHeight = 1.7,
    this.surahDetailsPageThemeIndex = 3,
    this.fontType = "Nunito",
    this.fontTypeArabic = "Uthmani",
  });

  @override
  String toString() {
    return 'LocalSettingModel{quranType: $quranType, readOptions: $readOptions, layoutOptions: $layoutOptions, textScaleFactor: $textScaleFactor, lineHeight: $lineHeight, fontType: $fontType, fontTypeArabic: $fontTypeArabic}';
  }

  factory LocalSettingModel.fromJson(dynamic json) {
    if (json == null || json is! Map) return LocalSettingModel();
    final map = Map<String, dynamic>.from(json);
    int safeIndex(int? value, int length, int fallback) {
      if (value == null) return fallback;
      if (value < 0 || value >= length) return fallback;
      return value;
    }
    return LocalSettingModel(
      quranType: EQuranType.values[safeIndex(map['quranType'] as int?, EQuranType.values.length, 0)],
      readOptions: EReadOptions.values[safeIndex(map['readOptions'] as int?, EReadOptions.values.length, 0)],
      layoutOptions: ELayoutOptions.values[safeIndex(map['layoutOptions'] as int?, ELayoutOptions.values.length, 0)],
      textScaleFactor: (map['textScaleFactor'] is num) ? (map['textScaleFactor'] as num).toDouble() : 1.5,
      lineHeight: (map['lineHeight'] is num) ? (map['lineHeight'] as num).toDouble().clamp(1.0, 2.5) : 1.7,
      surahDetailsPageThemeIndex: (map['mushafBackgroundColorIndex'] is int) ? (map['mushafBackgroundColorIndex'] as int).clamp(0, 7) : 3,
      fontType: map['fontType'] is String ? map['fontType'] as String : "Nunito",
      fontTypeArabic: map['fontTypeArabic'] is String ? map['fontTypeArabic'] as String : "Uthmani",
    );
  }

  Map<String, dynamic> toJson() => {
        'quranType': quranType.index,
        'readOptions': readOptions.index,
        'layoutOptions': layoutOptions.index,
        'textScaleFactor': textScaleFactor,
        'lineHeight': lineHeight,
        'mushafBackgroundColorIndex': surahDetailsPageThemeIndex,
        'fontType': fontType,
        'fontTypeArabic': fontTypeArabic,
      };
}
