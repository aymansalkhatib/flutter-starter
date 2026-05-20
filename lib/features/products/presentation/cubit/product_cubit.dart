import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/extensions/safe_emit_extension.dart';
import 'package:flutter_starter/core/shared/usecase.dart';

import '../../domain/usecases/get_products_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase _getProductsUseCase;

  ProductCubit({required GetProductsUseCase getProductsUseCase})
      : _getProductsUseCase = getProductsUseCase,
        super(const ProductState.initial());

  Future<void> loadProducts() async {
    safeEmit(const ProductState.loading());
    final result = await _getProductsUseCase(NoParams.instance);
    result.fold(
      (failure) => safeEmit(ProductState.error(failure: failure)),
      (products) => safeEmit(ProductState.loaded(products: products)),
    );
  }
}
