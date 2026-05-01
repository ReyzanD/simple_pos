import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/data/datasources/product_local_datasource.dart';
import 'package:simple_pos/features/inventory/data/models/product_model.dart';
import 'package:simple_pos/features/inventory/data/repositories/product_repository_impl.dart';

import 'product_repository_impl_test.mocks.dart';

@GenerateMocks([ProductLocalDataSource])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(localDataSource: mockDataSource);
  });

  group('getStock', () {
    final tProductId = 1;
    final tProductModel = ProductModel(
      id: tProductId,
      name: 'Test Product',
      price: 10.0,
      costPrice: 5.0,
      stock: 50,
      categoryId: 1,
      supplierId: 1,
      unitOfMeasurement: 'pcs',
    );

    test('should return stock when product exists', () async {
      when(mockDataSource.getProductById(tProductId))
          .thenAnswer((_) async => tProductModel);

      final result = await repository.getStock(tProductId);

      expect(result, equals(50));
      verify(mockDataSource.getProductById(tProductId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should throw NotFoundException when product does not exist', () async {
      when(mockDataSource.getProductById(tProductId))
          .thenThrow(NotFoundException('Product not found'));

      final call = repository.getStock(tProductId);

      expect(() => call, throwsA(isA<NotFoundException>()));
      verify(mockDataSource.getProductById(tProductId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should throw DatabaseException when datasource fails', () async {
      when(mockDataSource.getProductById(tProductId))
          .thenThrow(DatabaseException('Database error', operation: 'getProductById'));

      final call = repository.getStock(tProductId);

      expect(() => call, throwsA(isA<DatabaseException>()));
    });
  });

  group('updateStock', () {
    final tProductId = 1;
    final tProductModel = ProductModel(
      id: tProductId,
      name: 'Test Product',
      price: 10.0,
      costPrice: 5.0,
      stock: 50,
      categoryId: 1,
      supplierId: 1,
      unitOfMeasurement: 'pcs',
    );
    final tNewStock = 100;

    test('should update stock successfully', () async {
      when(mockDataSource.getProductById(tProductId))
          .thenAnswer((_) async => tProductModel);
      when(mockDataSource.updateProduct(any))
          .thenAnswer((_) async => Future.value());

      await repository.updateStock(tProductId, tNewStock);

      verify(mockDataSource.getProductById(tProductId));
      verify(mockDataSource.updateProduct(any));
    });

    test('should throw ValidationException when new stock is negative', () async {
      final call = repository.updateStock(tProductId, -10);

      expect(() => call, throwsA(isA<ValidationException>()));
      verifyNever(mockDataSource.getProductById(any));
      verifyNever(mockDataSource.updateProduct(any));
    });

    test('should throw NotFoundException when product does not exist', () async {
      when(mockDataSource.getProductById(tProductId))
          .thenThrow(NotFoundException('Product not found'));

      final call = repository.updateStock(tProductId, tNewStock);

      expect(() => call, throwsA(isA<NotFoundException>()));
      verify(mockDataSource.getProductById(tProductId));
      verifyNever(mockDataSource.updateProduct(any));
    });

    test('should throw DatabaseException when datasource fails', () async {
      when(mockDataSource.getProductById(tProductId))
          .thenAnswer((_) async => tProductModel);
      when(mockDataSource.updateProduct(any))
          .thenThrow(DatabaseException('Database error', operation: 'updateProduct'));

      final call = repository.updateStock(tProductId, tNewStock);

      expect(() => call, throwsA(isA<DatabaseException>()));
    });
  });
}
