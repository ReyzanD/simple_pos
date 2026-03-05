import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart';
import '../../../helpers/test_constants.dart';

void main() {
  late Product testProduct;

  setUp(() {
    testProduct = Product(
      id: TestConstants.testProductId,
      name: TestConstants.testProductName,
      price: TestConstants.testProductPrice,
      stock: TestConstants.testProductStock,
    );
  });

  group('CartItem entity', () {
    group('Constructor', () {
      test('should create cart item with default quantity', () {
        // Act
        final cartItem = CartItem(product: testProduct);

        // Assert
        expect(cartItem.product, testProduct);
        expect(cartItem.quantity, TestConstants.testDefaultQuantity);
      });

      test('should create cart item with custom quantity', () {
        // Arrange
        const customQuantity = TestConstants.testQuantityMultiple;

        // Act
        final cartItem = CartItem(
          product: testProduct,
          quantity: customQuantity,
        );

        // Assert
        expect(cartItem.product, testProduct);
        expect(cartItem.quantity, customQuantity);
      });

      test('should create cart item with quantity of zero', () {
        // Arrange
        const zeroQuantity = 0;

        // Act
        final cartItem = CartItem(
          product: testProduct,
          quantity: zeroQuantity,
        );

        // Assert
        expect(cartItem.quantity, zeroQuantity);
      });
    });

    group('copyWith', () {
      test('should create copy with all fields replaced', () {
        // Arrange
        final newProduct = Product(
          id: 2,
          name: 'New Product',
          price: 20000.0,
          stock: 20,
        );
        final original = CartItem(
          product: testProduct,
          quantity: 1,
        );

        // Act
        final copy = original.copyWith(
          product: newProduct,
          quantity: 5,
        );

        // Assert
        expect(copy.product, newProduct);
        expect(copy.quantity, 5);
        expect(original.product, testProduct); // Original unchanged
      });

      test('should create copy with only product replaced', () {
        // Arrange
        final newProduct = Product(
          id: 2,
          name: 'New Product',
          price: 20000.0,
          stock: 20,
        );
        final original = CartItem(
          product: testProduct,
          quantity: 1,
        );

        // Act
        final copy = original.copyWith(product: newProduct);

        // Assert
        expect(copy.product, newProduct);
        expect(copy.quantity, 1);
      });

      test('should create copy with only quantity replaced', () {
        // Arrange
        final original = CartItem(
          product: testProduct,
          quantity: 1,
        );

        // Act
        final copy = original.copyWith(quantity: 10);

        // Assert
        expect(copy.product, testProduct);
        expect(copy.quantity, 10);
      });

      test('should create copy with no fields replaced', () {
        // Arrange
        final original = CartItem(
          product: testProduct,
          quantity: 1,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.product, testProduct);
        expect(copy.quantity, 1);
      });
    });

    group('totalPrice', () {
      test('should calculate total price correctly for single item', () {
        // Arrange
        final cartItem = CartItem(
          product: testProduct,
          quantity: 1,
        );

        // Act
        final total = cartItem.totalPrice;

        // Assert
        expect(total, TestConstants.testProductPrice);
      });

      test('should calculate total price correctly for multiple items', () {
        // Arrange
        const quantity = TestConstants.testQuantityMultiple;
        final cartItem = CartItem(
          product: testProduct,
          quantity: quantity,
        );

        // Act
        final total = cartItem.totalPrice;

        // Assert
        final expected = TestConstants.testProductPrice * quantity;
        expect(total, expected);
      });

      test('should return zero when quantity is zero', () {
        // Arrange
        final cartItem = CartItem(
          product: testProduct,
          quantity: 0,
        );

        // Act
        final total = cartItem.totalPrice;

        // Assert
        expect(total, 0.0);
      });

      test('should handle fractional prices correctly', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 15000.50,
          stock: 10,
        );
        final cartItem = CartItem(
          product: product,
          quantity: 2,
        );

        // Act
        final total = cartItem.totalPrice;

        // Assert
        expect(total, 30001.0);
      });
    });

    group('canAddMore', () {
      test('should return true when quantity is less than stock', () {
        // Arrange
        final cartItem = CartItem(
          product: testProduct,
          quantity: 10,
        );

        // Act
        final result = cartItem.canAddMore;

        // Assert
        expect(result, true);
      });

      test('should return false when quantity equals stock', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 5,
        );
        final cartItem = CartItem(
          product: product,
          quantity: 5,
        );

        // Act
        final result = cartItem.canAddMore;

        // Assert
        expect(result, false);
      });

      test('should return false when quantity exceeds stock', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 5,
        );
        final cartItem = CartItem(
          product: product,
          quantity: 10,
        );

        // Act
        final result = cartItem.canAddMore;

        // Assert
        expect(result, false);
      });

      test('should return true when stock is zero but quantity is also zero', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 0,
        );
        final cartItem = CartItem(
          product: product,
          quantity: 0,
        );

        // Act
        final result = cartItem.canAddMore;

        // Assert
        expect(result, false);
      });
    });

    group('isOutOfStock', () {
      test('should return true when product stock is zero', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 0,
        );
        final cartItem = CartItem(
          product: product,
          quantity: 0,
        );

        // Act
        final result = cartItem.isOutOfStock;

        // Assert
        expect(result, true);
      });

      test('should return false when product has stock', () {
        // Arrange
        final cartItem = CartItem(
          product: testProduct,
          quantity: 1,
        );

        // Act
        final result = cartItem.isOutOfStock;

        // Assert
        expect(result, false);
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        final cartItem = CartItem(
          product: testProduct,
          quantity: 2,
        );

        // Act
        final result = cartItem.toString();

        // Assert
        expect(
          result,
          'CartItem(product: ${testProduct.name}, quantity: 2, total: ${testProduct.price * 2})',
        );
      });
    });

    group('equality', () {
      test('should be equal when product id and quantity match', () {
        // Arrange
        final cartItem1 = CartItem(
          product: testProduct,
          quantity: 2,
        );
        final cartItem2 = CartItem(
          product: testProduct,
          quantity: 2,
        );

        // Assert
        expect(cartItem1, cartItem2);
      });

      test('should not be equal when product id differs', () {
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
        final cartItem1 = CartItem(product: product1, quantity: 1);
        final cartItem2 = CartItem(product: product2, quantity: 1);

        // Assert
        expect(cartItem1, isNot(cartItem2));
      });

      test('should not be equal when quantity differs', () {
        // Arrange
        final cartItem1 = CartItem(
          product: testProduct,
          quantity: 1,
        );
        final cartItem2 = CartItem(
          product: testProduct,
          quantity: 2,
        );

        // Assert
        expect(cartItem1, isNot(cartItem2));
      });

      test('should be identical when comparing same instance', () {
        // Arrange
        final cartItem = CartItem(
          product: testProduct,
          quantity: 1,
        );

        // Assert
        expect(cartItem, same(cartItem));
      });
    });

    group('hashCode', () {
      test('should have same hashCode for equal cart items', () {
        // Arrange
        final cartItem1 = CartItem(
          product: testProduct,
          quantity: 2,
        );
        final cartItem2 = CartItem(
          product: testProduct,
          quantity: 2,
        );

        // Assert
        expect(cartItem1.hashCode, cartItem2.hashCode);
      });

      test('should have different hashCode for different cart items', () {
        // Arrange
        final cartItem1 = CartItem(
          product: testProduct,
          quantity: 1,
        );
        final cartItem2 = CartItem(
          product: testProduct,
          quantity: 2,
        );

        // Assert
        expect(cartItem1.hashCode, isNot(cartItem2.hashCode));
      });
    });
  });
}
