import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for Transaction, TransactionItem, and Payment table operations.
///
/// This class provides a clean abstraction layer for all Transaction-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for Transaction, TransactionItem, and Payment entities.
///
/// Usage:
/// ```dart
/// final dao = TransactionDao();
/// final txId = await dao.createFullTransaction(
///   txnMap: {'total_amount': 100.0, 'payment_method': 'cash'},
///   itemMaps: [{'product_id': 1, 'quantity': 2, 'unit_price': 50.0}],
///   paymentMap: {'amount': 100.0, 'payment_method': 'cash'},
/// );
/// final allTransactions = await dao.getAll();
/// ```
class TransactionDao {
  // Private constructor to prevent instantiation
  TransactionDao._();

  // Singleton instance
  static final TransactionDao instance = TransactionDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== Transaction CRUD Operations ====================

  /// Performs an atomic sale: Inserts Transaction, Items, Payment, and Updates Stock
  ///
  /// This method runs within a database transaction to ensure data consistency.
  /// If any operation fails, all changes are rolled back.
  ///
  /// [txnMap] - A map containing transaction fields
  /// [itemMaps] - A list of maps containing transaction item fields
  /// [paymentMap] - An optional map containing payment fields
  /// Returns the created transaction ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> createFullTransaction({
    required Map<String, dynamic> txnMap,
    required List<Map<String, dynamic>> itemMaps,
    Map<String, dynamic>? paymentMap,
  }) async {
    try {
      AppLogger.database(
          'Creating full transaction with ${itemMaps.length} items');

      final db = await _db;

      return await db.transaction((txn) async {
        // 1. Insert Transaction
        final txId = await txn.insert('transactions', txnMap);

        AppLogger.database('Transaction inserted', details: 'ID: $txId');

        // 2. Insert Items & Update Product Stock
        for (var item in itemMaps) {
          item['transaction_id'] = txId;
          await txn.insert('transaction_items', item);

          // Decrement inventory stock automatically
          await txn.execute(
            'UPDATE products SET stock = stock - ? WHERE id = ?',
            [item['quantity'], item['product_id']],
          );
        }

        AppLogger.database('Transaction items inserted',
            details: '${itemMaps.length} items, stock updated');

        // 3. Insert Payment (if applicable)
        if (paymentMap != null) {
          paymentMap['transaction_id'] = txId;
          await txn.insert('payments', paymentMap);

          AppLogger.database('Payment inserted', details: 'Transaction ID: $txId');
        }

        return txId;
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create full transaction',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal membuat transaksi',
        operation: 'create full transaction',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all transactions from database.
  ///
  /// Returns a list of transaction maps, ordered by transaction date (newest first)
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all transactions from database');

      final db = await _db;
      final transactions =
          await db.query('transactions', orderBy: 'transaction_date DESC');

      AppLogger.database('Transactions fetched successfully',
          details: 'Count: ${transactions.length}');

      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all transactions',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua transaksi',
        operation: 'get all transactions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single transaction by its ID.
  ///
  /// [id] - The transaction ID to retrieve
  /// Returns transaction map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching transaction by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Transaction fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('Transaction not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch transaction by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil transaksi',
        operation: 'get transaction by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing transaction in database.
  ///
  /// [transaction] - A map containing transaction fields including 'id' field
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> update(Map<String, dynamic> transaction) async {
    try {
      AppLogger.database('Updating transaction in database',
          details: 'ID: ${transaction['id']}');

      if (transaction['id'] == null) {
        throw const app_exceptions.ValidationException(
          'ID transaksi diperlukan untuk update',
          field: 'id',
        );
      }

      final db = await _db;
      final count = await db.update(
        'transactions',
        transaction,
        where: 'id = ?',
        whereArgs: [transaction['id']],
      );

      AppLogger.database('Transaction updated successfully',
          details: 'ID: ${transaction['id']}, Affected rows: $count');

      return count;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update transaction',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate transaksi',
        operation: 'update transaction',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates transaction payment status.
  ///
  /// [id] - The transaction ID to update
  /// [status] - The new payment status
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> updateStatus(int id, String status) async {
    try {
      AppLogger.database('Updating transaction status',
          details: 'ID: $id, Status: $status');

      final db = await _db;
      final count = await db.update(
        'transactions',
        {
          'payment_status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      AppLogger.database('Transaction status updated successfully',
          details: 'ID: $id, Status: $status, Affected rows: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update transaction status',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate status transaksi',
        operation: 'update transaction status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Soft deletes a transaction by ID (sets payment_status to 'refunded').
  ///
  /// [id] - The transaction ID to delete
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Soft deleting transaction', details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'transactions',
        {
          'payment_status': 'refunded',
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      AppLogger.database('Transaction soft deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete transaction',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus transaksi',
        operation: 'delete transaction',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Transaction Query Operations ====================

  /// Fetches transactions within a specific date range.
  ///
  /// [start] - Start date in ISO8601 format
  /// [end] - End date in ISO8601 format
  /// Returns a list of transaction maps within the date range
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByDateRange(
    String start,
    String end,
  ) async {
    try {
      AppLogger.database('Fetching transactions by date range',
          details: '$start to $end');

      final db = await _db;
      final transactions = await db.query(
        'transactions',
        where: 'transaction_date BETWEEN ? AND ?',
        whereArgs: [start, end],
        orderBy: 'transaction_date DESC',
      );

      AppLogger.database('Transactions by date range fetched successfully',
          details: 'Count: ${transactions.length}');

      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch transactions by date range',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil transaksi berdasarkan rentang tanggal',
        operation: 'get transactions by date range',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches transactions filtered by their payment status.
  ///
  /// [status] - The payment status to filter by
  /// Returns a list of transaction maps with the specified status
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByStatus(String status) async {
    try {
      AppLogger.database('Fetching transactions by status', details: status);

      final db = await _db;
      final transactions = await db.query(
        'transactions',
        where: 'payment_status = ?',
        whereArgs: [status],
        orderBy: 'transaction_date DESC',
      );

      AppLogger.database('Transactions by status fetched successfully',
          details: 'Status: $status, Count: ${transactions.length}');

      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch transactions by status',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil transaksi berdasarkan status',
        operation: 'get transactions by status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches recent transactions with a limit.
  ///
  /// [limit] - Maximum number of transactions to retrieve (default: 50)
  /// Returns a list of recent transaction maps
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getRecent({int limit = 50}) async {
    try {
      AppLogger.database('Fetching recent transactions', details: 'Limit: $limit');

      final db = await _db;
      final transactions = await db.query(
        'transactions',
        orderBy: 'transaction_date DESC',
        limit: limit,
      );

      AppLogger.database('Recent transactions fetched successfully',
          details: 'Count: ${transactions.length}');

      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch recent transactions',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil transaksi terbaru',
        operation: 'get recent transactions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Transaction Item Operations ====================

  /// Retrieves all transaction items for a specific transaction.
  ///
  /// [transactionId] - The transaction ID to fetch items for
  /// Returns a list of transaction item maps
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getItems(int transactionId) async {
    try {
      AppLogger.database('Fetching transaction items',
          details: 'Transaction ID: $transactionId');

      final db = await _db;
      final items = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
        orderBy: 'id ASC',
      );

      AppLogger.database('Transaction items fetched successfully',
          details: 'Transaction ID: $transactionId, Count: ${items.length}');

      return items;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch transaction items',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil item transaksi',
        operation: 'get transaction items',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Creates a transaction item.
  ///
  /// [item] - A map containing transaction item fields
  /// Returns the created transaction item map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> item) async {
    try {
      AppLogger.database('Creating transaction item',
          details: 'Product ID: ${item['product_id']}');

      final db = await _db;
      final id = await db.insert('transaction_items', item);

      AppLogger.database('Transaction item created successfully',
          details: 'ID: $id');

      return {...item, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create transaction item',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal membuat item transaksi',
        operation: 'create transaction item',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Payment Operations ====================

  /// Creates a payment record.
  ///
  /// [payment] - A map containing payment fields
  /// Returns the created payment map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> payment) async {
    try {
      AppLogger.database('Creating payment',
          details: 'Transaction ID: ${payment['transaction_id']}');

      final db = await _db;
      final id = await db.insert('payments', payment);

      AppLogger.database('Payment created successfully', details: 'ID: $id');

      return {...payment, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create payment',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal membuat pembayaran',
        operation: 'create payment',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves payment for a specific transaction.
  ///
  /// [transactionId] - The transaction ID to fetch payment for
  /// Returns payment map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getPayment(int transactionId) async {
    try {
      AppLogger.database('Fetching payment', details: 'Transaction ID: $transactionId');

      final db = await _db;
      final results = await db.query(
        'payments',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Payment fetched successfully',
            details: 'Transaction ID: $transactionId');
        return results.first;
      } else {
        AppLogger.database('Payment not found',
            details: 'Transaction ID: $transactionId');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch payment',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pembayaran',
        operation: 'get payment',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all payments for a specific transaction.
  ///
  /// [transactionId] - The transaction ID to fetch payments for
  /// Returns a list of payment maps
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getPaymentsByTransactionId(
      int transactionId) async {
    try {
      AppLogger.database('Fetching payments by transaction',
          details: 'Transaction ID: $transactionId');

      final db = await _db;
      final payments = await db.query(
        'payments',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
        orderBy: 'payment_date DESC',
      );

      AppLogger.database('Payments by transaction fetched successfully',
          details: 'Transaction ID: $transactionId, Count: ${payments.length}');

      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch payments by transaction',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pembayaran berdasarkan transaksi',
        operation: 'get payments by transaction',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Analytics & Reporting Operations ====================

  /// Calculates total sales amount within a date range.
  ///
  /// [start] - Start date in ISO8601 format
  /// [end] - End date in ISO8601 format
  /// Returns total sales amount
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<double> getTotalSalesInRange(String start, String end) async {
    try {
      AppLogger.database('Calculating total sales in range',
          details: '$start to $end');

      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM transactions WHERE transaction_date BETWEEN ? AND ? AND payment_status = ?',
        [start, end, 'completed'],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;

      AppLogger.database('Total sales calculated',
          details: 'Range: $start to $end, Total: $total');

      return total;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total sales',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung total penjualan',
        operation: 'calculate total sales',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total profit within a date range.
  ///
  /// [start] - Start date in ISO8601 format
  /// [end] - End date in ISO8601 format
  /// Returns total profit amount
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<double> getTotalProfitInRange(String start, String end) async {
    try {
      AppLogger.database('Calculating total profit in range',
          details: '$start to $end');

      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM((ti.unit_price - ti.cost_price) * ti.quantity) as total FROM transaction_items ti INNER JOIN transactions t ON ti.transaction_id = t.id WHERE t.transaction_date BETWEEN ? AND ? AND t.payment_status = ?',
        [start, end, 'completed'],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;

      AppLogger.database('Total profit calculated',
          details: 'Range: $start to $end, Total: $total');

      return total;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total profit',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung total keuntungan',
        operation: 'calculate total profit',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets sales breakdown by payment method within a date range.
  ///
  /// [start] - Start date in ISO8601 format
  /// [end] - End date in ISO8601 format
  /// Returns a list of maps with payment_method and total_amount
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getSalesByPaymentMethod(
    String start,
    String end,
  ) async {
    try {
      AppLogger.database('Getting sales by payment method',
          details: '$start to $end');

      final db = await _db;
      final results = await db.rawQuery(
        'SELECT payment_method, SUM(total_amount) as total_amount, COUNT(*) as transaction_count FROM transactions WHERE transaction_date BETWEEN ? AND ? AND payment_status = ? GROUP BY payment_method',
        [start, end, 'completed'],
      );

      AppLogger.database('Sales by payment method fetched',
          details: 'Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get sales by payment method',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil penjualan berdasarkan metode pembayaran',
        operation: 'get sales by payment method',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets top selling products within a date range.
  ///
  /// [start] - Start date in ISO8601 format
  /// [end] - End date in ISO8601 format
  /// [limit] - Maximum number of products to return (default: 10)
  /// Returns a list of maps with product details and total quantity sold
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String start,
    String end, {
    int limit = 10,
  }) async {
    try {
      AppLogger.database('Getting top selling products',
          details: '$start to $end, Limit: $limit');

      final db = await _db;
      final results = await db.rawQuery(
        'SELECT product_id, product_name, SUM(quantity) as total_quantity, SUM(transaction_items.subtotal) as total_revenue FROM transaction_items INNER JOIN transactions ON transaction_items.transaction_id = transactions.id WHERE transactions.transaction_date BETWEEN ? AND ? AND transactions.payment_status = ? GROUP BY product_id ORDER BY total_quantity DESC LIMIT ?',
        [start, end, 'completed', limit],
      );

      AppLogger.database('Top selling products fetched',
          details: 'Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get top selling products',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil produk terlaris',
        operation: 'get top selling products',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Utility Operations ====================

  /// Counts total number of transactions in database.
  ///
  /// Returns total count of transactions
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total transactions');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total transactions counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count transactions',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah transaksi',
        operation: 'count transactions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts transactions by payment status.
  ///
  /// [status] - The payment status to count
  /// Returns count of transactions with the specified status
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> countByStatus(String status) async {
    try {
      AppLogger.database('Counting transactions by status', details: status);

      final db = await _db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM transactions WHERE payment_status = ?',
        [status],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Transactions by status counted',
          details: 'Status: $status, Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count transactions by status',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung transaksi berdasarkan status',
        operation: 'count transactions by status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
