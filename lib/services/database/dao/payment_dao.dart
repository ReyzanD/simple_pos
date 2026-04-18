import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for Payment table operations.
///
/// This class provides a clean abstraction layer for all Payment-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for Payment entities.
///
/// Usage:
/// ```dart
/// final dao = PaymentDao.instance;
/// final payments = await dao.getByTransactionId(1);
/// final payment = await dao.insert({'transaction_id': 1, 'payment_method': 'cash', 'amount': 100.0});
/// ```
class PaymentDao {
  // Private constructor to prevent instantiation
  PaymentDao._();

  // Singleton instance
  static final PaymentDao instance = PaymentDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== CRUD Operations ====================

  /// Inserts a new payment into the database.
  ///
  /// [payment] - A map containing payment fields (transaction_id, payment_method, amount, cash_received, card_last_4_digits, payment_date)
  /// Returns the created payment map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> insert(Map<String, dynamic> payment) async {
    try {
      AppLogger.database('Inserting payment', details: 'Transaction ID: ${payment['transaction_id']}');

      final db = await _db;
      final id = await db.insert('payments', payment);

      AppLogger.database('Payment inserted', details: 'ID: $id');

      // Return the payment with its ID
      return {...payment, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert payment',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan pembayaran',
        operation: 'insert payment',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all payments from database.
  ///
  /// Returns a list of payment maps, ordered by payment_date DESC (newest first)
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all payments from database');

      final db = await _db;
      final payments = await db.query(
        'payments',
        orderBy: 'payment_date DESC',
      );

      AppLogger.database('Payments fetched successfully',
          details: 'Count: ${payments.length}');

      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all payments',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua pembayaran',
        operation: 'get all payments',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single payment by its ID.
  ///
  /// [id] - The payment ID to retrieve
  /// Returns payment map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching payment by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'payments',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Payment fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('Payment not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch payment by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pembayaran',
        operation: 'get payment by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing payment in database.
  ///
  /// [id] - The payment ID to update
  /// [values] - A map containing payment fields to update
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if payment not found
  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      AppLogger.database('Updating payment in database',
          details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'payments',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Pembayaran tidak ditemukan',
          resourceType: 'Pembayaran',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Payment updated successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update payment',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate pembayaran',
        operation: 'update payment',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a payment by ID.
  ///
  /// [id] - The payment ID to delete
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if payment not found
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Deleting payment', details: 'ID: $id');

      final db = await _db;
      final count = await db.delete(
        'payments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Pembayaran tidak ditemukan',
          resourceType: 'Pembayaran',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Payment deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete payment',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus pembayaran',
        operation: 'delete payment',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Query Operations ====================

  /// Retrieves all payments for a specific transaction.
  ///
  /// [transactionId] - The transaction ID to filter by
  /// Returns a list of payment maps for the specified transaction
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByTransactionId(int transactionId) async {
    try {
      AppLogger.database('Fetching payments by transaction ID',
          details: 'Transaction ID: $transactionId');

      final db = await _db;
      final payments = await db.query(
        'payments',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
        orderBy: 'payment_date ASC',
      );

      AppLogger.database('Payments by transaction ID fetched successfully',
          details: 'Transaction ID: $transactionId, Count: ${payments.length}');

      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch payments by transaction ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pembayaran berdasarkan transaksi',
        operation: 'get payments by transaction ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves payments filtered by payment method.
  ///
  /// [paymentMethod] - The payment method to filter by (e.g., 'cash', 'card', 'qr', 'transfer')
  /// Returns a list of payment maps for the specified payment method
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByPaymentMethod(String paymentMethod) async {
    try {
      AppLogger.database('Fetching payments by method', details: paymentMethod);

      final db = await _db;
      final payments = await db.query(
        'payments',
        where: 'payment_method = ?',
        whereArgs: [paymentMethod],
        orderBy: 'payment_date DESC',
      );

      AppLogger.database('Payments by method fetched successfully',
          details: 'Method: $paymentMethod, Count: ${payments.length}');

      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch payments by method',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pembayaran berdasarkan metode pembayaran',
        operation: 'get payments by method',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total amount for a specific transaction.
  ///
  /// [transactionId] - The transaction ID to calculate total for
  /// Returns sum of all payment amounts for the transaction
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<double> getTotalByTransactionId(int transactionId) async {
    try {
      AppLogger.database('Calculating total payments for transaction',
          details: 'Transaction ID: $transactionId');

      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM payments WHERE transaction_id = ?',
        [transactionId],
      );
      final total = result.first['total'] as double? ?? 0.0;

      AppLogger.database('Total payments calculated',
          details: 'Transaction ID: $transactionId, Total: $total');

      return total;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total payments',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung total pembayaran',
        operation: 'calculate total payments',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves payments within a date range.
  ///
  /// [startDate] - Start date in ISO8601 format (inclusive)
  /// [endDate] - End date in ISO8601 format (inclusive)
  /// Returns a list of payment maps within the date range
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByDateRange(
      String startDate, String endDate) async {
    try {
      AppLogger.database('Fetching payments by date range',
          details: '$startDate to $endDate');

      final db = await _db;
      final payments = await db.query(
        'payments',
        where: 'payment_date >= ? AND payment_date <= ?',
        whereArgs: [startDate, endDate],
        orderBy: 'payment_date DESC',
      );

      AppLogger.database('Payments by date range fetched successfully',
          details: 'Range: $startDate to $endDate, Count: ${payments.length}');

      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch payments by date range',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pembayaran berdasarkan rentang tanggal',
        operation: 'get payments by date range',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts total number of payments in database.
  ///
  /// Returns total count of payments
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total payments');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM payments');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total payments counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count payments',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah pembayaran',
        operation: 'count payments',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts payments by transaction ID.
  ///
  /// [transactionId] - The transaction ID to count payments for
  /// Returns count of payments for the transaction
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> countByTransactionId(int transactionId) async {
    try {
      AppLogger.database('Counting payments for transaction',
          details: 'Transaction ID: $transactionId');

      final db = await _db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM payments WHERE transaction_id = ?',
        [transactionId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Payments counted for transaction',
          details: 'Transaction ID: $transactionId, Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count payments for transaction',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah pembayaran untuk transaksi',
        operation: 'count payments by transaction ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes all payments for a specific transaction.
  ///
  /// [transactionId] - The transaction ID to delete payments for
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> deleteByTransactionId(int transactionId) async {
    try {
      AppLogger.database('Deleting payments for transaction',
          details: 'Transaction ID: $transactionId');

      final db = await _db;
      final count = await db.delete(
        'payments',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      AppLogger.database('Payments deleted for transaction',
          details: 'Transaction ID: $transactionId, Affected rows: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete payments for transaction',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus pembayaran untuk transaksi',
        operation: 'delete payments by transaction ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
