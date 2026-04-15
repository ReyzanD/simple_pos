import 'package:simple_pos/core/database/database_helper.dart';
import '../models/expense_model.dart';

/// Local data source implementation for Expense using SQLite
class ExpenseLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  ExpenseLocalDataSourceImpl({required this.databaseHelper});

  /// Get all expenses with optional filters
  Future<List<ExpenseModel>> getExpenses({
    int? startDate,
    int? endDate,
    String? category,
  }) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (startDate != null) {
      conditions.add('date >= ?');
      whereArgs.add(startDate);
    }
    if (endDate != null) {
      conditions.add('date <= ?');
      whereArgs.add(endDate);
    }
    if (category != null) {
      conditions.add('category = ?');
      whereArgs.add(category);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final maps = await db.query(
      'expenses',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );

    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  /// Get expense by ID
  Future<ExpenseModel?> getExpenseById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ExpenseModel.fromMap(maps.first);
  }

  /// Create new expense
  Future<int> addExpense(ExpenseModel expense) async {
    final db = await databaseHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  /// Update existing expense
  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await databaseHelper.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Delete expense
  Future<void> deleteExpense(int id) async {
    final db = await databaseHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  /// Get expense summary grouped by category
  Future<Map<String, double>> getExpenseSummary({
    int? startDate,
    int? endDate,
  }) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (startDate != null) {
      conditions.add('date >= ?');
      whereArgs.add(startDate);
    }
    if (endDate != null) {
      conditions.add('date <= ?');
      whereArgs.add(endDate);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final maps = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM expenses
      ${where != null ? 'WHERE $where' : ''}
      GROUP BY category
      ORDER BY total DESC
    ''', whereArgs.isNotEmpty ? whereArgs : null);

    final summary = <String, double>{};
    for (var map in maps) {
      summary[map['category'] as String] = (map['total'] as num).toDouble();
    }

    return summary;
  }

  /// Get total expenses
  Future<double> getTotalExpenses({int? startDate, int? endDate}) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (startDate != null) {
      conditions.add('date >= ?');
      whereArgs.add(startDate);
    }
    if (endDate != null) {
      conditions.add('date <= ?');
      whereArgs.add(endDate);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM expenses
      ${where != null ? 'WHERE $where' : ''}
    ''', whereArgs.isNotEmpty ? whereArgs : null);

    if (result.isEmpty || result.first['total'] == null) {
      return 0.0;
    }

    return (result.first['total'] as num).toDouble();
  }

  /// Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    return await getExpenses(category: category);
  }

  /// Get today's expenses
  Future<List<ExpenseModel>> getTodayExpenses() async {
    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch ~/
        1000;
    final endOfDay =
        DateTime(
          today.year,
          today.month,
          today.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch ~/
        1000;

    return await getExpenses(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get this month's expenses
  Future<List<ExpenseModel>> getThisMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth =
        DateTime(now.year, now.month, 1).millisecondsSinceEpoch ~/ 1000;
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).millisecondsSinceEpoch ~/ 1000 - 1;

    return await getExpenses(startDate: startOfMonth, endDate: endOfMonth);
  }
}
