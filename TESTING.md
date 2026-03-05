# Simple POS - Testing Guide

This guide explains how to run and write tests for the Simple POS application.

## Table of Contents

1. [Running Tests](#running-tests)
2. [Test Structure](#test-structure)
3. [Writing Tests](#writing-tests)
4. [Coverage Requirements](#coverage-requirements)
5. [Testing Conventions](#testing-conventions)

---

## Running Tests

### Run All Tests

```bash
# Using the test script (Unix/Linux/macOS)
./scripts/run_all_tests.sh

# Using the test script (Windows)
scripts\run_all_tests.bat

# Or manually
flutter test
```

### Run Specific Test Types

```bash
# Unit tests only
flutter test test/unit

# Widget tests only
flutter test test/widget

# Integration tests only
flutter test integration_test

# Specific test file
flutter test test/unit/core/utils/validators_test.dart

# Specific test group
flutter test --name "Validators.validateProductName"
```

### Run Tests with Coverage

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML coverage report (requires lcov installed)
genhtml coverage/lcov.info -o coverage/html

# View the report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

---

## Test Structure

The test directory is organized as follows:

```
test/
├── unit/                           # Unit tests
│   ├── core/
│   │   └── utils/                  # Utility tests
│   ├── features/
│   │   ├── inventory/             # Inventory feature tests
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Entity tests
│   │   │   │   └── usecases/      # Use case tests
│   │   ├── pos/                   # POS feature tests
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       └── usecases/
│   │   └── sales/                 # Sales feature tests (future)
│   └── helpers/                   # Test helpers and fixtures
│       ├── test_constants.dart
│       └── mocks.dart
├── widget/                         # Widget tests
│   ├── inventory/
│   │   └── widgets/
│   ├── pos/
│   │   └── widgets/
│   └── shared/
│       └── widgets/
└── integration/                    # Integration tests
    ├── inventory_flow_test.dart
    ├── pos_flow_test.dart
    └── checkout_flow_test.dart

integration_test/                   # Integration tests (Flutter specific)
└── (same structure as test/integration)
```

---

## Writing Tests

### Unit Tests

Unit tests test pure functions and business logic in isolation.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/utils/validators.dart';

void main() {
  group('Validators.validateProductName', () {
    test('should return trimmed name when valid', () {
      // Arrange
      const validName = '  Test Product  ';

      // Act
      final result = Validators.validateProductName(validName);

      // Assert
      expect(result, 'Test Product');
    });

    test('should throw ValidationException when name is empty', () {
      // Arrange
      const emptyName = '';

      // Act & Assert
      expect(
        () => Validators.validateProductName(emptyName),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

### Widget Tests

Widget tests verify UI components render and behave correctly.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/shared/widgets/price_text.dart';

void main() {
  group('PriceText widget', () {
    testWidgets('should display price with decimals by default', (tester) async {
      // Arrange
      const price = 15000.50;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(price: price),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 15.000,50'), findsOneWidget);
    });
  });
}
```

### Integration Tests

Integration tests verify complete user workflows.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:simple_pos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Inventory Flow Integration Tests', () {
    testWidgets('should add, retrieve, update, and delete product', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to inventory screen
      final inventoryButton = find.text('Inventory');
      await tester.tap(inventoryButton);
      await tester.pumpAndSettle();

      // ... test workflow
    });
  });
}
```

### Use Case Tests (with Mocks)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/features/inventory/domain/usecases/add_product_usecase.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([ProductRepository])
import 'add_product_usecase_test.mocks.dart';

void main() {
  late AddProductUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = AddProductUseCase(repository: mockRepository);
  });

  test('should add product successfully', () async {
    // Arrange
    final product = Product(name: 'Test', price: 100.0, stock: 10);
    when(mockRepository.addProduct(any))
        .thenAnswer((_) async => product);

    // Act
    final result = await useCase.execute(product);

    // Assert
    expect(result.name, 'Test');
    verify(mockRepository.addProduct(product)).called(1);
  });
}
```

---

## Coverage Requirements

### Target Coverage by Layer

| Layer | Target Coverage |
|-------|----------------|
| Domain (entities, use cases) | 90%+ |
| Data (repositories, data sources) | 80%+ |
| Presentation (widgets, controllers) | 70%+ |
| **Overall** | **75%+** |

### View Coverage Report

After running tests with coverage:

```bash
# View summary in terminal
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### Coverage Scripts

```bash
# Run tests and generate coverage
./scripts/test_coverage.sh

# Or manually
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

---

## Testing Conventions

### Naming Conventions

- **Test files**: `[name]_test.dart`
- **Test groups**: Use `group()` to organize related tests
- **Test names**: Use descriptive names that describe what is being tested

```dart
group('ClassName', () {
  group('methodName', () {
    test('should return expected value when condition', () {
      // Test code
    });
  });
});
```

### AAA Pattern (Arrange-Act-Assert)

```dart
test('should calculate total correctly', () {
  // Arrange - Set up test data
  final cartItem = CartItem(product: product, quantity: 5);
  const expectedTotal = 500.0;

  // Act - Execute the code being tested
  final total = cartItem.totalPrice;

  // Assert - Verify the result
  expect(total, expectedTotal);
});
```

### Mock Generation

When using mocks, generate them with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test Data

Use test constants and helpers for consistency:

```dart
import '../../../helpers/test_constants.dart';

test('should validate product', () {
  final product = Product(
    name: TestConstants.testProductName,
    price: TestConstants.testProductPrice,
    stock: TestConstants.testProductStock,
  );
  // Test code
});
```

---

## Continuous Integration

In CI/CD pipelines, run:

```bash
# Install dependencies
flutter pub get

# Generate mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## Best Practices

1. **Test behavior, not implementation** - Focus on what the code does, not how
2. **Keep tests independent** - Each test should be able to run alone
3. **Use descriptive test names** - Make it clear what is being tested
4. **Mock external dependencies** - Use mocks for databases, APIs, etc.
5. **Test edge cases** - Include null values, empty strings, boundary conditions
6. **Keep tests fast** - Unit tests should run in milliseconds
7. **Avoid test interdependence** - Tests shouldn't rely on other tests
8. **Use setUp/tearDown** - For common test setup/cleanup
9. **Group related tests** - Use `group()` for organization
10. **Follow TDD** - Write tests before implementation when possible

---

## Troubleshooting

### Tests Fail with "No widget tests found"

Ensure you're running tests from the project root:
```bash
cd D:\CODE\Project\simple_pos
flutter test
```

### Mocks Not Generated

Run the build runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Integration Tests Fail

Make sure you have the integration_test package installed:
```bash
flutter pub get
```

### Coverage Report Not Generated

Ensure you have lcov installed:
- macOS: `brew install lcov`
- Linux: `sudo apt-get install lcov`
- Windows: Download from https://github.com/linux-test-project/lcov

---

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [ Mockito Package](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
