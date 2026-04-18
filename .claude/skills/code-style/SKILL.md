---
name: code-style
description: Code style rules and anti-patterns for flutter_genesis — comment discipline (write only for non-obvious why), SOLID principles, no speculative abstractions, and a concrete anti-patterns table covering dartz vs custom Either, datasource-returns-Either, e.toString() in Failure, emit vs safeEmit, state.navigateToX, Navigator.of(context).push* directly, raw-map route args, hardcoded Colors.white / TextStyle / EdgeInsets, print / AppLogger.debug, @freezed class (non-abstract), TextEditingController in StatefulWidget, AppBar in body widget, setState inside BlocConsumer. Use before finalizing any Dart file in this project.
---

# Code style

## 1. Comments

Default: **no comments**. Write one only when it captures non-obvious *why*:

```dart
// ✅ hidden constraint
// Cache miss on cold start is expected — remote is authoritative.
final cached = await _local.getCached();

// ❌ restates the code
/// Fetches the user.
Future<User> getUser() { ... }
```

Dart doc `///` only on widely consumed public API. Inline `//` only for non-obvious details.

## 2. Principles — enforced

- **SRP** — one reason to change per file.
- **OCP** — extend by adding files, not by editing unrelated ones.
- **DIP** — depend on abstractions. Repository interface in `domain`, impl in `data`.
- **DRY** — extract only when duplicated twice or more.
- **YAGNI** — build what is asked. No speculative abstractions, flags, or hooks.

## 3. Anti-patterns — stop writing these

High-signal traps that the linter won't catch.

| ❌ Anti-pattern | ✅ Correct |
|---|---|
| `import 'package:dartz/dartz.dart';` | Custom `Either` from `core/shared/either.dart` |
| `new Dio()` inside a DataSource | `sl<ApiClient>()` |
| DataSource returns `Either` | DataSource throws; Repository maps to `Either` |
| Repository lets `DioException` escape | `Left(ServerFailure.fromDioError(e))` |
| `catch (_) {}` swallows silently | `AppLogger.error(..., stackTrace: st)` then map |
| `e.toString()` in `ServerFailure.message` | `LocaleKeys.errorUnexpected` — never leak internals |
| Registering `HiveStorageService` in `sl` | Factory-cached per box; instantiate inside LocalDataSource |
| `emit(...)` directly | `safeEmit(...)` always |
| `State.error({required String message})` | `State.error({required Failure failure})` |
| `State.navigateToHome()` | Derive navigation in the `listener`, not as state |
| `Cubit.call(context, ...)` / `BuildContext` in Cubit | Cubit is UI-agnostic |
| `Navigator.of(context).push(MaterialPageRoute(...))` | `NavigationService.push(AppRoute.x, arguments: XArgs(...))` |
| `arguments: {'id': 12}` raw map | Typed `XArgs` class |
| Route registered in only 1–2 of 3 places | enum + `generateRoute` + `_guardsFor` — all three |
| `Text('Welcome')` / `Text('مرحبا')` | `LocaleKeys.welcome.tr(context)` |
| `Colors.white` / `Colors.black` | `context.colors.<token>` |
| `TextStyle(fontSize: 16, color: ...)` | `context.styles.regular16.copyWith(color: ...)` |
| `EdgeInsets.only(left: 16)` | `EdgeInsetsDirectional.only(start: 16)` |
| `MediaQuery.of(context).size.width` | `context.screenWidth` |
| Inline regex for validation | `Validator.validate*(context, v)` |
| `registerSingleton<XCubit>` | Cubit → `registerFactory` |
| `print(...)` / `debugPrint(...)` / `AppLogger.debug` | `AppLogger.info(msg, tag: 'ClassName')` |
| `@freezed class` (Freezed 3.x) | `@freezed abstract class` |
| Editing `.g.dart` / `.freezed.dart` | Fix source; wait for build_runner |
| Side effects inside `builder` | Always in `listener`; builder is pure |
| `AnimatedDotsLoader.show` from builder | Only from `listener` |
| `TextEditingController` in a `StatefulWidget` | Declare in Cubit; dispose in `close()` |
| `AppBar(...)` anywhere | `CustomAppBar(...)` |
| `Scaffold` or `AppBar` inside a body widget | Page only |
| `ListView(children: [...])` for 20+ items | `ListView.builder` |
| Sort / filter large lists in `builder` | Do it in Cubit before emitting `_Loaded` |
| `setState` inside `BlocConsumer` | Split: wrap only the stateful subtree |
| Timers / Streams not disposed | Dispose in `close()` / `dispose()` |

## 4. Structural smells

- **God widget / Cubit** — split on 3+ concerns.
- **Magic numbers** outside the spacing / radii scale — see `ux-principles`.
- **Dead code** — commented blocks, unused imports, ownerless `TODO`.
- **Copy-pasted logic** — second occurrence → move to `core/`.
- **Feature flags with no removal plan** — delete or plan the removal.
