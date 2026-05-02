import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/inventory/domain/usecases/update_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/repositories/product_repository.dart';
import '../../../../helpers/test_constants.dart';

// Generate mocks
@GenerateMocks([ProductRepository])
import 'update_product_usecase_test.mocks.dart';

void main() {
  late UpdateProductUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = UpdateProductUseCase(repository: mockRepository);
  });

  group('UpdateProductUseCase', () {
    final testProduct = Product(
      id: TestConstants.testProductId,
      name: 'Updated Product',
      price: 20000.0,
      stock: 30,
    );

    test('should update product successfully', () async {
      // Arrange
      when(mockRepository.productExists(TestConstants.testProductId))
          .thenAnswer((_) async => true);
      when(mockRepository.updateProduct(any))
          .thenAnswer((_) async {
            return;
          });

      // Act
      await useCase.execute(testProduct);

      // Assert
      verify(mockRepository.productExists(TestConstants.testProductId)).called(1);
      verify(mockRepository.updateProduct(testProduct)).called(1);
    });

    test('should throw ValidationException when product id is null', () async {
      // Arrange
      final productWithoutId = Product(
        name: 'Product',
        price: 100.0,
        stock: 10,
      );

      // Act & Assert
      expect(
        () => useCase.execute(productWithoutId),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message',
                contains('diperlukan untuk update'))),
      );
      verifyNever(mockRepository.productExists(any));
      verifyNever(mockRepository.updateProduct(any));
    });

    test('should throw ValidationException when product name is invalid', () async {
      // Arrange
      final invalidProduct = Product(
        id: 1,
        name: 'AB', // Too short
        price: 100.0,
        stock: 10,
      );

      // Act & Assert
      expect(
        () => useCase.execute(invalidProduct),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.productExists(any));
      verifyNever(mockRepository.updateProduct(any));
    });

    test('should throw ValidationException when price is invalid', () async {
      // Arrange
      final invalidProduct = Product(
        id: 1,
        name: 'Product',
        price: 0.0,
        stock: 10,
      );

      // Act & Assert
      expect(
        () => useCase.execute(invalidProduct),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.productExists(any));
      verifyNever(mockRepository.updateProduct(any));
    });

    test('should throw ValidationException when stock is invalid', () async {
      // Arrange
      final invalidProduct = Product(
        id: 1,
        name: 'Product',
        price: 100.0,
        stock: -1,
      );

      // Act & Assert
      expect(
        () => useCase.execute(invalidProduct),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.productExists(any));
      verifyNever(mockRepository.updateProduct(any));
    });

    test('should throw NotFoundException when product does not exist', () async {
      // Arrange
      when(mockRepository.productExists(TestConstants.testProductId))
          .thenAnswer((_) async => false);

      // Act & Assert
      expect(
        () => useCase.execute(testProduct),
        throwsA(isA<NotFoundException>()
            .having((e) => e.resourceType, 'resourceType', 'Produk')),
      );
      verify(mockRepository.productExists(TestConstants.testProductId)).called(1);
      verifyNever(mockRepository.updateProduct(any));
    });

    test('should throw DatabaseException when repository fails', () async {
      // Arrange
      when(mockRepository.productExists(TestConstants.testProductId))
          .thenAnswer((_) async => true);
      when(mockRepository.updateProduct(any))
          .thenThrow(DatabaseException(
                'Database error',
                operation: 'update',
              ));

      // Act & Assert
      expect(
        () => useCase.execute(testProduct),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('should allow updating product with valid fields', () async {
      // Arrange
      final updatedProduct = Product(
        id: 1,
        name: 'Valid Product Name',
        price: 15000.50,
        stock: 50,
      );
      when(mockRepository.productExists(1))
          .thenAnswer((_) async => true);
      when(mockRepository.updateProduct(any))
          .thenAnswer((_) async {
            return;
          });

      // Act
      await useCase.execute(updatedProduct);

      // Assert
      verify(mockRepository.updateProduct(updatedProduct)).called(1);
    });
  });
}
