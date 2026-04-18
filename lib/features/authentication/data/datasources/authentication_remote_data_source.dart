import 'package:flutter_genesis/core/constants/api_endpoints.dart';
import 'package:flutter_genesis/core/network/api_client.dart';

import '../../domain/entities/authentication_entity.dart';
import '../../domain/usecases/login_usecase.dart';

abstract class AuthenticationRemoteDataSource {
  Future<AuthenticationEntity> login(LoginParams params);
}

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final ApiClient _apiClient;

  const AuthenticationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthenticationEntity> login(LoginParams params) async {
    final res = await _apiClient.post(
      ApiEndpoints.login,
      body: {
        'username': params.username,
        'password': params.password,
      },
    );
    return AuthenticationEntity.fromJson(res.data as Map<String, dynamic>);
  }
}
