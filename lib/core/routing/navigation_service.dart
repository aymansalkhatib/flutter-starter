import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../observers/app_route_observer.dart';
import '../utils/app_logger.dart';
import 'app_route.dart';

/// Provides context-free navigation using the [GlobalKey<NavigatorState>]
/// registered in GetIt.
///
/// Setup:
/// ```dart
/// MaterialApp(
///   navigatorKey: sl<GlobalKey<NavigatorState>>(),
///   navigatorObservers: [NavigationService.routeObserver],
///   initialRoute: AppRoute.splashScreen.path,
///   onGenerateRoute: RouteManager.generateRoute,
/// )
/// ```
abstract class NavigationService {
  /// Route observer for navigation logging.
  static final AppRouteObserver routeObserver = AppRouteObserver();

  // ─── Navigation ────────────────────────────────────────────────────────────

  /// Pushes a named route onto the stack.
  static Future<T?> push<T>(AppRoute route, {Object? arguments}) async {
    try {
      return await _navigator?.pushNamed<T>(route.path, arguments: arguments);
    } catch (e) {
      AppLogger.error('push failed for ${route.path}',
          tag: 'NavigationService', error: e);
      return null;
    }
  }

  /// Replaces the current route.
  static Future<T?> replace<T>(AppRoute route, {Object? arguments}) async {
    try {
      return await _navigator?.pushReplacementNamed<T, dynamic>(
        route.path,
        arguments: arguments,
      );
    } catch (e) {
      AppLogger.error('replace failed for ${route.path}',
          tag: 'NavigationService', error: e);
      return null;
    }
  }

  /// Clears the entire stack and pushes a new route.
  ///
  /// Useful for logout or post-onboarding flows.
  static Future<T?> clearAndPush<T>(AppRoute route, {Object? arguments}) async {
    try {
      return await _navigator?.pushNamedAndRemoveUntil<T>(
        route.path,
        (_) => false,
        arguments: arguments,
      );
    } catch (e) {
      AppLogger.error('clearAndPush failed for ${route.path}',
          tag: 'NavigationService', error: e);
      return null;
    }
  }

  /// Pushes a new route and removes routes until [untilRoute] is reached.
  static Future<T?> pushAndRemoveUntil<T>(
    AppRoute route,
    AppRoute untilRoute, {
    Object? arguments,
  }) async {
    try {
      return await _navigator?.pushNamedAndRemoveUntil<T>(
        route.path,
        (r) => r.settings.name == untilRoute.path,
        arguments: arguments,
      );
    } catch (e) {
      AppLogger.error('pushAndRemoveUntil failed for ${route.path}',
          tag: 'NavigationService', error: e);
      return null;
    }
  }

  /// Pops the current route.
  static void pop<T>([T? result]) {
    try {
      if (_navigator?.canPop() ?? false) {
        _navigator?.pop<T>(result);
      } else {
        AppLogger.info('pop: no routes to pop');
      }
    } catch (e) {
      AppLogger.error('pop failed', tag: 'NavigationService', error: e);
    }
  }

  /// Pops if possible, otherwise calls [fallback].
  static void maybePop<T>({T? result, VoidCallback? fallback}) {
    try {
      if (_navigator?.canPop() ?? false) {
        _navigator?.pop<T>(result);
      } else {
        fallback?.call();
      }
    } catch (e) {
      AppLogger.error('maybePop failed', tag: 'NavigationService', error: e);
      fallback?.call();
    }
  }

  /// Pops until [route] is at the top of the stack.
  static void popUntil(AppRoute route) {
    try {
      _navigator?.popUntil((r) => r.settings.name == route.path);
    } catch (e) {
      AppLogger.error('popUntil failed for ${route.path}',
          tag: 'NavigationService', error: e);
    }
  }

  // ─── Guard Return ──────────────────────────────────────────────────────────

  /// Reads the [returnTo] argument injected by [RouteManager] when a guard
  /// redirects, then navigates to it (or [fallback] if absent).
  ///
  /// Call this after a successful flow completion (e.g. after login, after
  /// subscribing, after adding an address).
  ///
  /// ```dart
  /// // In LoginScreen — after successful sign-in:
  /// NavigationService.returnOrFallback(
  ///   context,
  ///   fallback: AppRoute.homeScreen,
  /// );
  /// ```
  static void returnOrFallback(
    BuildContext context, {
    required AppRoute fallback,
  }) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final returnPath = (args is Map) ? args['returnTo'] as String? : null;
    final target = AppRoute.fromPath(returnPath) ?? fallback;
    replace<void>(target);
  }

  // ─── State ─────────────────────────────────────────────────────────────────

  /// Returns `true` if the navigator can go back.
  static bool canPop() {
    try {
      return _navigator?.canPop() ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Returns the name of the current route.
  static String? getCurrentRouteName([BuildContext? context]) {
    try {
      final ctx = context ?? _context;
      if (ctx == null) {
        return null;
      }
      return ModalRoute.of(ctx)?.settings.name;
    } catch (e) {
      AppLogger.error('getCurrentRouteName failed',
          tag: 'NavigationService', error: e);
      return null;
    }
  }

  /// Returns `true` if [route] is currently at the top of the stack.
  static bool isCurrentRoute(AppRoute route, [BuildContext? context]) {
    try {
      final ctx = context ?? _context;
      if (ctx == null) {
        return false;
      }
      return ModalRoute.of(ctx)?.settings.name == route.path;
    } catch (e) {
      AppLogger.error('isCurrentRoute failed for ${route.path}',
          tag: 'NavigationService', error: e);
      return false;
    }
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  static NavigatorState? get _navigator =>
      sl<GlobalKey<NavigatorState>>().currentState;
  static BuildContext? get _context =>
      sl<GlobalKey<NavigatorState>>().currentContext;
}
