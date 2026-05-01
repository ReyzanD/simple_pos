import 'package:simple_pos/features/inventory/data/datasources/stock_adjustment_local_datasource.dart';
import 'package:simple_pos/features/inventory/data/models/stock_adjustment_model.dart';
import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:simple_pos/features/inventory/domain/repositories/stock_adjustment_repository.dart';

class StockAdjustmentRepositoryImpl implements StockAdjustmentRepository {
  final StockAdjustmentLocalDataSource localDataSource;

  StockAdjustmentRepositoryImpl({required this.localDataSource});

  @override
  Future<void> recordAdjustment(StockAdjustment adjustment) async {
    final model = StockAdjustmentModel.fromEntity(adjustment);
    await localDataSource.recordAdjustment(model);
  }

  @override
  Future<List<StockAdjustment>> getAdjustmentsByProductId(int productId) async {
    final models = await localDataSource.getAdjustmentsByProductId(productId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteAdjustmentsByProductId(int productId) async {
    await localDataSource.deleteAdjustmentsByProductId(productId);
  }
}
