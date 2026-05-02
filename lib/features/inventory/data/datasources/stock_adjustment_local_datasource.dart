import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/features/inventory/data/models/stock_adjustment_model.dart';

class StockAdjustmentLocalDataSource {
  final DatabaseHelper databaseHelper;

  StockAdjustmentLocalDataSource({required this.databaseHelper});

  Future<void> recordAdjustment(StockAdjustmentModel adjustment) async {
    final db = await databaseHelper.database;
    await db.insert('stock_adjustments', adjustment.toJson());
  }

  Future<List<StockAdjustmentModel>> getAdjustmentsByProductId(
    int productId,
  ) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_adjustments',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => StockAdjustmentModel.fromJson(map)).toList();
  }

  Future<void> deleteAdjustmentsByProductId(int productId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'stock_adjustments',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
}
