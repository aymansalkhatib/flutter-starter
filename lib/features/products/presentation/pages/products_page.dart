import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/di/service_locator.dart';
import 'package:flutter_starter/core/ui/components/custom_app_bar.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import '../cubit/product_cubit.dart';
import '../widgets/products_body_widget.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductCubit>()..loadProducts(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: LocaleKeys.productsTitle.tr(context),
        ),
        body: const ProductsBodyWidget(),
      ),
    );
  }
}
