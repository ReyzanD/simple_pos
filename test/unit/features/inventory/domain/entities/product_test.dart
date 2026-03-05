import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/core/constants/app_constants.dart';
import '../../../helpers/test_constants.dart';

void main() {
  group('Product entity', () {
    group('Constructor', () {
      test('should create product with all fields', () {
        // Arrange
        const id = TestConstants.testProductId;
        const name = TestConstants.testProductName;
        const price = TestConstants.testProductPrice;
        const stock = TestConstants.testProductStock;

        // Act
        final product = Product(
          id: id,
          name: name,
          price: price,
          stock: stock,
        );

        // Assert
        expect(product.id, id);
        expect(product.name, name);
        expect(product.price, price);
        expect(product.stock, stock);
      });

      test('should create product without id', () {
        // Arrange
        const name = TestConstants.testProductName;
        const price = TestConstants.testProductPrice;
        const stock = TestConstants.testProductStock;

        // Act
        final product = Product(
          name: name,
          price: price,
          stock: stock,
        );

        // Assert
        expect(product.id, null);
        expect(product.name, name);
        expect(product.price, price);
        expect(product.stock, stock);
      });
    });

    group('copyWith', () {
      test('should create copy with all fields replaced', () {
        // Arrange
        final original = Product(
          id: 1,
          name: 'Original',
          price: 100.0,
          stock: 10,
        );

        // Act
        final copy = original.copyWith(
          id: 2,
          name: 'Copy',
          price: 200.0,
          stock: 20,
        );

        // Assert
        expect(copy.id, 2);
        expect(copy.name, 'Copy');
        expect(copy.price, 200.0);
        expect(copy.stock, 20);
        expect(original.id, 1); // Original unchanged
        expect(original.name, 'Original');
      });

      test('should create copy with only id replaced', () {
        // Arrange
        final original = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final copy = original.copyWith(id: 2);

        // Assert
        expect(copy.id, 2);
        expect(copy.name, 'Product');
        expect(copy.price, 100.0);
        expect(copy.stock, 10);
      });

      test('should create copy with only name replaced', () {
        // Arrange
        final original = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final copy = original.copyWith(name: 'New Name');

        // Assert
        expect(copy.id, 1);
        expect(copy.name, 'New Name');
        expect(copy.price, 100.0);
        expect(copy.stock, 10);
      });

      test('should create copy with only price replaced', () {
        // Arrange
        final original = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final copy = original.copyWith(price: 200.0);

        // Assert
        expect(copy.id, 1);
        expect(copy.name, 'Product');
        expect(copy.price, 200.0);
        expect(copy.stock, 10);
      });

      test('should create copy with only stock replaced', () {
        // Arrange
        final original = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final copy = original.copyWith(stock: 20);

        // Assert
        expect(copy.id, 1);
        expect(copy.name, 'Product');
        expect(copy.price, 100.0);
        expect(copy.stock, 20);
      });

      test('should create copy with no fields replaced (null values)', () {
        // Arrange
        final original = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.id, 1);
        expect(copy.name, 'Product');
        expect(copy.price, 100.0);
        expect(copy.stock, 10);
      });
    });

    group('isOutOfStock', () {
      test('should return true when stock is 0', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 0,
        );

        // Act
        final result = product.isOutOfStock;

        // Assert
        expect(result, true);
      });

      test('should return true when stock is less than threshold', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: AppConstants.outOfStockThreshold,
        );

        // Act
        final result = product.isOutOfStock;

        // Assert
        expect(result, true);
      });

      test('should return false when stock is positive', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final result = product.isOutOfStock;

        // Assert
        expect(result, false);
      });
    });

    group('isLowStock', () {
      test('should return true when stock is between thresholds', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: AppConstants.lowStockThreshold,
        );

        // Act
        final result = product.isLowStock;

        // Assert
        expect(result, true);
      });

      test('should return false when stock is zero', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 0,
        );

        // Act
        final result = product.isLowStock;

        // Assert
        expect(result, false);
      });

      test('should return false when stock is high', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 100,
        );

        // Act
        final result = product.isLowStock;

        // Assert
        expect(result, false);
      });
    });

    group('validate', () {
      test('should not throw when all fields are valid', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Valid Product',
          price: 100.0,
          stock: 10,
        );

        // Act & Assert
        expect(() => product.validate(), returnsNormally);
      });

      test('should throw ValidationException when name is invalid', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'AB', // Too short
          price: 100.0,
          stock: 10,
        );

        // Act & Assert
        expect(
          () => product.validate(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when price is invalid', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Valid Product',
          price: 0.0, // Invalid
          stock: 10,
        );

        // Act & Assert
        expect(
          () => product.validate(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when stock is invalid', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Valid Product',
          price: 100.0,
          stock: -1, // Invalid
        );

        // Act & Assert
        expect(
          () => product.validate(),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('toMap', () {
      test('should convert product to map with id', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final map = product.toMap();

        // Assert
        expect(map['id'], 1);
        expect(map['name'], 'Product');
        expect(map['price'], 100.0);
        expect(map['stock'], 10);
      });

      test('should convert product to map without id', () {
        // Arrange
        final product = Product(
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final map = product.toMap();

        // Assert
        expect(map['id'], null);
        expect(map['name'], 'Product');
        expect(map['price'], 100.0);
        expect(map['stock'], 10);
      });
    });

    group('fromMap', () {
      test('should create product from map with id', () {
        // Arrange
        final map = {
          'id': 1,
          'name': 'Product',
          'price': 100.0,
          'stock': 10,
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.id, 1);
        expect(product.name, 'Product');
        expect(product.price, 100.0);
        expect(product.stock, 10);
      });

      test('should create product from map with int price', () {
        // Arrange
        final map = {
          'id': 1,
          'name': 'Product',
          'price': 100, // int instead of double
          'stock': 10,
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.price, 100.0);
      });

      test('should create product from map without id', () {
        // Arrange
        final map = {
          'name': 'Product',
          'price': 100.0,
          'stock': 10,
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.id, null);
        expect(product.name, 'Product');
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Act
        final result = product.toString();

        // Assert
        expect(result, 'Product(id: 1, name: Product, price: 100.0, stock: 10)');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final product1 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );
        final product2 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Assert
        expect(product1, product2);
      });

      test('should not be equal when id differs', () {
        // Arrange
        final product1 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );
        final product2 = Product(
          id: 2,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Assert
        expect(product1, isNot(product2));
      });

      test('should not be equal when name differs', () {
        // Arrange
        final product1 = Product(
          id: 1,
          name: 'Product1',
          price: 100.0,
          stock: 10,
        );
        final product2 = Product(
          id: 1,
          name: 'Product2',
          price: 100.0,
          stock: 10,
        );

        // Assert
        expect(product1, isNot(product2));
      });

      test('should not be equal when price differs', () {
        // Arrange
        final product1 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );
        final product2 = Product(
          id: 1,
          name: 'Product',
          price: 200.0,
          stock: 10,
        );

        // Assert
        expect(product1, isNot(product2));
      });

      test('should not be equal when stock differs', () {
        // Arrange
        final product1 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );
        final product2 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 20,
        );

        // Assert
        expect(product1, isNot(product2));
      });

      test('should be identical when comparing same instance', () {
        // Arrange
        final product = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Assert
        expect(product, same(product));
      });
    });

    group('hashCode', () {
      test('should have same hashCode for equal products', () {
        // Arrange
        final product1 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );
        final product2 = Product(
          id: 1,
          name: 'Product',
          price: 100.0,
          stock: 10,
        );

        // Assert
        expect(product1.hashCode, product2.hashCode);
      });

      test('should have different hashCode for different products', () {
        // Arrange
        final product1 = Product(
          id: 1,
          name: 'Product1',
          price: 100.0,
          stock: 10,
        );
        final product2 = Product(
          id: 2,
          name: 'Product2',
          price: 200.0,
          stock: 20,
        );

        // Assert
        expect(product1.hashCode, isNot(product2.hashCode));
      });
    });
  });
}
