import 'package:clarity/core/error/failure.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepo {
  Future<Either<Failure, List<ProductEntity>>> getAllProducts({
    int limit = 20,
    int skip = 0,
  });

  Future<Either<Failure, ProductEntity>> getProductById(int id);
}
