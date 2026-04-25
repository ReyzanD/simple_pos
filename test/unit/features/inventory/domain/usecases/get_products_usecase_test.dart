import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/inventory/domain/usecases/get_products_usecase.dart';
import 'package:simple_pos/features/inventory/domain/repositories/product_repository.dart';

// Generate mocks
@GenerateMocks([ProductRepository])
import 'get_products_usecase_test.mocks.dart';

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(repository: mockRepository);
  });

  group('GetProductsUseCase', () {
    test('should return list of products successfully', () async {
      // Arrange
      final products = [
        Product(
          id: 1,
          name: 'Product 1',
          price: 100.0,
          stock: 10,
        ),
        Product(
          id: 2,
          name: 'Product 2',
          price: 200.0,
          stock: 20,
        ),
      ];
      when(mockRepository.getProducts())
          .thenAnswer((_) async => products);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, 2);
      expect(result[0].name, 'Product 1');
      expect(result[1].name, 'Product 2');
      verify(mockRepository.getProducts()).called(1);
    });

    test('should return empty list when no products exist', () async {
      // Arrange
      when(mockRepository.getProducts())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getProducts()).called(1);
    });

    test('should throw DatabaseException when repository fails', () async {
      // Arrange
      when(mockRepository.getProducts())
          .thenThrow(DatabaseException(
                'Database error',
                operation: 'getProducts',
              ));

      // Act & Assert
      expect(
        () => useCase.execute(),
        throwsA(isA<DatabaseException>()),
      );
      verify(mockRepository.getProducts()).called(1);
    });

    test('should handle products with various stock levels', () async {
      // Arrange
      final products = [
        Product(
          id: 1,
          name: 'Out of Stock',
          price: 100.0,
          stock: 0,
        ),
        Product(
          id: 2,
          name: 'Low Stock',
          price: 200.0,
          stock: 5,
        ),
        Product(
          id: 3,
          name: 'High Stock',
          price: 300.0,
          stock: 100,
        ),
      ];
      when(mockRepository.getProducts())
          .thenAnswer((_) async => products);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, 3);
      expect(result[0].isOutOfStock, true);
      expect(result[1].isLowStock, true);
      expect(result[2].isLowStock, false);
    });

    test('should handle products with decimal prices', () async {
      // Arrange
      final products = [
        Product(
          id: 1,
          name: 'Product 1',
          price: 15000.50,
          stock: 10,
        ),
        Product(
          id: 2,
          name: 'Product 2',
          price: 25000.99,
          stock: 20,
        ),
      ];
      when(mockRepository.getProducts())
          .thenAnswer((_) async => products);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, 2);
      expect(result[0].price, 15000.50);
      expect(result[1].price, 25000.99);
    });
  });
}
