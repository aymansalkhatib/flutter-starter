import 'package:flutter_starter/core/errors/failure.dart';
import 'package:flutter_starter/core/shared/either.dart';
import 'package:flutter_starter/core/shared/usecase.dart';

import '../entities/authentication_entity.dart';
import '../repositories/authentication_repository.dart';

class LoginParams {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});
}

class LoginUseCase extends Usecase<AuthenticationEntity, LoginParams> {
  final AuthenticationRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Either<Failure, AuthenticationEntity>> call(LoginParams param) {
    return _repository.login(param);
  }
}
