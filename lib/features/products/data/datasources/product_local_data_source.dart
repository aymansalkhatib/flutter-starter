import 'package:flutter_genesis/core/constants/hive/hive_box_names.dart';
import 'package:flutter_genesis/core/storage/hive/hive_storage_service.dart';

import '../../domain/entities/product_entity.dart';

abstract class ProductLocalDataSource {
  List<ProductEntity> getAll();
  Future<void> cacheAll(List<ProductEntity> products);
  Future<void> clear();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final HiveStorageService<ProductEntity> _storage =
      HiveStorageService<ProductEntity>(HiveBoxNames.productBox);

  @override
  List<ProductEntity> getAll() => _storage.values();

  @override
  Future<void> cacheAll(List<ProductEntity> products) async {
    await _storage.clear();
    for (final product in products) {
      await _storage.put(product.id.toString(), product);
    }
  }

  @override
  Future<void> clear() => _storage.clear();
}
