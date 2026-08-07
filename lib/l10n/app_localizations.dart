import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku')
  ];

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an'**
  String get quran;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @hizb.
  ///
  /// In en, this message translates to:
  /// **'Hizb'**
  String get hizb;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @sajda.
  ///
  /// In en, this message translates to:
  /// **'Sajda'**
  String get sajda;

  /// No description provided for @ayat.
  ///
  /// In en, this message translates to:
  /// **'Ayat'**
  String get ayat;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @helpGuide.
  ///
  /// In en, this message translates to:
  /// **'Help Guide'**
  String get helpGuide;

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// No description provided for @switchTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch Theme'**
  String get switchTheme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @quranMode.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an Mode'**
  String get quranMode;

  /// No description provided for @greenMode.
  ///
  /// In en, this message translates to:
  /// **'Green Mode'**
  String get greenMode;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @selectedTranslation.
  ///
  /// In en, this message translates to:
  /// **'Selected Translations'**
  String get selectedTranslation;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @searchSurah.
  ///
  /// In en, this message translates to:
  /// **'Search Surah'**
  String get searchSurah;

  /// No description provided for @madeByFabrikod.
  ///
  /// In en, this message translates to:
  /// **'Made by AbdulrahmanMH'**
  String get madeByFabrikod;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **' - V'**
  String get version;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @scroll.
  ///
  /// In en, this message translates to:
  /// **'Scroll'**
  String get scroll;

  /// No description provided for @mushaf.
  ///
  /// In en, this message translates to:
  /// **'Mushaf'**
  String get mushaf;

  /// No description provided for @quranType.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an Type'**
  String get quranType;

  /// No description provided for @readingStyle.
  ///
  /// In en, this message translates to:
  /// **'Reading Style'**
  String get readingStyle;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @fontType.
  ///
  /// In en, this message translates to:
  /// **'Font Type'**
  String get fontType;

  /// No description provided for @helpGuideTitle1.
  ///
  /// In en, this message translates to:
  /// **'What is Qur\'an Kareem'**
  String get helpGuideTitle1;

  /// No description provided for @helpGuideDescription1.
  ///
  /// In en, this message translates to:
  /// **'The Holy Quran is the religious text of Islam, believed by Muslims to be the word of God as revealed to Prophet Muhammad through the angel Gabriel. It contains guidance and teachings on various aspects of life, including faith, morality, spirituality, and daily living.'**
  String get helpGuideDescription1;

  /// No description provided for @helpGuideTitle2.
  ///
  /// In en, this message translates to:
  /// **'How many chapters does the Qur’an Kareem include?'**
  String get helpGuideTitle2;

  /// No description provided for @helpGuideDescription2.
  ///
  /// In en, this message translates to:
  /// **'114 chapters'**
  String get helpGuideDescription2;

  /// No description provided for @helpGuideTitle3.
  ///
  /// In en, this message translates to:
  /// **'Can I read separately versicles and chapters?'**
  String get helpGuideTitle3;

  /// No description provided for @helpGuideDescription3.
  ///
  /// In en, this message translates to:
  /// **'Yes you can. You can jump from one page to another in the way you prefer. You can also mark them so you can directly read them without searching them in the whole book.'**
  String get helpGuideDescription3;

  /// No description provided for @helpGuideTitle4.
  ///
  /// In en, this message translates to:
  /// **'Can I share the content in other places?'**
  String get helpGuideTitle4;

  /// No description provided for @helpGuideDescription4.
  ///
  /// In en, this message translates to:
  /// **'Yes you can, أوقات الأذان آزاد الكُردي is an open source app where you are free to use the content.'**
  String get helpGuideDescription4;

  /// No description provided for @helpGuideTitle5.
  ///
  /// In en, this message translates to:
  /// **'What is the purpose of the app?'**
  String get helpGuideTitle5;

  /// No description provided for @helpGuideDescription5.
  ///
  /// In en, this message translates to:
  /// **'The main purpose of the app is to offer to the community a native open source mobile app where they can read, listen and save their surahs, ayas or juzs.'**
  String get helpGuideDescription5;

  /// No description provided for @helpGuideTitle6.
  ///
  /// In en, this message translates to:
  /// **'What are the key features of the app?'**
  String get helpGuideTitle6;

  /// No description provided for @helpGuideDescription6.
  ///
  /// In en, this message translates to:
  /// **'You can read with no limit the Holy Qur’an, you mark with the bookmarks the last aya you read so you won’t get lost next time you open your Qur’an. You can listen the ayas in case you don’t know how to read it in Arabic and also you can save your most read surahs, ayas or juzs.'**
  String get helpGuideDescription6;

  /// No description provided for @helpGuideTitle7.
  ///
  /// In en, this message translates to:
  /// **'How can users troubleshoot problems and find solutions? '**
  String get helpGuideTitle7;

  /// No description provided for @helpGuideDescription7.
  ///
  /// In en, this message translates to:
  /// **'You can always contact us via email: aabdulrahman1229@gmail.com'**
  String get helpGuideDescription7;

  /// No description provided for @helpGuideTitle8.
  ///
  /// In en, this message translates to:
  /// **'Are there any known limitations or restrictions in the app?'**
  String get helpGuideTitle8;

  /// No description provided for @helpGuideDescription8.
  ///
  /// In en, this message translates to:
  /// **'No there is not, you can read and listen as much as you want.'**
  String get helpGuideDescription8;

  /// No description provided for @helpGuideTitle9.
  ///
  /// In en, this message translates to:
  /// **'Who is the target audience for the app?'**
  String get helpGuideTitle9;

  /// No description provided for @helpGuideDescription9.
  ///
  /// In en, this message translates to:
  /// **'Everyone who has an interest in getting to know the Holy Qur’an, reading or listen to it. Everyone is welcome.'**
  String get helpGuideDescription9;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next Page'**
  String get nextPage;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous Page'**
  String get previousPage;

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found\nTry searching for a different keyword'**
  String get noResultsFound;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @noBookMarksAdded.
  ///
  /// In en, this message translates to:
  /// **'No Bookmarks Added'**
  String get noBookMarksAdded;

  /// No description provided for @noFavoritesAdded.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Added'**
  String get noFavoritesAdded;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'And'**
  String get and;

  /// No description provided for @theOpenQuran.
  ///
  /// In en, this message translates to:
  /// **'أوقات الأذان آزاد الكُردي'**
  String get theOpenQuran;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @lineSpacing.
  ///
  /// In en, this message translates to:
  /// **'Line Spacing'**
  String get lineSpacing;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @ayatAndTranslation.
  ///
  /// In en, this message translates to:
  /// **'Ayat + Translation'**
  String get ayatAndTranslation;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @writeAnAppStoreReview.
  ///
  /// In en, this message translates to:
  /// **'Write an app store review'**
  String get writeAnAppStoreReview;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigations'**
  String get navigation;

  /// No description provided for @searchSurahJuzOrAyahs.
  ///
  /// In en, this message translates to:
  /// **'Search surah, juz or ayahs...'**
  String get searchSurahJuzOrAyahs;

  /// No description provided for @searchSurahJuzOrPage.
  ///
  /// In en, this message translates to:
  /// **'Search for surah, juz or page...'**
  String get searchSurahJuzOrPage;

  /// No description provided for @searchFor.
  ///
  /// In en, this message translates to:
  /// **'Search for'**
  String get searchFor;

  /// No description provided for @reciter.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciter;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @quranFont.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an Font'**
  String get quranFont;

  /// No description provided for @availableToDownload.
  ///
  /// In en, this message translates to:
  /// **'Available to Download'**
  String get availableToDownload;

  /// No description provided for @fabrikodTwoThree.
  ///
  /// In en, this message translates to:
  /// **'@2025 AbdulrahmanMH'**
  String get fabrikodTwoThree;

  /// No description provided for @referencesDescription.
  ///
  /// In en, this message translates to:
  /// **'The goal of the project is to provide people with a convenient platform for studying the Holy Qur\'an. Therefore, the Qur\'an can now be read on smartphones, tablets and other modern devices. To see the source code for this app, please visit the '**
  String get referencesDescription;

  /// No description provided for @referencesDescription2.
  ///
  /// In en, this message translates to:
  /// **' As explained in our Privacy Policy we do not collect any personal information.'**
  String get referencesDescription2;

  /// No description provided for @referencesDescription3.
  ///
  /// In en, this message translates to:
  /// **'The API and all Qur\'an sources are used from '**
  String get referencesDescription3;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us at aabdulrahman1229@gmail.com for assistance.'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @nextSurah.
  ///
  /// In en, this message translates to:
  /// **'Next Surah'**
  String get nextSurah;

  /// No description provided for @previousSurah.
  ///
  /// In en, this message translates to:
  /// **'Previous Surah'**
  String get previousSurah;

  /// No description provided for @beggingOfSurah.
  ///
  /// In en, this message translates to:
  /// **'Beginning of Surah'**
  String get beggingOfSurah;

  /// No description provided for @openSourceDevelopedByFabrikod.
  ///
  /// In en, this message translates to:
  /// **'Open source developed by AbdulrahmanMH'**
  String get openSourceDevelopedByFabrikod;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @permissionsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissionsNotifications;

  /// No description provided for @permissionsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable to get prayer time reminders and other alerts.'**
  String get permissionsNotificationsDescription;

  /// No description provided for @permissionsPrayerWidget.
  ///
  /// In en, this message translates to:
  /// **'Prayer times widget'**
  String get permissionsPrayerWidget;

  /// No description provided for @permissionsPrayerWidgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Add the prayer times widget to your home screen from your device\'s widget menu.'**
  String get permissionsPrayerWidgetDescription;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @couldNotLoadPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Could not load prayer times'**
  String get couldNotLoadPrayerTimes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noAdhanSound.
  ///
  /// In en, this message translates to:
  /// **'No adhan sound'**
  String get noAdhanSound;

  /// No description provided for @notifyAtPrayerTimeOnly.
  ///
  /// In en, this message translates to:
  /// **'At prayer time only'**
  String get notifyAtPrayerTimeOnly;

  /// No description provided for @notifyMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String notifyMinutesBefore(int minutes);

  /// No description provided for @playAdhan.
  ///
  /// In en, this message translates to:
  /// **'Play adhan'**
  String get playAdhan;

  /// No description provided for @kurdistan.
  ///
  /// In en, this message translates to:
  /// **'Kurdistan'**
  String get kurdistan;

  /// No description provided for @includeIraq.
  ///
  /// In en, this message translates to:
  /// **'Other countries'**
  String get includeIraq;

  /// No description provided for @searchCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Search country (name or code)'**
  String get searchCountryHint;

  /// No description provided for @searchCityHint.
  ///
  /// In en, this message translates to:
  /// **'Search city (Kurdish, Arabic, English)'**
  String get searchCityHint;

  /// No description provided for @noCountryMatches.
  ///
  /// In en, this message translates to:
  /// **'No country matches'**
  String get noCountryMatches;

  /// No description provided for @noCityMatches.
  ///
  /// In en, this message translates to:
  /// **'No city matches'**
  String get noCityMatches;

  /// No description provided for @pdfBooks.
  ///
  /// In en, this message translates to:
  /// **'PDF Books'**
  String get pdfBooks;

  /// No description provided for @yourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your library'**
  String get yourLibrary;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'book'**
  String get book;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'books'**
  String get books;

  /// No description provided for @tapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get tapToOpen;

  /// No description provided for @noPdfBooksYet.
  ///
  /// In en, this message translates to:
  /// **'No PDF books yet'**
  String get noPdfBooksYet;

  /// No description provided for @couldNotLoadPdf.
  ///
  /// In en, this message translates to:
  /// **'Could not load PDF'**
  String get couldNotLoadPdf;

  /// No description provided for @goToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get goToPage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @openBook.
  ///
  /// In en, this message translates to:
  /// **'Open Book'**
  String get openBook;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @memorizationProgram.
  ///
  /// In en, this message translates to:
  /// **'Memorization program'**
  String get memorizationProgram;

  /// No description provided for @memorized.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get memorized;

  /// No description provided for @markAsMemorized.
  ///
  /// In en, this message translates to:
  /// **'Mark as memorized'**
  String get markAsMemorized;

  /// No description provided for @removePlan.
  ///
  /// In en, this message translates to:
  /// **'Remove plan'**
  String get removePlan;

  /// No description provided for @memorize.
  ///
  /// In en, this message translates to:
  /// **'Memorize'**
  String get memorize;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @qiblaDescription.
  ///
  /// In en, this message translates to:
  /// **'Point your device so the arrow points up toward the Kaaba.'**
  String get qiblaDescription;

  /// No description provided for @enableLocationForAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Enable location for accurate direction'**
  String get enableLocationForAccuracy;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location denied. Using default direction.'**
  String get locationPermissionDenied;

  /// No description provided for @testReminder.
  ///
  /// In en, this message translates to:
  /// **'Test reminder'**
  String get testReminder;

  /// No description provided for @testReminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Notification shown. Another in 15 sec if you minimize the app. Tap any to play adhan.'**
  String get testReminderScheduled;

  /// No description provided for @testReminderQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick test (5 sec)'**
  String get testReminderQuick;

  /// No description provided for @testReminderQuickScheduled.
  ///
  /// In en, this message translates to:
  /// **'Adhan will play in 5 sec. Minimize the app to hear it.'**
  String get testReminderQuickScheduled;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to test reminders.'**
  String get notificationPermissionRequired;

  /// No description provided for @testReminderOneMinute.
  ///
  /// In en, this message translates to:
  /// **'Test in 10 sec'**
  String get testReminderOneMinute;

  /// No description provided for @testReminderOneMinuteScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder in 10 sec. Notification and adhan will play together.'**
  String get testReminderOneMinuteScheduled;

  /// No description provided for @testReminderExactAlarmHint.
  ///
  /// In en, this message translates to:
  /// **'If the 10 sec reminder doesn\'t appear: Settings → Apps → أوقات الأذان آزاد الكُردي → Alarms & reminders → turn ON.'**
  String get testReminderExactAlarmHint;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @nextPrayerIn.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String nextPrayerIn(String duration);

  /// No description provided for @nextPrayerTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow at {time}'**
  String nextPrayerTomorrowAt(String time);

  /// No description provided for @remindersAutomaticHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders and adhan play automatically at prayer time. Tap a notification only to open the app.'**
  String get remindersAutomaticHint;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Update your settings like language and privacy policy.'**
  String get settingsDescription;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @viewManageMemorizationPlans.
  ///
  /// In en, this message translates to:
  /// **'View and manage your memorization plans'**
  String get viewManageMemorizationPlans;

  /// No description provided for @readPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readPrivacyPolicy;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @surahListStats.
  ///
  /// In en, this message translates to:
  /// **'114 chapters • 6,236 verses'**
  String get surahListStats;

  /// No description provided for @meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @kurdish.
  ///
  /// In en, this message translates to:
  /// **'Kurdî'**
  String get kurdish;

  /// No description provided for @preparingCompass.
  ///
  /// In en, this message translates to:
  /// **'Preparing compass...\nPlease wait...'**
  String get preparingCompass;

  /// No description provided for @qiblaCompassHint.
  ///
  /// In en, this message translates to:
  /// **'Align both arrow head. Do not put device close to metal object. Calibrate the compass every time you use it.'**
  String get qiblaCompassHint;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopAdhan.
  ///
  /// In en, this message translates to:
  /// **'Stop adhan'**
  String get stopAdhan;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @adhkarRepeatProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target}'**
  String adhkarRepeatProgress(int current, int target);

  /// No description provided for @adhkarResetCounter.
  ///
  /// In en, this message translates to:
  /// **'Reset counter'**
  String get adhkarResetCounter;

  /// No description provided for @adhkarComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get adhkarComplete;

  /// No description provided for @adhkarTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to count each repetition'**
  String get adhkarTapHint;

  /// No description provided for @adhkarRepetitionsTitle.
  ///
  /// In en, this message translates to:
  /// **'How many times for this dhikr?'**
  String get adhkarRepetitionsTitle;

  /// No description provided for @adhkarRepetitionsMenu.
  ///
  /// In en, this message translates to:
  /// **'Set repetitions'**
  String get adhkarRepetitionsMenu;

  /// No description provided for @adhkarCustomRepetitions.
  ///
  /// In en, this message translates to:
  /// **'Custom number…'**
  String get adhkarCustomRepetitions;

  /// No description provided for @adhkarResetTarget.
  ///
  /// In en, this message translates to:
  /// **'Reset to default count'**
  String get adhkarResetTarget;

  /// No description provided for @adhkarEnterNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Number of times (1 or more)'**
  String get adhkarEnterNumberHint;

  /// No description provided for @adhanLearnSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn the Adhan'**
  String get adhanLearnSectionTitle;

  /// No description provided for @adhanLearnBookLink.
  ///
  /// In en, this message translates to:
  /// **'Lessons & resources (Book of Adhan)'**
  String get adhanLearnBookLink;

  /// No description provided for @adhanLearnVideosLink.
  ///
  /// In en, this message translates to:
  /// **'Instructional videos'**
  String get adhanLearnVideosLink;

  /// No description provided for @bilalAcademyTelegram.
  ///
  /// In en, this message translates to:
  /// **'Bilal al-Habashi Academy (Telegram)'**
  String get bilalAcademyTelegram;

  /// No description provided for @openExternalLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openExternalLink;

  /// No description provided for @auxiliaryRemindersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Dhikr & voluntary fasting'**
  String get auxiliaryRemindersSectionTitle;

  /// No description provided for @adhkarMorningReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar reminder'**
  String get adhkarMorningReminderTitle;

  /// No description provided for @adhkarEveningReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar reminder'**
  String get adhkarEveningReminderTitle;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTimeLabel;

  /// No description provided for @fastingMonThuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunnah fast (Monday & Thursday)'**
  String get fastingMonThuTitle;

  /// No description provided for @fastingMonThuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder before dawn on those days (approximate).'**
  String get fastingMonThuSubtitle;

  /// No description provided for @fastingWhiteDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'White days (13–15 Hijri)'**
  String get fastingWhiteDaysTitle;

  /// No description provided for @fastingWhiteDaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses calculated Hijri dates; verify locally if needed.'**
  String get fastingWhiteDaysSubtitle;

  /// No description provided for @recitationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recitation audio'**
  String get recitationSettingsTitle;

  /// No description provided for @recitationReciterLabel.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get recitationReciterLabel;

  /// No description provided for @recitationDownloadSurah.
  ///
  /// In en, this message translates to:
  /// **'Download this surah (cache for offline)'**
  String get recitationDownloadSurah;

  /// No description provided for @recitationDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String recitationDownloading(int percent);

  /// No description provided for @selectCityAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Select City & Region'**
  String get selectCityAndRegion;

  /// No description provided for @adhanSoundSettings.
  ///
  /// In en, this message translates to:
  /// **'Adhan Sound Settings'**
  String get adhanSoundSettings;

  /// No description provided for @classicMihrabView.
  ///
  /// In en, this message translates to:
  /// **'Classic Mihrab Card View'**
  String get classicMihrabView;

  /// No description provided for @kurdistanRegion.
  ///
  /// In en, this message translates to:
  /// **'Kurdistan Region'**
  String get kurdistanRegion;

  /// No description provided for @otherCountriesDb.
  ///
  /// In en, this message translates to:
  /// **'Other Countries DB'**
  String get otherCountriesDb;

  /// No description provided for @duration3Sec.
  ///
  /// In en, this message translates to:
  /// **'3 Seconds'**
  String get duration3Sec;

  /// No description provided for @duration15Sec.
  ///
  /// In en, this message translates to:
  /// **'15 Seconds'**
  String get duration15Sec;

  /// No description provided for @duration30Sec.
  ///
  /// In en, this message translates to:
  /// **'30 Seconds (Half Minute)'**
  String get duration30Sec;

  /// No description provided for @duration1Min.
  ///
  /// In en, this message translates to:
  /// **'1 Minute'**
  String get duration1Min;

  /// No description provided for @duration2Min.
  ///
  /// In en, this message translates to:
  /// **'2 Minutes'**
  String get duration2Min;

  /// No description provided for @duration3Min.
  ///
  /// In en, this message translates to:
  /// **'3 Minutes'**
  String get duration3Min;

  /// No description provided for @fullAdhan.
  ///
  /// In en, this message translates to:
  /// **'Full Adhan (Longest Audio)'**
  String get fullAdhan;

  /// No description provided for @alarmOffsetTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarm Timing Offset'**
  String get alarmOffsetTitle;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time (0 min)'**
  String get onTime;

  /// No description provided for @minsBefore.
  ///
  /// In en, this message translates to:
  /// **'{mins} mins before'**
  String minsBefore(Object mins);

  /// No description provided for @minsAfter.
  ///
  /// In en, this message translates to:
  /// **'{mins} mins after'**
  String minsAfter(Object mins);

  /// No description provided for @supportUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Us / Donate'**
  String get supportUsTitle;

  /// No description provided for @supportAppDev.
  ///
  /// In en, this message translates to:
  /// **'Support App Development'**
  String get supportAppDev;

  /// No description provided for @supportAppDevDesc.
  ///
  /// In en, this message translates to:
  /// **'Your support helps keep the app ad-free, open source, and continuously updated for everyone.'**
  String get supportAppDevDesc;

  /// No description provided for @fibTitle.
  ///
  /// In en, this message translates to:
  /// **'First Iraqi Bank (FIB)'**
  String get fibTitle;

  /// No description provided for @fibPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'FIB Phone Number:'**
  String get fibPhoneLabel;

  /// No description provided for @fibStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Copy phone number above'**
  String get fibStep1;

  /// No description provided for @fibStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Open First Iraqi Bank (FIB) app'**
  String get fibStep2;

  /// No description provided for @fibStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Tap Send / Request -> Paste number'**
  String get fibStep3;

  /// No description provided for @openFibApp.
  ///
  /// In en, this message translates to:
  /// **'Open FIB App'**
  String get openFibApp;

  /// No description provided for @openSuperQiApp.
  ///
  /// In en, this message translates to:
  /// **'Open SuperQi App'**
  String get openSuperQiApp;

  /// No description provided for @superQiTitle.
  ///
  /// In en, this message translates to:
  /// **'SuperQi (Qi Card)'**
  String get superQiTitle;

  /// No description provided for @superQiAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'SuperQi Account / Card Number:'**
  String get superQiAccountLabel;

  /// No description provided for @superQiStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Copy Account Number above'**
  String get superQiStep1;

  /// No description provided for @superQiStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Open SuperQi app'**
  String get superQiStep2;

  /// No description provided for @superQiStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Tap Transfer -> Choose Card/Account Transfer -> Paste number'**
  String get superQiStep3;

  /// No description provided for @donateViaFibSuperQi.
  ///
  /// In en, this message translates to:
  /// **'Donate via FIB & SuperQi'**
  String get donateViaFibSuperQi;

  /// No description provided for @copiedToast.
  ///
  /// In en, this message translates to:
  /// **'{label} Copied!'**
  String copiedToast(String label);

  /// No description provided for @fridaySunnahs.
  ///
  /// In en, this message translates to:
  /// **'Friday Sunnahs'**
  String get fridaySunnahs;

  /// No description provided for @fridaySunnahsDesc.
  ///
  /// In en, this message translates to:
  /// **'Blessed acts recommended on Friday'**
  String get fridaySunnahsDesc;

  /// No description provided for @readSurahKahf.
  ///
  /// In en, this message translates to:
  /// **'Read Surah Al-Kahf'**
  String get readSurahKahf;

  /// No description provided for @readSurahKahfDesc.
  ///
  /// In en, this message translates to:
  /// **'A light between two Fridays'**
  String get readSurahKahfDesc;

  /// No description provided for @salawatCounter.
  ///
  /// In en, this message translates to:
  /// **'Salawat Counter'**
  String get salawatCounter;

  /// No description provided for @salawatCounterDesc.
  ///
  /// In en, this message translates to:
  /// **'Send blessings upon Prophet Muhammad ﷺ'**
  String get salawatCounterDesc;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get tapToCount;

  /// No description provided for @resetCounter.
  ///
  /// In en, this message translates to:
  /// **'Reset Counter'**
  String get resetCounter;

  /// No description provided for @salawatTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {count}'**
  String salawatTarget(int count);

  /// No description provided for @sunnahGhusl.
  ///
  /// In en, this message translates to:
  /// **'Friday Bathing (Ghusl)'**
  String get sunnahGhusl;

  /// No description provided for @sunnahGhuslDesc.
  ///
  /// In en, this message translates to:
  /// **'Purify oneself before Friday prayer'**
  String get sunnahGhuslDesc;

  /// No description provided for @sunnahSiwak.
  ///
  /// In en, this message translates to:
  /// **'Siwak & Fragrance'**
  String get sunnahSiwak;

  /// No description provided for @sunnahSiwakDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Siwak and wear pleasant perfume'**
  String get sunnahSiwakDesc;

  /// No description provided for @sunnahCleanClothes.
  ///
  /// In en, this message translates to:
  /// **'Clean & Best Clothes'**
  String get sunnahCleanClothes;

  /// No description provided for @sunnahCleanClothesDesc.
  ///
  /// In en, this message translates to:
  /// **'Dress nicely for the day of Friday'**
  String get sunnahCleanClothesDesc;

  /// No description provided for @sunnahEarlyMosque.
  ///
  /// In en, this message translates to:
  /// **'Going Early to Jumu\'ah'**
  String get sunnahEarlyMosque;

  /// No description provided for @sunnahEarlyMosqueDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn great reward by arriving early'**
  String get sunnahEarlyMosqueDesc;

  /// No description provided for @sunnahDuaHour.
  ///
  /// In en, this message translates to:
  /// **'Hour of Response (Dua)'**
  String get sunnahDuaHour;

  /// No description provided for @sunnahDuaHourDesc.
  ///
  /// In en, this message translates to:
  /// **'Make abundant Dua, especially between Asr and Maghrib'**
  String get sunnahDuaHourDesc;

  /// No description provided for @fridayReminders.
  ///
  /// In en, this message translates to:
  /// **'Friday Reminders'**
  String get fridayReminders;

  /// No description provided for @fridayRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get weekly reminders for Surah Al-Kahf & Friday Sunnahs'**
  String get fridayRemindersDesc;

  /// No description provided for @fridayNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Friday Sunnahs Reminder'**
  String get fridayNotificationTitle;

  /// No description provided for @fridayNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to read Surah Al-Kahf & send Salawat today!'**
  String get fridayNotificationBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
