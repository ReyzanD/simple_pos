import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/data/models/stock_adjustment_model.dart';
import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';

void main() {
  test('StockAdjustmentModel should convert to/from entity', () {
    final json = {
      'id': 1,
      'product_id': 10,
      'previous_quantity': 100,
      'new_quantity': 95,
      'adjustment_type': 'sale',
      'reason': 'Sold 5 items',
      'created_by': 'admin',
      'created_at': '2026-05-01 10:00:00',
    };

    final model = StockAdjustmentModel.fromJson(json);
    final entity = model.toEntity();

    expect(entity.adjustmentType, equals(StockAdjustmentType.sale));
    expect(entity.reason, equals('Sold 5 items'));
  });

  test('StockAdjustmentModel should convert from entity', () {
    final entity = StockAdjustment(
      id: 1,
      productId: 10,
      previousQuantity: 100,
      newQuantity: 95,
      adjustmentType: StockAdjustmentType.sale,
      reason: 'Sold 5 items',
      createdBy: 'admin',
      createdAt: DateTime(2026, 5, 1, 10, 0, 0),
    );

    final model = StockAdjustmentModel.fromEntity(entity);
    final json = model.toJson();

    expect(json['id'], equals(1));
    expect(json['product_id'], equals(10));
    expect(json['adjustment_type'], equals('sale'));
    expect(json['reason'], equals('Sold 5 items'));
  });

  test('StockAdjustmentModel should handle null reason', () {
    final json = {
      'id': 1,
      'product_id': 10,
      'previous_quantity': 100,
      'new_quantity': 95,
      'adjustment_type': 'set',
      'reason': null,
      'created_by': 'admin',
      'created_at': '2026-05-01 10:00:00',
    };

    final model = StockAdjustmentModel.fromJson(json);
    final entity = model.toEntity();

    expect(entity.reason, isNull);
  });
}
