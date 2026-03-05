import '../datasources/transaction_local_datasource_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of TransactionRepository
/// Handles transaction data operations through local data source
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSourceImpl localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      AppLogger.useCase('GetTransactions');
      return await localDataSource.getTransactions();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get transactions in repository',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Transaction> getTransactionById(int id) async {
    try {
      AppLogger.useCase('GetTransactionById', details: 'ID: $id');
      final transaction = await localDataSource.getTransactionById(id);

      if (transaction == null) {
        throw NotFoundException(
          'Transaksi tidak ditemukan',
          resourceType: 'Transaksi',
          resourceId: id.toString(),
        );
      }

      return transaction;
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get transaction by ID in repository',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionRepository',
      );
      rethrow;
    }
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      AppLogger.useCase('CreateTransaction', details: '${transaction.items.length} items');

      // Validate transaction
      if (transaction.items.isEmpty) {
        throw ValidationException('Transaksi harus memiliki minimal satu item');
      }

      if (transaction.totalAmount <= 0) {
        throw ValidationException('Total transaksi harus lebih dari 0');
      }

      final createdTransaction = await localDataSource.createTransaction(transaction);

      AppLogger.info('Transaction created successfully in repository');
      return createdTransaction;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create transaction in repository',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionRepository',
      );
      throw DatabaseException(
        'Gagal membuat transaksi',
        operation: 'buat transaksi',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> refundTransaction(int transactionId) async {
    try {
      AppLogger.useCase('RefundTransaction', details: 'ID: $transactionId');

      // Get transaction to validate it can be refunded
      final transaction = await getTransactionById(transactionId);

      // Validate transaction is refundable
      if (!transaction.isRefundable) {
        throw ValidationException(
          'Transaksi ini tidak dapat dikembalikan. Status: ${transaction.paymentStatus.name}',
        );
      }

      // Update transaction status to refunded
      await localDataSource.updateTransactionStatus(
        transactionId,
        'refunded',
      );

      AppLogger.info('Transaction refunded successfully');
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to refund transaction in repository',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      AppLogger.useCase('GetTransactionsByDateRange', details: '$start to $end');

      if (start.isAfter(end)) {
        throw ValidationException('Tanggal awal tidak boleh setelah tanggal akhir');
      }

      return await localDataSource.getTransactionsByDateRange(start, end);
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get transactions by date range in repository',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionRepository',
      );
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByStatus(String status) async {
    try {
      AppLogger.useCase('GetTransactionsByStatus', details: status);

      // Validate status
      final validStatuses = ['pending', 'completed', 'cancelled', 'refunded'];
      if (!validStatuses.contains(status.toLowerCase())) {
        throw ValidationException('Status pembayaran tidak valid: $status');
      }

      return await localDataSource.getTransactionsByStatus(status);
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get transactions by status in repository',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionRepository',
      );
      rethrow;
    }
  }
}
