import '../../../../services/database/database_helper.dart';
import '../../domain/entities/cash_count.dart';

/// Local data source for cash count operations using SQLite
class CashCountLocalDataSourceImpl {
  final DatabaseHelper _databaseHelper;

  CashCountLocalDataSourceImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  /// Save cash count (replaces existing for same shift)
  Future<CashCount> saveCashCount(CashCount cashCount) async {
    final db = await _databaseHelper.database;

    // First, delete existing cash counts for this shift
    await db.delete(
      'cash_counts',
      where: 'shift_id = ?',
      whereArgs: [cashCount.shiftId],
    );

    // Insert new cash count records (one per denomination)
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final entry in cashCount.billCounts.entries) {
      if (entry.value > 0) {
        await db.insert('cash_counts', {
          'shift_id': cashCount.shiftId,
          'denomination': entry.key,
          'count': entry.value,
          'counted_at': now,
          'counted_by': cashCount.countedBy,
        });
      }
    }

    // Return the saved entity
    return cashCount;
  }

  /// Get cash count by shift ID (aggregates denominations)
  Future<CashCount?> getCashCountByShift(int shiftId) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'cash_counts',
      where: 'shift_id = ?',
      whereArgs: [shiftId],
    );

    if (results.isEmpty) return null;

    // Aggregate denominations
    final Map<int, int> billCounts = {};
    int totalCounted = 0;

    for (final row in results) {
      final denomination = row['denomination'] as int;
      final count = row['count'] as int;
      billCounts[denomination] = count;
      totalCounted += denomination * count;
    }

    // Get expected amount from shift
    final shiftResult = await db.query(
      'shifts',
      where: 'id = ?',
      whereArgs: [shiftId],
      limit: 1,
    );

    if (shiftResult.isEmpty) {
      throw Exception('Shift not found: $shiftId');
    }

    final shift = shiftResult.first;
    final openingBalance = shift['opening_balance'] as double;
    final cashSales = shift['cash_sales'] as double;
    final expectedAmount = (openingBalance + cashSales).toInt();

    return CashCount(
      shiftId: shiftId,
      billCounts: billCounts,
      totalCounted: totalCounted,
      expectedAmount: expectedAmount,
      discrepancy: totalCounted - expectedAmount,
      countedAt: DateTime.fromMillisecondsSinceEpoch(
        results.first['counted_at'] as int,
      ),
      countedBy: results.first['counted_by'] as String,
    );
  }

  /// Get all cash counts for a shift (history)
  Future<List<Map<String, dynamic>>> getCashCountHistory(int shiftId) async {
    final db = await _databaseHelper.database;

    return await db.query(
      'cash_counts',
      where: 'shift_id = ?',
      whereArgs: [shiftId],
      orderBy: 'counted_at DESC',
    );
  }

  /// Delete a cash count
  Future<bool> deleteCashCount(int id) async {
    final db = await _databaseHelper.database;

    final rowsAffected = await db.delete(
      'cash_counts',
      where: 'id = ?',
      whereArgs: [id],
    );

    return rowsAffected > 0;
  }
}
