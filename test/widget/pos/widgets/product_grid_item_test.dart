import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/pos/presentation/widgets/product_grid_item.dart';

void main() {
  group('ProductGridItem widget', () {
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

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: testProduct,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Rp 15.000,00'), findsOneWidget);
      expect(find.text('Stok: 50'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: testProduct,
              quantity: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should show quantity badge when quantity > 0', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: testProduct,
              quantity: 5,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Keranjang: 5'), findsOneWidget);
    });

    testWidgets('should not show quantity badge when quantity is 0', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: testProduct,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Keranjang: 0'), findsNothing);
    });

    testWidgets('should show out of stock indicator when stock is 0', (tester) async {
      // Arrange
      final outOfStockProduct = Product(
        id: 1,
        name: 'Out of Stock',
        price: 100.0,
        stock: 0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: outOfStockProduct,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Stok Habis'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('should show low stock indicator when stock is low', (tester) async {
      // Arrange
      final lowStockProduct = Product(
        id: 1,
        name: 'Low Stock',
        price: 100.0,
        stock: 5,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: lowStockProduct,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Stok Rendah: 5'), findsOneWidget);
    });

    testWidgets('should show add icon when can add more', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: testProduct,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
    });

    testWidgets('should show check icon when quantity equals stock', (tester) async {
      // Arrange
      final product = Product(
        id: 1,
        name: 'Product',
        price: 100.0,
        stock: 5,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: product,
              quantity: 5,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should be greyed out when out of stock', (tester) async {
      // Arrange
      final outOfStockProduct = Product(
        id: 1,
        name: 'Out of Stock',
        price: 100.0,
        stock: 0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: outOfStockProduct,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.grey.shade300);
    });

    testWidgets('should not be tappable when out of stock', (tester) async {
      // Arrange
      final outOfStockProduct = Product(
        id: 1,
        name: 'Out of Stock',
        price: 100.0,
        stock: 0,
      );
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: outOfStockProduct,
              quantity: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, false);
    });

    testWidgets('should truncate long product names', (tester) async {
      // Arrange
      final longNameProduct = Product(
        id: 1,
        name: 'This is a very long product name that should be truncated',
        price: 100.0,
        stock: 10,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: longNameProduct,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(
        find.text('This is a very long product name that should be truncated'),
      );
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should handle various price formats', (tester) async {
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
            body: ProductGridItem(
              product: product,
              quantity: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 15.000.000,00'), findsOneWidget);
    });

    testWidgets('should display quantity badge with proper styling', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductGridItem(
              product: testProduct,
              quantity: 10,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ProductGridItem),
          matching: find.byType(Container).last,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF2196F3)); // primaryColor
    });
  });
}
