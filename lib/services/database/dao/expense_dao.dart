import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for Expense table operations.
///
/// This class provides a clean abstraction layer for all Expense-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for Expense entities.
///
/// Usage:
/// ```dart
/// final dao = ExpenseDao.instance;
/// final expenses = await dao.getAll();
/// final expense = await dao.insert({'category': 'Supplies', 'amount': 500.0, 'date': timestamp});
/// ```
class ExpenseDao {
  // Private constructor to prevent instantiation
  ExpenseDao._();

  // Singleton instance
  static final ExpenseDao instance = ExpenseDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== CRUD Operations ====================

  /// Inserts a new expense into the database.
  ///
  /// [expense] - A map containing expense fields (category, amount, date, created_by, description, payment_method, receipt_image)
  /// Returns the created expense map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> insert(Map<String, dynamic> expense) async {
    try {
      AppLogger.database('Inserting expense', details: expense['category']);

      final db = await _db;
      final id = await db.insert('expenses', expense);

      AppLogger.database('Expense inserted', details: 'ID: $id');

      // Return the expense with its ID
      return {...expense, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert expense',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan pengeluaran',
        operation: 'insert expense',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all expenses from database.
  ///
  /// Returns a list of expense maps, ordered by date (newest first)
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all expenses from database');

      final db = await _db;
      final expenses =
          await db.query('expenses', orderBy: 'date DESC');

      AppLogger.database('Expenses fetched successfully',
          details: 'Count: ${expenses.length}');

      return expenses;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all expenses',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua pengeluaran',
        operation: 'get all expenses',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single expense by its ID.
  ///
  /// [id] - The expense ID to retrieve
  /// Returns expense map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching expense by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Expense fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('Expense not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch expense by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pengeluaran',
        operation: 'get expense by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing expense in database.
  ///
  /// [id] - The expense ID to update
  /// [values] - A map containing expense fields to update
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if expense not found
  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      AppLogger.database('Updating expense in database',
          details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'expenses',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Pengeluaran tidak ditemukan',
          resourceType: 'Pengeluaran',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Expense updated successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update expense',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate pengeluaran',
        operation: 'update expense',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes an expense by ID.
  ///
  /// [id] - The expense ID to delete
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if expense not found
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Deleting expense', details: 'ID: $id');

      final db = await _db;
      final count = await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Pengeluaran tidak ditemukan',
          resourceType: 'Pengeluaran',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Expense deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete expense',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus pengeluaran',
        operation: 'delete expense',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Query Operations ====================

  /// Retrieves expenses within a specific date range.
  ///
  /// [startDate] - Start date timestamp
  /// [endDate] - End date timestamp
  /// Returns a list of expense maps within the date range
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByDateRange(int startDate, int endDate) async {
    try {
      AppLogger.database('Fetching expenses by date range',
          details: '$startDate to $endDate');

      final db = await _db;
      final expenses = await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date DESC',
      );

      AppLogger.database('Expenses by date range fetched successfully',
          details: 'Count: ${expenses.length}');

      return expenses;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch expenses by date range',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pengeluaran berdasarkan rentang tanggal',
        operation: 'get expenses by date range',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves expenses by category.
  ///
  /// [category] - The category to filter by
  /// Returns a list of expense maps for the specified category
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByCategory(String category) async {
    try {
      AppLogger.database('Fetching expenses by category', details: category);

      final db = await _db;
      final expenses = await db.query(
        'expenses',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'date DESC',
      );

      AppLogger.database('Expenses by category fetched successfully',
          details: 'Category: $category, Count: ${expenses.length}');

      return expenses;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch expenses by category',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pengeluaran berdasarkan kategori',
        operation: 'get expenses by category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total expenses within a date range.
  ///
  /// [startDate] - Start date timestamp
  /// [endDate] - End date timestamp
  /// Returns total expense amount
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<double> getTotalInRange(int startDate, int endDate) async {
    try {
      AppLogger.database('Calculating total expenses in range',
          details: '$startDate to $endDate');

      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?',
        [startDate, endDate],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;

      AppLogger.database('Total expenses calculated',
          details: 'Range: $startDate to $endDate, Total: $total');

      return total;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total expenses',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung total pengeluaran',
        operation: 'calculate total expenses',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total expenses by category within a date range.
  ///
  /// [startDate] - Start date timestamp
  /// [endDate] - End date timestamp
  /// Returns a list of maps with category and total amount
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getTotalByCategory(int startDate, int endDate) async {
    try {
      AppLogger.database('Calculating expenses by category',
          details: '$startDate to $endDate');

      final db = await _db;
      final results = await db.rawQuery(
        'SELECT category, SUM(amount) as total, COUNT(*) as count FROM expenses WHERE date BETWEEN ? AND ? GROUP BY category ORDER BY total DESC',
        [startDate, endDate],
      );

      AppLogger.database('Expenses by category calculated',
          details: 'Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate expenses by category',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung pengeluaran berdasarkan kategori',
        operation: 'calculate expenses by category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts total number of expenses in database.
  ///
  /// Returns total count of expenses
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total expenses');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM expenses');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total expenses counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count expenses',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah pengeluaran',
        operation: 'count expenses',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
