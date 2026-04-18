import 'package:flutter_genesis/core/errors/failure.dart';
import 'package:flutter_genesis/core/shared/either.dart';
import 'package:flutter_genesis/core/shared/usecase.dart';

import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase extends Usecase<List<ProductEntity>, NoParams> {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams param) {
    return _repository.getAll();
  }
}
