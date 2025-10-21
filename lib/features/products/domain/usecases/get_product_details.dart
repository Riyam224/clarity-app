import 'package:clarity/core/error/failure.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:clarity/features/products/domain/repositories/product_repo.dart';
import 'package:dartz/dartz.dart';

class GetProductDetailsUseCase {
  final ProductRepo productRepo;
  GetProductDetailsUseCase(this.productRepo);

  Future<Either<Failure, ProductEntity>> call(int id) {
    return productRepo.getProductById(id);
  }
}
