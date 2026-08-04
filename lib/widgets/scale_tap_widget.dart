import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps [child] with tap feedback: scale down to 0.97 (120 ms) and light haptic.
/// Use on cards, buttons, and nav items for premium feel.
class ScaleTapWidget extends StatefulWidget {
  const ScaleTapWidget({
    super.key,
    required this.child,
    this.onTap,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final HitTestBehavior behavior;

  @override
  State<ScaleTapWidget> createState() => _ScaleTapWidgetState();
}

class _ScaleTapWidgetState extends State<ScaleTapWidget> {
  bool _pressed = false;

  static const Duration _duration = Duration(milliseconds: 120);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: _duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
