import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('ProductModel should convert unitOfMeasurement to/from entity', () {
      final model = ProductModel(
        id: 1,
        name: 'Test',
        price: 100.0,
        costPrice: 80.0,
        stock: 50,
        categoryId: 1,
        supplierId: 1,
        barcode: '123456',
        unitOfMeasurement: 'box',
      );

      final entity = model.toEntity();
      final backToModel = ProductModel.fromEntity(entity);

      expect(entity.unitOfMeasurement, equals('box'));
      expect(backToModel.unitOfMeasurement, equals('box'));
    });

    test('ProductModel should convert unitOfMeasurement to/from map', () {
      final model = ProductModel(
        id: 1,
        name: 'Test',
        price: 100.0,
        costPrice: 80.0,
        stock: 50,
        categoryId: 1,
        supplierId: 1,
        barcode: '123456',
        unitOfMeasurement: 'box',
      );

      final map = model.toMap();
      final fromMapModel = ProductModel.fromMap(map);

      expect(map['unit_of_measurement'], equals('box'));
      expect(fromMapModel.unitOfMeasurement, equals('box'));
    });

    test('ProductModel should default unitOfMeasurement to "pcs"', () {
      final model = ProductModel(
        name: 'Test',
        price: 100.0,
        stock: 50,
      );

      expect(model.unitOfMeasurement, equals('pcs'));
    });
  });
}
