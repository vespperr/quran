import 'package:flutter/material.dart';

/// A reusable widget that overlays a smooth, premium light-sweep (shimmer beam) animation over its child.
class LightSweepContainer extends StatefulWidget {
  const LightSweepContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.sweepColor,
    this.sweepDuration = const Duration(milliseconds: 3500),
    this.enabled = true,
    this.maxAlpha = 0.18,
    this.decoration,
    this.padding,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color? sweepColor;
  final Duration sweepDuration;
  final bool enabled;
  final double maxAlpha;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;

  @override
  State<LightSweepContainer> createState() => _LightSweepContainerState();
}

class _LightSweepContainerState extends State<LightSweepContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    );
    if (widget.enabled) {
      _sweepController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LightSweepContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _sweepController.repeat();
      } else {
        _sweepController.stop();
      }
    }
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return Container(
        decoration: widget.decoration,
        padding: widget.padding,
        child: widget.child,
      );
    }

    final beamColor = widget.sweepColor ?? Colors.white;

    return Container(
      decoration: widget.decoration,
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sweepController,
                  builder: (context, _) {
                    final progress = _sweepController.value;
                    final alignX = -2.5 + (progress * 5.0);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(alignX - 0.4, -1.2),
                          end: Alignment(alignX + 0.4, 1.2),
                          stops: const [0.0, 0.42, 0.5, 0.58, 1.0],
                          colors: [
                            Colors.transparent,
                            beamColor.withValues(alpha: widget.maxAlpha * 0.1),
                            beamColor.withValues(alpha: widget.maxAlpha),
                            beamColor.withValues(alpha: widget.maxAlpha * 0.1),
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

/// A widget that applies a pure white light-sweep (shimmer beam) animation specifically over its Text child character glyphs.
class LightSweepText extends StatefulWidget {
  const LightSweepText({
    super.key,
    required this.child,
    required this.baseColor,
    this.sweepColor = Colors.white,
    this.sweepDuration = const Duration(milliseconds: 3500),
    this.enabled = true,
  });

  final Widget child;
  final Color baseColor;
  final Color sweepColor;
  final Duration sweepDuration;
  final bool enabled;

  @override
  State<LightSweepText> createState() => _LightSweepTextState();
}

class _LightSweepTextState extends State<LightSweepText>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    );
    if (widget.enabled) {
      _sweepController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LightSweepText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _sweepController.repeat();
      } else {
        _sweepController.stop();
      }
    }
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _sweepController,
      builder: (context, child) {
        final progress = _sweepController.value;
        final alignX = -2.5 + (progress * 5.0);

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(alignX - 0.4, -1.2),
              end: Alignment(alignX + 0.4, 1.2),
              stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.sweepColor,
                widget.baseColor,
                widget.baseColor,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
