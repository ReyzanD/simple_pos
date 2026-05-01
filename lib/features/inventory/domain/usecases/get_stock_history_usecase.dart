import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:simple_pos/features/inventory/domain/repositories/stock_adjustment_repository.dart';

class GetStockHistoryUseCase {
  final StockAdjustmentRepository repository;

  GetStockHistoryUseCase({required this.repository});

  Future<List<StockAdjustment>> execute({required int productId}) async {
    return repository.getAdjustmentsByProductId(productId);
  }
}
