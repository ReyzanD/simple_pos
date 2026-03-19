import '../models/shift_model.dart';
import '../../../../services/database/database_helper.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Local data source implementation for shifts using SQLite
class ShiftLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  ShiftLocalDataSourceImpl({required this.databaseHelper});

  /// Opens a new shift
  Future<ShiftModel> openShift({
    required String userName,
    required double openingBalance,
  }) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Opening shift', details: 'User: $userName');

      final now = DateTime.now();
      final model = ShiftModel(
        userName: userName,
        openingBalance: openingBalance,
        openedAt: now,
      );

      final id = await db.insert('shifts', model.toMap());
      final created = model.copyWith(id: id);

      AppLogger.database('Shift opened', details: 'ID: $id');
      return created;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to open shift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuka shift',
        operation: 'openShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Closes an active shift
  Future<ShiftModel> closeShift({
    required int shiftId,
    required double closingBalance,
  }) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Closing shift', details: 'ID: $shiftId');

      // First get the current shift data
      final currentShift = await getShiftById(shiftId);

      final now = DateTime.now().millisecondsSinceEpoch;
      final count = await db.update(
        'shifts',
        {
          'closing_balance': closingBalance,
          'closed_at': now,
        },
        where: 'id = ?',
        whereArgs: [shiftId],
      );

      if (count == 0) {
        throw NotFoundException('Shift dengan ID $shiftId tidak ditemukan');
      }

      AppLogger.database('Shift closed', details: 'ID: $shiftId');
      return currentShift.copyWith(
        closingBalance: closingBalance,
        closedAt: DateTime.fromMillisecondsSinceEpoch(now),
      );
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to close shift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menutup shift',
        operation: 'closeShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the currently active shift (closed_at is NULL)
  Future<ShiftModel?> getCurrentShift() async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching current shift');

      final result = await db.query(
        'shifts',
        where: 'closed_at IS NULL',
        orderBy: 'opened_at DESC',
        limit: 1,
      );

      if (result.isEmpty) {
        AppLogger.database('No active shift found');
        return null;
      }

      AppLogger.database('Active shift found', details: 'ID: ${result.first['id']}');
      return ShiftModel.fromMap(result.first);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get current shift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil shift aktif',
        operation: 'getCurrentShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets shifts with optional date filtering
  Future<List<ShiftModel>> getShifts({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching shifts', details: 'Limit: $limit, Offset: $offset');

      String? where;
      List<dynamic>? whereArgs;

      if (startDate != null && endDate != null) {
        where = 'opened_at >= ? AND opened_at <= ?';
        whereArgs = [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ];
      } else if (startDate != null) {
        where = 'opened_at >= ?';
        whereArgs = [startDate.millisecondsSinceEpoch];
      } else if (endDate != null) {
        where = 'opened_at <= ?';
        whereArgs = [endDate.millisecondsSinceEpoch];
      }

      final result = await db.query(
        'shifts',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'opened_at DESC',
        limit: limit,
        offset: offset,
      );

      AppLogger.database('Shifts fetched', details: '${result.length} items');
      return result.map((map) => ShiftModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get shifts',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil riwayat shift',
        operation: 'getShifts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a shift by ID
  Future<ShiftModel> getShiftById(int id) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching shift', details: 'ID: $id');

      final results = await db.query(
        'shifts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        throw NotFoundException('Shift dengan ID $id tidak ditemukan');
      }

      AppLogger.database('Shift fetched', details: 'ID: $id');
      return ShiftModel.fromMap(results.first);
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get shift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data shift',
        operation: 'getShiftById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates shift totals after a transaction
  Future<ShiftModel> updateShiftTotals({
    required int shiftId,
    required double cashSales,
    required double cardSales,
    required double qrSales,
    required double transferSales,
    required int transactionCount,
  }) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Updating shift totals', details: 'ID: $shiftId');

      // First get current shift data
      final currentShift = await getShiftById(shiftId);

      // Calculate new totals
      final newCashSales = currentShift.cashSales + cashSales;
      final newCardSales = currentShift.cardSales + cardSales;
      final newQrSales = currentShift.qrSales + qrSales;
      final newTransferSales = currentShift.transferSales + transferSales;
      final newTotalTransactions = currentShift.totalTransactions + transactionCount;

      final count = await db.update(
        'shifts',
        {
          'cash_sales': newCashSales,
          'card_sales': newCardSales,
          'qr_sales': newQrSales,
          'transfer_sales': newTransferSales,
          'total_transactions': newTotalTransactions,
        },
        where: 'id = ?',
        whereArgs: [shiftId],
      );

      if (count == 0) {
        throw NotFoundException('Shift dengan ID $shiftId tidak ditemukan');
      }

      AppLogger.database('Shift totals updated', details: 'ID: $shiftId');
      return currentShift.copyWith(
        cashSales: newCashSales,
        cardSales: newCardSales,
        qrSales: newQrSales,
        transferSales: newTransferSales,
        totalTransactions: newTotalTransactions,
      );
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update shift totals',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengupdate total shift',
        operation: 'updateShiftTotals',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a shift
  Future<bool> deleteShift(int id) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Deleting shift', details: 'ID: $id');

      final count = await db.delete(
        'shifts',
        where: 'id = ?',
        whereArgs: [id],
      );

      AppLogger.database('Shift deleted', details: 'ID: $id, affected: $count');
      return count > 0;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete shift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menghapus shift',
        operation: 'deleteShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
