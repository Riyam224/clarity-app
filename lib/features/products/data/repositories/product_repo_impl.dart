import 'package:clarity/core/error/failure.dart';
import 'package:clarity/core/network/api_error_handler.dart';
import 'package:clarity/features/products/data/datasources/product_remote.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:clarity/features/products/domain/repositories/product_repo.dart';
import 'package:dartz/dartz.dart';

class ProductRepoImpl implements ProductRepo {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepoImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final httpResponse = await remoteDataSource.getAllProducts(limit, skip);

      // Extract products from the wrapper response
      final productsResponse = httpResponse.data;
      final products = productsResponse.products
          .map((model) => model.toEntity())
          .toList();

      return Right(products);
    } catch (error) {
      final failure = ApiErrorHandler.handleError(error);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    try {
      final httpResponse = await remoteDataSource.getProductById(id.toString());
      final model = httpResponse.data;
      final entity = model.toEntity();
      return Right(entity);
    } catch (error) {
      final failure = ApiErrorHandler.handleError(error);
      return Left(failure);
    }
  }
}
