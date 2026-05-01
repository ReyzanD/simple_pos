import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:simple_pos/features/inventory/domain/repositories/product_repository.dart';
import 'package:simple_pos/features/inventory/domain/repositories/stock_adjustment_repository.dart';

class AdjustStockUseCase {
  final ProductRepository productRepository;
  final StockAdjustmentRepository stockAdjustmentRepository;

  AdjustStockUseCase({
    required this.productRepository,
    required this.stockAdjustmentRepository,
  });

  Future<void> execute({
    required int productId,
    required int adjustmentAmount,
    required StockAdjustmentType adjustmentType,
    required String? reason,
    required String createdBy,
  }) async {
    if (adjustmentAmount == 0) {
      throw ValidationException('Adjustment amount cannot be zero');
    }

    final currentStock = await productRepository.getStock(productId);
    final newStock = currentStock + adjustmentAmount;

    if (newStock < 0) {
      throw ValidationException(
        'Adjustment would make stock negative (current: $currentStock, adjustment: $adjustmentAmount)',
      );
    }

    await productRepository.updateStock(productId, newStock);

    await stockAdjustmentRepository.recordAdjustment(
      StockAdjustment(
        id: 0,
        productId: productId,
        previousQuantity: currentStock,
        newQuantity: newStock,
        adjustmentType: adjustmentType,
        reason: reason,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      ),
    );
  }
}
