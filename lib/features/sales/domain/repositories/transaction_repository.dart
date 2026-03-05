import '../entities/transaction.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Interface for transaction repository operations
abstract class TransactionRepository {
  /// Retrieves all transactions from the data source
  /// Throws [DatabaseException] if retrieval fails
  Future<List<Transaction>> getTransactions();

  /// Retrieves a single transaction by ID
  /// Throws [NotFoundException] if transaction doesn't exist
  /// Throws [DatabaseException] if retrieval fails
  Future<Transaction> getTransactionById(int id);

  /// Creates a new transaction with items and payment
  /// Throws [ValidationException] if validation fails
  /// Throws [DatabaseException] if creation fails
  Future<Transaction> createTransaction(Transaction transaction);

  /// Refunds a transaction and restores stock
  /// Throws [NotFoundException] if transaction doesn't exist
  /// Throws [ValidationException] if transaction is not refundable
  /// Throws [DatabaseException] if refund fails
  Future<void> refundTransaction(int transactionId);

  /// Searches for transactions by date range
  /// Throws [DatabaseException] if search fails
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);

  /// Gets transactions by payment status
  /// Throws [DatabaseException] if retrieval fails
  Future<List<Transaction>> getTransactionsByStatus(String status);
}
