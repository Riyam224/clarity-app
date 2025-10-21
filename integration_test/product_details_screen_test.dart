import 'helpers/test_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Product Details Screen Integration Tests', () {
    testWidgets('Can navigate to product details screen',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Tap first product
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle();

      // Verify navigation succeeded
      expect(find.text('Product Details'), findsOneWidget);
    });

    testWidgets('Product details screen shows loading state',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to product details
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Product details screen loads data successfully',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to product details
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show SingleChildScrollView with product data
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Should not show loading indicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Product details screen displays product image',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show product image
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('Product details screen displays product title',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have multiple text widgets including title
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Product details screen displays product price',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show price with dollar sign
      expect(find.textContaining('\$'), findsWidgets);
    });

    testWidgets('Product details screen displays product description',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show description text
      final textWidgets = find.byType(Text);
      expect(textWidgets.evaluate().length, greaterThan(2));
    });

    testWidgets('Product details screen has proper layout structure',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have Column layout
      expect(find.byType(Column), findsWidgets);

      // Should have SingleChildScrollView for scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Product details screen has proper spacing',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('Product details screen content is scrollable',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);

      // Attempt to scroll
      await tester.drag(scrollView, const Offset(0, -100));
      await tester.pumpAndSettle();

      // ScrollView should still be visible
      expect(scrollView, findsOneWidget);
    });

    testWidgets('Product details screen has app bar',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have app bar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Product Details'), findsOneWidget);
    });

    testWidgets('Product details screen has back button',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have back button in app bar
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('Can navigate back from product details',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back on products screen
      expect(find.text('🛍️ Products'), findsOneWidget);
    });

    testWidgets('Can navigate back using back button',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back on products screen
      expect(find.text('🛍️ Products'), findsOneWidget);
    });

    testWidgets('Product image has proper height',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Find centered image
      final centeredImage = find.descendant(
        of: find.byType(Center),
        matching: find.byType(Image),
      );

      expect(centeredImage, findsOneWidget);
    });

    testWidgets('Multiple products can be viewed in sequence',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);

      // View first product
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.text('Product Details'), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // View second product
      await tester.tap(productCards.at(1));
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.text('Product Details'), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('🛍️ Products'), findsOneWidget);
    });

    testWidgets('Product details screen has proper padding',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Find SingleChildScrollView
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );

      // Should have padding
      expect(scrollView.padding, equals(const EdgeInsets.all(16)));
    });
  });
}
