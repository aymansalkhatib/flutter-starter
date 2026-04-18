import 'package:flutter/material.dart';

import '../logger/route_logger.dart';

/// Navigator observer that logs all route transitions via [RouteLogger].
///
/// Registered in [MaterialApp.navigatorObservers] through
/// [NavigationService.routeObserver].
class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    RouteLogger.logPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    RouteLogger.logPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    RouteLogger.logReplace(newRoute, oldRoute);
  }

  /// Fired when a route is removed mid-stack (e.g. [NavigationService.clearAndPush]).
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    RouteLogger.logRemove(route, previousRoute);
  }
}
