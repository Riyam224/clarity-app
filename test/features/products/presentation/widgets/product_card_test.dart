import 'package:clarity/core/routing/app_routes.dart';
import 'package:clarity/features/products/domain/entities/product_entity.dart';
import 'package:clarity/features/products/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  // Helper function to create a testable widget with GoRouter
  Widget createWidgetUnderTest(ProductEntity product) {
    return MaterialApp(
      home: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: Scaffold(
          body: ProductCard(product: product),
        ),
      ),
    );
  }

  group('ProductCard Widget Tests', () {
    const testProduct = ProductEntity(
      id: 1,
      title: 'iPhone 9',
      description: 'An apple mobile which is nothing like apple',
      price: 549.99,
      imageUrl: 'https://example.com/image.jpg',
    );

    testWidgets('should display product title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      expect(find.text('iPhone 9'), findsOneWidget);
    });

    testWidgets('should display product price with dollar sign',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      expect(find.text('\$549.99'), findsOneWidget);
    });

    testWidgets('should display product image when imageUrl is provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget(imageFinder);
      expect(imageWidget.image, isA<NetworkImage>());
    });

    testWidgets('should display error icon when imageUrl is null',
        (WidgetTester tester) async {
      // Arrange
      const productWithoutImage = ProductEntity(
        id: 1,
        title: 'iPhone 9',
        description: 'An apple mobile which is nothing like apple',
        price: 549.99,
        imageUrl: null,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(productWithoutImage));

      // Assert
      expect(find.byType(Image), findsOneWidget);
      final Image imageWidget = tester.widget(find.byType(Image));
      final NetworkImage networkImage = imageWidget.image as NetworkImage;
      expect(networkImage.url, '');
    });

    testWidgets('should truncate long title with ellipsis',
        (WidgetTester tester) async {
      // Arrange
      const productWithLongTitle = ProductEntity(
        id: 1,
        title:
            'This is a very long product title that should be truncated with ellipsis',
        description: 'Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(productWithLongTitle));

      // Assert
      final textFinder = find.text(
          'This is a very long product title that should be truncated with ellipsis');
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should have rounded corners and shadow',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      final containerFinder = find.descendant(
        of: find.byType(ProductCard),
        matching: find.byType(Container),
      );

      final Container container = tester.widget(containerFinder.first);
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.color, Colors.white);
    });

    testWidgets('should navigate to product details when tapped',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockGoRouter.go(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Act
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockGoRouter.go(AppRoutes.productDetailsPath(1))).called(1);
    });

    testWidgets('should have correct layout structure',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(Padding), findsAtLeastNWidgets(2));
    });

    testWidgets('should display price in green color',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      final priceFinder = find.text('\$549.99');
      final Text priceWidget = tester.widget(priceFinder);
      expect(priceWidget.style?.color, Colors.green);
    });

    testWidgets('should display title in bold',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      final titleFinder = find.text('iPhone 9');
      final Text titleWidget = tester.widget(titleFinder);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should have image with BoxFit.cover',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testProduct));

      // Assert
      final imageFinder = find.byType(Image);
      final Image imageWidget = tester.widget(imageFinder);
      expect(imageWidget.fit, BoxFit.cover);
      expect(imageWidget.width, double.infinity);
    });

    testWidgets('should display different products correctly',
        (WidgetTester tester) async {
      // Arrange
      const product1 = ProductEntity(
        id: 1,
        title: 'Product 1',
        description: 'Description 1',
        price: 99.99,
        imageUrl: 'https://example.com/image1.jpg',
      );

      const product2 = ProductEntity(
        id: 2,
        title: 'Product 2',
        description: 'Description 2',
        price: 199.99,
        imageUrl: 'https://example.com/image2.jpg',
      );

      // Act - Test first product
      await tester.pumpWidget(createWidgetUnderTest(product1));
      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);

      // Act - Test second product
      await tester.pumpWidget(createWidgetUnderTest(product2));
      expect(find.text('Product 2'), findsOneWidget);
      expect(find.text('\$199.99'), findsOneWidget);
    });
  });
}
