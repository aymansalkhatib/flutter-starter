import 'package:dio/dio.dart';
import 'package:flutter_genesis/core/errors/failure.dart';
import 'package:flutter_genesis/core/errors/server_failure.dart';
import 'package:flutter_genesis/core/errors/storage_exception.dart';
import 'package:flutter_genesis/core/shared/either.dart';
import 'package:flutter_genesis/core/utils/app_logger.dart';
import 'package:flutter_genesis/generated/locale_keys.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  const ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, List<ProductEntity>>> getAll() async {
    try {
      final fresh = await _remote.getAll();
      await _local.cacheAll(fresh);
      return Right(fresh);
    } on DioException catch (e) {
      final cached = _local.getAll();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(ServerFailure.fromDioError(e));
    } on StorageException catch (e) {
      AppLogger.error('products cache failed',
          tag: 'ProductRepository', error: e);
      return Left(
          ServerFailure(LocaleKeys.unexpectedErrorPleaseTryAgain, errorCode: 2000));
    } catch (e, st) {
      AppLogger.error('unexpected error fetching products',
          tag: 'ProductRepository', error: e, stackTrace: st);
      return Left(
          ServerFailure(LocaleKeys.unexpectedErrorPleaseTryAgain, errorCode: 9999));
    }
  }
}
