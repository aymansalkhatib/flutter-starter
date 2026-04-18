import 'package:flutter_genesis/core/errors/failure.dart';
import 'package:flutter_genesis/core/shared/either.dart';

import '../entities/authentication_entity.dart';
import '../usecases/login_usecase.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, AuthenticationEntity>> login(LoginParams params);
}
