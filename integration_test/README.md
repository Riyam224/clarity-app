# Integration Tests

This directory contains integration tests for the Clarity app. Integration tests verify that different parts of the app work together correctly, including UI interactions, navigation, and data flow.

## Test Structure

### Test Files

- **app_test.dart** - Main integration tests covering overall app functionality
- **products_screen_test.dart** - Tests specific to the products screen
- **product_details_screen_test.dart** - Tests for product details screen
- **navigation_flow_test.dart** - Tests for navigation flows between screens

### Helpers

- **helpers/test_helpers.dart** - Reusable helper functions for integration tests
- **helpers/test_setup.dart** - App initialization helper to ensure proper dependency injection

## Running Integration Tests

### Run All Integration Tests

```bash
flutter test integration_test
```

### Run Specific Test File

```bash
flutter test integration_test/app_test.dart
flutter test integration_test/products_screen_test.dart
flutter test integration_test/product_details_screen_test.dart
flutter test integration_test/navigation_flow_test.dart
```

### Run on Device/Emulator

For better performance and real-world testing, run on a device or emulator:

```bash
flutter drive \
  --driver=integration_test_driver/integration_test_driver.dart \
  --target=integration_test/app_test.dart
```

### Run on Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter drive \
  --driver=integration_test_driver/integration_test_driver.dart \
  --target=integration_test/app_test.dart \
  -d <device_id>
```

## Test Coverage

### App Tests (app_test.dart)
- App launch and initialization
- Products screen loading
- Navigation to product details
- Multiple navigation cycles
- Scroll functionality
- Error handling for images

### Products Screen Tests (products_screen_test.dart)
- Screen rendering
- Loading states
- Data display (products, prices, images)
- Grid layout (2 columns, spacing, padding)
- Product card interactions
- Scroll behavior
- State preservation after navigation

### Product Details Tests (product_details_screen_test.dart)
- Navigation to details screen
- Loading states
- Product information display (image, title, price, description)
- Layout structure and spacing
- Scroll functionality
- Back navigation (button and gesture)
- Multiple product viewing

### Navigation Flow Tests (navigation_flow_test.dart)
- Initial route
- Forward and backward navigation
- Multiple navigation cycles
- Rapid navigation
- State preservation
- App bar updates
- Navigation after scrolling
- Data persistence

## Writing New Tests

When adding new integration tests:

1. Import required packages:
```dart
import 'package:clarity/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
```

2. Initialize integration test binding:
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Your Test Group', () {
    testWidgets('Your test description', (WidgetTester tester) async {
      // Your test code
    });
  });
}
```

3. Use helper functions from `test_helpers.dart`:
```dart
import 'helpers/test_helpers.dart';

// Wait for network requests
await IntegrationTestHelpers.waitForNetworkRequest(tester);

// Navigate to product details
await IntegrationTestHelpers.navigateToProductDetails(tester, 0);

// Navigate back
await IntegrationTestHelpers.navigateBack(tester);
```

## Best Practices

1. **Wait for UI to settle**: Always use `await tester.pumpAndSettle()` after interactions
2. **Use appropriate timeouts**: Network requests may take time, use longer durations for API calls
3. **Test real scenarios**: Simulate actual user workflows
4. **Clean test state**: Each test should be independent
5. **Use descriptive names**: Test names should clearly describe what they verify
6. **Group related tests**: Use `group()` to organize tests logically

## Troubleshooting

### Tests Timeout
- Increase timeout duration: `await tester.pumpAndSettle(const Duration(seconds: 15));`
- Check network connectivity
- Verify API endpoints are accessible

### Flaky Tests
- Add proper wait times between actions
- Use `pumpAndSettle()` instead of `pump()`
- Ensure widgets are fully rendered before interaction

### Widget Not Found
- Verify widget is visible on screen
- Check if scrolling is needed to find widget
- Use `find.byType()` instead of `find.byKey()` when appropriate

## CI/CD Integration

To run integration tests in CI/CD pipelines:

```bash
# Run tests in headless mode
flutter test integration_test --headless

# Generate test report
flutter test integration_test --reporter json > test_results.json
```

## Dependencies

Required packages in `pubspec.yaml`:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

## Notes

- Integration tests require the app to be fully functional
- Network connectivity is required for API tests
- Tests interact with real backend (no mocking at integration level)
- Tests may take longer than unit tests due to full app initialization
