import 'package:simple_pos/services/database/dao/transaction_dao.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/entities/payment.dart';
import '../../../../core/exceptions/app_exceptions.dart' as app_exceptions;
import '../../../../core/utils/logger.dart';
import '../models/payment_model.dart';

class TransactionLocalDataSourceImpl {
  final TransactionDao transactionDao;

  TransactionLocalDataSourceImpl({required this.transactionDao});

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final txId = await transactionDao.createFullTransaction(
        txnMap: transaction.toMap(),
        itemMaps: transaction.items.map((e) => e.toMap()).toList(),
        paymentMap: transaction.payment?.toMap(),
      );

      return transaction.copyWith(
        id: txId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create transaction',
        error: e,
        stackTrace: stackTrace,
      );
      throw app_exceptions.DatabaseException(
        'Gagal membuat transaksi',
        operation: 'create',
        originalError: e,
      );
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final txMaps = await transactionDao.getAll();
      final List<Transaction> transactions = [];

      for (var map in txMaps) {
        final id = map['id'] as int;
        final itemMaps = await transactionDao.getItems(id);
        final payMap = await transactionDao.getPayment(id);

        transactions.add(
          Transaction.fromMap(
            map,
            items: itemMaps.map((i) => TransactionItem.fromMap(i)).toList(),
            payment: payMap != null ? Payment.fromMap(payMap) : null,
          ),
        );
      }
      return transactions;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        'Gagal mengambil transaksi',
        operation: 'getAll',
        originalError: e,
      );
    }
  }

  Future<Transaction?> getTransactionById(int id) async {
    final map = await transactionDao.getById(id);
    if (map == null) return null;

    final items = await transactionDao.getItems(id);
    final payment = await transactionDao.getPayment(id);

    return Transaction.fromMap(
      map,
      items: items.map((i) => TransactionItem.fromMap(i)).toList(),
      payment: payment != null ? Payment.fromMap(payment) : null,
    );
  }

  Future<void> updateTransactionStatus(int id, String status) async {
    await transactionDao.updateStatus(id, status);
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final txnMaps = await transactionDao.getByDateRange(
        start.toIso8601String(),
        end.toIso8601String(),
      );
      return _mapTransactionList(txnMaps);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        'Gagal ambil range tanggal',
        operation: 'range',
        originalError: e,
      );
    }
  }

  Future<List<Transaction>> getTransactionsByStatus(String status) async {
    try {
      final txnMaps = await transactionDao.getByStatus(status);
      return _mapTransactionList(txnMaps);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        'Gagal ambil status',
        operation: 'status',
        originalError: e,
      );
    }
  }

  // Private helper to avoid repeating code
  Future<List<Transaction>> _mapTransactionList(
    List<Map<String, dynamic>> maps,
  ) async {
    final List<Transaction> transactions = [];
    for (var map in maps) {
      final id = map['id'] as int;
      final itemMaps = await transactionDao.getItems(id);
      final payMap = await transactionDao.getPayment(id);

      transactions.add(
        Transaction.fromMap(
          map,
          items: itemMaps.map((i) => TransactionItem.fromMap(i)).toList(),
          payment: payMap != null ? PaymentModel.fromMap(payMap) : null,
        ),
      );
    }
    return transactions;
  }
}
