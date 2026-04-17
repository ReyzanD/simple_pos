import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/repositories/product_repository.dart';
import '../../../../helpers/test_constants.dart';

// Generate mocks
@GenerateMocks([ProductRepository])
import 'delete_product_usecase_test.mocks.dart';

void main() {
  late DeleteProductUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = DeleteProductUseCase(repository: mockRepository);
  });

  group('DeleteProductUseCase', () {
    test('should delete product successfully', () async {
      // Arrange
      when(mockRepository.productExists(TestConstants.testProductId))
          .thenAnswer((_) async => true);
      when(mockRepository.deleteProduct(TestConstants.testProductId))
          .thenAnswer((_) async => 1);

      // Act
      await useCase.execute(TestConstants.testProductId);

      // Assert
      verify(mockRepository.productExists(TestConstants.testProductId)).called(1);
      verify(mockRepository.deleteProduct(TestConstants.testProductId)).called(1);
    });

    test('should throw ValidationException when id is zero', () async {
      // Act & Assert
      expect(
        () => useCase.execute(0),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.productExists(any));
      verifyNever(mockRepository.deleteProduct(any));
    });

    test('should throw ValidationException when id is negative', () async {
      // Act & Assert
      expect(
        () => useCase.execute(-1),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.productExists(any));
      verifyNever(mockRepository.deleteProduct(any));
    });

    test('should throw NotFoundException when product does not exist', () async {
      // Arrange
      when(mockRepository.productExists(TestConstants.testProductId))
          .thenAnswer((_) async => false);

      // Act & Assert
      expect(
        () => useCase.execute(TestConstants.testProductId),
        throwsA(isA<NotFoundException>()
            .having((e) => e.resourceType, 'resourceType', 'Produk')),
      );
      verify(mockRepository.productExists(TestConstants.testProductId)).called(1);
      verifyNever(mockRepository.deleteProduct(any));
    });

    test('should throw DatabaseException when repository fails', () async {
      // Arrange
      when(mockRepository.productExists(TestConstants.testProductId))
          .thenAnswer((_) async => true);
      when(mockRepository.deleteProduct(TestConstants.testProductId))
          .thenThrow(DatabaseException(
                'Database error',
                operation: 'delete',
              ));

      // Act & Assert
      expect(
        () => useCase.execute(TestConstants.testProductId),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('should handle valid product id', () async {
      // Arrange
      const validId = 123;
      when(mockRepository.productExists(validId))
          .thenAnswer((_) async => true);
      when(mockRepository.deleteProduct(validId))
          .thenAnswer((_) async => 1);

      // Act
      await useCase.execute(validId);

      // Assert
      verify(mockRepository.productExists(validId)).called(1);
      verify(mockRepository.deleteProduct(validId)).called(1);
    });
  });
}
