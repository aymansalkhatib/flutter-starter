import 'package:flutter/material.dart';
import 'package:flutter_starter/features/authentication/presentation/pages/authentication_page.dart';
import 'package:flutter_starter/features/products/presentation/pages/products_page.dart';
import 'package:flutter_starter/features/splash/screens/splash_screen.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import 'app_route.dart';
import 'page_route_animator.dart';
import 'route_guard.dart';

/// Generates routes for [MaterialApp.onGenerateRoute].
///
/// Setup:
/// ```dart
/// MaterialApp(
///   navigatorKey: NavigationService.navigatorKey,
///   initialRoute: AppRoute.splashScreen.path,
///   onGenerateRoute: RouteManager.generateRoute,
/// )
/// ```
abstract class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final route = AppRoute.fromPath(settings.name);

    // Evaluate guards — redirect if any guard triggers.
    // The original route is passed as [returnTo] so the redirect target
    // (e.g. login) can navigate back to it after completing its flow.
    final guards = _guardsFor(route);
    if (guards.isNotEmpty) {
      final redirectPath = evaluateGuards(guards);
      if (redirectPath != null) {
        return generateRoute(
          RouteSettings(
            name: redirectPath,
            arguments: {'returnTo': settings.name},
          ),
        );
      }
    }

    return switch (route) {
      AppRoute.splashScreen => PageRouteAnimator.fade(
          const SplashScreen(),
          settings,
        ),
      AppRoute.loginScreen => PageRouteAnimator.fade(
          const AuthenticationPage(),
          settings,
        ),
      AppRoute.productsScreen => PageRouteAnimator.fade(
          const ProductsPage(),
          settings,
        ),
      null => PageRouteAnimator.fade(_notFoundPage(settings), settings),
    };
  }

  // ─── Guards per route ─────────────────────────────────────────────────────

  /// Defines which guards apply to each route.
  ///
  /// To protect a route:
  /// ```dart
  /// AppRoute.homeScreen => [const AuthGuard()],
  /// ```
  ///
  /// To chain multiple guards (all must pass):
  /// ```dart
  /// AppRoute.adminScreen => [const AuthGuard(), const AdminGuard()],
  /// ```
  static List<RouteGuard> _guardsFor(AppRoute? route) => switch (route) {
        AppRoute.splashScreen => [],
        AppRoute.loginScreen => [const GuestGuard(redirectTo: AppRoute.splashScreen)],
        AppRoute.productsScreen => [const AuthGuard()],
        null => [],
      };

  // ─── Not found ────────────────────────────────────────────────────────────

  static Widget _notFoundPage(RouteSettings settings) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => Text(
            LocaleKeys.pageNotFound.tr(context),
          ),
        ),
      ),
    );
  }
}
