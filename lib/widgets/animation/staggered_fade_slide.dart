import 'package:flutter/material.dart';

/// Wraps [child] with a staggered fade-in + slide-up animation.
/// [index] controls delay (index * 40ms). Duration 200ms, easeOutCubic.
class StaggeredFadeSlide extends StatefulWidget {
  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  static const int _delayMs = 40;
  static const int _durationMs = 200;

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: StaggeredFadeSlide._durationMs),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 24),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(
      Duration(milliseconds: widget.index * StaggeredFadeSlide._delayMs),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _offset.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
