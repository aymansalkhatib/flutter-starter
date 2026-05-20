import 'package:flutter_starter/core/errors/failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_entity.dart';

part 'product_state.freezed.dart';

@freezed
abstract class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.loaded({
    required List<ProductEntity> products,
  }) = _Loaded;
  const factory ProductState.error({
    required Failure failure,
  }) = _Error;
}
