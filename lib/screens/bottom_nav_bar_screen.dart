import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; //asking access for location
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/l10n/app_localizations.dart';
import 'package:the_open_quran/screens/settings_screen.dart';
import 'package:the_open_quran/services/prayer_notification_service.dart';

import '../widgets/bottom_sheets/design_bottom_sheet.dart';
import '../providers/home_provider.dart';
import '../providers/more_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/cards/slidable_verse_card/slidable_provider.dart';
import 'home_screen.dart';
import 'pdf_books_screen.dart';
import 'prayer_times_screen.dart';
import 'thikr_screen.dart';

/// Responsive values for bottom nav: scales with screen width and safe area.
class _NavBarMetrics {
  const _NavBarMetrics._({
    required this.notchRadius,
    required this.fabSize,
    required this.barHeight,
    required this.bottomPadding,
    required this.iconSize,
    required this.fabIconSize,
  });

  final double notchRadius;
  final double fabSize;
  final double barHeight;
  final double bottomPadding;
  final double iconSize;
  final double fabIconSize;

  factory _NavBarMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final width = size.width;

    final notchRadius = (width.clamp(280.0, 500.0) * 0.095).clamp(28.0, 40.0);
    final fabSize = (width * 0.14).clamp(48.0, 60.0);
    final barContentHeight = 62.0;
    final bottomPadding = padding.bottom;
    final iconSize = (width * 0.065).clamp(22.0, 28.0);
    final fabIconSize = (fabSize * 0.5).clamp(24.0, 30.0);

    return _NavBarMetrics._(
      notchRadius: notchRadius,
      fabSize: fabSize,
      barHeight: barContentHeight,
      bottomPadding: bottomPadding,
      iconSize: iconSize,
      fabIconSize: fabIconSize,
    );
  }

  double get totalBarHeight => barHeight + bottomPadding;
  double get fabBottomOffset => totalBarHeight - fabSize / 2;
}

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key, this.routeObserver});

  final RouteObserver<ModalRoute<void>>? routeObserver;

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> with RouteAware {
  /// Current index of bottom navigation bar: defaults to 2 (Prayer Times)
  int currentIndex = 2;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrayerNotificationService.handleLaunchFromNotification();
      Geolocator.requestPermission();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe only once; re-subscribing in didChangeDependencies can trigger RouteObserver assertions.
    if (_subscribed) return;
    final observer = widget.routeObserver;
    final route = ModalRoute.of(context);
    if (observer != null && route != null) {
      observer.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    if (_subscribed) {
      widget.routeObserver?.unsubscribe(this);
      _subscribed = false;
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // When returning from a pushed route (e.g. Prayer Times full screen), force rebuild so content repaints and avoids black screen.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => HomeProvider(context), lazy: false),
        ChangeNotifierProvider(create: (_) => MoreProvider(context)),
        ChangeNotifierProvider(create: (_) => SearchProvider(context)),
        ChangeNotifierProvider(create: (_) => SlidableProvider(context)),
      ],
      child: Scaffold(
        body: buildBody,
        bottomNavigationBar: buildBottomNavigationBar,
      ),
    );
  }

  /// Bar has 5 items: [Quran, Thikr(FAB), Library, Prayer, Settings]. Pages: 0=Quran, 1=Library, 2=Prayer, 3=Settings. Thikr opens sheet.
  int get _selectedBarIndex => currentIndex == 0 ? 0 : currentIndex == 1 ? 2 : currentIndex == 2 ? 3 : 4;

  Widget get buildBody {
    return IndexedStack(
      index: currentIndex,
      sizing: StackFit.expand,
      children: [
        const HomeScreen(),
        const PdfBooksScreen(),
        PrayerTimesScreen(selected: currentIndex == 2),
        const SettingsScreen(),
      ],
    );
  }

  void _onTabTap(int rawIndex) {
    HapticFeedback.lightImpact();
    if (rawIndex == 1) {
      DesignBottomSheet.show<void>(
        context,
        child: ThikrScreen(selected: true, inSheet: true),
        showHandle: false,
      ).then((_) {});
      return;
    }
    if (rawIndex == 0) setState(() => currentIndex = 0);
    if (rawIndex == 2) setState(() => currentIndex = 1); // Library
    if (rawIndex == 3) setState(() => currentIndex = 2); // Prayer
    if (rawIndex == 4) setState(() => currentIndex = 3); // Settings
  }

  Widget get buildBottomNavigationBar {
    final t = context.translate;
    final metrics = _NavBarMetrics.of(context);
    // Always LTR order: Quran, Library, Prayer, Settings (left to right) regardless of app language.
    const tabOrder = [0, 2, 3, 4];

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        PhysicalShape(
          color: DesignSystem.surface,
          elevation: 16.0,
          clipper: _NavBarNotchedClipper(radius: metrics.notchRadius),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: metrics.totalBarHeight,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 4,
                  bottom: metrics.bottomPadding,
                ),
                // Use LTR so Row layout is always left-to-right; we control order via tabOrder.
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Expanded(child: _buildNavTab(0, tabOrder[0], tabOrder[0] == _selectedBarIndex, t, metrics.iconSize)),
                      Expanded(child: _buildNavTab(2, tabOrder[1], tabOrder[1] == _selectedBarIndex, t, metrics.iconSize)),
                      SizedBox(width: metrics.notchRadius * 2),
                      Expanded(child: _buildNavTab(3, tabOrder[2], tabOrder[2] == _selectedBarIndex, t, metrics.iconSize)),
                      Expanded(child: _buildNavTab(4, tabOrder[3], tabOrder[3] == _selectedBarIndex, t, metrics.iconSize)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: metrics.fabBottomOffset),
          child: _CenterFab(
            size: metrics.fabSize,
            iconSize: metrics.fabIconSize,
            onTap: () => _onTabTap(1),
          ),
        ),
      ],
    );
  }

  Widget _buildNavTab(int displayIndex, int rawIndex, bool selected, AppLocalizations t, double iconSize) {
    return _NavTab(
      selected: selected,
      onTap: () => _onTabTap(rawIndex),
      icon: _buildTabIcon(rawIndex, selected, iconSize),
      label: _tabLabel(rawIndex, t),
    );
  }

  Widget _buildTabIcon(int rawIndex, bool selected, double iconSize) {
    final color = selected ? DesignSystem.primary : DesignSystem.onSurface.withValues(alpha: 0.6);
    switch (rawIndex) {
      case 0:
        return SvgPicture.asset(
          ImageConstants.quranNavIcon,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 2:
        return Icon(
          selected ? Icons.menu_book : Icons.menu_book_outlined,
          size: iconSize,
          color: color,
        );
      case 3:
        return ColorFiltered(
          colorFilter: ColorFilter.mode(color, BlendMode.modulate),
          child: Image.asset(
            ImageConstants.prayerTimesIcon,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.schedule, size: iconSize, color: color),
          ),
        );
      case 4:
        return Icon(
          selected ? Icons.tune : Icons.tune_rounded,
          size: iconSize,
          color: color,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _tabLabel(int rawIndex, AppLocalizations t) {
    switch (rawIndex) {
      case 0: return t.quran;
      case 2: return t.library;
      case 3: return t.prayer;
      case 4: return t.settings;
      default: return '';
    }
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.theme.textTheme.labelSmall?.copyWith(
                color: selected ? DesignSystem.primary : DesignSystem.onSurface.withValues(alpha: 0.6),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
    );
  }
}

/// Notched bar: rounded top corners + center curved cutout for FAB.
class _NavBarNotchedClipper extends CustomClipper<Path> {
  _NavBarNotchedClipper({this.radius = 38.0});
  final double radius;

  double _deg2rad(double deg) => (math.pi / 180) * deg;

  @override
  Path getClip(Size size) {
    final path = Path();
    final v = radius * 2;
    final cx = size.width / 2;
    path.lineTo(0, 0);
    path.arcTo(Rect.fromLTWH(0, 0, radius, radius), _deg2rad(180), _deg2rad(90), false);
    path.arcTo(
      Rect.fromLTWH((cx - v / 2) - radius + v * 0.04, 0, radius, radius),
      _deg2rad(270), _deg2rad(70), false,
    );
    path.arcTo(
      Rect.fromLTWH(cx - v / 2, -v / 2, v, v),
      _deg2rad(160), _deg2rad(-140), false,
    );
    path.arcTo(
      Rect.fromLTWH(cx + v / 2 - v * 0.04, 0, radius, radius),
      _deg2rad(200), _deg2rad(70), false,
    );
    path.arcTo(Rect.fromLTWH(size.width - radius, 0, radius, radius), _deg2rad(270), _deg2rad(90), false);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_NavBarNotchedClipper oldClipper) => oldClipper.radius != radius;
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.size, required this.iconSize, required this.onTap});
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignSystem.primary,
            boxShadow: [
              BoxShadow(
                color: DesignSystem.primary.withValues(alpha: 0.4),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Image.asset(
            ImageConstants.athkarsNavIcon,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            color: DesignSystem.onPrimary,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (_, __, ___) => Icon(Icons.favorite, color: DesignSystem.onPrimary, size: iconSize),
          ),
        ),
      ),
    );
  }
}
