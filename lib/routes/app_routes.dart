import 'package:flutter/material.dart';

/// Premium app transitions: fade + vertical slide (8–12 px from bottom),
/// 220–260 ms, easeOutCubic. Use for all full-screen pushes.
class AppRoutes {
  AppRoutes._();

  static const Duration _duration = Duration(milliseconds: 240);
  static const Curve _curve = Curves.easeOutCubic;

  /// Returns a [PageRoute] that fades in and slides up slightly.
  static PageRoute<T> fadeSlideRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: _curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
