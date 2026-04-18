import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PageTransitionType
// ─────────────────────────────────────────────────────────────────────────────

enum PageTransitionType { fade, slide, scale }

enum SlideDirection { right, left, up, down }

// ─────────────────────────────────────────────────────────────────────────────
// PageRouteAnimator
// ─────────────────────────────────────────────────────────────────────────────

/// Builds page transitions.
///
/// Shortcuts:
/// ```dart
/// PageRouteAnimator.fade(page, settings)
/// PageRouteAnimator.slide(page, settings)
/// PageRouteAnimator.scale(page, settings)
/// ```
abstract class PageRouteAnimator {
  static const Duration _fast = Duration(milliseconds: 250);
  static const Duration _normal = Duration(milliseconds: 400);

  // ─── Shortcuts ─────────────────────────────────────────────────────────────

  static Route<dynamic> fade(Widget page, RouteSettings settings) =>
      _build(page, settings, type: PageTransitionType.fade, duration: _fast);

  static Route<dynamic> slide(
    Widget page,
    RouteSettings settings, {
    SlideDirection direction = SlideDirection.right,
  }) =>
      _build(page, settings, type: PageTransitionType.slide, direction: direction);

  static Route<dynamic> scale(Widget page, RouteSettings settings) =>
      _build(page, settings, type: PageTransitionType.scale);

  // ─── Builder ───────────────────────────────────────────────────────────────

  static Route<dynamic> _build(
    Widget page,
    RouteSettings settings, {
    required PageTransitionType type,
    SlideDirection direction = SlideDirection.right,
    Duration duration = _normal,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: Duration(
        milliseconds: (duration.inMilliseconds * 0.7).round(),
      ),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          _transition(type, direction, animation, child),
    );
  }

  static Widget _transition(
    PageTransitionType type,
    SlideDirection direction,
    Animation<double> animation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return switch (type) {
      PageTransitionType.fade => FadeTransition(opacity: curved, child: child),
      PageTransitionType.slide => SlideTransition(
        position: Tween<Offset>(
          begin: _slideOffset(direction),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6),
            ),
          ),
          child: child,
        ),
      ),
      PageTransitionType.scale => ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      ),
    };
  }

  static Offset _slideOffset(SlideDirection direction) => switch (direction) {
    SlideDirection.right => const Offset(1.0, 0.0),
    SlideDirection.left  => const Offset(-1.0, 0.0),
    SlideDirection.up    => const Offset(0.0, 1.0),
    SlideDirection.down  => const Offset(0.0, -1.0),
  };
}
