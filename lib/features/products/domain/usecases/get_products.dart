import 'package:clarity/core/error/failure.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:clarity/features/products/domain/repositories/product_repo.dart';
import 'package:dartz/dartz.dart';

class GetProductsUseCase {
  final ProductRepo productRepo;
  GetProductsUseCase(this.productRepo);

  Future<Either<Failure, List<ProductEntity>>> call({
    int limit = 20,
    int skip = 0,
  }) {
    return productRepo.getAllProducts(limit: limit, skip: skip);
  }
}
