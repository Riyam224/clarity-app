import 'package:clarity/features/products/data/datasources/product_remote.dart';
import 'package:clarity/features/products/data/models/product_model.dart';
import 'package:clarity/features/products/data/models/products_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ProductRemoteDataSource productRemoteDataSource;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    productRemoteDataSource = ProductRemoteDataSource(dio);
  });

  group('ProductRemoteDataSource', () {
    group('getAllProducts', () {
      test('should return ProductsResponse when the call is successful',
          () async {
        // Arrange
        final mockResponse = {
          'products': [
            {
              'id': 1,
              'title': 'iPhone 9',
              'description': 'An apple mobile which is nothing like apple',
              'price': 549,
              'thumbnail': 'https://example.com/image1.jpg',
            },
            {
              'id': 2,
              'title': 'iPhone X',
              'description':
                  'SIM-Free, Model A19211 6.5-inch Super Retina HD display',
              'price': 899,
              'thumbnail': 'https://example.com/image2.jpg',
            },
          ],
          'total': 100,
          'skip': 0,
          'limit': 10,
        };

        dioAdapter.onGet(
          'products',
          (server) => server.reply(200, mockResponse),
          queryParameters: {'limit': 10, 'skip': 0},
        );

        // Act
        final result = await productRemoteDataSource.getAllProducts(10, 0);

        // Assert
        expect(result.response.statusCode, 200);
        expect(result.data, isA<ProductsResponse>());
        expect(result.data.products.length, 2);
        expect(result.data.total, 100);
        expect(result.data.skip, 0);
        expect(result.data.limit, 10);
        expect(result.data.products[0].id, 1);
        expect(result.data.products[0].title, 'iPhone 9');
        expect(result.data.products[0].price, 549);
      });

      test('should throw DioException when the call fails with 404', () async {
        // Arrange
        dioAdapter.onGet(
          'products',
          (server) => server.reply(404, {'message': 'Not Found'}),
          queryParameters: {'limit': 10, 'skip': 0},
        );

        // Act & Assert
        expect(
          () => productRemoteDataSource.getAllProducts(10, 0),
          throwsA(isA<DioException>()),
        );
      });

      test('should throw DioException when the call fails with 500', () async {
        // Arrange
        dioAdapter.onGet(
          'products',
          (server) => server.reply(500, {'message': 'Internal Server Error'}),
          queryParameters: {'limit': 10, 'skip': 0},
        );

        // Act & Assert
        expect(
          () => productRemoteDataSource.getAllProducts(10, 0),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle empty products list', () async {
        // Arrange
        final mockResponse = {
          'products': [],
          'total': 0,
          'skip': 0,
          'limit': 10,
        };

        dioAdapter.onGet(
          'products',
          (server) => server.reply(200, mockResponse),
          queryParameters: {'limit': 10, 'skip': 0},
        );

        // Act
        final result = await productRemoteDataSource.getAllProducts(10, 0);

        // Assert
        expect(result.response.statusCode, 200);
        expect(result.data.products, isEmpty);
        expect(result.data.total, 0);
      });
    });

    group('getProductById', () {
      test('should return a single ProductModel when the call is successful',
          () async {
        // Arrange
        final mockProduct = {
          'id': 1,
          'title': 'iPhone 9',
          'description': 'An apple mobile which is nothing like apple',
          'price': 549,
          'thumbnail': 'https://example.com/image1.jpg',
        };

        dioAdapter.onGet(
          'products/1',
          (server) => server.reply(200, mockProduct),
        );

        // Act
        final result = await productRemoteDataSource.getProductById('1');

        // Assert
        expect(result.response.statusCode, 200);
        expect(result.data, isA<ProductModel>());
        expect(result.data.id, 1);
        expect(result.data.title, 'iPhone 9');
        expect(result.data.description, 'An apple mobile which is nothing like apple');
        expect(result.data.price, 549);
        expect(result.data.imageUrl, 'https://example.com/image1.jpg');
      });

      test('should throw DioException when the call fails with 404', () async {
        // Arrange
        dioAdapter.onGet(
          'products/999',
          (server) => server.reply(404, {'message': 'Product not found'}),
        );

        // Act & Assert
        expect(
          () => productRemoteDataSource.getProductById('999'),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle product with images array instead of thumbnail',
          () async {
        // Arrange
        final mockProduct = {
          'id': 1,
          'title': 'iPhone 9',
          'description': 'An apple mobile which is nothing like apple',
          'price': 549,
          'images': ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        };

        dioAdapter.onGet(
          'products/1',
          (server) => server.reply(200, mockProduct),
        );

        // Act
        final result = await productRemoteDataSource.getProductById('1');

        // Assert
        expect(result.response.statusCode, 200);
        expect(result.data.imageUrl, 'https://example.com/image1.jpg');
      });

      test('should handle product with null imageUrl', () async {
        // Arrange
        final mockProduct = {
          'id': 1,
          'title': 'iPhone 9',
          'description': 'An apple mobile which is nothing like apple',
          'price': 549,
        };

        dioAdapter.onGet(
          'products/1',
          (server) => server.reply(200, mockProduct),
        );

        // Act
        final result = await productRemoteDataSource.getProductById('1');

        // Assert
        expect(result.response.statusCode, 200);
        expect(result.data.imageUrl, isNull);
      });
    });
  });
}
