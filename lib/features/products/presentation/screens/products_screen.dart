import 'package:clarity/features/products/presentation/cubit/cubit/products_cubit.dart';
import 'package:clarity/features/products/presentation/cubit/cubit/products_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:clarity/features/products/presentation/widgets/product_card.dart';
import 'package:get_it/get_it.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) => GetIt.instance<ProductsCubit>()..fetchProducts(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '🛍️ Products',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductsError) {
              return Center(
                child: Text(
                  '❌ ${state.message}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            if (state is ProductsLoaded) {
              final products = state.products;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(product: product);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
