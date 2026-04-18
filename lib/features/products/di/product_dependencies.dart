import 'package:flutter_genesis/core/di/service_locator.dart';
import 'package:flutter_genesis/core/network/api_client.dart';

import '../data/datasources/product_local_data_source.dart';
import '../data/datasources/product_remote_data_source.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/usecases/get_products_usecase.dart';
import '../presentation/cubit/product_cubit.dart';

void registerProductDependencies() {
  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    ProductLocalDataSourceImpl.new,
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remote: sl(), local: sl()),
  );

  // Use cases
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl()),
  );

  // Cubit
  sl.registerFactory<ProductCubit>(
    () => ProductCubit(getProductsUseCase: sl()),
  );
}
