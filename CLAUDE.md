# CLAUDE.md — Flutter Clean Architecture Standards

The authoritative build contract for this repository.
Every rule here is enforced. When a user request conflicts with a rule, **ask before deviating**.

For generating a new feature end-to-end, use the `/generate-feature` skill.

When rules conflict: **security (§8.5) > architecture (§2) > no-backend (§4) > user instruction > defaults.** Surface unresolved conflicts.

---

## 0. Project Specifics

| Key | Value |
|-----|-------|
| Package name | `flutter_genesis` |
| State mgmt | `flutter_bloc` — Cubit preferred over Bloc |
| DI container | `sl` (GetIt) — [core/di/service_locator.dart](lib/core/di/service_locator.dart) |
| HTTP client | `ApiClient` (Dio) — [core/network/api_client.dart](lib/core/network/api_client.dart) |
| Local storage | `HiveStorageService<T>` — [core/storage/hive/hive_storage_service.dart](lib/core/storage/hive/hive_storage_service.dart) |
| App boxes | `HiveBoxes.appBox` — [core/storage/hive/hive_boxes.dart](lib/core/storage/hive/hive_boxes.dart) |
| Logger | `AppLogger` (info / error only) — [core/utils/app_logger.dart](lib/core/utils/app_logger.dart) |
| Navigation | `NavigationService` — [core/routing/navigation_service.dart](lib/core/routing/navigation_service.dart) |
| Routes enum | `AppRoute` — [core/routing/app_route.dart](lib/core/routing/app_route.dart) |
| Route manager | [core/routing/route_manager.dart](lib/core/routing/route_manager.dart) |
| Route guards | `RouteGuard` / `AuthGuard` / `GuestGuard` — [core/routing/route_guard.dart](lib/core/routing/route_guard.dart) |
| Page transitions | `PageRouteAnimator` — [core/routing/page_route_animator.dart](lib/core/routing/page_route_animator.dart) |
| Either | Custom — [core/shared/either.dart](lib/core/shared/either.dart) *(not `dartz`)* |
| Failure base | [core/errors/failure.dart](lib/core/errors/failure.dart) |
| Server failure | `ServerFailure.fromDioError(e)` — [core/errors/server_failure.dart](lib/core/errors/server_failure.dart) |
| Storage exception | [core/errors/storage_exception.dart](lib/core/errors/storage_exception.dart) |
| UseCase base | `Usecase<R, P>` + `NoParams` — [core/shared/usecase.dart](lib/core/shared/usecase.dart) |
| Loader overlay | `AnimatedDotsLoader` — [core/ui/components/animated_dots_loader.dart](lib/core/ui/components/animated_dots_loader.dart) |
| Theme manager | `AppThemeManager` + `AppTheme` / `LightTheme` / `DarkTheme` — [core/themes/](lib/core/themes/) |
| Translation manager | `TranslationManager` — [core/localization/translation_manager.dart](lib/core/localization/translation_manager.dart) |
| Localization runtime | `AppLocalizations` + delegate — [core/localization/app_localizations.dart](lib/core/localization/app_localizations.dart) |
| Push notifications | `FcmService` — [core/services/fcm_service.dart](lib/core/services/fcm_service.dart) |
| Google Sign-In | `GoogleAuthService` — [core/services/google_auth_service.dart](lib/core/services/google_auth_service.dart) |
| Network interceptors | header / auth-refresh / logging / connectivity — [core/network/interceptors/](lib/core/network/interceptors/) |
| User roles | `Roles` enum — [core/enums/roles.dart](lib/core/enums/roles.dart) |
| Reusable models | `LanguageOption`, `ThemeOption` — [core/models/](lib/core/models/) |
| Platform helpers | `downloadPath`, `sdkVersion`, `storagePermission` — [core/functions/](lib/core/functions/) |
| Extensions | `safeEmit`, `.tr(context)`, `.sp(context)`, edge insets, GetIt, build context — [core/extensions/](lib/core/extensions/) |
| Environment | `EnvironmentConfig.apiBaseUrl` — [core/constants/environment_config.dart](lib/core/constants/environment_config.dart) |
| App settings | `AppSettings.isProduction`, `.enableLogging` — [core/constants/app_settings.dart](lib/core/constants/app_settings.dart) |
| Hive box names | [core/constants/hive/hive_box_names.dart](lib/core/constants/hive/hive_box_names.dart) |
| Storage keys | [core/constants/hive/storage_keys.dart](lib/core/constants/hive/storage_keys.dart) |
| Locale keys (generated) | `lib/generated/locale_keys.dart` |
| Asset keys (generated) | `lib/generated/assets.dart`, `fonts.dart` |
| Translation master | `assets/translations/translations.json` — numbered + named entries |
| Translation codegen | `dart helpers/translation_codegen.dart` — generates locales + LocaleKeys |
| Generated locales | `assets/locales/en.json`, `assets/locales/ar.json` — **do not edit manually** |
| Commands reference | [COMMANDS.md](COMMANDS.md) |

**Import convention:** inside the same feature → relative imports; cross-feature / core → `package:flutter_genesis/...`.

---

## 1. Before You Build Anything

> Never start implementing when information is missing. **Ask first.**

Answer these 5 questions before any feature:

1. **Scope** — what does the feature do end-to-end?
2. **Backend** — any API calls? which endpoints? request/response shape?
3. **Caching** — does it need local persistence (Hive)? What expires it?
4. **Inputs/Outputs** — what comes in from the user or route args; what leaves the screen?
5. **Navigation** — which screen comes next on success / on error / on back?

Silent defaults to avoid: no caching, no model, no extra states, no new routes, no new translations unless explicitly asked.

---

## 2. Clean Architecture — Layer Rules

```
presentation  →  domain  ←  data
```

| Layer | Contains | Depends on |
|-------|----------|------------|
| `domain` | Entity, Repository (abstract), UseCase + Params | Nothing |
| `data` | Repository (impl), RemoteDataSource, LocalDataSource *(if cached)*, Model *(only if API diverges)* | domain |
| `presentation` | Cubit, State, Page, Widget, Args | domain |

- Dependency direction is non-negotiable. `data` imports `domain`, **never the reverse**.
- `presentation` never imports `data` directly — only through the domain `Repository` abstraction resolved from `sl`.
- One feature never imports another feature's `data/` or `cubit/` internals.

---

## 3. Feature Folder Structure

Folder names are **plural** (collections). File names are **singular** (one concern per file).

```
lib/features/<feature>/
├── data/
│   ├── datasources/
│   │   ├── <feature>_remote_data_source.dart   # abstract + impl — same file
│   │   └── <feature>_local_data_source.dart    # only if caching was requested
│   ├── models/                                 # only if API diverges from domain
│   │   └── <feature>_model.dart
│   └── repositories/
│       └── <feature>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <feature>_entity.dart
│   ├── repositories/
│   │   └── <feature>_repository.dart           # abstract only
│   └── usecases/
│       ├── get_<feature>_usecase.dart
│       └── create_<feature>_usecase.dart       # Params in same file
├── presentation/
│   ├── args/
│   │   └── <feature>_args.dart                 # typed route arguments
│   ├── cubit/
│   │   ├── <feature>_cubit.dart
│   │   └── <feature>_state.dart
│   ├── pages/
│   │   └── <feature>_page.dart
│   └── widgets/
│       └── <feature>_body_widget.dart
└── di/
    └── <feature>_dependencies.dart
```

- Every file belongs to exactly one of those folders — no loose files at the feature root.
- Page holds `BlocProvider` + `Scaffold` + `CustomAppBar`; body widget holds `BlocConsumer` + content only. Keep them separate.
- **Never** use Flutter's `AppBar` directly — always use `CustomAppBar` from [core/ui/components/custom_app_bar.dart](lib/core/ui/components/custom_app_bar.dart).
- **Never** place `Scaffold` or `AppBar`/`CustomAppBar` inside a body widget — they belong exclusively in the page.

---

## 4. No-Backend Features (Splash, Onboarding, Info)

Build **presentation only** — no Cubit, no UseCase, no Repository, no DataSource, no `di/`:

```
presentation/
├── pages/
└── widgets/
```

If dynamic behaviour is later needed, scale up then. Never pre-build empty layers.

---

## 5. Entity vs Model

**Default: Entity only, owns its own `fromJson`.**
Introduce a separate Model **only** when the API payload genuinely diverges from the domain (extra fields, renamed keys, type coercion, nested normalisation).

```dart
// lib/features/product/domain/entities/product_entity.dart
@freezed
abstract class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required String id,
    required String name,
  }) = _ProductEntity;

  factory ProductEntity.fromJson(Map<String, dynamic> json) =>
      _$ProductEntityFromJson(json);
}
```

If a Model is required, it lives in `data/models/` and exposes `toEntity()`.

---

## 6. UseCase & Params

- Base class: `Usecase<ResultType, Param>` from [core/shared/usecase.dart](lib/core/shared/usecase.dart).
- Return type is **always** `Future<Either<Failure, ResultType>>`.
- **Params live in the same file** as the UseCase — plain Dart, no HTTP concerns.
- For no-input use cases: `Usecase<Result, NoParams>` → invoke with `NoParams.instance`.

```dart
// lib/features/order/domain/usecases/create_order_usecase.dart
class CreateOrderParams {
  final String productId;
  final int quantity;
  const CreateOrderParams({required this.productId, required this.quantity});
}

class CreateOrderUseCase extends Usecase<OrderEntity, CreateOrderParams> {
  final OrderRepository _repository;
  CreateOrderUseCase(this._repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams param) {
    return _repository.create(param);
  }
}
```

**One UseCase = one operation.** Do not bundle multiple actions.

---

## 7. Data Layer Recipes

### 7.1 RemoteDataSource — calls `ApiClient`

```dart
// lib/features/order/data/datasources/order_remote_data_source.dart
abstract class OrderRemoteDataSource {
  Future<OrderEntity> create(CreateOrderParams params);
  Future<List<OrderEntity>> getAll();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;
  const OrderRemoteDataSourceImpl(this._apiClient);

  @override
  Future<OrderEntity> create(CreateOrderParams params) async {
    final res = await _apiClient.post(
      '/orders',
      body: {'productId': params.productId, 'quantity': params.quantity},
    );
    return OrderEntity.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<OrderEntity>> getAll() async {
    final res = await _apiClient.get('/orders');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => OrderEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

Data sources **throw**; they do not return `Either`. Either mapping happens in the repository.

`ApiClient` methods: `get`, `post`, `put`, `patch`, `delete`, `upload`. All support `queryParams`, `headers`, `cancelToken`, `maxRetries`.

### 7.2 RepositoryImpl — the Either boundary

Wrap every data-source call in `try/catch` and convert exceptions into typed `Failure`s via `ServerFailure.fromDioError(e)`:

```dart
// lib/features/order/data/repositories/order_repository_impl.dart
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;
  final OrderLocalDataSource? _local; // optional — only if caching was requested

  const OrderRepositoryImpl({
    required OrderRemoteDataSource remote,
    OrderLocalDataSource? local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, OrderEntity>> create(CreateOrderParams params) async {
    try {
      final order = await _remote.create(params);
      await _local?.cache(order);
      return Right(order);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } on StorageException catch (e) {
      AppLogger.error('cache failed', tag: 'OrderRepository', error: e);
      return Left(ServerFailure(e.message, errorCode: 2000));
    } catch (e, st) {
      AppLogger.error('unexpected', tag: 'OrderRepository', error: e, stackTrace: st);
      return Left(ServerFailure(LocaleKeys.errorUnexpected, errorCode: 9999));
    }
  }
}
```

**Generic-catch rule:** never pass `e.toString()` into `ServerFailure.message` — on `TypeError`, `RangeError`, or JSON errors it leaks internals to the UI. Log the real error with stack trace; return a translated generic key (`LocaleKeys.errorUnexpected`) to the user. The full detail stays in `AppLogger`.

### Timeouts (required)

`ApiClient` must be constructed with explicit timeouts — infinite hangs produce unrecoverable `_Loading` states:

```dart
connectTimeout: Duration(seconds: 15)
receiveTimeout: Duration(seconds: 30)
sendTimeout:    Duration(seconds: 30)
```

For uploads, override `sendTimeout` at the call site (e.g. `Duration(minutes: 5)`). Never set a timeout to zero.

### `Failure.isRetryable`

Base `Failure` exposes a computed flag:

```dart
bool get isRetryable => const {1001, 1002, 1003, 500, 502, 503}.contains(errorCode);
```

UI uses `failure.isRetryable` to decide whether to show a retry action in `FailureWidget` or error snackbars — no per-screen retry logic.

**Cache-first read pattern:**

```dart
@override
Future<Either<Failure, List<OrderEntity>>> getAll() async {
  try {
    final fresh = await _remote.getAll();
    if (_local != null) {
      await Future.wait(fresh.map((o) => _local!.cache(o)));
    }
    return Right(fresh);
  } on DioException catch (e) {
    final cached = _local?.getAll() ?? [];
    if (cached.isNotEmpty) {
      return Right(cached); // fallback to cache on network failure
    }
    return Left(ServerFailure.fromDioError(e));
  }
}
```

### 7.3 Error codes (from `ServerFailure`)

| Range | Meaning |
|-------|---------|
| `1001–1008` | Dio transport: timeouts, cancel, cert, connection, no-internet |
| `4xx` | HTTP client errors — message comes from server response |
| `5xx` | HTTP server errors — localized generic message |
| `2000+` | App-level failures (storage, validation, custom) |

---

## 8. Local Caching (Hive)

> Only build caching when the user explicitly asks for it.

**1. Add a box name** — [core/constants/hive/hive_box_names.dart](lib/core/constants/hive/hive_box_names.dart):
```dart
static const String orderBox = 'orderBox';
```

**2. Key strategy:**
- `appBox` is a **key-value dictionary** — its keys live in `StorageKeys`.
- Any feature box is a **collection** for a single entity type — use the entity's `id` as the key.

**3. Annotate the Entity** (pick the next unused `typeId`):
```dart
@freezed
@HiveType(typeId: 3)
abstract class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
    @HiveField(0) required String id,
    @HiveField(1) required String productId,
    @HiveField(2) required int quantity,
  }) = _OrderEntity;

  factory OrderEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderEntityFromJson(json);
}
```

**4. LocalDataSource** (abstract + impl in the same file):
```dart
abstract class OrderLocalDataSource {
  Future<OrderEntity?> getById(String id);
  List<OrderEntity> getAll();
  Future<void> cache(OrderEntity entity);
  Future<void> clear();
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final HiveStorageService<OrderEntity> _storage =
      HiveStorageService<OrderEntity>(HiveBoxNames.orderBox);

  @override
  Future<OrderEntity?> getById(String id) async => _storage.get(id);

  @override
  List<OrderEntity> getAll() => _storage.values();

  @override
  Future<void> cache(OrderEntity e) => _storage.put(e.id, e);

  @override
  Future<void> clear() => _storage.clear();
}
```

`HiveStorageService` API: `get`, `put`, `delete`, `getAll`, `values`, `keys`, `clear`, `watch`, `watchAll`, `transaction`. Instances are factory-cached per `boxName` — **do not register in DI**, and call `initialize()` on the box once at app boot (in `HiveBoxes`).

### Schema migration — `@HiveType` / `@HiveField` rules

Breaking Hive schemas silently corrupts cached data on app updates:

- **`typeId` is immutable.** Never change an existing entity's `typeId`. Pick the next unused integer for new entities.
- **`@HiveField(N)` indexes are immutable.** Never reuse a retired index. Adding a new field = new index. Removing a field = keep the annotation one release, then drop it.
- **Safe changes:** adding a nullable field, renaming the Dart identifier (index unchanged).
- **Unsafe changes:** changing a field's type, reordering indexes, reusing an old index. These require a full box clear or a manual migration.

### Cache invalidation — required triggers

Every feature that caches user-specific data must:

- Clear its box on **logout** — register the call in the logout use case. A stale cache leaking across accounts is a security bug.
- Clear its box on **app version change** if the server contract changed — gate via `AppSettings` version diff at boot.
- Accept `DioException` → cache fallback only when cached data is non-empty (§7.2).

---

## 8.5 Security — non-negotiable

Security rules override every other rule when they conflict.

### Storage encryption

- `HiveStorageService` is **not** encrypted by default.
- **Sensitive data** (auth tokens, refresh tokens, user PII, session state) → a dedicated encrypted box (`HiveBoxes.secureBox`) using `HiveAesCipher`.
- The AES key is generated once and stored in `flutter_secure_storage`; retrieved at boot **before** opening the secure box.
- `appBox` is permitted only for non-sensitive preferences (theme, locale, onboarding flags).
- Any `@HiveField` that holds credentials or PII must carry a comment: `// stored in encrypted box — HiveBoxes.secureBox`.
- Never store raw tokens in `SharedPreferences` or an unencrypted Hive box.

### Network security

- **Timeouts** are required (see §7 Timeouts). Infinite hangs = unrecoverable UI.
- **Certificate pinning:** declare the project stance in `EnvironmentConfig.certificatePinning` (required / explicitly opted out with reason). If required, implement via `HttpClient.badCertificateCallback` with pinned fingerprints — **never** return `true` to bypass verification.
- Never construct a second `Dio` instance; everything routes through `ApiClient`.

### Logging prohibitions

`AppLogger` must **never** receive:

- Auth tokens (access, refresh, API keys).
- Passwords, PINs, biometric data.
- Full API response bodies — log status code + endpoint only.
- Device identifiers (IMEI, advertising ID, FCM token).
- PII (name, email, phone) unless masked.

On unknown errors, sanitize before logging — `e.toString()` on unfamiliar exceptions may contain secrets. Prefer `runtimeType` + the operation name; pass the raw error as `error:` where the sink can redact.

### User input sanitization

Validation (`Validator.*`) checks format; sanitization removes dangerous content. Both apply to free-text fields sent to the backend:

- Any user-submitted string rendered to other users (bio, comments, display name) must pass `StringUtils.sanitizeForApi(value)` before the API call.
- Not required for fields already constrained to safe formats (email, phone, date, numeric) — `Validator` rejects unsafe input.

### Deep-link / external argument validation

Arguments from **external sources** (deep links, push payloads, inter-app intents) are untrusted. The receiving page must validate before dispatching:

```dart
final args = ModalRoute.of(context)?.settings.arguments as OtpArgs?;
if (args == null || !Validator.validatePhone(context, args.phoneNumber)) {
  NavigationService.pop();
  return;
}
```

Internal `NavigationService.push(...)` calls are trusted by construction.

### Service lifecycles

**FcmService:**
- Register FCM token with backend **only after** successful authentication.
- Deregister on every logout path — including `UnauthorizedInterceptor` forced logout.
- `onTokenRefresh` updates the backend atomically; never creates duplicate registrations.
- FCM tokens are device identifiers: never log them, never cache them unencrypted.

**GoogleAuthService:**
- ID tokens are one-time and expire in ~1 hour. Send to the backend immediately; never cache.
- Never decode the ID token client-side to extract user data — trust only the backend's verified response.
- On acquisition failure, return `Left(ServerFailure(...))` from the repository — no silent retries.

---

## 9. Freezed — syntax contract

All `@freezed` classes **must** be declared `abstract class`:

```dart
// ✅
@freezed
abstract class HomeState with _$HomeState { ... }

// ❌ compile error under Freezed 3.x
@freezed
class HomeState with _$HomeState { ... }
```

Applies to: **States, Entities, Models, DTOs.**

> `build_runner --watch` is already running. Do not invoke it from tool calls. If generated files are stale, tell the user; don't launch commands.

---

## 10. State Management — Cubit

### 10.1 State definition

`error` carries a **`Failure`**, not a `String` — the UI decides how to render.

```dart
@freezed
abstract class FeatureState with _$FeatureState {
  const factory FeatureState.initial()                              = _Initial;
  const factory FeatureState.loading()                              = _Loading;
  const factory FeatureState.loaded({required FeatureEntity data})  = _Loaded;
  const factory FeatureState.error({required Failure failure})      = _Error;
}
```

Do **not** add navigation-specific states (`navigateToX`). Derive navigation from business states in the listener.

### 10.2 Cubit — always `safeEmit`

`safeEmit` ([core/extensions/safe_emit_extension.dart](lib/core/extensions/safe_emit_extension.dart)) is a no-op if the cubit is closed. **Never call `emit` directly.**

```dart
class FeatureCubit extends Cubit<FeatureState> {
  final GetFeatureUseCase _getFeatureUseCase;

  FeatureCubit({required GetFeatureUseCase getFeatureUseCase})
      : _getFeatureUseCase = getFeatureUseCase,
        super(const FeatureState.initial());

  Future<void> load() async {
    safeEmit(const FeatureState.loading());
    final result = await _getFeatureUseCase(NoParams.instance);
    result.fold(
      (failure) => safeEmit(FeatureState.error(failure: failure)),
      (data)    => safeEmit(FeatureState.loaded(data: data)),
    );
  }
}
```

Cubits never call `NavigationService`, never show dialogs, never touch `BuildContext`.

### 10.4 TextEditingController ownership

`TextEditingController` (and `FocusNode`, `GlobalKey<FormState>`) live in the **Cubit**, not in the widget.

```dart
class FeatureCubit extends Cubit<FeatureState> {
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState>  formKey            = GlobalKey<FormState>();

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
```

**Why:** The Cubit's lifecycle is tied to `BlocProvider` — when the page is popped the Cubit is closed and `close()` disposes the controllers. This keeps the widget stateless (`StatelessWidget`) and centralises all form state in one place.

**Rules:**
- Always `dispose()` every controller and FocusNode inside `close()`.
- Widget reads values via `cubit.emailController` — never duplicates state.
- `formKey` also lives in the Cubit so `validate()` can be called from a Cubit method if needed.

### 10.3 Page + BlocConsumer pattern

```dart
// pages/feature_page.dart
class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FeatureCubit>()..load(),
      child: const _FeatureView(),
    );
  }
}

class _FeatureView extends StatelessWidget {
  const _FeatureView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKeys.featureTitle.tr(context)),
      body: BlocConsumer<FeatureCubit, FeatureState>(
        listener: (context, state) {
          state.whenOrNull(
            loading: () => AnimatedDotsLoader.show(context),
            loaded: (data) {
              AnimatedDotsLoader.dismiss();
              // Navigate only when the flow requires it.
            },
            error: (failure) {
              AnimatedDotsLoader.dismiss();
              showSnackbar(failure.message, type: OverlaySnackbarType.error);
            },
          );
        },
        builder: (context, state) => state.maybeWhen(
          loaded: (data) => FeatureBodyWidget(data: data),
          error:  (_)    => const FailureWidget(),
          orElse: ()     => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
```

**Rules:**
- `AnimatedDotsLoader` is a dialog overlay — show/dismiss from **listener**, never builder.
- Navigation only from **listener**. Never from Cubit, never from builder.
- Prefer `whenOrNull` in listeners, `maybeWhen` + `orElse` in builders.
- Keep builders pure — no side effects.

---

## 11. Navigation

### 11.1 Route Arguments — typed classes

Always a typed class, even for a single field. Never `Map`, never raw positional params.

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

### 11.2 Adding a route — 3 edits

**[core/routing/app_route.dart](lib/core/routing/app_route.dart):**
```dart
enum AppRoute {
  splashScreen('/'),
  loginScreen('/login'),
  featureScreen('/feature'); // ← add
}
```

**[core/routing/route_manager.dart](lib/core/routing/route_manager.dart) — `generateRoute` switch:**
```dart
AppRoute.featureScreen => PageRouteAnimator.fade(const FeaturePage(), settings),
```

**Same file — `_guardsFor` switch:**
```dart
AppRoute.featureScreen => [const AuthGuard()], // or [] if public
```

### 11.3 NavigationService API

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

Never call `Navigator.of(context).push*` directly.

### 11.4 Transitions — `PageRouteAnimator`

- `PageRouteAnimator.fade(page, settings)` — default
- `PageRouteAnimator.slide(page, settings, direction: SlideDirection.right)`
- `PageRouteAnimator.scale(page, settings)`

### 11.5 Route guards

Built-ins: `AuthGuard` (blocks unauthenticated), `GuestGuard` (blocks already-signed-in). Create new guards by implementing `RouteGuard.redirect()`. Chain in `_guardsFor` — all must pass.

After the redirect target completes its flow, call `NavigationService.returnOrFallback(context, fallback: ...)` to resume the original destination (the guard attaches `returnTo` automatically).

---

## 12. DI Registration

Every feature owns `di/<feature>_dependencies.dart` exporting `register<Feature>Dependencies()`. Call it from `initializeDependencies()` in [core/di/service_locator.dart](lib/core/di/service_locator.dart).

**Order:** DataSources → Repository → UseCases → Cubit.

```dart
void registerOrderDependencies() {
  // Data sources — lazy singletons (stateless / long-lived)
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(), // HiveStorageService is self-managed
  );

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remote: sl(), local: sl()),
  );

  // Use cases
  sl.registerLazySingleton<CreateOrderUseCase>(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton<GetAllOrdersUseCase>(() => GetAllOrdersUseCase(sl()));

  // Cubit — factory (fresh instance per page entry)
  sl.registerFactory<OrderCubit>(
    () => OrderCubit(createOrderUseCase: sl(), getAllOrdersUseCase: sl()),
  );
}
```

- Stateless / cache-bearing services → `registerLazySingleton`.
- Cubits and anything re-entered by the user → `registerFactory`.

---

## 13. Translations — no hard-coded user text

Every string shown to the user goes through translations. **Never** write English/Arabic literals in `Text`, hints, labels, validators, error messages, snackbars, or dialogs.

```dart
// ✅
Text(LocaleKeys.welcome.tr(context))

// ✅ with placeholder args
Text(LocaleKeys.greetName.tr(context, args: {'name': user.name}))

// ❌
Text('Welcome')
Text('مرحبا')
```

Placeholders use `{{name}}` syntax and are replaced via `args`.

**Workflow when a new string is needed:**
1. Open `assets/translations/translations.json` — read the last ~30 lines to find the last key.
2. Add a new entry:
   - **Shared/common string** → use the next integer key: `"88": { "en": "...", "ar": "..." }`  
     The Dart identifier is auto-derived from the English text (camelCase).
   - **Feature-specific string** → use a named string key: `"productsTitle": { "en": "...", "ar": "..." }`  
     The key name becomes the Dart identifier directly (first letter lowercased).
3. Run `dart helpers/translation_codegen.dart` — regenerates `assets/locales/en.json`, `assets/locales/ar.json`, and `lib/generated/locale_keys.dart`.
4. Use `LocaleKeys.<key>.tr(context)` in widget code.

**Never** edit `assets/locales/en.json`, `assets/locales/ar.json`, or `lib/generated/locale_keys.dart` directly — they are overwritten every time the codegen runs.

**Runtime locale switching:** use `TranslationManager` ([core/localization/translation_manager.dart](lib/core/localization/translation_manager.dart)) — it persists the choice and rebuilds the app. Never call `Localizations.localeOf` for switching. `AppLocalizations` + its delegate wire the loaded JSON into Flutter's localization pipeline.

**Pluralization:** Arabic has six plural forms (`zero`, `one`, `two`, `few`, `many`, `other`). Never implement with ternaries in widget code — use the plural-key convention:

```json
// en.json
"itemCount_zero":  "No items",
"itemCount_one":   "{{count}} item",
"itemCount_other": "{{count}} items"

// ar.json
"itemCount_zero":  "لا عناصر",
"itemCount_one":   "عنصر واحد",
"itemCount_two":   "عنصران",
"itemCount_few":   "{{count}} عناصر",
"itemCount_many":  "{{count}} عنصرًا",
"itemCount_other": "{{count}} عنصر"
```

Consume via `LocaleKeys.itemCount.plural(context, count: items.length)`.

---

## 14. Assets & Generated Code

Never hardcode asset paths. Use the generated indices under `lib/generated/`:

| File | Purpose |
|------|---------|
| `locale_keys.dart` | Translation keys (`LocaleKeys.welcome`) |
| `assets.dart` | Images & SVGs (`Assets.logo`, `Assets.iconSearch`) |
| `fonts.dart` | Font family names |

If a new asset or string is needed, ask the user to add it to the source and regenerate. Do not run codegen yourself.

---

## 15. Context-based Theming & Layout

Consume styling, colors, device info, and locale through `BuildContext` extensions ([core/extensions/build_context_extensions.dart](lib/core/extensions/build_context_extensions.dart)):

| Expression | Returns |
|------------|---------|
| `context.colors` | Active `AppColors` — every color (`primary`, `error`, `textPrimary`, `surface`, …) |
| `context.styles` | `AppFontStyle` — preset getters (`bold16`, `regular14`, `semiBold20`, …) |
| `context.theme` / `context.isDarkMode` | `ThemeData` / bool |
| `context.isArabic` / `context.isEnglish` / `context.currentLocale` | locale helpers |
| `context.screenWidth` / `.screenHeight` / `.screenSize` / `.isPortrait` | size & orientation |
| `context.safePadding` / `.viewInsets` / `.isKeyboardVisible` | safe area & keyboard |
| `context.isAndroid` / `.isIOS` / `.isWeb` / `.isDesktop` | platform |
| `context.unfocus()` | dismiss keyboard |

See [build_context_extensions.dart](lib/core/extensions/build_context_extensions.dart) for the full set (includes `reverseColors`, `currentRouteName`, etc.).

### Responsive sizing — `num.sp(BuildContext)`

From [core/extensions/responsive_font_size_extension.dart](lib/core/extensions/responsive_font_size_extension.dart):
```dart
Text(label, style: TextStyle(fontSize: 16.sp(context)))
```
Scales 0.85× (≤300px) to 1.3× (≥800px) around a 400px baseline. `AppFontStyle` presets already call `.sp(context)` internally.

### Padding helpers

[core/extensions/edge_insets_extension.dart](lib/core/extensions/edge_insets_extension.dart):
```dart
16.horizontal   // EdgeInsets.symmetric(horizontal: 16)
24.all          // EdgeInsets.all(24)
8.top           // EdgeInsets.only(top: 8)
12.vertical     // EdgeInsets.symmetric(vertical: 12)
```

**Never hardcode colors, text styles, or font sizes.** Always come through `context.colors` / `context.styles` / `.sp(context)`.

### OS text-scale clamp

At extreme OS text scales, layouts break silently. Clamp once at the `MaterialApp.builder`:

```dart
builder: (context, child) {
  final clamped = MediaQuery.of(context).textScaler
      .clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: clamped),
    child: child!,
  );
},
```

This is the **only** permitted location for text-scale modification. Feature code never overrides `textScaler`.

### Theme source & runtime switching

Palettes live in [core/themes/](lib/core/themes/):
- `AppTheme` — abstract base holding `AppColors` + `AppFontStyle`.
- `LightTheme` / `DarkTheme` — concrete overrides.
- `AppThemeManager` — runtime mode switcher (system / light / dark). It persists the choice and notifies the app to rebuild.

Add or tune colors only inside `LightTheme` / `DarkTheme`. Never build a one-off palette inside a feature.

---

## 16. Core UI Components — use these, don't re-invent

All under [core/ui/](lib/core/ui/). Reach for them before writing a new widget.

| Component | Purpose | Key props |
|-----------|---------|-----------|
| `CustomButton` | Primary button — loading / disabled / icon alignment | `text`, `onPressed`, `isLoading`, `icon`, `iconAlignment`, `height=52`, `borderRadius=8` |
| `CustomTextFormField` | Inputs — SVG prefix, password toggle, focus-aware | `controller`, `validator`, `prefixIconSvg`, `showVisibilityToggle`, `keyboardType` |
| `CustomAppBar` | App bar — auto overlay style; `gradient` reserved for hero surfaces (§21) | `title`, `actions`, `centerTitle`, `gradient` |
| `CustomCachedNetworkImage` | Cached network image with placeholder & error | — |
| `OTPInputField` | OTP entry field | — |
| `AnimatedDotsLoader` | Full-screen loader (dialog overlay) | `.show(context)` / `.dismiss()` |
| `RoundedLoadingButton` | Button that morphs into a loader | — |
| `ConfirmBackScope` | Confirms leaving a page with unsaved changes | — |
| `DoubleBackToExit` | Root-level "tap back twice to exit" | — |
| `EmptyWidget` | Standard empty state | — |
| `FailureWidget` | Standard error state — pair with `error` cubit state | — |
| `MenuAction` | Popup menu item model | — |

### Snackbars

- `showSnackbar(msg, type: OverlaySnackbarType.success)` — `ScaffoldMessenger`-based; requires Scaffold ancestor. [scaffold_snackbar.dart](lib/core/ui/snackbar/scaffold_snackbar.dart)
- `showOverlaySnackbar(msg, type: ..., position: OverlaySnackbarPosition.top)` — floating overlay outside Scaffold; use from guards, background tasks, or root listeners. [overlay_snackbar.dart](lib/core/ui/snackbar/overlay_snackbar.dart)

`OverlaySnackbarType`: `success`, `error`, `warning`, `info`. Both snackbars auto-translate the message via `.tr(context)` — pass a `LocaleKeys.x` value directly.

### Dialogs

- `showWarningDialog(context, title: ..., content: ..., confirmButtonText: ..., onConfirm: ...)` — destructive-action confirmation. Not dismissible by barrier tap. [warning_dialog.dart](lib/core/ui/dialogs/warning_dialog.dart)

---

## 17. Form Validation — use `Validator`

Never roll custom regex in pages. [core/utils/validator.dart](lib/core/utils/validator.dart) exposes pre-translated validators:

```dart
CustomTextFormField(
  controller: _emailCtl,
  validator: (v) => Validator.validateEmail(context, v),
)
```

All `validate*` methods live in [validator.dart](lib/core/utils/validator.dart). If none fit, **add a new method there** — don't inline a regex.

---

## 18. Core Utilities Index

Reach for these before writing helpers:

| Utility | Purpose |
|---------|---------|
| `AppLogger` | `info` / `error` only — **never `debug`** ([utils/app_logger.dart](lib/core/utils/app_logger.dart)) |
| `DateFormatter` | Date/time formatting, relative time ([utils/date_formatter.dart](lib/core/utils/date_formatter.dart)) |
| `NumberFormatter` | Decimals, currency, compact ([utils/number_formatter.dart](lib/core/utils/number_formatter.dart)) |
| `StringUtils` | String manipulation helpers ([utils/string_helper.dart](lib/core/utils/string_helper.dart)) |
| `Debouncer` | Debounce callbacks (search fields, resize) ([utils/debouncer.dart](lib/core/utils/debouncer.dart)) |
| `PaginationController` | Infinite-scroll list pagination ([utils/pagination_controller.dart](lib/core/utils/pagination_controller.dart)) |
| `FilePickerUtils` | File picking wrapper ([utils/file_picker_helper.dart](lib/core/utils/file_picker_helper.dart)) |
| `ImagePickerUtils` | Image picking wrapper ([utils/image_picker_helper.dart](lib/core/utils/image_picker_helper.dart)) |
| `OrientationManager` | Lock/unlock orientation ([utils/orientation_manager.dart](lib/core/utils/orientation_manager.dart)) |
| `AppRouteObserver` | Navigation event observer ([observers/app_route_observer.dart](lib/core/observers/app_route_observer.dart)) |
| `AppBlocObserver` | Global Bloc/Cubit lifecycle logger ([observers/app_bloc_observer.dart](lib/core/observers/app_bloc_observer.dart)) |
| `NetworkMonitor` | Connectivity state ([network/network_monitor.dart](lib/core/network/network_monitor.dart)) |

### Platform helpers — [core/functions/](lib/core/functions/)

| Helper | Purpose |
|--------|---------|
| `downloadPath` | Resolves the platform-appropriate downloads directory ([functions/download_path.dart](lib/core/functions/download_path.dart)) |
| `sdkVersion` | Android SDK int via platform channel ([functions/sdk_version.dart](lib/core/functions/sdk_version.dart)) |
| `storagePermission` | Requests the right storage permission per OS version ([functions/storage_permission.dart](lib/core/functions/storage_permission.dart)) |

Use these instead of re-invoking `permission_handler` or `path_provider` inline in features.

---

### Services — [core/services/](lib/core/services/)

| Service | Purpose |
|---------|---------|
| `FcmService` | Push registration, token refresh, message routing |
| `GoogleAuthService` | Google Sign-In; returns ID token for the backend |

Consumed by repositories/use cases — **never Cubits directly**. Wrap their calls inside a UseCase or DataSource; services throw, repository maps to `Failure`. Register as `registerLazySingleton`.

### Network interceptors — [core/network/interceptors/](lib/core/network/interceptors/)

| Interceptor | Role |
|-------------|------|
| `HeaderInterceptor` | Injects auth token, locale, device headers |
| `UnauthorizedInterceptor` | Catches 401 → refresh + replay, or force logout |
| `NetworkInterceptor` | Short-circuits when offline (`NetworkMonitor`) |
| `ApiLoggerInterceptor` | Request/response logging; gated by `AppSettings.enableLogging` |

Features never create a second `Dio`. New headers or retry logic → edit `HeaderInterceptor` or extend `ApiClient`.

---

## 19. Logging

Only two levels exist — **never add `AppLogger.debug`**.

```dart
AppLogger.info('user signed in', tag: 'AuthCubit');
AppLogger.error('refresh token failed',
    tag: 'AuthRepository', error: e, stackTrace: st);
```

- `print` is forbidden.
- `tag` is required — use the class name.
- Gated by `AppSettings.enableLogging` — safe in release.

---

## 20. Code Style

### Comments

Default: **no comments**. Write one only if it captures a non-obvious *why*:

```dart
// ✅ hidden constraint
// Cache miss on cold start is expected — remote is authoritative.
final cached = await _local.getCached();

// ❌ restates the code
/// Fetches the user.
Future<User> getUser() { ... }
```

Dart doc `///` only on widely consumed public API. Inline `//` only for non-obvious details.

### Principles (enforced)

- **SRP** — one reason to change per file.
- **OCP** — extend by adding files, not by editing unrelated ones.
- **DIP** — depend on abstractions. Repository interface in `domain`, impl in `data`.
- **DRY** — extract only when duplicated twice or more.
- **YAGNI** — build what is asked. No speculative abstractions, flags, or hooks.

---

## 20b. Anti-patterns & Code Smells

High-signal traps — things the linter won't catch and that contradict rules stated above. If you catch yourself writing ❌, stop.

| ❌ Anti-pattern | ✅ Correct |
|---|---|
| `import 'package:dartz/dartz.dart';` | Custom `Either` from `core/shared/either.dart` |
| `new Dio()` inside a DataSource | `sl<ApiClient>()` |
| DataSource returns `Either` | DataSource throws; Repository maps to Either |
| Repository lets `DioException` escape | `Left(ServerFailure.fromDioError(e))` |
| `catch (_) {}` swallows silently | Log with `AppLogger.error(..., stackTrace: st)` then map |
| `e.toString()` in `ServerFailure.message` | `LocaleKeys.errorUnexpected` — never leak internals |
| Registering `HiveStorageService` in `sl` | Factory-cached per box; instantiate inside LocalDataSource |
| `emit(...)` directly | `safeEmit(...)` always |
| `State.error({required String message})` | `State.error({required Failure failure})` |
| `State.navigateToHome()` | Derive navigation in the `listener`, not as state |
| `Cubit.call(context, ...)` / `BuildContext` in Cubit | Cubit is UI-agnostic |
| `Navigator.of(context).push(MaterialPageRoute(...))` | `NavigationService.push(AppRoute.x, arguments: XArgs(...))` |
| `arguments: {'id': 12}` raw map | Typed `XArgs` class (§11.1) |
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
| `AppBar(...)` anywhere in the app | `CustomAppBar(...)` from `core/ui/components/custom_app_bar.dart` |
| `Scaffold` or `AppBar` inside a body widget | `Scaffold` + `CustomAppBar` belong in the page only |
| `ListView(children: [...])` for 20+ items | `ListView.builder` |
| Sort/filter large lists in `builder` | Do it in Cubit before emitting `_Loaded` |
| `setState` inside `BlocConsumer` | Split: wrap only the stateful subtree |
| Timers/Streams not disposed | Dispose in `close()` / `dispose()` |

**Structural smells** — God widget/Cubit (split on 3+ concerns), magic numbers outside the spacing/radii scale, dead code (commented blocks, unused imports, ownerless `TODO`), copy-pasted logic (second occurrence → `core/`), feature flags with no removal plan.

---

## 21. UX / UI Design Principles

**Hierarchy** — one hero per screen (title, primary CTA, or key metric). Build contrast via weight + color + spacing, not size alone. Scannable in 3 seconds or restructure.

**Spacing (8pt grid)** — `4 / 8 / 12 / 16 / 24 / 32 / 48`. Nothing in between. Default screen padding `16`; inside-group `8`, between-group `16`, between-section `24–32`. Radii: buttons/inputs `8`, cards `12`, sheets/dialogs `16`. Elevation `0–4`, single level.

**Color (60/30/10)** — 60% neutral surface, 30% content, 10% accent (CTAs only). Gradients on hero surfaces only (app bar, splash, primary CTA); never on body, cards, or inputs. Semantic colors (`error`/`success`/`warning`/`info`) reserved for meaning. All colors via `context.colors`.

**Typography** — `context.styles.<preset>` only, never a free `TextStyle(fontSize:)`. Max 3 sizes per screen. Body line length 45–75 chars. Always `maxLines` + `ellipsis` on Text that can overflow.

**Iconography** — no emojis; Material or `Assets.*` SVG. One icon family per screen. Sizes `16 / 20 / 24` matched to adjacent text. `CustomCachedNetworkImage` with explicit width/height.

**Motion** — `150–300ms` micro, `300–500ms` transitions. `easeOut` in, `easeIn` out, `easeInOut` both. No bounce/elastic. Feedback within 100ms of any tap. Haptics on destructive confirms only.

**Five required states** — empty (`EmptyWidget`), loading (`AnimatedDotsLoader` or skeleton), loaded, error (`FailureWidget` with retry iff `failure.isRetryable`), partial/stale (cache-while-refreshing). Missing any = bug.

**Forms** — one column, label-above-field, errors inline. Validate on blur. Correct `keyboardType` + `textInputAction` + autofill hints on every field. Sticky primary CTA above keyboard. Validators from §17.

**Accessibility** — 4.5:1 body contrast, 3:1 large text and UI. 44×44pt tap targets. `tooltip` on every `IconButton`; `Semantics(label:, button: true)` on any icon-only gesture; `semanticsLabel` on images. Focus follows reading order. Color never the only signal.

**RTL & dark mode** — `EdgeInsetsDirectional` + `Alignment.centerStart` (never `left/right`). Directional icons (arrows, chevrons) mirror in RTL. Numbers/dates via `NumberFormatter` / `DateFormatter`. No hardcoded `Colors.black/white`. Test both locales + both themes. Match existing screens — if a pattern is wrong, fix it everywhere.

---

## 22. Feature-Delivery Checklist

Critical gates before marking a feature complete — each maps to a rule above, not a restatement.

- [ ] 5 pre-build questions answered (§1).
- [ ] Repository returns `Either<Failure, T>`; DataSource throws (§7.2).
- [ ] Cubit uses `safeEmit`; navigation/loaders/snackbars only in `listener` (§10).
- [ ] Route wired in all three places: enum + `generateRoute` + `_guardsFor` (§11.2).
- [ ] Feature DI file created and registered in `service_locator.dart` (§12).
- [ ] Zero hardcoded strings / colors / font sizes — translations + `context.*` (§13, §15).
- [ ] Security: sensitive data in encrypted box; no tokens/PII in logs; no `e.toString()` to UI; external args validated (§8.5).
- [ ] Hive: `typeId` and `@HiveField` indexes unchanged from prior releases (§8).
- [ ] Five UI states handled: empty, loading, loaded, error, stale (§21).
- [ ] Tested in both locales (en/ar) and both themes (light/dark).
