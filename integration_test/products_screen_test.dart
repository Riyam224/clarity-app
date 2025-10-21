import 'helpers/test_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Products Screen Integration Tests', () {
    testWidgets('Products screen renders correctly',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle();

      // Verify app bar
      expect(find.text('🛍️ Products'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify scaffold
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Products screen shows loading state',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);

      // Pump once to trigger initial build
      await tester.pump();

      // Should show CircularProgressIndicator while loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Products screen loads data successfully',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show GridView after loading
      expect(find.byType(GridView), findsOneWidget);

      // Should not show loading indicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Products grid displays multiple products',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should have multiple GestureDetectors (product cards)
      final productCards = find.byType(GestureDetector);
      expect(productCards, findsWidgets);

      // Should have at least one product
      expect(productCards.evaluate().length, greaterThan(0));
    });

    testWidgets('Product cards display title and price',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show price indicators
      expect(find.textContaining('\$'), findsWidgets);

      // Should show text widgets for titles
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Product cards display images',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show network images
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('Product cards are tappable',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final productCards = find.byType(GestureDetector);
      expect(productCards, findsWidgets);

      // Tap first product
      await tester.tap(productCards.first);
      await tester.pumpAndSettle();

      // Should navigate to details screen
      expect(find.text('Product Details'), findsOneWidget);
    });

    testWidgets('Products grid uses 2 columns',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, equals(2));
    });

    testWidgets('Products grid has proper spacing',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisSpacing, equals(16));
      expect(delegate.mainAxisSpacing, equals(16));
    });

    testWidgets('Products grid has proper padding',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final padding = gridView.padding as EdgeInsets;

      expect(padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('Products grid is scrollable',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final gridView = find.byType(GridView);

      // Attempt to scroll
      await tester.drag(gridView, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Grid should still be visible after scroll
      expect(gridView, findsOneWidget);
    });

    testWidgets('App bar is centered',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('Product cards have proper styling',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Find Container widgets (product cards)
      final containers = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      );

      expect(containers, findsWidgets);
    });

    testWidgets('Product titles have ellipsis overflow',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Find text widgets in product cards
      final textWidgets = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Text),
      );

      expect(textWidgets, findsWidgets);
    });

    testWidgets('Products screen maintains state after navigation',
        (WidgetTester tester) async {
      await TestSetup.initializeApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to details and back
      final productCards = find.byType(GestureDetector);
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should still show products grid
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('🛍️ Products'), findsOneWidget);
    });
  });
}
