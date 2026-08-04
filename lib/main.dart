import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:the_open_quran/constants/app_brand.dart';
import 'package:the_open_quran/l10n/app_localizations.dart';
import 'package:the_open_quran/l10n/ku_material_localizations_delegate.dart';
import 'package:the_open_quran/providers/app_settings_provider.dart';
import 'package:the_open_quran/providers/bookmark_provider.dart';
import 'package:the_open_quran/providers/favorites_provider.dart';
import 'package:the_open_quran/providers/quran_provider.dart';
import 'package:the_open_quran/providers/search_provider.dart';
import 'package:the_open_quran/screens/splash_screen.dart';
import 'package:the_open_quran/services/prayer_notification_service.dart';
import 'package:the_open_quran/themes/theme.dart';

import 'main_builder.dart';

/// Observer used to notify the bottom nav (home) route when a pushed route is popped.
final RouteObserver<ModalRoute<void>> _routeObserver =
    RouteObserver<ModalRoute<void>>();

/// Debug log path (works when run from project on host; on device writes are no-op).
void _writeErrorLog(String message, String? stack) {
  try {
    const path =
        r'c:\Users\aabdu\Downloads\Compressed\quran-main\quran-main\.cursor\debug.log';
    final line =
        '{"timestamp":${DateTime.now().millisecondsSinceEpoch},"message":"${message.replaceAll('"', '\\"').replaceAll('\n', ' ')}","stack":"${stack?.replaceAll('"', '\\"').replaceAll('\n', ' ') ?? ""}"}\n';
    File(path).writeAsStringSync(line, mode: FileMode.append);
  } catch (_) {}
}

Future<void> main() async {
  print('flutter: [STARTUP] 0. main() entered');
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _writeErrorLog(details.exceptionAsString(), details.stack?.toString());
    };
    print('flutter: [STARTUP] 1. GetStorage.init');
    await GetStorage.init('FabrikodQuran');
    // Run app immediately so launcher doesn't hang; do notification setup in background
    print('flutter: [STARTUP] 2. runApp');
    runApp(const MyApp());
    // Schedule prayer reminders after first frame (permission dialog can show then without blocking launch)
    Future<void>.delayed(Duration.zero, () async {
      try {
        await PrayerNotificationService.init();
        await PrayerNotificationService.rescheduleFromStoredPrefs();
      } catch (e, st) {
        _writeErrorLog('PrayerNotificationService: $e', st.toString());
        print('flutter: [STARTUP] Prayer notifications init failed: $e');
      }
    });
  }, (Object error, StackTrace stack) {
    _writeErrorLog(error.toString(), stack.toString());
    print('flutter: [CRASH] $error');
    print(stack);
  });
}

/// Use en for framework when locale is tr (Turkish removed).
Locale? _effectiveLocale(Locale? appLocale) {
  if (appLocale == null) return null;
  if (appLocale.languageCode == 'tr') return const Locale('en');
  return appLocale;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<AppSettingsProvider>(
        builder: (context, appSettingProvider, child) {
          return MaterialApp(
            key: ValueKey(appSettingProvider.appLocale?.languageCode ?? ''),
            title: kAppDisplayName,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [_routeObserver],
            locale: _effectiveLocale(appSettingProvider.appLocale),
            localizationsDelegates: [
              AppLocalizations.delegate,
              const KuMaterialLocalizationsDelegate(),
              ...AppLocalizations.localizationsDelegates.skip(1),
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: MainBuilder.builder,
            localeResolutionCallback:
                appSettingProvider.localeResolutionCallback,
            theme: themeForLocale(appSettingProvider.appLocale),
            home: SplashScreen(routeObserver: _routeObserver),
          );
        },
      ),
    );
  }

  /// Create App Global Providers
  List<SingleChildWidget> get providers {
    return [
      ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ChangeNotifierProvider(create: (_) => QuranProvider(), lazy: false),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ChangeNotifierProvider(create: (_) => SearchProvider(_)),
    ];
  }
}
