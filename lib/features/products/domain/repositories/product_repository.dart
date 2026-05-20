import 'package:flutter_starter/core/errors/failure.dart';
import 'package:flutter_starter/core/shared/either.dart';

import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getAll();
}
