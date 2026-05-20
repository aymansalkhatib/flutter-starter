import 'package:flutter_starter/core/di/service_locator.dart';
import 'package:flutter_starter/core/network/api_client.dart';

import '../data/datasources/authentication_local_data_source.dart';
import '../data/datasources/authentication_remote_data_source.dart';
import '../data/repositories/authentication_repository_impl.dart';
import '../domain/repositories/authentication_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../presentation/cubit/authentication_cubit.dart';

void registerAuthenticationDependencies() {
  // Data sources
  sl.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthenticationLocalDataSource>(
    AuthenticationLocalDataSourceImpl.new,
  );

  // Repository
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

  // Cubit
  sl.registerFactory<AuthenticationCubit>(
    () => AuthenticationCubit(loginUseCase: sl()),
  );
}
