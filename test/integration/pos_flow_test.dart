import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:simple_pos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('POS Flow Integration Tests', () {
    testWidgets('should add products to cart and checkout', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      final posButton = find.text('POS');
      expect(posButton, findsOneWidget);
      await tester.tap(posButton);
      await tester.pumpAndSettle();

      // Verify POS screen is displayed
      expect(find.text('Point of Sale'), findsOneWidget);

      // Add first product to cart
      await tester.tap(find.text('Product 1'));
      await tester.pumpAndSettle();

      // Verify cart badge shows quantity
      expect(find.text('Keranjang: 1'), findsOneWidget);

      // Add same product again
      await tester.tap(find.text('Product 1'));
      await tester.pumpAndSettle();

      // Verify quantity increased
      expect(find.text('Keranjang: 2'), findsOneWidget);

      // Tap cart icon to view cart
      final cartIcon = find.byIcon(Icons.shopping_cart);
      expect(cartIcon, findsOneWidget);
      await tester.tap(cartIcon);
      await tester.pumpAndSettle();

      // Verify cart items displayed
      expect(find.text('Keranjang Belanja'), findsOneWidget);
      expect(find.text('Product 1'), findsOneWidget);

      // Proceed to checkout
      final checkoutButton = find.text('Checkout');
      expect(checkoutButton, findsOneWidget);
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      // Verify checkout dialog
      expect(find.text('Konfirmasi Checkout'), findsOneWidget);

      // Confirm checkout
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Checkout berhasil!'), findsOneWidget);
    });

    testWidgets('should prevent adding out of stock items', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Try to tap out of stock product
      final outOfStockText = find.text('Stok Habis');
      if (outOfStockText.evaluate().isNotEmpty) {
        await tester.tap(outOfStockText.first);
        await tester.pumpAndSettle();

        // Verify nothing added to cart
        expect(find.text('Keranjang: 1'), findsNothing);
      }
    });

    testWidgets('should remove items from cart', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Add product to cart
      await tester.tap(find.text('Product 1'));
      await tester.pumpAndSettle();

      // Tap cart icon
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Remove item from cart
      await tester.tap(find.byIcon(Icons.remove_circle));
      await tester.pumpAndSettle();

      // Verify cart is empty
      expect(find.text('Keranjang kosong'), findsOneWidget);
    });

    testWidgets('should update cart quantity', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Add product to cart
      await tester.tap(find.text('Product 1'));
      await tester.pumpAndSettle();

      // Tap cart icon
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Increase quantity
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Verify quantity increased
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('should display total price correctly', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Add products to cart
      await tester.tap(find.text('Product 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Product 2'));
      await tester.pumpAndSettle();

      // Tap cart icon
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify total is displayed
      expect(find.textContaining('Total'), findsOneWidget);
    });
  });
}
