import 'package:clarity/core/error/failure.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:clarity/features/products/domain/usecases/get_product_details.dart';
import 'package:clarity/features/products/domain/usecases/get_products.dart';
import 'package:clarity/features/products/presentation/cubit/cubit/products_state.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getAllProducts;
  final GetProductDetailsUseCase getProduct;

  ProductsCubit({required this.getAllProducts, required this.getProduct})
    : super(ProductsInitial());

  Future<void> fetchProducts() async {
    emit(ProductsLoading());
    final Either<Failure, List<ProductEntity>> result = await getAllProducts(
      limit: 20,
      skip: 0,
    );

    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  Future<void> fetchProductDetails(int id) async {
    emit(ProductsLoading());
    final Either<Failure, ProductEntity> result = await getProduct(id);

    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }
}
