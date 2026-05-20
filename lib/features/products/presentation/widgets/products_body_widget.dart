import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/extensions/edge_insets_extension.dart';
import 'package:flutter_starter/core/ui/components/animated_dots_loader.dart';
import 'package:flutter_starter/core/ui/components/empty_widget.dart';
import 'package:flutter_starter/core/ui/components/failure_widget.dart';
import 'package:flutter_starter/core/ui/snackbar/overlay_snackbar.dart';
import 'package:flutter_starter/core/ui/snackbar/scaffold_snackbar.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import 'product_card_widget.dart';

class ProductsBodyWidget extends StatelessWidget {
  const ProductsBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => AnimatedDotsLoader.show(context),
          loaded: (_) => AnimatedDotsLoader.dismiss(),
          error: (failure) {
            AnimatedDotsLoader.dismiss();
            showSnackbar(failure.message, type: OverlaySnackbarType.error);
          },
        );
      },
      builder: (context, state) => state.maybeWhen(
        loaded: (products) => EmptyWidget(
          isEmpty: products.isEmpty,
          message: LocaleKeys.productsNoItemsTitle.tr(context),
          subtitle: LocaleKeys.productsNoItemsSubtitle.tr(context),
          child: GridView.builder(
            padding: 16.all,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) =>
                ProductCardWidget(product: products[index]),
          ),
        ),
        error: (failure) => FailureWidget(
          failure: failure,
          onRetry: context.read<ProductCubit>().loadProducts,
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
