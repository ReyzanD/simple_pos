import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/inventory/presentation/widgets/product_list_item.dart';

void main() {
  group('ProductListItem widget', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: 1,
        name: 'Test Product',
        price: 15000.0,
        stock: 50,
      );
    });

    testWidgets('should display product information', (tester) async {
      // Arrange
      bool editPressed = false;
      bool deletePressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: testProduct,
              onEdit: () => editPressed = true,
              onDelete: () => deletePressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Rp 15.000,00'), findsOneWidget);
      expect(find.text('Stok: 50'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should call onEdit when edit button is pressed', (tester) async {
      // Arrange
      bool editPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: testProduct,
              onEdit: () => editPressed = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Assert
      expect(editPressed, true);
    });

    testWidgets('should call onDelete when delete button is pressed', (tester) async {
      // Arrange
      bool deletePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: testProduct,
              onEdit: () {},
              onDelete: () => deletePressed = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Assert
      expect(deletePressed, true);
    });

    testWidgets('should show green chip for normal stock', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: testProduct,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      final chip = tester.widget<Chip>(
        find.descendant(
          of: find.byType(Chip),
          matching: find.byType(Chip),
        ),
      );
      expect(chip.backgroundColor, Colors.green.shade100);
    });

    testWidgets('should show orange chip for low stock', (tester) async {
      // Arrange
      final lowStockProduct = Product(
        id: 1,
        name: 'Low Stock Product',
        price: 100.0,
        stock: 5,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: lowStockProduct,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      final chip = tester.widget<Chip>(
        find.descendant(
          of: find.byType(Chip),
          matching: find.byType(Chip),
        ),
      );
      expect(chip.backgroundColor, Colors.orange.shade100);
    });

    testWidgets('should show red chip for out of stock', (tester) async {
      // Arrange
      final outOfStockProduct = Product(
        id: 1,
        name: 'Out of Stock Product',
        price: 100.0,
        stock: 0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: outOfStockProduct,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      final chip = tester.widget<Chip>(
        find.descendant(
          of: find.byType(Chip),
          matching: find.byType(Chip),
        ),
      );
      expect(chip.backgroundColor, Colors.red.shade100);
    });

    testWidgets('should display product ID in CircleAvatar', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: testProduct,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('1'), findsOneWidget);
      final circleAvatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar),
      );
      expect(circleAvatar.backgroundColor, const Color(0xFF2196F3)); // primaryColor
    });

    testWidgets('should show question mark for product without ID', (tester) async {
      // Arrange
      final productWithoutId = Product(
        name: 'New Product',
        price: 100.0,
        stock: 10,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: productWithoutId,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should format price correctly', (tester) async {
      // Arrange
      final product = Product(
        id: 1,
        name: 'Product',
        price: 15000000.0,
        stock: 10,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: product,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 15.000.000,00'), findsOneWidget);
    });

    testWidgets('should have correct tooltip for buttons', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListItem(
              product: testProduct,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byTooltip('Edit'), findsOneWidget);
      expect(find.byTooltip('Delete'), findsOneWidget);
    });
  });
}
