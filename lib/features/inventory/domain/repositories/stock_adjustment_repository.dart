import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';

abstract class StockAdjustmentRepository {
  Future<void> recordAdjustment(StockAdjustment adjustment);
  Future<List<StockAdjustment>> getAdjustmentsByProductId(int productId);
  Future<void> deleteAdjustmentsByProductId(int productId);
}
