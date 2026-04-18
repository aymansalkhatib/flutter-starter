import 'package:dio/dio.dart';
import 'package:flutter_genesis/core/errors/failure.dart';
import 'package:flutter_genesis/core/errors/server_failure.dart';
import 'package:flutter_genesis/core/errors/storage_exception.dart';
import 'package:flutter_genesis/core/shared/either.dart';
import 'package:flutter_genesis/core/utils/app_logger.dart';
import 'package:flutter_genesis/generated/locale_keys.dart';

import '../../domain/entities/authentication_entity.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../datasources/authentication_local_data_source.dart';
import '../datasources/authentication_remote_data_source.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationRemoteDataSource _remote;
  final AuthenticationLocalDataSource _local;

  const AuthenticationRepositoryImpl({
    required AuthenticationRemoteDataSource remote,
    required AuthenticationLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, AuthenticationEntity>> login(
      LoginParams params) async {
    try {
      final entity = await _remote.login(params);
      await _local.cacheToken(entity.token);
      return Right(entity);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } on StorageException catch (e) {
      AppLogger.error('token cache failed',
          tag: 'AuthenticationRepository', error: e);
      return Left(ServerFailure(LocaleKeys.unexpectedErrorPleaseTryAgain,
          errorCode: 2000));
    } catch (e, st) {
      AppLogger.error('unexpected error during login',
          tag: 'AuthenticationRepository', error: e, stackTrace: st);
      return Left(ServerFailure(LocaleKeys.unexpectedErrorPleaseTryAgain,
          errorCode: 9999));
    }
  }
}
