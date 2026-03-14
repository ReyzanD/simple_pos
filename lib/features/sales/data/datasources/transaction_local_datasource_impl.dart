import 'package:sqflite/sqflite.dart' as sqflite;
import '../../../../services/database/database_helper.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/entities/payment.dart';
import '../../../../core/exceptions/app_exceptions.dart' as app_exceptions;
import '../../../../core/utils/logger.dart';

/// Local data source implementation for transactions using SQLite
class TransactionLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  TransactionLocalDataSourceImpl({required this.databaseHelper});

  /// Creates a new transaction with items and payment
  /// Returns the created transaction with generated ID
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Creating transaction', details: 'Items: ${transaction.items.length}');

      int transactionId = 0;

      // Begin transaction
      await db.transaction((txn) async {
        // Insert transaction
        transactionId = await txn.insert(
          'transactions',
          transaction.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );

        AppLogger.database('Transaction created', details: 'ID: $transactionId');

        // Insert transaction items
        for (final item in transaction.items) {
          final itemMap = item.toMap();
          itemMap['transaction_id'] = transactionId;

          await txn.insert(
            'transaction_items',
            itemMap,
            conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
          );
        }

        AppLogger.database('Transaction items created', details: '${transaction.items.length} items');

        // Insert payment if provided
        if (transaction.payment != null) {
          final paymentMap = transaction.payment!.toMap();
          paymentMap['transaction_id'] = transactionId;

          await txn.insert(
            'payments',
            paymentMap,
            conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
          );

          AppLogger.database('Payment created', details: 'Transaction ID: $transactionId');
        }
      });

      // Return transaction with actual ID from database
      return transaction.copyWith(
        id: transactionId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create transaction',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionLocalDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal membuat transaksi',
        operation: 'buat transaksi',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all transactions from database
  Future<List<Transaction>> getTransactions() async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching all transactions');

      final transactionMaps = await db.query(
        'transactions',
        orderBy: 'transaction_date DESC',
      );

      final transactions = <Transaction>[];

      for (final txMap in transactionMaps) {
        final transactionId = txMap['id'] as int;

        // Get transaction items
        final items = await _getTransactionItems(db, transactionId);

        // Get payment
        final payment = await _getPayment(db, transactionId);

        transactions.add(Transaction.fromMap(txMap, items: items, payment: payment));
      }

      AppLogger.database('Transactions fetched', details: '${transactions.length} items');
      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch transactions',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionLocalDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil data transaksi',
        operation: 'ambil transaksi',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves transaction items for a transaction
  Future<List<TransactionItem>> _getTransactionItems(sqflite.Database db, int transactionId) async {
    final itemMaps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );

    return itemMaps.map((map) => TransactionItem.fromMap(map)).toList();
  }

  /// Retrieves payment for a transaction
  Future<Payment?> _getPayment(sqflite.Database db, int transactionId) async {
    final paymentMaps = await db.query(
      'payments',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      limit: 1,
    );

    if (paymentMaps.isEmpty) {
      return null;
    }

    return Payment.fromMap(paymentMaps.first);
  }

  /// Retrieves a single transaction by ID
  Future<Transaction?> getTransactionById(int id) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching transaction', details: 'ID: $id');

      final transactionMaps = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (transactionMaps.isEmpty) {
        AppLogger.database('Transaction not found', details: 'ID: $id');
        return null;
      }

      final txMap = transactionMaps.first;
      final items = await _getTransactionItems(db, id);
      final payment = await _getPayment(db, id);

      return Transaction.fromMap(txMap, items: items, payment: payment);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch transaction by ID',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionLocalDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil data transaksi',
        operation: 'ambil transaksi by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching transactions by date range');

      final transactionMaps = await db.query(
        'transactions',
        where: 'transaction_date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'transaction_date DESC',
      );

      final transactions = <Transaction>[];

      for (final txMap in transactionMaps) {
        final transactionId = txMap['id'] as int;
        final items = await _getTransactionItems(db, transactionId);
        final payment = await _getPayment(db, transactionId);

        transactions.add(Transaction.fromMap(txMap, items: items, payment: payment));
      }

      AppLogger.database('Transactions fetched', details: '${transactions.length} items in range');
      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch transactions by date range',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionLocalDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil data transaksi',
        operation: 'ambil transaksi by tanggal',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets transactions by payment status
  Future<List<Transaction>> getTransactionsByStatus(String status) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching transactions by status', details: status);

      final transactionMaps = await db.query(
        'transactions',
        where: 'payment_status = ?',
        whereArgs: [status],
        orderBy: 'transaction_date DESC',
      );

      final transactions = <Transaction>[];

      for (final txMap in transactionMaps) {
        final transactionId = txMap['id'] as int;
        final items = await _getTransactionItems(db, transactionId);
        final payment = await _getPayment(db, transactionId);

        transactions.add(Transaction.fromMap(txMap, items: items, payment: payment));
      }

      AppLogger.database('Transactions fetched', details: '${transactions.length} items with status $status');
      return transactions;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch transactions by status',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionLocalDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil data transaksi',
        operation: 'ambil transaksi by status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates transaction status (e.g., for refunds)
  Future<void> updateTransactionStatus(int id, String status) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Updating transaction status', details: 'ID: $id, Status: $status');

      final rowsAffected = await db.update(
        'transactions',
        {
          'payment_status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.database('Transaction not found for update', details: 'ID: $id');
        throw app_exceptions.NotFoundException(
          'Transaksi tidak ditemukan',
          resourceType: 'Transaksi',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Transaction status updated', details: 'ID: $id');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update transaction status',
        error: e,
        stackTrace: stackTrace,
        tag: 'TransactionLocalDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate status transaksi',
        operation: 'update status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
