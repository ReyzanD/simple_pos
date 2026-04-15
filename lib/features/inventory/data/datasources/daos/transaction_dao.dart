import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart' show AppLogger;
import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/database/database_helper.dart';

class TransactionDao {
  final DatabaseHelper _dbHelper;
  TransactionDao(this._dbHelper);

  Future<Database> get _db async => await _dbHelper.database;

  /// Performs an atomic sale: Inserts Transaction, Items, Payment, and Updates Stock
  Future<int> createFullTransaction({
    required Map<String, dynamic> txnMap,
    required List<Map<String, dynamic>> itemMaps,
    Map<String, dynamic>? paymentMap,
  }) async {
    final db = await _db;

    return await db.transaction((txn) async {
      // 1. Insert Transaction
      final txId = await txn.insert('transactions', txnMap);

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

      // 3. Insert Payment (if applicable)
      if (paymentMap != null) {
        paymentMap['transaction_id'] = txId;
        await txn.insert('payments', paymentMap);
      }

      return txId;
    });
  }

  // --- Helpers for fetching ---
  Future<List<Map<String, dynamic>>> getAll() async =>
      await (await _db).query('transactions', orderBy: 'transaction_date DESC');

  Future<Map<String, dynamic>?> getById(int id) async {
    final res = await (await _db).query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> getItems(int txId) async =>
      await (await _db).query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [txId],
      );

  Future<Map<String, dynamic>?> getPayment(int txId) async {
    final res = await (await _db).query(
      'payments',
      where: 'transaction_id = ?',
      whereArgs: [txId],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> updateStatus(int id, String status) async {
    await (await _db).update(
      'transactions',
      {
        'payment_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fetches transactions within a specific date range
  Future<List<Map<String, dynamic>>> getByDateRange(
    String start,
    String end,
  ) async {
    try {
      final db = await _db;
      AppLogger.database(
        'Fetching transactions by date range in DAO',
        details: '$start to $end',
      );

      return await db.query(
        'transactions',
        where: 'transaction_date BETWEEN ? AND ?',
        whereArgs: [start, end],
        orderBy: 'transaction_date DESC',
      );
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'ambil transaksi by range tanggal');
    }
  }

  /// Fetches transactions filtered by their payment status
  Future<List<Map<String, dynamic>>> getByStatus(String status) async {
    try {
      final db = await _db;
      AppLogger.database(
        'Fetching transactions by status in DAO',
        details: status,
      );

      return await db.query(
        'transactions',
        where: 'payment_status = ?',
        whereArgs: [status],
        orderBy: 'transaction_date DESC',
      );
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'ambil transaksi by status');
    }
  }

  /// Centralized error handling for Transaction database operations
  app_exceptions.DatabaseException _handleError(
    dynamic e,
    StackTrace s,
    String op,
  ) {
    // Log the error using your AppLogger
    AppLogger.error(
      'Database Error in TransactionDao: $op',
      error: e,
      stackTrace: s,
      tag: 'TransactionDao',
    );

    // Return your custom DatabaseException
    return app_exceptions.DatabaseException(
      'Gagal $op',
      operation: op,
      originalError: e,
      stackTrace: s,
    );
  }
}
