import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/app/cubit/app_cubit.dart';
import 'package:flutter_starter/core/di/service_locator.dart';
import 'package:flutter_starter/core/network/api_client.dart';

/// Registers core services like networking and navigation.
void registerCoreDependencies() {
  sl.registerLazySingleton<ApiClient>(() => ApiClient(Dio()));

  sl.registerLazySingleton<GlobalKey<NavigatorState>>(
    GlobalKey<NavigatorState>.new,
  );

  sl.registerLazySingleton<GlobalKey<ScaffoldMessengerState>>(
    GlobalKey<ScaffoldMessengerState>.new,
  );

  sl.registerSingleton<AppCubit>(AppCubit());
}
