import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:simple_pos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Checkout Flow Integration Tests', () {
    testWidgets('should complete full checkout workflow', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Add multiple products to cart
      await tester.tap(find.text('Product 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Product 2'));
      await tester.pumpAndSettle();

      // Open cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify cart contents
      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);

      // Proceed to checkout
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      // Verify checkout summary
      expect(find.text('Konfirmasi Checkout'), findsOneWidget);
      expect(find.text('Total Items:'), findsOneWidget);
      expect(find.text('Total Amount:'), findsOneWidget);

      // Confirm checkout
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Checkout berhasil!'), findsOneWidget);
      expect(find.text('Stok produk telah diperbarui'), findsOneWidget);

      // Close success dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify cart is empty after checkout
      expect(find.text('Keranjang kosong'), findsOneWidget);
    });

    testWidgets('should handle empty cart checkout attempt', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Open empty cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify empty cart message
      expect(find.text('Keranjang kosong'), findsOneWidget);

      // Verify checkout button is disabled or not present
      final checkoutButton = find.text('Checkout');
      if (checkoutButton.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(checkoutButton);
        expect(button.enabled, false);
      }
    });

    testWidgets('should validate stock before checkout', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to inventory first to create low stock product
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      // Add product with low stock
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Low Stock Product');
      await tester.enterText(find.byType(TextField).at(1), '10000');
      await tester.enterText(find.byType(TextField).at(2), '2');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Navigate to POS
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Add more items than available stock
      await tester.tap(find.text('Low Stock Product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Low Stock Product'));
      await tester.pumpAndSettle();

      // Try to add third item (should be blocked)
      final productCard = find.ancestor(
        of: find.text('Low Stock Product'),
        matching: find.byType(InkWell),
      );

      if (productCard.evaluate().isNotEmpty) {
        await tester.tap(productCard);
        await tester.pumpAndSettle();

        // Verify quantity didn't increase beyond stock
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await tester.pumpAndSettle();

        // Should show check icon indicating max quantity reached
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      }
    });

    testWidgets('should update stock after checkout', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to inventory to check initial stock
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      // Find a product and note its stock
      final product1StockBefore = find.text('Stok: 50');
      final hasStockBefore = product1StockBefore.evaluate().isNotEmpty;

      // Navigate to POS
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Add product to cart
      if (find.text('Product 1').evaluate().isNotEmpty) {
        await tester.tap(find.text('Product 1'));
        await tester.pumpAndSettle();

        // Open cart and checkout
        await tester.tap(find.byIcon(Icons.shopping_cart));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Checkout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Konfirmasi'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Go back to inventory and verify stock decreased
        await tester.tap(find.text('Inventory'));
        await tester.pumpAndSettle();

        if (hasStockBefore) {
          // Stock should now be 49 (50 - 1)
          expect(find.text('Stok: 49'), findsOneWidget);
        }
      }
    });

    testWidgets('should cancel checkout without changes', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to POS screen
      await tester.tap(find.text('POS'));
      await tester.pumpAndSettle();

      // Add product to cart
      await tester.tap(find.text('Product 1'));
      await tester.pumpAndSettle();

      // Open cart and start checkout
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      // Cancel checkout
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Verify cart still has items
      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Keranjang: 1'), findsOneWidget);
    });
  });
}
