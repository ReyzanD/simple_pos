import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart';
import 'package:simple_pos/features/pos/domain/usecases/remove_from_cart_usecase.dart';

void main() {
  late RemoveFromCartUseCase useCase;

  setUp(() {
    useCase = RemoveFromCartUseCase();
  });

  group('RemoveFromCartUseCase', () {
    late Product testProduct1;
    late Product testProduct2;
    late Product testProduct3;

    setUp(() {
      testProduct1 = Product(
        id: 1,
        name: 'Product 1',
        price: 100.0,
        stock: 10,
      );
      testProduct2 = Product(
        id: 2,
        name: 'Product 2',
        price: 200.0,
        stock: 20,
      );
      testProduct3 = Product(
        id: 3,
        name: 'Product 3',
        price: 300.0,
        stock: 30,
      );
    });

    test('should remove product from cart', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct1, quantity: 2),
        CartItem(product: testProduct2, quantity: 1),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct1,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].product.id, 2);
    });

    test('should return same cart if product not found', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct1, quantity: 2),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct2,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].product.id, 1);
    });

    test('should return empty cart after removing only item', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct1, quantity: 2),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct1,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should remove correct item from cart with multiple items', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct1, quantity: 2),
        CartItem(product: testProduct2, quantity: 3),
        CartItem(product: testProduct3, quantity: 1),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct2,
      );

      // Assert
      expect(result.length, 2);
      expect(result[0].product.id, 1);
      expect(result[1].product.id, 3);
    });

    test('should handle empty cart', () {
      // Arrange
      final cart = <CartItem>[];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct1,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should preserve order of remaining items', () {
      // Arrange
      final cart = [
        CartItem(product: testProduct1, quantity: 1),
        CartItem(product: testProduct2, quantity: 2),
        CartItem(product: testProduct3, quantity: 3),
      ];

      // Act
      final result = useCase.execute(
        currentCart: cart,
        product: testProduct2,
      );

      // Assert
      expect(result.length, 2);
      expect(result[0].product.id, 1);
      expect(result[1].product.id, 3);
    });
  });
}
