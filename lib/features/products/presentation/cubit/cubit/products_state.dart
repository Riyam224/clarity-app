import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:equatable/equatable.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

final class ProductsInitial extends ProductsState {}

final class ProductsLoading extends ProductsState {}

final class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;

  const ProductsLoaded({required this.products});

  @override
  List<Object> get props => [products];
}

final class ProductDetailLoaded extends ProductsState {
  final ProductEntity product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object> get props => [product];
}

final class ProductsError extends ProductsState {
  final String message;

  const ProductsError({required this.message});

  @override
  List<Object> get props => [message];
}
