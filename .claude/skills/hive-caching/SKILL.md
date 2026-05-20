---
name: hive-caching
description: Rules for local caching with Hive in flutter_starter — box naming, key strategy, Entity annotation with @HiveType / @HiveField, LocalDataSource pattern, schema migration constraints (typeId/index immutability), and cache invalidation triggers (logout, version change). Use when adding caching to a feature, modifying a LocalDataSource, or editing an entity with @HiveField annotations.
---

# Hive caching

**Only build caching when the user explicitly asks for it.**

## 1. Add a box name

[core/constants/hive/hive_box_names.dart](../../../lib/core/constants/hive/hive_box_names.dart):

```dart
static const String orderBox = 'orderBox';
```

## 2. Key strategy

- `appBox` is a **key-value dictionary** — its keys live in `StorageKeys`.
- Any feature box is a **collection** for a single entity type — use the entity's `id` as the key.

## 3. Annotate the Entity — pick the next unused `typeId`

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

Also register the adapter in [core/storage/hive/hive_boxes.dart](../../../lib/core/storage/hive/hive_boxes.dart) and open the box in `HiveBoxes.initialize()`.

## 4. LocalDataSource — abstract + impl in the same file

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

`HiveStorageService` API: `get`, `put`, `delete`, `getAll`, `values`, `keys`, `clear`, `watch`, `watchAll`, `transaction`. Instances are factory-cached per `boxName` — **do not register in DI**, and call `initialize()` on the box once at app boot (inside `HiveBoxes`).

## 5. Schema migration — `@HiveType` / `@HiveField` immutability

Breaking schemas silently corrupts cached data on app updates.

- **`typeId` is immutable.** Never change an existing entity's `typeId`. Pick the next unused integer.
- **`@HiveField(N)` indexes are immutable.** Never reuse a retired index. Adding a new field = new index. Removing = keep the annotation one release, then drop it.
- **Safe:** adding a nullable field; renaming the Dart identifier (index unchanged).
- **Unsafe:** changing a field's type; reordering indexes; reusing an old index. These require a full box clear or a manual migration.

## 6. Cache invalidation — required triggers

Every feature that caches user-specific data must:

- Clear its box on **logout** — register the call in the logout use case. A stale cache leaking across accounts is a security bug.
- Clear its box on **app version change** if the server contract changed — gate via `AppSettings` version diff at boot.
- Accept `DioException` → cache fallback **only when cached data is non-empty** (see `data-layer` skill §6).
