import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart';
import 'package:simple_pos/features/pos/domain/usecases/update_cart_quantity_usecase.dart';
import '../../../../helpers/test_constants.dart';

void main() {
  late UpdateCartQuantityUseCase useCase;

  setUp(() {
    useCase = UpdateCartQuantityUseCase();
  });

  group('UpdateCartQuantityUseCase', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: TestConstants.testProductId,
        name: TestConstants.testProductName,
        price: TestConstants.testProductPrice,
        stock: TestConstants.testProductStock,
      );
    });

    test('should update quantity successfully', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct, quantity: 2),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct,
        newQuantity: 5,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].quantity, 5);
    });

    test('should remove item when quantity is set to 0', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct, quantity: 2),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct,
        newQuantity: 0,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should throw ValidationException when quantity is negative', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct, quantity: 2),
      ];

      // Act & Assert
      expect(
        () => useCase.execute(
          currentCart: cart,
          product: testProduct,
          newQuantity: -1,
        ),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message',
                contains('tidak boleh negatif'))),
      );
    });

    test('should throw ValidationException when product not in cart', () {
      // Arrange
      final cart = <CartItem>[];

      // Act & Assert
      expect(
        () => useCase.execute(
          currentCart: cart,
          product: testProduct,
          newQuantity: 5,
        ),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message',
                contains('tidak ada di keranjang'))),
      );
    });

    test('should throw InsufficientStockException when quantity exceeds stock', () {
      // Arrange
      final lowStockProduct = Product(
        id: 1,
        name: 'Low Stock',
        price: 100.0,
        stock: 5,
      );
      final cart = [
        CartItem(product: lowStockProduct, quantity: 2),
      ];

      // Act & Assert
      expect(
        () => useCase.execute(
          currentCart: cart,
          product: lowStockProduct,
          newQuantity: 10,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('should allow setting quantity to match stock exactly', () {
      // Arrange
      final product = Product(
        id: 1,
        name: 'Product',
        price: 100.0,
        stock: 10,
      );
      final cart = [
        CartItem(product: product, quantity: 5),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: product,
        newQuantity: 10,
      );

      // Assert
      expect(result[0].quantity, 10);
    });

    test('should preserve other items when updating one', () {
      // Arrange
      final product1 = Product(
        id: 1,
        name: 'Product 1',
        price: 100.0,
        stock: 10,
      );
      final product2 = Product(
        id: 2,
        name: 'Product 2',
        price: 200.0,
        stock: 20,
      );
      final cart = [
        CartItem(product: product1, quantity: 2),
        CartItem(product: product2, quantity: 3),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: product1,
        newQuantity: 5,
      );

      // Assert
      expect(result.length, 2);
      expect(result[0].quantity, 5);
      expect(result[1].quantity, 3); // Unchanged
    });

    test('should allow zero quantity when removing item', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct, quantity: 5),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct,
        newQuantity: 0,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should throw InsufficientStockException for zero stock product', () {
      // Arrange
      final outOfStockProduct = Product(
        id: 1,
        name: 'Out of Stock',
        price: 100.0,
        stock: 0,
      );
      final cart = [
        CartItem(product: outOfStockProduct, quantity: 0),
      ];

      // Act & Assert
      expect(
        () => useCase.execute(
          currentCart: cart,
          product: outOfStockProduct,
          newQuantity: 1,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('should update first matching item when duplicates exist', () {
      // Arrange
      final product = Product(
        id: 1,
        name: 'Product',
        price: 100.0,
        stock: 20,
      );
      final cart = [
        CartItem(product: product, quantity: 5),
        CartItem(product: product, quantity: 3),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: product,
        newQuantity: 8,
      );

      // Assert
      expect(result.length, 2);
      expect(result[0].quantity, 8);
      expect(result[1].quantity, 3);
    });
  });
}
