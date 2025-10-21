import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for integration tests
class IntegrationTestHelpers {
  /// Wait for network requests to complete with a reasonable timeout
  static Future<void> waitForNetworkRequest(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }

  /// Wait for initial app load
  static Future<void> waitForAppLoad(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Navigate to product details by index
  static Future<void> navigateToProductDetails(
    WidgetTester tester,
    int index,
  ) async {
    final productCards = find.byType(GestureDetector);
    await tester.tap(productCards.at(index));
    await waitForNetworkRequest(tester);
  }

  /// Navigate back to previous screen
  static Future<void> navigateBack(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  /// Scroll widget by offset
  static Future<void> scrollWidget(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// Tap on a widget with delay for animation
  static Future<void> tapWithDelay(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Wait for loading indicator to disappear
  static Future<void> waitForLoadingToComplete(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 15));
  }

  /// Verify that a screen has loaded successfully
  static void verifyScreenLoaded(String expectedTitle) {
    expect(find.text(expectedTitle), findsOneWidget);
  }

  /// Get count of visible widgets
  static int getVisibleWidgetCount(Finder finder) {
    return finder.evaluate().length;
  }

  /// Verify minimum number of widgets
  static void verifyMinimumWidgetCount(Finder finder, int minimum) {
    expect(finder.evaluate().length, greaterThanOrEqualTo(minimum));
  }

  /// Verify exact widget count
  static void verifyExactWidgetCount(Finder finder, int count) {
    expect(finder.evaluate().length, equals(count));
  }

  /// Check if widget exists
  static bool widgetExists(Finder finder) {
    return finder.evaluate().isNotEmpty;
  }

  /// Wait for specific widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    throw Exception('Widget not found within timeout');
  }

  /// Scroll to bottom of scrollable widget
  static Future<void> scrollToBottom(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.drag(finder, const Offset(0, -500));
    await tester.pumpAndSettle();
  }

  /// Scroll to top of scrollable widget
  static Future<void> scrollToTop(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.drag(finder, const Offset(0, 500));
    await tester.pumpAndSettle();
  }

  /// Perform fling gesture
  static Future<void> fling(
    WidgetTester tester,
    Finder finder,
    Offset offset,
    double velocity,
  ) async {
    await tester.fling(finder, offset, velocity);
    await tester.pumpAndSettle();
  }

  /// Take screenshot (for debugging purposes)
  static Future<void> takeScreenshot(
    WidgetTester tester,
    String name,
  ) async {
    await tester.pumpAndSettle();
    // Screenshot functionality would be implemented here
    // This is a placeholder for future implementation
  }

  /// Print widget tree (for debugging)
  static void printWidgetTree(WidgetTester tester) {
    // Print all widgets for debugging
    print(tester.allWidgets.toString());
  }

  /// Wait for animation to complete
  static Future<void> waitForAnimation(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  /// Verify no overflow errors
  static void verifyNoOverflow() {
    // This would check for rendering errors
    // Implementation depends on test framework capabilities
  }

  /// Tap at specific coordinates
  static Future<void> tapAt(
    WidgetTester tester,
    Offset position,
  ) async {
    await tester.tapAt(position);
    await tester.pumpAndSettle();
  }

  /// Long press on widget
  static Future<void> longPress(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text into text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Clear text from text field
  static Future<void> clearText(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.enterText(finder, '');
    await tester.pumpAndSettle();
  }
}
