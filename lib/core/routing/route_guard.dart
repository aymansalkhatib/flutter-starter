import '../constants/hive/storage_keys.dart';
import '../storage/hive/hive_boxes.dart';
import 'app_route.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RouteGuard — interface
// ─────────────────────────────────────────────────────────────────────────────

/// Base interface for all route guards.
///
/// Each guard returns the path to redirect to, or `null` to allow navigation.
abstract interface class RouteGuard {
  String? redirect();
}

/// Runs [guards] in order. Returns the first redirect path, or `null` if all
/// guards pass.
///
/// Usage — single guard:
/// ```dart
/// evaluateGuards([const AuthGuard()])
/// ```
///
/// Usage — chained guards (all must pass):
/// ```dart
/// evaluateGuards([const AuthGuard(), const OnboardingGuard()])
/// ```
String? evaluateGuards(List<RouteGuard> guards) {
  for (final guard in guards) {
    final path = guard.redirect();
    if (path != null) {
      return path;
    }
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in Guards
// ─────────────────────────────────────────────────────────────────────────────

/// Blocks unauthenticated users.
///
/// Redirects to [redirectTo] if no auth token is found.
/// Apply to protected routes (home, profile, settings…).
class AuthGuard implements RouteGuard {
  const AuthGuard({this.redirectTo = AppRoute.loginScreen});

  final AppRoute redirectTo;

  @override
  String? redirect() {
    final token = HiveBoxes.appBox.get(StorageKeys.authToken) as String?;
    return (token != null && token.isNotEmpty) ? null : redirectTo.path;
  }
}

/// Blocks already-authenticated users.
///
/// Redirects to [redirectTo] if an auth token already exists.
/// Apply to guest-only routes (splash, login, register…).
class GuestGuard implements RouteGuard {
  const GuestGuard({required this.redirectTo});

  final AppRoute redirectTo;

  @override
  String? redirect() {
    final token = HiveBoxes.appBox.get(StorageKeys.authToken) as String?;
    return (token != null && token.isNotEmpty) ? redirectTo.path : null;
  }
}
