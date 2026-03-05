import '../repositories/transaction_repository.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for refunding a transaction
class RefundTransactionUseCase {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;

  RefundTransactionUseCase({
    required this.transactionRepository,
    required this.productRepository,
  });

  /// Executes the use case
  /// Refunds the transaction and restores stock
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
        final product = await productRepository.getProductById(item.productId);

        final updatedProduct = product.copyWith(
          stock: product.stock + item.quantity,
        );

        await productRepository.updateProduct(updatedProduct);

        AppLogger.info(
          'Stock restored for ${updatedProduct.name}: ${product.stock} -> ${updatedProduct.stock}',
        );
      }

      // Process the refund
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
