---
name: di-registration
description: Rules for dependency injection with GetIt (sl) in flutter_genesis — every feature owns a di/<feature>_dependencies.dart registered in service_locator.dart, with registration order DataSources → Repository → UseCases → Cubit, and lazy-singleton vs factory guidance. Use when creating a new feature's DI file, editing service_locator.dart, or deciding how to register a service.
---

# DI registration

## 1. Every feature owns its own DI file

`lib/features/<feature>/di/<feature>_dependencies.dart` exports `register<Feature>Dependencies()`. Call it from `initializeDependencies()` in [core/di/service_locator.dart](../../../lib/core/di/service_locator.dart).

## 2. Registration order: DataSources → Repository → UseCases → Cubit

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

## 3. Lifetime choice

| Type | Lifetime |
|------|----------|
| DataSource, Repository, UseCase, stateless services | `registerLazySingleton` |
| Cubit, anything re-entered by the user | `registerFactory` |

## 4. Things **never** registered in `sl`

- `HiveStorageService` — factory-cached per `boxName` internally.
- `BuildContext`, widgets, Flutter objects.
- One-off helpers that can be instantiated at the call site.

## 5. Wire it up in `service_locator.dart`

```dart
void initializeDependencies() {
  registerCoreDependencies();
  registerAuthenticationDependencies();
  registerOrderDependencies(); // ← add
}
```
