import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/repositories/product_repository.dart';
import '../../../helpers/test_constants.dart';

// Generate mocks
@GenerateMocks([ProductRepository])
import 'add_product_usecase_test.mocks.dart';

void main() {
  late AddProductUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = AddProductUseCase(repository: mockRepository);
  });

  group('AddProductUseCase', () {
    final testProduct = Product(
      name: TestConstants.testProductName,
      price: TestConstants.testProductPrice,
      stock: TestConstants.testProductStock,
    );

    final productWithId = Product(
      id: TestConstants.testProductId,
      name: TestConstants.testProductName,
      price: TestConstants.testProductPrice,
      stock: TestConstants.testProductStock,
    );

    test('should add product successfully when valid', () async {
      // Arrange
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => []);
      when(mockRepository.addProduct(any))
          .thenAnswer((_) async => productWithId);

      // Act
      final result = await useCase.execute(testProduct);

      // Assert
      expect(result.id, TestConstants.testProductId);
      expect(result.name, TestConstants.testProductName);
      verify(mockRepository.searchProducts(testProduct.name)).called(1);
      verify(mockRepository.addProduct(testProduct)).called(1);
    });

    test('should throw ValidationException when product name already exists', () async {
      // Arrange
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => [productWithId]);

      // Act & Assert
      expect(
        () => useCase.execute(testProduct),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message',
                contains('sudah ada'))),
      );
      verify(mockRepository.searchProducts(testProduct.name)).called(1);
      verifyNever(mockRepository.addProduct(any));
    });

    test('should throw ValidationException when product name is invalid', () async {
      // Arrange
      final invalidProduct = Product(
        name: 'AB', // Too short
        price: TestConstants.testProductPrice,
        stock: TestConstants.testProductStock,
      );
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => useCase.execute(invalidProduct),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.addProduct(any));
    });

    test('should throw ValidationException when price is invalid', () async {
      // Arrange
      final invalidProduct = Product(
        name: TestConstants.testProductName,
        price: 0.0, // Invalid
        stock: TestConstants.testProductStock,
      );
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => useCase.execute(invalidProduct),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.addProduct(any));
    });

    test('should throw ValidationException when stock is invalid', () async {
      // Arrange
      final invalidProduct = Product(
        name: TestConstants.testProductName,
        price: TestConstants.testProductPrice,
        stock: -1, // Invalid
      );
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => useCase.execute(invalidProduct),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.addProduct(any));
    });

    test('should throw DatabaseException when repository throws', () async {
      // Arrange
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => []);
      when(mockRepository.addProduct(any))
          .thenThrow(DatabaseException(
                'Database error',
                operation: 'add',
              ));

      // Act & Assert
      expect(
        () => useCase.execute(testProduct),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('should handle case-insensitive duplicate name check', () async {
      // Arrange
      final existingProduct = Product(
        id: 1,
        name: 'test product', // lowercase
        price: 100.0,
        stock: 10,
      );
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => [existingProduct]);

      final newProduct = Product(
        name: 'Test Product', // Mixed case
        price: 200.0,
        stock: 20,
      );

      // Act & Assert
      expect(
        () => useCase.execute(newProduct),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should allow product with different name', () async {
      // Arrange
      final existingProduct = Product(
        id: 1,
        name: 'Different Product',
        price: 100.0,
        stock: 10,
      );
      when(mockRepository.searchProducts(any))
          .thenAnswer((_) async => [existingProduct]);
      when(mockRepository.addProduct(any))
          .thenAnswer((_) async => productWithId);

      // Act
      final result = await useCase.execute(testProduct);

      // Assert
      expect(result.id, TestConstants.testProductId);
      verify(mockRepository.addProduct(testProduct)).called(1);
    });
  });
}
