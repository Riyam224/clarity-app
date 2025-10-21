import 'package:clarity/core/network/api_constants.dart';
import 'package:clarity/features/products/data/models/product_model.dart';
import 'package:clarity/features/products/data/models/products_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'product_remote.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ProductRemoteDataSource {
  factory ProductRemoteDataSource(Dio dio, {String baseUrl}) =
      _ProductRemoteDataSource;

  @GET("products")
  Future<HttpResponse<ProductsResponse>> getAllProducts(
    @Query('limit') int limit,
    @Query('skip') int skip,
  );

  /// Fetch a single product by ID
  @GET("products/{id}")
  Future<HttpResponse<ProductModel>> getProductById(@Path("id") String id);
}
