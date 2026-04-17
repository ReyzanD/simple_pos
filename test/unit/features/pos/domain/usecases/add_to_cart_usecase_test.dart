import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/inventory/domain/repositories/product_repository.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart';
import 'package:simple_pos/features/pos/domain/usecases/add_to_cart_usecase.dart';
import '../../../../helpers/test_constants.dart';

// Generate mocks
@GenerateMocks([ProductRepository])
import 'add_to_cart_usecase_test.mocks.dart';

void main() {
  late AddToCartUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = AddToCartUseCase(productRepository: mockRepository);
  });

  group('AddToCartUseCase', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: TestConstants.testProductId,
        name: TestConstants.testProductName,
        price: TestConstants.testProductPrice,
        stock: TestConstants.testProductStock,
      );
    });

    test('should add new product to cart', () async {
      // Arrange
      final cart = <CartItem>[];

      // Act
      final result = await useCase.execute(
        currentCart: cart,
        product: testProduct,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].product.id, TestConstants.testProductId);
      expect(result[0].quantity, 1);
    });

    test('should increment quantity when product already in cart', () async {
      // Arrange
      final cart = [
        CartItem(
          product: testProduct,
          quantity: 2,
        ),
      ];

      // Act
      final result = await useCase.execute(
        currentCart: cart,
        product: testProduct,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].quantity, 3);
    });

    test('should throw InsufficientStockException when no stock available', () async {
      // Arrange
      final outOfStockProduct = Product(
        id: 1,
        name: 'Out of Stock',
        price: 100.0,
        stock: 0,
      );
      final cart = <CartItem>[];

      // Act & Assert
      expect(
        () => useCase.execute(
          currentCart: cart,
          product: outOfStockProduct,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('should throw InsufficientStockException when adding exceeds stock', () async {
      // Arrange
      final lowStockProduct = Product(
        id: 1,
        name: 'Low Stock',
        price: 100.0,
        stock: 5,
      );
      final cart = [
        CartItem(
          product: lowStockProduct,
          quantity: 5,
        ),
      ];

      // Act & Assert
      expect(
        () => useCase.execute(
          currentCart: cart,
          product: lowStockProduct,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('should add multiple different products to cart', () async {
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
      final cart = <CartItem>[
        CartItem(product: product1, quantity: 2),
      ];

      // Act
      final result = await useCase.execute(
        currentCart: cart,
        product: product2,
      );

      // Assert
      expect(result.length, 2);
      expect(result[0].product.id, 1);
      expect(result[1].product.id, 2);
    });

    test('should allow adding up to available stock', () async {
      // Arrange
      final product = Product(
        id: 1,
        name: 'Product',
        price: 100.0,
        stock: 10,
      );
      final cart = [
        CartItem(product: product, quantity: 9),
      ];

      // Act
      final result = await useCase.execute(
        currentCart: cart,
        product: product,
      );

      // Assert
      expect(result[0].quantity, 10);
    });

    test('should handle product with stock of 1', () async {
      // Arrange
      final singleStockProduct = Product(
        id: 1,
        name: 'Single Item',
        price: 100.0,
        stock: 1,
      );
      final cart = <CartItem>[];

      // Act
      final result = await useCase.execute(
        currentCart: cart,
        product: singleStockProduct,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].quantity, 1);
    });

    test('should preserve other items when updating existing item', () async {
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
      final cart = <CartItem>[
        CartItem(product: product1, quantity: 2),
        CartItem(product: product2, quantity: 3),
      ];

      // Act
      final result = await useCase.execute(
        currentCart: cart,
        product: product1,
      );

      // Assert
      expect(result.length, 2);
      expect(result[0].quantity, 3);
      expect(result[1].quantity, 3); // Unchanged
    });
  });
}
