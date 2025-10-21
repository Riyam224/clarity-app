import 'package:clarity/core/error/failure.dart';
import 'package:clarity/core/routing/app_routes.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:clarity/features/products/domain/repositories/product_repo.dart';
import 'package:clarity/features/products/domain/usecases/get_product_details.dart';
import 'package:clarity/features/products/domain/usecases/get_products.dart';
import 'package:clarity/features/products/presentation/cubit/cubit/products_cubit.dart';
import 'package:clarity/features/products/presentation/screens/product_details_screen.dart';
import 'package:clarity/features/products/presentation/screens/products_screen.dart';
import 'package:clarity/features/products/presentation/widgets/product_card.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

// Mock Repository
class MockProductRepo extends Mock implements ProductRepo {}

void main() {
  late MockProductRepo mockProductRepo;
  final sl = GetIt.instance;

  // Mock product data
  final mockProducts = [
    const ProductEntity(
      id: 1,
      title: 'iPhone 13',
      description: 'The latest iPhone with amazing features',
      price: 999.99,
      imageUrl: 'https://dummyjson.com/image/400',
    ),
    const ProductEntity(
      id: 2,
      title: 'Samsung Galaxy S21',
      description: 'High-end Android smartphone',
      price: 799.99,
      imageUrl: 'https://dummyjson.com/image/400',
    ),
    const ProductEntity(
      id: 3,
      title: 'MacBook Pro',
      description: 'Powerful laptop for professionals',
      price: 2399.99,
      imageUrl: 'https://dummyjson.com/image/400',
    ),
    const ProductEntity(
      id: 4,
      title: 'iPad Air',
      description: 'Thin and light tablet',
      price: 599.99,
      imageUrl: 'https://dummyjson.com/image/400',
    ),
    const ProductEntity(
      id: 5,
      title: 'AirPods Pro',
      description: 'Wireless earbuds with noise cancellation',
      price: 249.99,
      imageUrl: 'https://dummyjson.com/image/400',
    ),
    const ProductEntity(
      id: 6,
      title: 'Apple Watch',
      description: 'Smart watch with health tracking',
      price: 399.99,
      imageUrl: 'https://dummyjson.com/image/400',
    ),
  ];

  setUp(() {
    // Reset GetIt
    sl.reset();

    // Initialize mock repository
    mockProductRepo = MockProductRepo();

    // Register mock dependencies
    sl.registerLazySingleton<ProductRepo>(() => mockProductRepo);
    sl.registerLazySingleton(() => GetProductsUseCase(sl()));
    sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));
    sl.registerFactory(
      () => ProductsCubit(getAllProducts: sl(), getProduct: sl()),
    );
  });

  tearDown(() {
    sl.reset();
  });

  // Helper function to create a test router
  GoRouter createTestRouter() {
    return GoRouter(
      errorBuilder: (context, state) =>
          const Scaffold(body: Center(child: Text('404 Not Found'))),
      initialLocation: AppRoutes.products,
      routes: [
        GoRoute(
          path: AppRoutes.products,
          name: AppRoutes.products,
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.productsDetails}/:id',
          name: AppRoutes.productsDetails,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ProductDetailsScreen(id: id);
          },
        ),
      ],
    );
  }

  group('Products Flow Integration Tests', () {
    testWidgets('should load products and display them in a grid',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => Right(mockProducts));

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );

      // Wait for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the async operation to complete
      await tester.pumpAndSettle();

      // Assert - Products should be displayed (at least the visible ones)
      expect(find.byType(ProductCard), findsAtLeastNWidgets(2));
      expect(find.text('iPhone 13'), findsOneWidget);
      expect(find.text('Samsung Galaxy S21'), findsOneWidget);
      expect(find.text('\$999.99'), findsOneWidget);

      // Verify the repository was called
      verify(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .called(1);
    });

    testWidgets('should scroll through the product list',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => Right(mockProducts));

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the GridView
      final gridFinder = find.byType(GridView);
      expect(gridFinder, findsOneWidget);

      // Verify first products are visible
      expect(find.text('iPhone 13'), findsOneWidget);
      expect(find.text('Samsung Galaxy S21'), findsOneWidget);

      // Scroll down
      await tester.drag(gridFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Products should still be visible after scrolling
      expect(find.byType(ProductCard), findsWidgets);
    });

    testWidgets(
        'should navigate to product details when a product card is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => Right(mockProducts));

      when(() => mockProductRepo.getProductById(1))
          .thenAnswer((_) async => Right(mockProducts[0]));

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Products list is displayed
      expect(find.text('🛍️ Products'), findsOneWidget);
      expect(find.text('iPhone 13'), findsOneWidget);

      // Tap on the first product card
      await tester.tap(find.text('iPhone 13'));
      await tester.pumpAndSettle();

      // Assert - Product details screen is displayed
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('iPhone 13'), findsOneWidget);
      expect(find.text('The latest iPhone with amazing features'),
          findsOneWidget);
      expect(find.text('\$999.99'), findsOneWidget);

      // Verify the repository was called for product details
      verify(() => mockProductRepo.getProductById(1)).called(1);
    });

    testWidgets('should navigate to second visible product details',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => Right(mockProducts));

      when(() => mockProductRepo.getProductById(2))
          .thenAnswer((_) async => Right(mockProducts[1]));

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Samsung Galaxy S21 (visible in viewport)
      await tester.tap(find.text('Samsung Galaxy S21'));
      await tester.pumpAndSettle();

      // Assert - Samsung Galaxy S21 details are displayed
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Samsung Galaxy S21'), findsOneWidget);
      expect(find.text('High-end Android smartphone'), findsOneWidget);
      expect(find.text('\$799.99'), findsOneWidget);

      verify(() => mockProductRepo.getProductById(2)).called(1);
    });

    testWidgets('should display product details with all information',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => Right(mockProducts));

      when(() => mockProductRepo.getProductById(1))
          .thenAnswer((_) async => Right(mockProducts[0]));

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to product details
      await tester.tap(find.text('iPhone 13'));
      await tester.pumpAndSettle();

      // Assert - All product details are displayed
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('iPhone 13'), findsOneWidget);
      expect(find.text('The latest iPhone with amazing features'),
          findsOneWidget);
      expect(find.text('\$999.99'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display error message when products fail to load',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer(
        (_) async => Left(
          ServerFailure('Failed to load products'),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Error message should be displayed
      expect(find.text('❌ Failed to load products'), findsOneWidget);
      expect(find.byType(ProductCard), findsNothing);

      verify(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .called(1);
    });

    testWidgets('should display error when product details fail to load',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => Right(mockProducts));

      when(() => mockProductRepo.getProductById(1)).thenAnswer(
        (_) async => Left(
          ServerFailure('Product not found'),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on first product
      await tester.tap(find.text('iPhone 13'));
      await tester.pumpAndSettle();

      // Assert - Error message should be displayed
      expect(find.text('Product not found'), findsOneWidget);

      verify(() => mockProductRepo.getProductById(1)).called(1);
    });

    testWidgets('should display grid layout with correct properties',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockProductRepo.getAllProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => Right(mockProducts));

      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: createTestRouter(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check grid structure
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final gridDelegate = gridView.gridDelegate
          as SliverGridDelegateWithFixedCrossAxisCount;

      expect(gridDelegate.crossAxisCount, 2);
      expect(gridDelegate.crossAxisSpacing, 16);
      expect(gridDelegate.mainAxisSpacing, 16);
      expect(gridDelegate.childAspectRatio, 0.7);

      // Verify visible products are displayed
      expect(find.text('iPhone 13'), findsOneWidget);
      expect(find.text('Samsung Galaxy S21'), findsOneWidget);

      // Scroll to see more products
      await tester.drag(find.byType(GridView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Now we should see different products
      expect(find.byType(ProductCard), findsAtLeastNWidgets(2));
    });
  });
}
