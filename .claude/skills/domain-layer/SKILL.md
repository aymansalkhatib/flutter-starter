---
name: domain-layer
description: Rules for the domain layer in flutter_starter — Freezed entities with self-owned fromJson, UseCase + Params pattern, and abstract Repository contracts. Use when creating or editing any file under lib/features/*/domain/, or deciding whether a feature needs a separate Model class beyond its Entity.
---

# Domain layer

## Entity — default: entity only, owns its own `fromJson`

Introduce a separate **Model** only when the API genuinely diverges from the domain (extra fields, renamed keys, type coercion, nested normalisation). If a Model is required, it lives in `data/models/` and exposes `toEntity()`.

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

- Freezed 3.x: always `abstract class`.
- If the entity is cached in Hive, see the `hive-caching` skill for `@HiveType` / `@HiveField`.

## UseCase + Params — one operation per UseCase

- Base class: `Usecase<ResultType, Param>` from `core/shared/usecase.dart`.
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
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams param) =>
      _repository.create(param);
}
```

**Do not bundle multiple actions.** One UseCase = one operation.

## Repository — abstract only, in `domain/repositories/`

```dart
// lib/features/order/domain/repositories/order_repository.dart
abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> create(CreateOrderParams params);
  Future<Either<Failure, List<OrderEntity>>> getAll();
}
```

The implementation lives in `data/` — see the `data-layer` skill.
