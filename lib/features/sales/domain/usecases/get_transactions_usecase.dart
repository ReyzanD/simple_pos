import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for retrieving transactions
class GetTransactionsUseCase {
  final TransactionRepository transactionRepository;

  GetTransactionsUseCase({required this.transactionRepository});

  /// Executes the use case to get all transactions
  Future<List<Transaction>> execute() async {
    try {
      AppLogger.useCase('GetTransactions');

      final transactions = await transactionRepository.getTransactions();

      AppLogger.info('Retrieved ${transactions.length} transactions');

      return transactions;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetTransactionsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data transaksi',
        operation: 'GetTransactions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Executes the use case to get transactions by date range
  Future<List<Transaction>> executeByDateRange(DateTime start, DateTime end) async {
    try {
      AppLogger.useCase('GetTransactionsByDateRange', details: '$start to $end');

      final transactions = await transactionRepository.getTransactionsByDateRange(start, end);

      AppLogger.info('Retrieved ${transactions.length} transactions in date range');

      return transactions;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetTransactionsByDateRange',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data transaksi',
        operation: 'GetTransactionsByDateRange',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Executes the use case to get a single transaction by ID
  Future<Transaction> executeById(int id) async {
    try {
      AppLogger.useCase('GetTransactionById', details: 'ID: $id');

      if (id <= 0) {
        throw ValidationException('ID transaksi tidak valid', field: 'ID');
      }

      final transaction = await transactionRepository.getTransactionById(id);

      AppLogger.info('Retrieved transaction: $id');

      return transaction;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetTransactionById',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data transaksi',
        operation: 'GetTransactionById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
