---
name: navigation
description: Rules for navigation in flutter_genesis — typed route argument classes (no raw Maps), the three-edit rule (AppRoute enum + generateRoute switch + _guardsFor switch), NavigationService API, route guards (AuthGuard / GuestGuard / custom), PageRouteAnimator transitions, and returnOrFallback after guard redirects. Use when adding or modifying any route, writing navigation calls, or creating route guards.
---

# Navigation

## 1. Route arguments — typed classes, never raw Maps

Always a typed class, even for a single field.

```dart
// lib/features/otp/presentation/args/otp_args.dart
class OtpArgs {
  final String phoneNumber;
  const OtpArgs({required this.phoneNumber});
}
```

Read in the destination page:

```dart
final args = ModalRoute.of(context)?.settings.arguments as OtpArgs;
```

For external-source args (deep links, push payloads), see `security` skill §5.

## 2. Adding a route — **all three edits required**

### a. `AppRoute` enum — [core/routing/app_route.dart](../../../lib/core/routing/app_route.dart)

```dart
enum AppRoute {
  splashScreen('/'),
  loginScreen('/login'),
  featureScreen('/feature'); // ← add
}
```

### b. `generateRoute` switch — [core/routing/route_manager.dart](../../../lib/core/routing/route_manager.dart)

```dart
AppRoute.featureScreen => PageRouteAnimator.fade(const FeaturePage(), settings),
```

### c. `_guardsFor` switch — same file

```dart
AppRoute.featureScreen => [const AuthGuard()], // or [] if public
```

**A route missing from any of the three = broken route.**

## 3. `NavigationService` API

| Intent | Call |
|--------|------|
| Push onto stack | `NavigationService.push(AppRoute.x, arguments: XArgs(...))` |
| Replace current | `NavigationService.replace(AppRoute.x)` |
| Clear stack then push | `NavigationService.clearAndPush(AppRoute.home)` — logout / post-onboarding |
| Push & remove until | `NavigationService.pushAndRemoveUntil(AppRoute.x, AppRoute.home)` |
| Pop | `NavigationService.pop()` |
| Pop or fallback | `NavigationService.maybePop(fallback: () => ...)` |
| Pop until | `NavigationService.popUntil(AppRoute.home)` |
| Return to guard origin | `NavigationService.returnOrFallback(context, fallback: AppRoute.home)` |

**Never** call `Navigator.of(context).push*` directly.

## 4. Transitions — `PageRouteAnimator`

- `PageRouteAnimator.fade(page, settings)` — default
- `PageRouteAnimator.slide(page, settings, direction: SlideDirection.right)`
- `PageRouteAnimator.scale(page, settings)`

## 5. Route guards

Built-ins: `AuthGuard` (blocks unauthenticated), `GuestGuard` (blocks already-signed-in). Create new guards by implementing `RouteGuard.redirect()`. Chain in `_guardsFor` — **all must pass**.

After the redirect target completes its flow, call:

```dart
NavigationService.returnOrFallback(context, fallback: AppRoute.home);
```

The guard attaches `returnTo` automatically; `returnOrFallback` resumes the original destination.
