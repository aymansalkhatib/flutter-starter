---
name: data-layer
description: Rules for the data layer in flutter_starter — RemoteDataSource using ApiClient, RepositoryImpl as the Either boundary with exception-to-Failure mapping, cache-first read patterns, Dio timeouts, and the Failure error-code ranges. Use when creating or editing any file under lib/features/*/data/, or when mapping exceptions to Failure.
---

# Data layer

## 1. RemoteDataSource — calls `ApiClient`, **throws**, does not return `Either`

Abstract + impl in the same file.

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
    return (res.data as List<dynamic>)
        .map((e) => OrderEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

`ApiClient` methods: `get`, `post`, `put`, `patch`, `delete`, `upload`. All support `queryParams`, `headers`, `cancelToken`, `maxRetries`.

## 2. RepositoryImpl — the Either boundary

Wrap every DataSource call in `try/catch` and convert exceptions into typed `Failure`s.

```dart
// lib/features/order/data/repositories/order_repository_impl.dart
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;
  final OrderLocalDataSource? _local; // optional — only if caching requested

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

## 3. Generic-catch rule — never leak internals to the UI

On `TypeError`, `RangeError`, JSON errors, etc., **never** pass `e.toString()` into `ServerFailure.message`. Log the real error with stack trace via `AppLogger.error` and return a **translated generic key** (`LocaleKeys.errorUnexpected`) to the user.

## 4. Timeouts (required)

`ApiClient` must be constructed with explicit timeouts — infinite hangs produce unrecoverable `_Loading` states:

```dart
connectTimeout: Duration(seconds: 15)
receiveTimeout: Duration(seconds: 30)
sendTimeout:    Duration(seconds: 30)
```

For uploads, override `sendTimeout` at the call site (e.g. `Duration(minutes: 5)`). **Never set a timeout to zero.**

## 5. `Failure.isRetryable`

Base `Failure` exposes a computed flag:

```dart
bool get isRetryable => const {1001, 1002, 1003, 500, 502, 503}.contains(errorCode);
```

UI uses it to decide whether to show a retry action — no per-screen retry logic.

## 6. Cache-first read pattern

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
      return Right(cached); // fallback to cache only when non-empty
    }
    return Left(ServerFailure.fromDioError(e));
  }
}
```

## 7. Error code ranges (from `ServerFailure`)

| Range | Meaning |
|-------|---------|
| `1001–1008` | Dio transport: timeouts, cancel, cert, connection, no-internet |
| `4xx` | HTTP client errors — message comes from server response |
| `5xx` | HTTP server errors — localized generic message |
| `2000+` | App-level failures (storage, validation, custom) |
