import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../constants/app_settings.dart';

enum _RouteAction { push, pop, replace, remove }

/// Structured logger for navigation events.
abstract final class RouteLogger {
  static void logPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log(_RouteAction.push, route, previousRoute);

  static void logPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log(_RouteAction.pop, route, previousRoute);

  static void logReplace(Route<dynamic>? newRoute, Route<dynamic>? oldRoute) =>
      _log(_RouteAction.replace, newRoute, oldRoute);

  static void logRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log(_RouteAction.remove, route, previousRoute);

  static void _log(
    _RouteAction action,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    if (!AppSettings.enableLogging || !AppSettings.enableRouteLogger) {
      return;
    }

    final current = route?.settings.name ?? 'unnamed';
    final previous = previousRoute?.settings.name ?? 'none';

    final (emoji, label) = switch (action) {
      _RouteAction.push    => ('📤', 'PUSH'),
      _RouteAction.pop     => ('📥', 'POP'),
      _RouteAction.replace => ('🔄', 'REPLACE'),
      _RouteAction.remove  => ('🗑️', 'REMOVE'),
    };

    dev.log(
      '$emoji [$label] $current  ←  $previous',
      name: 'Router',
    );
  }
}
