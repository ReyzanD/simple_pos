import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';

void main() {
  test('StockAdjustment should create with all fields', () {
    final adjustment = StockAdjustment(
      id: 1,
      productId: 10,
      previousQuantity: 100,
      newQuantity: 95,
      adjustmentType: StockAdjustmentType.sale,
      reason: 'Sold 5 items',
      createdBy: 'admin',
      createdAt: DateTime(2026, 5, 1),
    );

    expect(adjustment.id, equals(1));
    expect(adjustment.productId, equals(10));
    expect(adjustment.previousQuantity, equals(100));
    expect(adjustment.newQuantity, equals(95));
    expect(adjustment.adjustmentType, equals(StockAdjustmentType.sale));
    expect(adjustment.reason, equals('Sold 5 items'));
    expect(adjustment.createdBy, equals('admin'));
    expect(adjustment.createdAt, equals(DateTime(2026, 5, 1)));
  });

  test('StockAdjustment should have computed properties', () {
    final adjustment = StockAdjustment(
      id: 1,
      productId: 10,
      previousQuantity: 100,
      newQuantity: 95,
      adjustmentType: StockAdjustmentType.sale,
      reason: 'Sold 5 items',
      createdBy: 'admin',
      createdAt: DateTime(2026, 5, 1),
    );

    expect(adjustment.adjustmentAmount, equals(-5));
    expect(adjustment.isIncrease, equals(false));
    expect(adjustment.isDecrease, equals(true));
  });
}
