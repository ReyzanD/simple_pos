import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
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
      expect(inventoryButton, findsOneWidget);
      await tester.tap(inventoryButton);
      await tester.pumpAndSettle();

      // Verify inventory screen is displayed
      expect(find.text('Produk'), findsOneWidget);

      // Tap add product button
      final addFab = find.byType(FloatingActionButton);
      expect(addFab, findsOneWidget);
      await tester.tap(addFab);
      await tester.pumpAndSettle();

      // Fill in product details
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Integration Test Product');

      final priceField = find.byType(TextField).at(1);
      await tester.enterText(priceField, '25000');

      final stockField = find.byType(TextField).at(2);
      await tester.enterText(stockField, '100');

      // Submit
      final saveButton = find.text('Simpan');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify product appears in list
      expect(find.text('Integration Test Product'), findsOneWidget);
      expect(find.text('Rp 25.000,00'), findsOneWidget);
      expect(find.text('Stok: 100'), findsOneWidget);

      // Edit product
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Update price
      final editPriceField = find.byType(TextField).at(1);
      await tester.enterText(editPriceField, '30000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Verify updated price
      expect(find.text('Rp 30.000,00'), findsOneWidget);

      // Delete product
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      final confirmDelete = find.text('Hapus');
      await tester.tap(confirmDelete);
      await tester.pumpAndSettle();

      // Verify product is removed
      expect(find.text('Integration Test Product'), findsNothing);
    });

    testWidgets('should search products correctly', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to inventory screen
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      // Tap search
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Product');
      await tester.pumpAndSettle();

      // Verify search results (products containing 'Product')
      final productsFound = find.text('Product');
      expect(productsFound, findsWidgets);
    });

    testWidgets('should handle validation errors on add product', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to inventory screen
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      // Tap add product button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to submit without entering data
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Verify validation error message
      expect(find.text('Nama produk tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should display low stock indicators', (tester) async {
      // Arrange & Act - Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to inventory screen
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      // Add low stock product
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Low Stock Item');
      await tester.enterText(find.byType(TextField).at(1), '5000');
      await tester.enterText(find.byType(TextField).at(2), '5');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Verify orange chip for low stock
      final chip = find.byType(Chip);
      expect(chip, findsOneWidget);
    });
  });
}
