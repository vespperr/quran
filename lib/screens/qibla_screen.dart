import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/utils/qibla_utils.dart';
import 'package:the_open_quran/widgets/app_bars/primary_app_bar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_open_quran/constants/prayer_times_storage.dart';

/// Full-screen Qibla direction: compass with arrow pointing to Kaaba.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver {
  double? _heading; // device compass 0–360 (North = 0)
  double? _qiblaBearing;
  String? _error;
  bool _locationDenied = false;
  StreamSubscription<CompassEvent>? _compassSub;
  bool _wasAligned = false;
  bool _useGps = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _useGps =
        GetStorage(PrayerTimesStorage.boxName).read('qibla_use_gps') ?? true;

    if (!_useGps) {
      _calculateQiblaForCity();
    } else {
      _qiblaBearing = qiblaBearingFrom(kDefaultLat, kDefaultLon);
    }
    _startCompass();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_useGps) {
        _requestLocationPermissionManually();
      }
    });
  }

  void _calculateQiblaForCity() {
    final cityName = GetStorage(PrayerTimesStorage.boxName)
            .read(PrayerTimesStorage.keyCity) ??
        'Kalar';
    final coords = kCityCoordinates[cityName];
    if (coords != null) {
      setState(() {
        _qiblaBearing = qiblaBearingFrom(coords[0], coords[1]);
        _error = null;
        _locationDenied = false;
      });
    } else {
      setState(() {
        _qiblaBearing = qiblaBearingFrom(kDefaultLat, kDefaultLon);
        _error = null;
        _locationDenied = false;
      });
    }
  }

  void _startCompass() {
    try {
      if (FlutterCompass.events != null) {
        _compassSub = FlutterCompass.events!.listen((e) {
          if (mounted && e.heading != null) {
            setState(() {
              _heading = e.heading;
            });

            if (_qiblaBearing != null && _heading != null) {
              double diff = (_heading! - _qiblaBearing!).abs() % 360;
              if (diff > 180) diff = 360 - diff;

              final isAligned = diff < 2.0;

              if (isAligned && !_wasAligned) {
                HapticFeedback.heavyImpact();
              }
              _wasAligned = isAligned;
            }
          }
        }, onError: (_) {});
      } else {
        _setFallbackHeadingValues();
      }
    } catch (_) {
      _setFallbackHeadingValues();
    }
  }

  void _setFallbackHeadingValues() {
    setState(() {
      _heading = 0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_useGps && (_error != null || _locationDenied)) {
        _requestLocationPermissionManually();
      }
    }
  }

  Future<void> _requestLocationPermissionManually(
      {bool isUserAction = false}) async {
    if (!mounted) return;
    setState(() {
      _error = null;
    });

    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever && isUserAction) {
        await Geolocator.openAppSettings();
        return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _locationDenied = true;
            _error = "Location services are turned off. Please enable GPS.";
          });
          return;
        }

        final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium),
        );

        if (mounted) {
          setState(() {
            _qiblaBearing = qiblaBearingFrom(pos.latitude, pos.longitude);
            _locationDenied = false;
            _error = null;
          });
        }
      } else if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationDenied = true;
          _error = "Location permission permanently denied.";
        });
      } else {
        setState(() {
          _locationDenied = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationDenied = true;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Widget _buildLoadingCompass() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            constraints.maxWidth < 360 ? constraints.maxWidth - 32.0 : 320.0;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(DesignSystem.screenPadding),
          child: Column(
            children: [
              Text(
                context.translate.qiblaDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DesignSystem.onSurface.withValues(alpha: 0.85),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.space24),
              Shimmer.fromColors(
                baseColor: DesignSystem.outline.withValues(alpha: 0.3),
                highlightColor: DesignSystem.outline.withValues(alpha: 0.1),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DesignSystem.surface,
                        border: Border.all(
                          color: DesignSystem.outline.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).appBarTheme.iconTheme?.color ??
        Theme.of(context).iconTheme.color ??
        DesignSystem.onSurface;
    return Scaffold(
      appBar: PrimaryAppBar(
        title: context.translate.qiblaDirection,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _heading == null ? _buildLoadingCompass() : _buildBody(),
    );
  }

  Widget _buildBody() {
    final qibla = _qiblaBearing ?? 0.0;
    final heading = _heading ?? 0.0;

    final ringRotation = -heading * math.pi / 180;
    final arrowRotation = (qibla - heading) * math.pi / 180;

    double diff = (heading - qibla).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    final isAligned = diff < 2.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            constraints.maxWidth < 360 ? constraints.maxWidth - 32.0 : 320.0;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(DesignSystem.screenPadding),
          child: Column(
            children: [
              if (_error != null && _error!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignSystem.space12),
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Text(
                context.translate.qiblaDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DesignSystem.onSurface.withValues(alpha: 0.85),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.space24),

              // No Tap Handlers Here. It is impossible to click this now.
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.primary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: ringRotation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  DesignSystem.surface,
                                  DesignSystem.surface.withValues(alpha: 0.98),
                                ],
                              ),
                              border: Border.all(
                                color:
                                    DesignSystem.outline.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: CustomPaint(
                              size: Size(size, size),
                              painter: _CompassRingPainter(),
                            ),
                          ),
                          _CompassLabels(size: size),
                          CustomPaint(
                            size: Size(size, size),
                            painter: _CompassDegreeLabelsPainter(),
                          ),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: arrowRotation,
                      child: CustomPaint(
                        size: Size(size, size),
                        painter: _QiblaArrowPainter(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignSystem.space24),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.space20,
                  vertical: DesignSystem.space12,
                ),
                decoration: BoxDecoration(
                  color: isAligned
                      ? Colors.green.withValues(alpha: 0.15)
                      : DesignSystem.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                  border: Border.all(
                    color: isAligned
                        ? Colors.green.withValues(alpha: 0.6)
                        : DesignSystem.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAligned
                          ? Icons.check_circle_rounded
                          : Icons.explore_rounded,
                      color: isAligned ? Colors.green : DesignSystem.primary,
                      size: 32,
                    ),
                    const SizedBox(width: DesignSystem.space16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qibla: ${qibla.toStringAsFixed(0)}°',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isAligned
                                ? Colors.green.shade700
                                : DesignSystem.primary,
                            fontWeight: FontWeight.w900,
                            fontFeatures: const [
                              ui.FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                        Text(
                          'Heading: ${heading.toStringAsFixed(0)}°',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isAligned
                                ? Colors.green.shade700.withValues(alpha: 0.8)
                                : DesignSystem.primary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [
                              ui.FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignSystem.space24),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.screenPadding),
                child: Text(
                  context.translate.qiblaCompassHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DesignSystem.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
              const SizedBox(height: DesignSystem.space24),

              Container(
                decoration: BoxDecoration(
                  color: DesignSystem.surface,
                  borderRadius:
                      BorderRadius.circular(DesignSystem.cornerRadius),
                  border: Border.all(
                    color: DesignSystem.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    "Automatic (GPS)",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: DesignSystem.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    "Turn off to use your selected city",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DesignSystem.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  value: _useGps,
                  activeThumbColor: DesignSystem.primary,
                  onChanged: (val) {
                    setState(() {
                      _useGps = val;
                      GetStorage(PrayerTimesStorage.boxName)
                          .write('qibla_use_gps', val);
                    });
                    if (val) {
                      _requestLocationPermissionManually(isUserAction: true);
                    } else {
                      _calculateQiblaForCity();
                    }
                  },
                ),
              ),
              const SizedBox(height: DesignSystem.space12),

              if (_useGps && (_locationDenied || _error != null))
                FilledButton.icon(
                  onPressed: () =>
                      _requestLocationPermissionManually(isUserAction: true),
                  icon: const Icon(Icons.location_on_outlined, size: 20),
                  label: Text(context.translate.enableLocationForAccuracy),
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignSystem.primary,
                    foregroundColor: DesignSystem.onPrimary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    for (var deg = 0; deg < 360; deg += 15) {
      final rad = (deg - 90) * math.pi / 180;

      final isCardinal = deg % 90 == 0;
      final isHalf = deg % 45 == 0 && !isCardinal;

      final innerRadiusOffset = isCardinal ? 16 : (isHalf ? 12 : 8);
      final inner = radius - innerRadiusOffset;
      final outer = radius;

      final tickPaint = Paint()
        ..color = DesignSystem.outline.withValues(alpha: isCardinal ? 0.7 : 0.4)
        ..strokeWidth = isCardinal ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(center.dx + inner * math.cos(rad),
            center.dy + inner * math.sin(rad)),
        Offset(center.dx + outer * math.cos(rad),
            center.dy + outer * math.sin(rad)),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassDegreeLabelsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final labelRadius = radius - 28;

    for (var deg = 30; deg < 360; deg += 30) {
      if (deg % 90 == 0) continue;

      canvas.save();
      final rad = deg * math.pi / 180;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rad);
      canvas.translate(0, -labelRadius);

      final tp = TextPainter(
        text: TextSpan(
          text: '$deg',
          style: TextStyle(
            color: DesignSystem.onSurface.withValues(alpha: 0.65),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassLabels extends StatelessWidget {
  const _CompassLabels({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final northStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.redAccent.shade400,
          fontWeight: FontWeight.w900,
          fontSize: 26,
          height: 1.0,
        );

    final secondary = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: DesignSystem.onSurface.withValues(alpha: 0.65),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        );

    const double inset = 16.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(top: inset, child: Text('N', style: northStyle)),
        Positioned(right: inset, child: Text('E', style: secondary)),
        Positioned(bottom: inset, child: Text('S', style: secondary)),
        Positioned(left: inset, child: Text('W', style: secondary)),
      ],
    );
  }
}

class _QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final arrowLength = size.width * 0.38;
    final arrowWidth = 14.0;

    final topTip = Offset(cx, cy - arrowLength);
    final bottomTip = Offset(cx, cy + arrowLength);
    final leftMid = Offset(cx - arrowWidth, cy);
    final rightMid = Offset(cx + arrowWidth, cy);

    final topLeftPath = Path()
      ..moveTo(topTip.dx, topTip.dy)
      ..lineTo(leftMid.dx, leftMid.dy)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(topLeftPath, Paint()..color = DesignSystem.primary);

    final topRightPath = Path()
      ..moveTo(topTip.dx, topTip.dy)
      ..lineTo(rightMid.dx, rightMid.dy)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(
      topRightPath,
      Paint()..color = Color.lerp(DesignSystem.primary, Colors.black, 0.25)!,
    );

    final bottomLeftPath = Path()
      ..moveTo(bottomTip.dx, bottomTip.dy)
      ..lineTo(leftMid.dx, leftMid.dy)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(bottomLeftPath, Paint()..color = Colors.grey.shade400);

    final bottomRightPath = Path()
      ..moveTo(bottomTip.dx, bottomTip.dy)
      ..lineTo(rightMid.dx, rightMid.dy)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(bottomRightPath, Paint()..color = Colors.grey.shade500);

    canvas.drawCircle(
      Offset(cx, cy),
      8,
      Paint()..color = DesignSystem.surface,
    );

    canvas.drawCircle(
      Offset(cx, cy),
      4,
      Paint()..color = DesignSystem.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
