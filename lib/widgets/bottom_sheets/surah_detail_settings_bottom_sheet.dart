import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/routes/app_routes.dart';

import '../../models/recitation_manifest_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/surah_details_provider.dart';
import '../../screens/quran_translation_screen.dart';
import '../../services/quran_recitation_service.dart';
import '../../services/recitation_prefs.dart';
import '../background_color_select.dart';
import '../buttons/layout_options_toggle_buttons.dart';
import '../buttons/quran_font_button.dart';
import '../buttons/read_options_toggle_buttons.dart';
import '../buttons/translation_box.dart';
import '../line_spacing_slider.dart';
import '../surah_size_slider.dart';

class SurahDetailSettingsBottomSheet extends StatelessWidget {
  const SurahDetailSettingsBottomSheet({super.key});

  static Future<dynamic> show(BuildContext context) {
    return showMaterialModalBottomSheet(
        context: context,
        builder: (_) => const SurahDetailSettingsBottomSheet(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kSizeXXL),
          ),
        ),
        backgroundColor: Colors.transparent);
  }

  /// Theme aligned with app design system (light, teal primary).
  static ThemeData _sheetTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: DesignSystem.surface,
        onSurface: DesignSystem.onSurface,
        primary: DesignSystem.primary,
        onPrimary: DesignSystem.onPrimary,
        outline: DesignSystem.outline,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: DesignSystem.onSurface,
        displayColor: DesignSystem.onSurface,
      ).copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: DesignSystem.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: DesignSystem.onSurface,
          fontSize: 15,
        ),
        labelMedium: base.textTheme.labelMedium?.copyWith(
          color: DesignSystem.onSurface,
          fontSize: 14,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          color: DesignSystem.onSurface.withValues(alpha: 0.9),
        ),
      ),
      cardTheme: CardThemeData(
        color: DesignSystem.cardBackground,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: DesignSystem.primary,
        inactiveTrackColor: DesignSystem.outlineVariant,
        thumbColor: DesignSystem.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Theme(
      data: _sheetTheme(context),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            gradient: DesignSystem.gradientLuxuryBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(kSizeXXL),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: kSizeL),
                child: Container(
                  height: kSizeS * 1.5,
                  width: kSize3XL * 5,
                  decoration: BoxDecoration(
                    color: DesignSystem.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(kSizeXXL),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    kSize3XL,
                    kSizeXL,
                    kSize3XL,
                    kSizeXL + bottomInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReadOptionsToggleButton(
                        isPopUp: false,
                        listType: context.watch<QuranProvider>().localSetting.readOptions,
                        onValueChanged: context.read<QuranProvider>().changeReadingType,
                      ),
                      SurahSizeSlider(
                        isPopUp: false,
                        size: context.watch<QuranProvider>().localSetting.textScaleFactor,
                        onChanged: context.read<QuranProvider>().changeFontSize,
                      ),
                      LineSpacingSlider(
                        isPopUp: false,
                        lineHeight: context.watch<QuranProvider>().localSetting.lineHeight,
                        onChanged: context.read<QuranProvider>().changeLineHeight,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QuranFontButton(
                            selectedFont: context.watch<QuranProvider>().localSetting.fontTypeArabic,
                            onChangeArabicFont: context.watch<QuranProvider>().changeFontTypeArabic,
                          ),
                          LayoutOptionsToggleButton(
                            isPopUp: false,
                            layoutOptions: context.watch<QuranProvider>().localSetting.layoutOptions,
                            onChanged: context.read<QuranProvider>().changeLayoutOptions,
                          ),
                        ],
                      ),
                      TranslationBox(
                        onTap: () {
                          Navigator.push(context, AppRoutes.fadeSlideRoute(
                            builder: (context) => const QuranTranslationsScreen(),
                          ));
                        },
                      ),
                      BackgroundColorSelect(
                        colors: const [AppColors.white2, AppColors.oasis, AppColors.white3, AppColors.grey7, AppColors.pink],
                        defaultIndex: context.watch<QuranProvider>().localSetting.surahDetailsPageThemeIndex,
                        onChangedColor: context.read<QuranProvider>().changeSurahDetailsPageTheme,
                      ),
                      const SizedBox(height: kSizeXL),
                      const _RecitationSettingsBlock(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecitationSettingsBlock extends StatefulWidget {
  const _RecitationSettingsBlock();

  @override
  State<_RecitationSettingsBlock> createState() => _RecitationSettingsBlockState();
}

class _RecitationSettingsBlockState extends State<_RecitationSettingsBlock> {
  String? _reciterId;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return FutureBuilder<RecitationManifest>(
      future: QuranRecitationService.loadManifest(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox.shrink();
        }
        final m = snap.data!;
        final effective = (_reciterId ??
                (RecitationPrefs.selectedReciterId.isEmpty
                    ? m.defaultReciterId
                    : RecitationPrefs.selectedReciterId))
            .trim();
        final selected =
            m.byId(effective) != null ? effective : m.defaultReciterId;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate.recitationSettingsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: kSizeM),
            Text(
              context.translate.recitationReciterLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            DropdownButton<String>(
              value: selected,
              isExpanded: true,
              items: m.reciters
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.labelForLocale(lang)),
                    ),
                  )
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                await RecitationPrefs.setSelectedReciterId(v);
                setState(() => _reciterId = v);
              },
            ),
            const SizedBox(height: kSizeM),
            ValueListenableBuilder<double?>(
              valueListenable: QuranRecitationService.downloadProgress,
              builder: (context, prog, _) {
                if (prog != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: kSizeM),
                    child: Text(
                      context.translate.recitationDownloading((prog * 100).round()),
                    ),
                  );
                }
                return OutlinedButton(
                  onPressed: () async {
                    final rec = m.byId(selected);
                    if (rec == null) return;
                    final verses =
                        context.read<SurahDetailsProvider>().displayedVerses;
                    await QuranRecitationService.downloadSurahAyahs(
                      reciter: rec,
                      verses: verses,
                    );
                  },
                  child: Text(context.translate.recitationDownloadSurah),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
