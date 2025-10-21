import 'package:clarity/core/di/get_it.dart';
import 'package:clarity/main_development.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to properly initialize the app for integration tests
class TestSetup {
  static bool _isInitialized = false;

  /// Initialize app with proper dependency injection
  static Future<void> initializeApp(WidgetTester tester) async {
    if (!_isInitialized) {
      // Setup dependencies before pumping the app
      await setupDependencies();
      _isInitialized = true;

      // Small delay to ensure everything is registered
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Pump the app
    await tester.pumpWidget(const MyApp());

    // Give it a moment to start rendering
    await tester.pump();
  }

  /// Reset initialization state (useful for testing)
  static void reset() {
    _isInitialized = false;
  }
}
