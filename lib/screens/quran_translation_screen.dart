import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../models/translation.dart';
import '../providers/quran_provider.dart';
import '../widgets/app_bars/primary_app_bar.dart';
import '../widgets/cards/translations_setting_card.dart';

class QuranTranslationsScreen extends StatefulWidget {
  const QuranTranslationsScreen({super.key});

  @override
  State<QuranTranslationsScreen> createState() =>
      _QuranTranslationsScreenState();
}

class _QuranTranslationsScreenState extends State<QuranTranslationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(
        title: context.translate.selectedTranslation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: buildBody,
    );
  }

  Widget get buildBody {
    var translationCountries =
        context.watch<QuranProvider>().translationService.allTranslationCountry;
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTitle(context.translate.downloaded),
          buildDownloadList(translationCountries),
          buildTitle(context.translate.availableToDownload),
          buildDownloadedList(translationCountries),
          const SizedBox(height: kSizeXL),
        ],
      ),
    );
  }

  Widget buildTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: kSizeL, right: kSizeL, top: kSizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: theme.dividerColor),
        ],
      ),
    );
  }

  /// List of Qur'an translations to download
  Widget buildDownloadList(List<TranslationCountry> translationCountries) {
    return ListView.builder(
      itemCount: translationCountries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return buildList(translationCountries.elementAt(index), true);
      },
    );
  }

  /// List of downloaded Qur'an translations
  Widget buildDownloadedList(List<TranslationCountry> translationCountries) {
    return ListView.builder(
      itemCount: translationCountries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return buildList(translationCountries.elementAt(index), false);
      },
    );
  }

  Widget buildList(TranslationCountry translationCountry, bool isDownloaded) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible:
                translationCountry.downloadedList.isNotEmpty || !isDownloaded,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kSizeS, vertical: kSizeL),
              child: Text(
                translationCountry.name ?? "",
                style: theme.textTheme.headlineSmall!.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ListView.separated(
            itemCount: translationCountry.translationsAuthor.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var value =
                  translationCountry.translationsAuthor.elementAt(index);
              bool control = false;
              if (isDownloaded) {
                control = value.verseTranslationState ==
                    EVerseTranslationState.downloaded;
              } else {
                control = value.verseTranslationState !=
                    EVerseTranslationState.downloaded;
              }
              if (control) {
                return TranslationsSettingCard(
                  translationAuthor: value,
                  onTap:
                      context.read<QuranProvider>().onTapTranslationAuthorCard,
                  isDownloaded: isDownloaded,
                );
              } else {
                return const SizedBox();
              }
            },
            separatorBuilder: (context, index) {
              var value =
                  translationCountry.translationsAuthor.elementAt(index);
              bool control = false;
              if (isDownloaded) {
                control = value.verseTranslationState ==
                    EVerseTranslationState.downloaded;
              } else {
                control = value.verseTranslationState !=
                    EVerseTranslationState.downloaded;
              }
              return control
                  ? const SizedBox(height: kSizeM)
                  : const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
