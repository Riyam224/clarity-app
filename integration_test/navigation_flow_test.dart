import 'helpers/test_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Flow Integration Tests', () {
    testWidgets('App starts on products screen', (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should start on products screen
      expect(find.text('🛍️ Products'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Can navigate from products to details', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Tap product card
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should be on details screen
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Can navigate from details back to products', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to details
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back on products screen
      expect(find.text('🛍️ Products'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Back button navigates to products screen', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to details
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back on products screen
      expect(find.text('🛍️ Products'), findsOneWidget);
    });

    testWidgets('Can navigate to multiple different products', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      final productCount = productCards.evaluate().length;

      // Navigate to first product
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.text('Product Details'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Navigate to second product if available
      if (productCount > 1) {
        await tester.tap(productCards.at(1));
        await tester.pumpAndSettle(const Duration(seconds: 10));
        expect(find.text('Product Details'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // Should be back on products screen
      expect(find.text('🛍️ Products'), findsOneWidget);
    });

    testWidgets('Navigation preserves products screen state', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Scroll products grid
      final gridView = find.byType(GridView);
      await tester.drag(gridView, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Navigate to details and back
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Products grid should still exist
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Can perform multiple navigation cycles', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);

      // First cycle
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.text('Product Details'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('🛍️ Products'), findsOneWidget);

      // Second cycle
      await tester.tap(productCards.at(1));
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.text('Product Details'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('🛍️ Products'), findsOneWidget);

      // Third cycle
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.text('Product Details'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('🛍️ Products'), findsOneWidget);
    });

    testWidgets('Navigation shows correct loading states', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to details
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pump();

      // Should show loading on details screen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Loading should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Can navigate rapidly between screens', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);

      // Rapid navigation
      for (int i = 0; i < 3; i++) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 10));
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // Should still be functional
      expect(find.text('🛍️ Products'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('App bar updates correctly during navigation', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Products screen app bar
      expect(find.text('🛍️ Products'), findsOneWidget);

      // Navigate to details
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Details screen app bar
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('🛍️ Products'), findsNothing);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Products screen app bar again
      expect(find.text('🛍️ Products'), findsOneWidget);
      expect(find.text('Product Details'), findsNothing);
    });

    testWidgets('Scaffold count changes correctly during navigation', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have scaffolds on products screen
      expect(find.byType(Scaffold), findsWidgets);

      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have scaffolds on details screen
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Navigation maintains app theme', (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate through screens
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // MaterialApp should still exist
      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // MaterialApp should still exist
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Can navigate to different products without scrolling', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      final visibleProducts = productCards.evaluate().length;

      if (visibleProducts >= 2) {
        // Tap first visible product
        await tester.tap(productCards.at(0));
        await tester.pumpAndSettle(const Duration(seconds: 10));
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Tap second visible product
        await tester.tap(productCards.at(1));
        await tester.pumpAndSettle(const Duration(seconds: 10));
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('🛍️ Products'), findsOneWidget);
      }
    });

    testWidgets('Navigation works after scrolling products', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Scroll down
      final gridView = find.byType(GridView);
      await tester.drag(gridView, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Navigate to a product
      final productCards = find.byType(GestureDetector);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 10));

        expect(find.text('Product Details'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('🛍️ Products'), findsOneWidget);
      }
    });

    testWidgets('Back navigation does not lose products data', (
      WidgetTester tester,
    ) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate away and back
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Product count should have products
      final afterProductCount = find.byType(GestureDetector).evaluate().length;
      expect(afterProductCount, greaterThan(0));
    });
  });
}
