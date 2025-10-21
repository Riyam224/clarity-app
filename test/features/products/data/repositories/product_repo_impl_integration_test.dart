import 'package:clarity/core/network/api_constants.dart';
import 'package:clarity/features/products/data/datasources/product_remote.dart';
import 'package:clarity/features/products/data/repositories/product_repo_impl.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ProductRemoteDataSource remoteDataSource;
  late ProductRepoImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    remoteDataSource = ProductRemoteDataSource(dio);
    repository = ProductRepoImpl(remoteDataSource);
  });

  group('ProductRepoImpl Integration Tests - getAllProducts', () {
    test(
        'should successfully fetch and transform products from API when response is valid',
        () async {
      // Arrange - Mock successful API response
      const limit = 20;
      const skip = 0;
      final mockResponseData = {
        'products': [
          {
            'id': 1,
            'title': 'iPhone 9',
            'description': 'An apple mobile which is nothing like apple',
            'price': 549.0,
            'thumbnail': 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
            'images': ['https://i.dummyjson.com/data/products/1/1.jpg']
          },
          {
            'id': 2,
            'title': 'iPhone X',
            'description': 'SIM-Free, Model A19211 6.5-inch Super Retina HD display',
            'price': 899.0,
            'thumbnail': 'https://i.dummyjson.com/data/products/2/thumbnail.jpg',
            'images': ['https://i.dummyjson.com/data/products/2/1.jpg']
          },
          {
            'id': 3,
            'title': 'Samsung Universe 9',
            'description': 'Samsung\'s new variant which goes beyond Galaxy',
            'price': 1249.0,
            'thumbnail': 'https://i.dummyjson.com/data/products/3/thumbnail.jpg',
            'images': ['https://i.dummyjson.com/data/products/3/1.jpg']
          }
        ],
        'total': 100,
        'skip': 0,
        'limit': 20,
      };

      dioAdapter.onGet(
        'products',
        (server) => server.reply(200, mockResponseData),
        queryParameters: {'limit': limit, 'skip': skip},
      );

      // Act
      final result = await repository.getAllProducts(limit: limit, skip: skip);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (products) {
          expect(products, isA<List<ProductEntity>>());
          expect(products.length, 3);

          // Verify first product
          expect(products[0].id, 1);
          expect(products[0].title, 'iPhone 9');
          expect(products[0].description,
              'An apple mobile which is nothing like apple');
          expect(products[0].price, 549.0);
          expect(products[0].imageUrl,
              'https://i.dummyjson.com/data/products/1/thumbnail.jpg');

          // Verify second product
          expect(products[1].id, 2);
          expect(products[1].title, 'iPhone X');
          expect(products[1].price, 899.0);

          // Verify third product
          expect(products[2].id, 3);
          expect(products[2].title, 'Samsung Universe 9');
          expect(products[2].price, 1249.0);
        },
      );
    });

    test('should handle empty product list from API', () async {
      // Arrange
      const limit = 20;
      const skip = 100;
      final mockResponseData = {
        'products': [],
        'total': 100,
        'skip': 100,
        'limit': 20,
      };

      dioAdapter.onGet(
        'products',
        (server) => server.reply(200, mockResponseData),
        queryParameters: {'limit': limit, 'skip': skip},
      );

      // Act
      final result = await repository.getAllProducts(limit: limit, skip: skip);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (products) {
          expect(products, isA<List<ProductEntity>>());
          expect(products.isEmpty, true);
        },
      );
    });

    test('should handle network error and return Failure', () async {
      // Arrange
      const limit = 20;
      const skip = 0;

      dioAdapter.onGet(
        'products',
        (server) => server.throws(
          500,
          DioException(
            requestOptions: RequestOptions(path: 'products'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: 'products'),
              statusCode: 500,
              statusMessage: 'Internal Server Error',
            ),
          ),
        ),
        queryParameters: {'limit': limit, 'skip': skip},
      );

      // Act
      final result = await repository.getAllProducts(limit: limit, skip: skip);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('Server error'));
        },
        (products) => fail('Expected Left but got Right: $products'),
      );
    });

    test('should handle connection timeout and return Failure', () async {
      // Arrange
      const limit = 20;
      const skip = 0;

      dioAdapter.onGet(
        'products',
        (server) => server.throws(
          408,
          DioException(
            requestOptions: RequestOptions(path: 'products'),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout',
          ),
        ),
        queryParameters: {'limit': limit, 'skip': skip},
      );

      // Act
      final result = await repository.getAllProducts(limit: limit, skip: skip);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
        },
        (products) => fail('Expected Left but got Right: $products'),
      );
    });

    test('should handle 404 error and return Failure', () async {
      // Arrange
      const limit = 20;
      const skip = 0;

      dioAdapter.onGet(
        'products',
        (server) => server.throws(
          404,
          DioException(
            requestOptions: RequestOptions(path: 'products'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: 'products'),
              statusCode: 404,
              statusMessage: 'Not Found',
            ),
          ),
        ),
        queryParameters: {'limit': limit, 'skip': skip},
      );

      // Act
      final result = await repository.getAllProducts(limit: limit, skip: skip);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
        },
        (products) => fail('Expected Left but got Right: $products'),
      );
    });

    test('should handle different pagination parameters correctly', () async {
      // Arrange
      const limit = 10;
      const skip = 20;
      final mockResponseData = {
        'products': [
          {
            'id': 21,
            'title': 'Product 21',
            'description': 'Description 21',
            'price': 100.0,
            'thumbnail': 'https://example.com/21.jpg',
          }
        ],
        'total': 100,
        'skip': skip,
        'limit': limit,
      };

      dioAdapter.onGet(
        'products',
        (server) => server.reply(200, mockResponseData),
        queryParameters: {'limit': limit, 'skip': skip},
      );

      // Act
      final result = await repository.getAllProducts(limit: limit, skip: skip);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (products) {
          expect(products.length, 1);
          expect(products[0].id, 21);
        },
      );
    });
  });

  group('ProductRepoImpl Integration Tests - getProductById', () {
    test('should successfully fetch and transform single product from API',
        () async {
      // Arrange
      const productId = 1;
      final mockProductData = {
        'id': 1,
        'title': 'iPhone 9',
        'description': 'An apple mobile which is nothing like apple',
        'price': 549.0,
        'thumbnail': 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
        'images': ['https://i.dummyjson.com/data/products/1/1.jpg']
      };

      dioAdapter.onGet(
        'products/$productId',
        (server) => server.reply(200, mockProductData),
      );

      // Act
      final result = await repository.getProductById(productId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (product) {
          expect(product, isA<ProductEntity>());
          expect(product.id, 1);
          expect(product.title, 'iPhone 9');
          expect(product.description,
              'An apple mobile which is nothing like apple');
          expect(product.price, 549.0);
          expect(product.imageUrl,
              'https://i.dummyjson.com/data/products/1/thumbnail.jpg');
        },
      );
    });

    test('should handle product with missing optional fields', () async {
      // Arrange
      const productId = 2;
      final mockProductData = {
        'id': 2,
        'title': 'Product Without Image',
        'description': 'This product has no images',
        'price': 299.0,
      };

      dioAdapter.onGet(
        'products/$productId',
        (server) => server.reply(200, mockProductData),
      );

      // Act
      final result = await repository.getProductById(productId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (product) {
          expect(product.id, 2);
          expect(product.title, 'Product Without Image');
          expect(product.price, 299.0);
          expect(product.imageUrl, isNull);
        },
      );
    });

    test('should handle 404 error when product not found', () async {
      // Arrange
      const productId = 9999;

      dioAdapter.onGet(
        'products/$productId',
        (server) => server.throws(
          404,
          DioException(
            requestOptions: RequestOptions(path: 'products/$productId'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: 'products/$productId'),
              statusCode: 404,
              statusMessage: 'Product not found',
            ),
          ),
        ),
      );

      // Act
      final result = await repository.getProductById(productId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
        },
        (product) => fail('Expected Left but got Right: $product'),
      );
    });

    test('should handle server error when fetching product by id', () async {
      // Arrange
      const productId = 1;

      dioAdapter.onGet(
        'products/$productId',
        (server) => server.throws(
          500,
          DioException(
            requestOptions: RequestOptions(path: 'products/$productId'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: 'products/$productId'),
              statusCode: 500,
              statusMessage: 'Internal Server Error',
            ),
          ),
        ),
      );

      // Act
      final result = await repository.getProductById(productId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('Server error'));
        },
        (product) => fail('Expected Left but got Right: $product'),
      );
    });

    test('should handle network connection error for product by id', () async {
      // Arrange
      const productId = 1;

      dioAdapter.onGet(
        'products/$productId',
        (server) => server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(path: 'products/$productId'),
            type: DioExceptionType.connectionError,
            message: 'No internet connection',
          ),
        ),
      );

      // Act
      final result = await repository.getProductById(productId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
        },
        (product) => fail('Expected Left but got Right: $product'),
      );
    });

    test('should handle product with images array but no thumbnail', () async {
      // Arrange
      const productId = 3;
      final mockProductData = {
        'id': 3,
        'title': 'Product With Images Array',
        'description': 'Has images but no thumbnail',
        'price': 399.0,
        'images': [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg'
        ]
      };

      dioAdapter.onGet(
        'products/$productId',
        (server) => server.reply(200, mockProductData),
      );

      // Act
      final result = await repository.getProductById(productId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (product) {
          expect(product.id, 3);
          expect(product.imageUrl, 'https://example.com/image1.jpg');
        },
      );
    });
  });

  group('ProductRepoImpl Integration Tests - Combined Scenarios', () {
    test('should handle multiple sequential API calls successfully', () async {
      // Arrange - Mock for getAllProducts
      final mockListResponse = {
        'products': [
          {
            'id': 1,
            'title': 'Product 1',
            'description': 'Description 1',
            'price': 100.0,
            'thumbnail': 'https://example.com/1.jpg',
          }
        ],
        'total': 1,
        'skip': 0,
        'limit': 20,
      };

      final mockDetailResponse = {
        'id': 1,
        'title': 'Product 1',
        'description': 'Description 1',
        'price': 100.0,
        'thumbnail': 'https://example.com/1.jpg',
      };

      dioAdapter.onGet(
        'products',
        (server) => server.reply(200, mockListResponse),
        queryParameters: {'limit': 20, 'skip': 0},
      );

      dioAdapter.onGet(
        'products/1',
        (server) => server.reply(200, mockDetailResponse),
      );

      // Act - First get all products
      final listResult = await repository.getAllProducts(limit: 20, skip: 0);

      // Assert list result
      expect(listResult.isRight(), true);
      listResult.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (products) {
          expect(products.length, 1);
          expect(products[0].id, 1);
        },
      );

      // Act - Then get product details
      final detailResult = await repository.getProductById(1);

      // Assert detail result
      expect(detailResult.isRight(), true);
      detailResult.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (product) {
          expect(product.id, 1);
          expect(product.title, 'Product 1');
        },
      );
    });

    test('should handle partial success (list success, detail failure)',
        () async {
      // Arrange
      final mockListResponse = {
        'products': [
          {
            'id': 1,
            'title': 'Product 1',
            'description': 'Description 1',
            'price': 100.0,
            'thumbnail': 'https://example.com/1.jpg',
          }
        ],
        'total': 1,
        'skip': 0,
        'limit': 20,
      };

      dioAdapter.onGet(
        'products',
        (server) => server.reply(200, mockListResponse),
        queryParameters: {'limit': 20, 'skip': 0},
      );

      dioAdapter.onGet(
        'products/1',
        (server) => server.throws(
          404,
          DioException(
            requestOptions: RequestOptions(path: 'products/1'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: 'products/1'),
              statusCode: 404,
            ),
          ),
        ),
      );

      // Act & Assert - List should succeed
      final listResult = await repository.getAllProducts(limit: 20, skip: 0);
      expect(listResult.isRight(), true);

      // Act & Assert - Detail should fail
      final detailResult = await repository.getProductById(1);
      expect(detailResult.isLeft(), true);
    });
  });
}
