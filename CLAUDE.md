# CLAUDE.md — `flutter_genesis`

Authoritative build contract. Detailed rules live in skills under `.claude/skills/` — this file is the **entry point and reference table**, not the rulebook.

**Rule priority when conflicts arise:** `security > architecture > no-backend > user instruction > defaults`. Surface unresolved conflicts instead of silently picking.

To scaffold a new feature end-to-end: use the `generate-feature` skill.

---

## 0. Project specifics — the single source of truth for names & paths

| Key | Value |
|-----|-------|
| Package name | `flutter_genesis` |
| State mgmt | `flutter_bloc` — Cubit preferred |
| DI container | `sl` (GetIt) — [core/di/service_locator.dart](lib/core/di/service_locator.dart) |
| HTTP client | `ApiClient` (Dio) — [core/network/api_client.dart](lib/core/network/api_client.dart) |
| Local storage | `HiveStorageService<T>` — [core/storage/hive/hive_storage_service.dart](lib/core/storage/hive/hive_storage_service.dart) |
| App box | `HiveBoxes.appBox` — [core/storage/hive/hive_boxes.dart](lib/core/storage/hive/hive_boxes.dart) |
| Logger | `AppLogger` (info / error only) — [core/utils/app_logger.dart](lib/core/utils/app_logger.dart) |
| Navigation | `NavigationService` — [core/routing/navigation_service.dart](lib/core/routing/navigation_service.dart) |
| Routes enum | `AppRoute` — [core/routing/app_route.dart](lib/core/routing/app_route.dart) |
| Route manager | [core/routing/route_manager.dart](lib/core/routing/route_manager.dart) |
| Route guards | `AuthGuard` / `GuestGuard` — [core/routing/route_guard.dart](lib/core/routing/route_guard.dart) |
| Transitions | `PageRouteAnimator` — [core/routing/page_route_animator.dart](lib/core/routing/page_route_animator.dart) |
| Either | Custom — [core/shared/either.dart](lib/core/shared/either.dart) *(not `dartz`)* |
| Failure base | [core/errors/failure.dart](lib/core/errors/failure.dart) |
| Server failure | `ServerFailure.fromDioError(e)` — [core/errors/server_failure.dart](lib/core/errors/server_failure.dart) |
| UseCase base | `Usecase<R, P>` + `NoParams` — [core/shared/usecase.dart](lib/core/shared/usecase.dart) |
| Loader overlay | `AnimatedDotsLoader` — [core/ui/components/animated_dots_loader.dart](lib/core/ui/components/animated_dots_loader.dart) |
| Theme manager | `AppThemeManager` — [core/themes/](lib/core/themes/) |
| Translation manager | `TranslationManager` — [core/localization/translation_manager.dart](lib/core/localization/translation_manager.dart) |
| Locale keys (generated) | `lib/generated/locale_keys.dart` |
| Assets (generated) | `lib/generated/assets.dart`, `fonts.dart` |
| Translation master | `assets/translations/translations.json` |
| Translation codegen | `dart helpers/translation_codegen.dart` |
| Generated locales | `assets/locales/en.json`, `assets/locales/ar.json` — **do not edit manually** |
| Hive box names | [core/constants/hive/hive_box_names.dart](lib/core/constants/hive/hive_box_names.dart) |
| Storage keys | [core/constants/hive/storage_keys.dart](lib/core/constants/hive/storage_keys.dart) |
| Environment | `EnvironmentConfig.apiBaseUrl` — [core/constants/environment_config.dart](lib/core/constants/environment_config.dart) |
| Commands | [COMMANDS.md](COMMANDS.md) |

**Import convention:** inside the same feature → relative imports. Cross-feature / core → `package:flutter_genesis/...`.

---

## 1. The 5 pre-build questions — answer before writing code

1. **Scope** — what does the feature do end-to-end?
2. **Backend** — which endpoints; request/response shapes?
3. **Caching** — any Hive? what expires it?
4. **Inputs / Outputs** — what comes in (user, route args); what leaves?
5. **Navigation** — next screen on success / error / back?

**Silent defaults to avoid:** no caching, no model, no extra states, no new routes, no new translations — unless explicitly asked.

---

## 2. Hard rules — always apply, never override

- `build_runner --watch` is running. **Never** invoke it from tool calls. If generated files look stale, tell the user.
- A new route requires **all three** edits: `AppRoute` enum + `generateRoute` switch + `_guardsFor` switch.
- Every feature owns `di/<feature>_dependencies.dart` registered in `service_locator.dart`.
- No hardcoded strings, colors, font sizes, or paddings in widget code.
- `@freezed` classes are always declared `abstract class` (Freezed 3.x).
- Every user-visible String flows through `.tr(context)`.
- Use custom `Either` from `core/shared/either.dart` — never `dartz`.
- Cubits never touch `BuildContext`, `NavigationService`, dialogs, or snackbars.
- Never use Flutter's `AppBar` directly — always `CustomAppBar`.
- Never place `Scaffold` or `AppBar` inside a body widget — page only.

---

## 3. Skill index — where to find the rules

Skills load on demand. Pick the right one for the task; don't load what you don't need.

| Skill | Use it when |
|---|---|
| `architecture` | Deciding where a file goes; layer dependency direction; feature folder structure; no-backend features |
| `domain-layer` | Creating/editing under `features/*/domain/` — Entity, UseCase + Params, Repository interface |
| `data-layer` | Creating/editing under `features/*/data/` — DataSources, RepositoryImpl, Either boundary, error codes, timeouts |
| `presentation-layer` | Creating/editing under `features/*/presentation/` — Cubit, State, Page/Body split, BlocConsumer |
| `hive-caching` | Adding or modifying local caching — box names, `@HiveType` / `@HiveField`, schema migration, invalidation |
| `security` | Tokens, PII, encrypted storage, cert pinning, logging, input sanitization, deep links, FCM/Google Auth |
| `navigation` | Adding/modifying routes, guards, transitions, typed route args, `NavigationService` calls |
| `di-registration` | Writing `di/<feature>_dependencies.dart` or editing `service_locator.dart` |
| `translations` | Adding user-visible text — keys in `translations.json` + codegen workflow |
| `theming` | Any styling decision — `context.colors`, `context.styles`, `.sp(context)`, padding extensions, dark/RTL |
| `ui-components` | Before writing a new widget — check the core components catalog first |
| `validation` | Adding/editing a `TextFormField` validator — use `Validator.*`, never inline regex |
| `code-style` | Before finishing any Dart file — anti-patterns checklist |
| `ux-principles` | Designing a screen — hierarchy, spacing grid, color, motion, five states, accessibility |
| `generate-feature` | Scaffolding a whole new feature end-to-end — intake + generation order |
| `migrate-packages` | Printing `flutter pub add` commands from `pubspec.yaml` |
