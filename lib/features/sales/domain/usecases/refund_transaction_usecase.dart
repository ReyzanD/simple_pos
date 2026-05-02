import '../repositories/transaction_repository.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../inventory/domain/repositories/product_variant_repository.dart';
import '../../../inventory/domain/repositories/stock_adjustment_repository.dart';
import '../../../inventory/domain/entities/stock_adjustment.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for refunding a transaction
class RefundTransactionUseCase {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;
  final ProductVariantRepository productVariantRepository;
  final StockAdjustmentRepository stockAdjustmentRepository;

  RefundTransactionUseCase({
    required this.transactionRepository,
    required this.productRepository,
    required this.productVariantRepository,
    required this.stockAdjustmentRepository,
  });

  /// Executes the use case
  /// Refunds the transaction and restores stock (including variant stock)
  Future<void> execute(int transactionId) async {
    try {
      AppLogger.useCase('RefundTransaction', details: 'ID: $transactionId');

      if (transactionId <= 0) {
        throw ValidationException('ID transaksi tidak valid', field: 'ID');
      }

      // Get the transaction to check if it's refundable
      final transaction = await transactionRepository.getTransactionById(transactionId);

      if (!transaction.isRefundable) {
        throw ValidationException(
          'Transaksi ini tidak dapat dikembalikan',
          field: 'Status Transaksi',
        );
      }

      // Restore stock for each item in the transaction
      for (final item in transaction.items) {
        // 1. Restore base product stock
        final previousStock = await productRepository.getStock(item.productId);
        final newStock = previousStock + item.quantity;
        await productRepository.updateStock(item.productId, newStock);

        AppLogger.info(
          'Base product stock restored for ${item.productName}: $previousStock -> $newStock',
        );

        // 2. Restore variant stock if the item was a variant (variantId > 0)
        if (item.variantId > 0) {
          try {
            final variant = await productVariantRepository.getVariantById(item.variantId);
            final newVariantStock = variant.stock + item.quantity;
            await productVariantRepository.updateVariantStock(item.variantId, newVariantStock);

            AppLogger.info(
              'Variant stock restored for variant ${item.variantId}: ${variant.stock} -> $newVariantStock',
            );
          } catch (e) {
            // Log but don't fail — variant may have been deleted after the original sale
            AppLogger.warning(
              'Could not restore variant stock for variantId=${item.variantId}: $e',
            );
          }
        }

        // 3. Record a stock adjustment for the audit trail
        try {
          await stockAdjustmentRepository.recordAdjustment(
            StockAdjustment(
              id: 0,
              productId: item.productId,
              previousQuantity: previousStock,
              newQuantity: newStock,
              adjustmentType: StockAdjustmentType.itemReturn,
              reason: 'Refund transaksi #$transactionId',
              createdBy: 'system',
              createdAt: DateTime.now(),
            ),
          );
        } catch (e) {
          // Log but don't fail — adjustment logging is non-critical
          AppLogger.warning('Could not record stock adjustment for product ${item.productId}: $e');
        }
      }

      // Process the refund (update transaction status to 'refunded')
      await transactionRepository.refundTransaction(transactionId);

      AppLogger.info('Transaction refunded successfully: $transactionId');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in RefundTransactionUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengembalikan transaksi',
        operation: 'RefundTransaction',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
