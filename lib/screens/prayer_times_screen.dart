import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../constants/adhan_assets.dart';
import '../constants/prayer_times_storage.dart';
import '../database/prayer_times_db.dart';
import '../models/prayer_city_model.dart';
import '../models/prayer_country_model.dart';
import '../models/prayer_time_model.dart';
import '../services/adhan_audio_service.dart';
import '../services/prayer_notification_service.dart';
import '../services/prayer_prefs.dart';
import '../services/prayer_times_source.dart';
import '../widgets/adhan_learning_links_card.dart';
import '../widgets/app_bars/primary_app_bar.dart';
import 'qibla_screen.dart';

/// Prayer times tab: city/country pickers, adhan settings, and mihrab-framed times list.
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key, this.selected = false});

  final bool selected;

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  List<PrayerCityModel> _cities = [];
  List<PrayerCountryModel> _countries = [];
  List<PrayerTimeModel> _times = [];
  String _selectedCity = PrayerTimesSourceRegistry.instance.defaultCity;
  String _selectedCountryIso = 'IQ';
  bool _loading = false;
  String? _error;
  bool _hasStartedLoad = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _countrySearchController =
      TextEditingController();

  /// Kurdistan = [kurdistandb.sqlite]. True = [KurdistanPrayerTimes.db] by country then city.
  bool _includeIraq = false;
  String _citySearchQuery = '';
  String _countrySearchQuery = '';
  String _adhanAsset = '';
  String _adhanRawName = '';
  List<Map<String, String>> _androidAdhanOptions = [];
  static const String _prayerAlarmsChannel = 'com.dya.azadalkrd/prayer_alarms';
  Map<String, bool> _notificationPrefs = {};
  bool _adhkarMorningReminder = false;
  bool _adhkarEveningReminder = false;
  int _adhkarMorningH = 6;
  int _adhkarMorningM = 0;
  int _adhkarEveningH = 17;
  int _adhkarEveningM = 0;
  bool _fastingMonThu = false;
  bool _fastingWhiteDays = false;
  Timer? _countdownTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _selectedCity = GetStorage(PrayerTimesStorage.boxName)
            .read(PrayerTimesStorage.keyCity) ??
        PrayerTimesSourceRegistry.instance.defaultCity;
    _includeIraq = PrayerTimesStorage.readIncludeIraq();
    final storedIso = PrayerTimesStorage.readCountryIso();
    if (storedIso != null) _selectedCountryIso = storedIso;
    if (Platform.isAndroid) {
      _adhanRawName = PrayerPrefs.adhanRawName;
      _loadAndroidAdhanOptions();
    } else {
      _adhanAsset = PrayerPrefs.adhanAsset;
    }
    _notificationPrefs = PrayerPrefs.getAllNotificationPrefs();
    _adhkarMorningReminder = PrayerPrefs.adhkarMorningReminderEnabled;
    _adhkarEveningReminder = PrayerPrefs.adhkarEveningReminderEnabled;
    _adhkarMorningH = PrayerPrefs.adhkarMorningHour;
    _adhkarMorningM = PrayerPrefs.adhkarMorningMinute;
    _adhkarEveningH = PrayerPrefs.adhkarEveningHour;
    _adhkarEveningM = PrayerPrefs.adhkarEveningMinute;
    _fastingMonThu = PrayerPrefs.fastingMondayThursdayEnabled;
    _fastingWhiteDays = PrayerPrefs.fastingWhiteDaysEnabled;
    if (widget.selected) _load();
    _searchController.addListener(() {
      if (mounted) setState(() => _citySearchQuery = _searchController.text);
    });
    _countrySearchController.addListener(() {
      if (mounted) {
        setState(() => _countrySearchQuery = _countrySearchController.text);
      }
    });
  }

  Future<void> _loadAndroidAdhanOptions() async {
    try {
      final list = await MethodChannel(_prayerAlarmsChannel)
          .invokeMethod<List<dynamic>>('getAdhanOptions');
      if (mounted && list != null) {
        setState(() {
          _androidAdhanOptions =
              list.map((e) => Map<String, String>.from(e as Map)).toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _searchController.dispose();
    _countrySearchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PrayerTimesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !_hasStartedLoad) _load();
  }

  Future<void> _load() async {
    if (_hasStartedLoad && _error == null && !_loading) return;
    _hasStartedLoad = true;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final src = PrayerTimesSourceRegistry.instance;
      if (!_includeIraq) {
        final cities = await src.getCities(includeIraq: false);
        var city = _selectedCity;
        if (!cities.any((c) => c.id == city) && cities.isNotEmpty) {
          city = cities.first.id;
          GetStorage(PrayerTimesStorage.boxName)
              .write(PrayerTimesStorage.keyCity, city);
        }
        final times = await src.getTodayPrayerTimes(city, includeIraq: false);
        if (mounted) {
          setState(() {
            _countries = [];
            _cities = cities;
            _selectedCity = city;
            _times = times;
            _loading = false;
          });
          Future.microtask(() => _rescheduleNotifications());
        }
      } else {
        final countries = await src.getPrayerCountries();
        if (countries.isEmpty) {
          if (mounted) {
            setState(() {
              _error = 'No countries available';
              _countries = [];
              _cities = [];
              _loading = false;
            });
          }
          return;
        }
        final storedIso = PrayerTimesStorage.readCountryIso();
        String countryIso =
            (storedIso != null && countries.any((c) => c.iso == storedIso))
                ? storedIso
                : countries.first.iso;
        if (storedIso != countryIso) {
          GetStorage(PrayerTimesStorage.boxName)
              .write(PrayerTimesStorage.keyCountryIso, countryIso);
        }
        final cities = await src.getCitiesForCountryIso(countryIso);
        var city = _selectedCity;
        if (!cities.any((c) => c.id == city) && cities.isNotEmpty) {
          city = cities.first.id;
          GetStorage(PrayerTimesStorage.boxName)
              .write(PrayerTimesStorage.keyCity, city);
        }
        final times = await src.getTodayPrayerTimes(
          city,
          includeIraq: true,
          countryIso: countryIso,
        );
        if (mounted) {
          setState(() {
            _countries = countries;
            _selectedCountryIso = countryIso;
            _cities = cities;
            _selectedCity = city;
            _times = times;
            _loading = false;
          });
          Future.microtask(() => _rescheduleNotifications());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _onCountryChanged(String iso) {
    GetStorage(PrayerTimesStorage.boxName)
        .write(PrayerTimesStorage.keyCountryIso, iso);
    setState(() => _selectedCountryIso = iso);
    _hasStartedLoad = false;
    _load();
  }

  void _onCityChanged(String cityId) {
    setState(() => _selectedCity = cityId);
    GetStorage(PrayerTimesStorage.boxName)
        .write(PrayerTimesStorage.keyCity, cityId);
    _hasStartedLoad = false;
    _load();
  }

  Future<void> _rescheduleNotifications() async {
    try {
      await PrayerNotificationService.init();
      final granted = await PrayerNotificationService.ensurePermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate.notificationPermissionRequired),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
      await PrayerNotificationService.schedule(
        city: _selectedCity,
        times: _times,
        notifyEnabled: PrayerPrefs.getAllNotificationPrefs(),
        includeIraq: _includeIraq,
        countryIso: _includeIraq ? _selectedCountryIso : null,
      );
      await PrayerNotificationService.scheduleAuxiliaryReminders();
    } catch (_) {}
  }

  Future<void> _onNotificationToggled(String prayerName, bool value) async {
    await PrayerPrefs.setNotificationEnabled(prayerName, value);
    setState(() => _notificationPrefs = PrayerPrefs.getAllNotificationPrefs());
    await _rescheduleNotifications();
  }

  Future<void> _onAdhanChanged(String? value) async {
    if (Platform.isAndroid) {
      final raw = value ?? '';
      await PrayerPrefs.setAdhanRawName(raw);
      setState(() => _adhanRawName = raw);
    } else {
      final p = value ?? AdhanAssets.none;
      await PrayerPrefs.setAdhanAsset(p);
      setState(() => _adhanAsset = p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).appBarTheme.iconTheme?.color ??
        Theme.of(context).iconTheme.color ??
        DesignSystem.onSurface;
    final showBackButton = Navigator.canPop(context);
    return Scaffold(
      appBar: PrimaryAppBar(
        title: context.translate.prayerTimes,
        leading: showBackButton
            ? IconButton(
                icon: SvgPicture.asset(
                  ImageConstants.newBackArrow,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _times.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _times.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kSizeXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.translate.couldNotLoadPrayerTimes,
                style: context.theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSizeM),
              Text(
                _error!,
                style: context.theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSizeL),
              TextButton(
                onPressed: () {
                  _hasStartedLoad = false;
                  _load();
                },
                child: Text(context.translate.retry),
              ),
            ],
          ),
        ),
      );
    }

    final nextInfo =
        PrayerTimesDb.getNextPrayerWithDuration(_times, _now);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignSystem.screenPadding,
              DesignSystem.space16,
              DesignSystem.screenPadding,
              DesignSystem.space24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroNextPrayerCard(nextInfo),
                const SizedBox(height: DesignSystem.space20),
                _buildLocationBar(),
                const SizedBox(height: DesignSystem.space20),
                _buildPrayerTimesGrid(nextInfo.next.name),
                const SizedBox(height: DesignSystem.space24),
                _buildQuickActionsRow(),
                const SizedBox(height: DesignSystem.space16),
                const AdhanLearningLinksCard(),
                const SizedBox(height: DesignSystem.space16),
                _buildAdhanAudioCard(),
                const SizedBox(height: DesignSystem.space16),
                _buildAuxiliaryRemindersCard(),
                const SizedBox(height: DesignSystem.space24),
                _buildMihrabExpansionTile(context),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.space48)),
      ],
    );
  }

  /// Modern Hero Card showing Next Prayer and live countdown
  Widget _buildHeroNextPrayerCard(NextPrayerInfo? nextInfo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String nextPrayerName = nextInfo != null
        ? nextInfo.next.name.translatedPrayerName(context)
        : '--';
    final String nextPrayerTime = nextInfo?.next.timeString ?? '--:--';

    final duration = nextInfo?.until ?? Duration.zero;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final countdownStr = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return _LightSweepCountdownCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_filled,
                        color: Color(0xFFD4AF37), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _dateHeader(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFFD4AF37), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCity,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              nextPrayerName,
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nextPrayerTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_top_rounded,
                      color: Color(0xFFD4AF37), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '-$countdownStr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Location selector bar trigger
  Widget _buildLocationBar() {
    return InkWell(
      onTap: _showLocationSelectionBottomSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: DesignSystem.outline.withValues(alpha: 0.6)),
          boxShadow: DesignSystem.shadowSoft,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignSystem.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.my_location,
                  color: DesignSystem.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCity,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.onSurface,
                    ),
                  ),
                  Text(
                    _includeIraq
                        ? context.translate.otherCountriesDb
                        : context.translate.kurdistanRegion,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: DesignSystem.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.unfold_more,
                color: DesignSystem.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  /// Modern Cards Grid for Today's Prayer Times
  Widget _buildPrayerTimesGrid(String? activePrayerName) {
    return Column(
      children: [
        for (var i = 0; i < _times.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildPrayerCard(
              _times[i], _times[i].name == activePrayerName, i < 3),
        ],
      ],
    );
  }

  Widget _buildPrayerCard(
      PrayerTimeModel timeModel, bool isActive, bool isDay) {
    final bool notificationOn = _notificationPrefs[timeModel.name] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? DesignSystem.primary.withValues(alpha: 0.12)
            : DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? DesignSystem.primary
              : DesignSystem.outline.withValues(alpha: 0.4),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive ? DesignSystem.shadowSoft : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? DesignSystem.primary
                  : DesignSystem.outline.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDay ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              size: 20,
              color: isActive
                  ? Colors.white
                  : DesignSystem.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              timeModel.name.translatedPrayerName(context),
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? DesignSystem.primary : DesignSystem.onSurface,
              ),
            ),
          ),
          Text(
            timeModel.timeString,
            style: context.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isActive ? DesignSystem.primary : DesignSystem.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              notificationOn
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: notificationOn
                  ? DesignSystem.primary
                  : DesignSystem.onSurface.withValues(alpha: 0.35),
              size: 22,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _onNotificationToggled(timeModel.name, !notificationOn);
            },
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Quick Action cards: Qibla & Learning
  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(child: _buildQiblaCard()),
      ],
    );
  }

  /// Location selection Bottom Sheet
  void _showLocationSelectionBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignSystem.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DesignSystem.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.translate.selectCityAndRegion,
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRegionToggle(),
                  if (_includeIraq) ...[
                    const SizedBox(height: 12),
                    _buildCountrySearch(),
                    const SizedBox(height: 8),
                    _buildCountryPicker(),
                  ],
                  const SizedBox(height: 12),
                  _buildCitySearch(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildCityPickerListModal(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCityPickerListModal(BuildContext context) {
    final filtered = _filteredCities;
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            '${context.translate.noCityMatches} "$_citySearchQuery"',
            style: context.theme.textTheme.bodyMedium,
          ),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final city in filtered)
          _CityChip(
            label: city.name,
            selected: city.id == _selectedCity,
            onTap: () {
              HapticFeedback.lightImpact();
              _onCityChanged(city.id);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }

  Widget _buildAdhanAudioCard() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space16),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        border: Border.all(color: DesignSystem.outline.withValues(alpha: 0.5)),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate.adhanSoundSettings,
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: DesignSystem.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildAdhanSetting(),
          const SizedBox(height: 12),
          _buildAdhanDurationSetting(),
        ],
      ),
    );
  }

  Widget _buildMihrabExpansionTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        context.translate.classicMihrabView,
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: DesignSystem.onSurface,
        ),
      ),
      iconColor: DesignSystem.primary,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _buildAdhanTimesMihrabCard(context),
        ),
      ],
    );
  }

  /// Native pixel size of [ImageConstants.adhanTimesBackground] (portrait 3:4).
  static const double _mihrabAssetW = 768;
  static const double _mihrabAssetH = 1024;

  /// Prayer rows centered inside the mihrab art; height derived from width × (1024/768).
  Widget _buildAdhanTimesMihrabCard(BuildContext context) {
    const textShadows = <Shadow>[
      Shadow(color: Color(0x99000000), blurRadius: 5, offset: Offset(0, 1.5)),
      Shadow(color: Color(0x55000000), blurRadius: 12, offset: Offset(0, 2)),
    ];
    const white = Colors.white;
    final dateStyle = context.theme.textTheme.titleSmall?.copyWith(
      color: white,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      shadows: textShadows,
    );
    final nameStyle = context.theme.textTheme.titleMedium?.copyWith(
      color: white,
      fontWeight: FontWeight.w800,
      shadows: textShadows,
    );
    final timeStyle = context.theme.textTheme.titleLarge?.copyWith(
      color: white,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
      shadows: textShadows,
    );
    final switchTheme = Theme.of(context).copyWith(
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.white38;
          if (states.contains(WidgetState.selected)) return white;
          return const Color(0xFFE8E8E8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return white.withValues(alpha: 0.42);
          }
          return const Color(0x66000000);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.white24),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w <= 0) return const SizedBox.shrink();
        final h = w * (_mihrabAssetH / _mihrabAssetW);
        return SizedBox(
          width: w,
          height: h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  ImageConstants.adhanTimesBackground,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    w * 0.17,
                    h * 0.13,
                    w * 0.17,
                    h * 0.17,
                  ),
                  child: Theme(
                    data: switchTheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: h * 0.012),
                        Text(
                          _dateHeader(),
                          textAlign: TextAlign.center,
                          style: dateStyle,
                        ),
                        SizedBox(height: h * 0.018),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: h * 0.04),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: w * 0.58),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var i = 0; i < _times.length; i++) ...[
                                      if (i > 0) SizedBox(height: h * 0.007),
                                      _MihrabPrayerRow(
                                        model: _times[i],
                                        isDay: i < 3,
                                        nameStyle: nameStyle,
                                        timeStyle: timeStyle,
                                        notificationOn: _notificationPrefs[
                                                _times[i].name] ??
                                            false,
                                        onNotificationChanged: (value) =>
                                            _onNotificationToggled(
                                                _times[i].name, value),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatReminderTime(int h, int m) {
    final hh = h.clamp(0, 23).toString().padLeft(2, '0');
    final mm = m.clamp(0, 59).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _syncAuxiliaryReminders() async {
    try {
      await PrayerNotificationService.init();
      final granted = await PrayerNotificationService.ensurePermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate.notificationPermissionRequired),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      await PrayerNotificationService.scheduleAuxiliaryReminders();
    } catch (_) {}
  }

  Future<void> _pickMorningAdhkarTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _adhkarMorningH, minute: _adhkarMorningM),
    );
    if (t == null || !mounted) return;
    await PrayerPrefs.setAdhkarMorningTime(t.hour, t.minute);
    setState(() {
      _adhkarMorningH = t.hour;
      _adhkarMorningM = t.minute;
    });
    if (_adhkarMorningReminder) await _syncAuxiliaryReminders();
  }

  Future<void> _pickEveningAdhkarTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _adhkarEveningH, minute: _adhkarEveningM),
    );
    if (t == null || !mounted) return;
    await PrayerPrefs.setAdhkarEveningTime(t.hour, t.minute);
    setState(() {
      _adhkarEveningH = t.hour;
      _adhkarEveningM = t.minute;
    });
    if (_adhkarEveningReminder) await _syncAuxiliaryReminders();
  }

  Future<void> _onAdhkarMorningToggle(bool value) async {
    await PrayerPrefs.setAdhkarMorningReminderEnabled(value);
    setState(() => _adhkarMorningReminder = value);
    await _syncAuxiliaryReminders();
  }

  Future<void> _onAdhkarEveningToggle(bool value) async {
    await PrayerPrefs.setAdhkarEveningReminderEnabled(value);
    setState(() => _adhkarEveningReminder = value);
    await _syncAuxiliaryReminders();
  }

  Future<void> _onFastingMonThuToggle(bool value) async {
    await PrayerPrefs.setFastingMondayThursdayEnabled(value);
    setState(() => _fastingMonThu = value);
    await _syncAuxiliaryReminders();
  }

  Future<void> _onFastingWhiteDaysToggle(bool value) async {
    await PrayerPrefs.setFastingWhiteDaysEnabled(value);
    setState(() => _fastingWhiteDays = value);
    await _syncAuxiliaryReminders();
  }

  Widget _buildAuxiliaryRemindersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSystem.space16),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        border: Border.all(color: DesignSystem.outline.withValues(alpha: 0.5)),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate.auxiliaryRemindersSectionTitle,
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: DesignSystem.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignSystem.space8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.translate.adhkarMorningReminderTitle),
            value: _adhkarMorningReminder,
            onChanged: _onAdhkarMorningToggle,
          ),
          if (_adhkarMorningReminder)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.schedule, size: 22),
              title: Text(context.translate.reminderTimeLabel),
              subtitle:
                  Text(_formatReminderTime(_adhkarMorningH, _adhkarMorningM)),
              onTap: _pickMorningAdhkarTime,
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.translate.adhkarEveningReminderTitle),
            value: _adhkarEveningReminder,
            onChanged: _onAdhkarEveningToggle,
          ),
          if (_adhkarEveningReminder)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.schedule, size: 22),
              title: Text(context.translate.reminderTimeLabel),
              subtitle:
                  Text(_formatReminderTime(_adhkarEveningH, _adhkarEveningM)),
              onTap: _pickEveningAdhkarTime,
            ),
          const Divider(height: DesignSystem.space24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.translate.fastingMonThuTitle),
            subtitle: Text(
              context.translate.fastingMonThuSubtitle,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: DesignSystem.onSurface.withValues(alpha: 0.65),
              ),
            ),
            value: _fastingMonThu,
            onChanged: _onFastingMonThuToggle,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.translate.fastingWhiteDaysTitle),
            subtitle: Text(
              context.translate.fastingWhiteDaysSubtitle,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: DesignSystem.onSurface.withValues(alpha: 0.65),
              ),
            ),
            value: _fastingWhiteDays,
            onChanged: _onFastingWhiteDaysToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        border: Border.all(
          color: DesignSystem.outline.withValues(alpha: 0.5),
        ),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const QiblaScreen(),
          ),
        ),
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space16,
            vertical: DesignSystem.space12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.explore_outlined,
                color: DesignSystem.primary,
                size: 26,
              ),
              const SizedBox(width: DesignSystem.space12),
              Expanded(
                child: Text(
                  context.translate.qiblaDirection,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: DesignSystem.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: DesignSystem.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdhanSetting() {
    final isAndroid = Platform.isAndroid;
    final options = [
      DropdownMenuItem<String>(
        value: '',
        child: Text(
          context.translate.noAdhanSound,
          style: context.theme.textTheme.bodyLarge?.copyWith(
            color: DesignSystem.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (isAndroid)
        ..._androidAdhanOptions.map((o) => DropdownMenuItem<String>(
              value: o['rawName'] ?? '',
              child: Text(
                o['label'] ?? '',
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  color: DesignSystem.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      if (!isAndroid)
        ...AdhanAssets.options.map((o) => DropdownMenuItem<String>(
              value: o['path']!,
              child: Text(
                o['label']!,
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  color: DesignSystem.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),
    ];
    final currentValue = isAndroid
        ? (_adhanRawName.isEmpty ||
                !_androidAdhanOptions.any((o) => o['rawName'] == _adhanRawName)
            ? ''
            : _adhanRawName)
        : (_adhanAsset.isEmpty ||
                !AdhanAssets.options.any((o) => o['path'] == _adhanAsset)
            ? ''
            : _adhanAsset);
    final hasSelection =
        isAndroid ? _adhanRawName.isNotEmpty : _adhanAsset.isNotEmpty;
    return Row(
      children: [
        Icon(Icons.volume_up_outlined, color: DesignSystem.primary, size: 22),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: currentValue,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: DesignSystem.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            isExpanded: true,
            items: options,
            selectedItemBuilder: (context) => [
              Text(
                context.translate.noAdhanSound,
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  color: DesignSystem.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isAndroid)
                ..._androidAdhanOptions.map((o) => Text(
                      o['label'] ?? '',
                      style: context.theme.textTheme.bodyLarge?.copyWith(
                        color: DesignSystem.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              if (!isAndroid)
                ...AdhanAssets.options.map((o) => Text(
                      o['label']!,
                      style: context.theme.textTheme.bodyLarge?.copyWith(
                        color: DesignSystem.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
            ],
            onChanged: (v) => _onAdhanChanged(v),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.play_circle_outline),
          onPressed: !hasSelection
              ? null
              : () async {
                  if (isAndroid) {
                    try {
                      await MethodChannel(_prayerAlarmsChannel)
                          .invokeMethod<void>(
                              'playAdhan', {'rawName': _adhanRawName});
                    } catch (_) {}
                  } else {
                    AdhanAudioService.play(_adhanAsset,
                        durationMs: PrayerPrefs.adhanDurationMs);
                  }
                },
          tooltip: context.translate.playAdhan,
        ),
        IconButton(
          icon: const Icon(Icons.stop_circle_outlined),
          onPressed: () async {
            if (isAndroid) {
              try {
                await MethodChannel(_prayerAlarmsChannel)
                    .invokeMethod<void>('stopAdhan');
              } catch (_) {}
            } else {
              AdhanAudioService.stop();
            }
          },
          tooltip: context.translate.stopAdhan,
        ),
      ],
    );
  }

  Widget _buildAdhanDurationSetting() {
    final int currentDuration = PrayerPrefs.adhanDurationMs;
    final options = [
      DropdownMenuItem<int>(
          value: 30000, child: Text(context.translate.duration30Sec)),
      DropdownMenuItem<int>(
          value: 60000, child: Text(context.translate.duration1Min)),
      DropdownMenuItem<int>(
          value: 120000, child: Text(context.translate.duration2Min)),
      DropdownMenuItem<int>(
          value: 180000, child: Text(context.translate.duration3Min)),
      DropdownMenuItem<int>(
          value: -1, child: Text(context.translate.fullAdhan)),
    ];

    return Row(
      children: [
        Icon(Icons.timer_outlined, color: DesignSystem.primary, size: 22),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: options.any((o) => o.value == currentDuration)
                ? currentDuration
                : 30000,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: DesignSystem.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            isExpanded: true,
            items: options,
            onChanged: (v) async {
              if (v != null) {
                await PrayerPrefs.setAdhanDurationMs(v);
                setState(() {});
                await _rescheduleNotifications();
              }
            },
          ),
        ),
      ],
    );
  }

  String _dateHeader() {
    final now = _now;
    final lang = Localizations.localeOf(context).languageCode;
    const enMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    const kuMonths = [
      'کانوونی دووەم', 'شوبات', 'ئازار', 'نیسان', 'ئایار', 'حوزەیران',
      'تەممووز', 'ئاب', 'ئەیلوول', 'تشرینی یەکەم', 'تشرینی دووەم', 'کانوونی یەکەم'
    ];
    final mList = lang == 'ar' ? arMonths : (lang == 'ku' ? kuMonths : enMonths);
    final monthName = mList[now.month - 1];
    if (lang == 'ar' || lang == 'ku') {
      return '$monthName ${now.day}، ${now.year}';
    }
    return '$monthName ${now.day}, ${now.year}';
  }

  /// Kurdistan (main) | Include Iraq (optional) segmented control.
  Widget _buildRegionToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        border: Border.all(color: DesignSystem.outline, width: 1),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: CupertinoSlidingSegmentedControl<bool>(
        backgroundColor: DesignSystem.outline.withValues(alpha: 0.3),
        thumbColor: DesignSystem.surface,
        groupValue: _includeIraq,
        children: {
          false: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Center(
              child: Text(
                context.translate.kurdistan,
                style: context.theme.textTheme.titleSmall?.copyWith(
                  color: _includeIraq == false
                      ? DesignSystem.primary
                      : DesignSystem.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          true: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Center(
              child: Text(
                context.translate.includeIraq,
                style: context.theme.textTheme.titleSmall?.copyWith(
                  color: _includeIraq == true
                      ? DesignSystem.primary
                      : DesignSystem.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        },
        onValueChanged: (value) {
          if (value == null) return;
          HapticFeedback.lightImpact();
          setState(() => _includeIraq = value);
          GetStorage(PrayerTimesStorage.boxName)
              .write(PrayerTimesStorage.keyIncludeIraq, value);
          _hasStartedLoad = false;
          _load();
        },
      ),
    );
  }

  /// Search city by CKB (Kurdish), Arabic, or English.
  Widget _buildCitySearch() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: context.translate.searchCityHint,
        hintStyle:
            TextStyle(color: DesignSystem.onSurface.withValues(alpha: 0.5)),
        prefixIcon: Icon(Icons.search,
            color: DesignSystem.onSurface.withValues(alpha: 0.6), size: 22),
        filled: true,
        fillColor: DesignSystem.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          borderSide: BorderSide(color: DesignSystem.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          borderSide: BorderSide(color: DesignSystem.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          borderSide: BorderSide(color: DesignSystem.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: context.theme.textTheme.bodyLarge
          ?.copyWith(color: DesignSystem.onSurface),
    );
  }

  List<PrayerCountryModel> get _filteredCountries {
    if (_countrySearchQuery.trim().isEmpty) return _countries;
    return _countries
        .where((c) => c.matchesSearch(_countrySearchQuery))
        .toList();
  }

  List<PrayerCityModel> get _filteredCities {
    if (_citySearchQuery.trim().isEmpty) return _cities;
    return _cities.where((c) => c.matchesSearch(_citySearchQuery)).toList();
  }

  Widget _buildCountrySearch() {
    return TextField(
      controller: _countrySearchController,
      decoration: InputDecoration(
        hintText: context.translate.searchCountryHint,
        hintStyle:
            TextStyle(color: DesignSystem.onSurface.withValues(alpha: 0.5)),
        prefixIcon: Icon(Icons.public,
            color: DesignSystem.onSurface.withValues(alpha: 0.6), size: 22),
        filled: true,
        fillColor: DesignSystem.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          borderSide: BorderSide(color: DesignSystem.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          borderSide: BorderSide(color: DesignSystem.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          borderSide: BorderSide(color: DesignSystem.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: context.theme.textTheme.bodyLarge
          ?.copyWith(color: DesignSystem.onSurface),
    );
  }

  /// Horizontal chips for country (world DB).
  Widget _buildCountryPicker() {
    if (_countries.isEmpty) {
      return const SizedBox.shrink();
    }
    final filtered = _filteredCountries;
    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.space20,
          vertical: DesignSystem.space12,
        ),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
          border: Border.all(color: DesignSystem.outline),
        ),
        child: Text(
          '${context.translate.noCountryMatches} "$_countrySearchQuery"',
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: DesignSystem.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
    }
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filtered.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: DesignSystem.space12),
        itemBuilder: (context, index) {
          final country = filtered[index];
          final isSelected = country.iso == _selectedCountryIso;
          return _CityChip(
            label: country.displayName,
            selected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              _onCountryChanged(country.iso);
            },
          );
        },
      ),
    );
  }
}

/// Animated chip for city selection in horizontal list.
class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.space20,
          vertical: DesignSystem.space12,
        ),
        decoration: BoxDecoration(
          color: selected ? DesignSystem.primary : DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          boxShadow: DesignSystem.shadowSoft,
          border: Border.all(
            color: selected ? DesignSystem.primary : DesignSystem.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: selected ? DesignSystem.onPrimary : DesignSystem.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// One prayer row inside the mihrab frame (centered block; switch kept inside arch).
class _MihrabPrayerRow extends StatelessWidget {
  const _MihrabPrayerRow({
    required this.model,
    required this.isDay,
    required this.nameStyle,
    required this.timeStyle,
    required this.notificationOn,
    required this.onNotificationChanged,
  });

  final PrayerTimeModel model;
  final bool isDay;
  final TextStyle? nameStyle;
  final TextStyle? timeStyle;
  final bool notificationOn;
  final ValueChanged<bool> onNotificationChanged;

  static const _iconShadows = <Shadow>[
    Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Icon(
            isDay ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            size: 18,
            color: Colors.white,
            shadows: _iconShadows,
          ),
        ),
        Expanded(
          child: Text(
            model.name.translatedPrayerName(context),
            style: nameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            model.timeString,
            style: timeStyle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(
          width: 44,
          height: 36,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Switch(
              value: notificationOn,
              onChanged: onNotificationChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card container with a smooth light sweep (shimmer beam) animation.
class _LightSweepCountdownCard extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _LightSweepCountdownCard({
    required this.child,
    required this.isDark,
  });

  @override
  State<_LightSweepCountdownCard> createState() =>
      _LightSweepCountdownCardState();
}

class _LightSweepCountdownCardState extends State<_LightSweepCountdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4D3E).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isDark
                      ? [const Color(0xFF0F382C), const Color(0xFF061A14)]
                      : [const Color(0xFF1B4D3E), const Color(0xFF0E2E25)],
                ),
              ),
              child: widget.child,
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sweepController,
                  builder: (context, _) {
                    final progress = _sweepController.value;
                    final alignX = -2.0 + (progress * 4.0);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(alignX - 0.4, -1.2),
                          end: Alignment(alignX + 0.4, 1.2),
                          stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.02),
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0.02),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
