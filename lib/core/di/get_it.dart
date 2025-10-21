import 'package:clarity/core/network/dio_client.dart';
import 'package:clarity/features/products/data/datasources/product_remote.dart';
import 'package:clarity/features/products/data/repositories/product_repo_impl.dart';
import 'package:clarity/features/products/domain/repositories/product_repo.dart';
import 'package:clarity/features/products/domain/usecases/get_product_details.dart';
import 'package:clarity/features/products/domain/usecases/get_products.dart';
import 'package:clarity/features/products/presentation/cubit/cubit/products_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  await _setupCore();
  _setupProducts();
}

Future<void> _setupCore() async {
  //  2. Dio Client
  sl.registerLazySingleton<Dio>(() => DioClient.createDio());
}

void _setupProducts() {
  //  6. Product Remote Data Source (Retrofit)
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(sl()),
  );

  //  7. Product Repository
  sl.registerLazySingleton<ProductRepo>(() => ProductRepoImpl(sl()));

  //  8. Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));
  //  9. Cubits
  sl.registerFactory(
    () => ProductsCubit(getAllProducts: sl(), getProduct: sl()),
  );
}
