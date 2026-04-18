import 'package:flutter_genesis/core/constants/api_endpoints.dart';
import 'package:flutter_genesis/core/network/api_client.dart';

import '../../domain/entities/product_entity.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductEntity>> getAll();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  const ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductEntity>> getAll() async {
    final res = await _apiClient.get(ApiEndpoints.products);
    final list = res.data as List<dynamic>;
    return list
        .map((e) => ProductEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
