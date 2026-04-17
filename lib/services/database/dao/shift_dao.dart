import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for Shift table operations.
///
/// This class provides a clean abstraction layer for all Shift-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for Shift entities.
///
/// Usage:
/// ```dart
/// final dao = ShiftDao.instance;
/// final shifts = await dao.getAll();
/// final shift = await dao.insert({'user_name': 'John', 'opening_balance': 1000.0});
/// ```
class ShiftDao {
  // Private constructor to prevent instantiation
  ShiftDao._();

  // Singleton instance
  static final ShiftDao instance = ShiftDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== CRUD Operations ====================

  /// Inserts a new shift into the database.
  ///
  /// [shift] - A map containing shift fields (user_name, opening_balance, opened_at, closed_at)
  /// Returns the created shift map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> insert(Map<String, dynamic> shift) async {
    try {
      AppLogger.database('Inserting shift', details: shift['user_name']);

      final db = await _db;
      final id = await db.insert('shifts', shift);

      AppLogger.database('Shift inserted', details: 'ID: $id');

      // Return the shift with its ID
      return {...shift, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert shift',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan shift',
        operation: 'insert shift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all shifts from database.
  ///
  /// Returns a list of shift maps, ordered by opened_at (newest first)
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all shifts from database');

      final db = await _db;
      final shifts =
          await db.query('shifts', orderBy: 'opened_at DESC');

      AppLogger.database('Shifts fetched successfully',
          details: 'Count: ${shifts.length}');

      return shifts;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all shifts',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua shift',
        operation: 'get all shifts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single shift by its ID.
  ///
  /// [id] - The shift ID to retrieve
  /// Returns shift map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching shift by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'shifts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Shift fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('Shift not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch shift by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil shift',
        operation: 'get shift by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing shift in database.
  ///
  /// [id] - The shift ID to update
  /// [values] - A map containing shift fields to update
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if shift not found
  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      AppLogger.database('Updating shift in database',
          details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'shifts',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Shift tidak ditemukan',
          resourceType: 'Shift',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Shift updated successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update shift',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate shift',
        operation: 'update shift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a shift by ID.
  ///
  /// [id] - The shift ID to delete
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if shift not found
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Deleting shift', details: 'ID: $id');

      final db = await _db;
      final count = await db.delete(
        'shifts',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Shift tidak ditemukan',
          resourceType: 'Shift',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Shift deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete shift',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus shift',
        operation: 'delete shift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Query Operations ====================

  /// Retrieves shifts by user name.
  ///
  /// [userName] - The user name to filter by
  /// Returns a list of shift maps for the specified user
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByUserName(String userName) async {
    try {
      AppLogger.database('Fetching shifts by user', details: 'User: $userName');

      final db = await _db;
      final shifts = await db.query(
        'shifts',
        where: 'user_name = ?',
        whereArgs: [userName],
        orderBy: 'opened_at DESC',
      );

      AppLogger.database('Shifts by user fetched successfully',
          details: 'User: $userName, Count: ${shifts.length}');

      return shifts;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch shifts by user',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil shift berdasarkan user',
        operation: 'get shifts by user name',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves the currently open shift for a user.
  ///
  /// [userName] - The user name to check
  /// Returns shift map if open shift found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getOpenShift(String userName) async {
    try {
      AppLogger.database('Fetching open shift', details: 'User: $userName');

      final db = await _db;
      final results = await db.query(
        'shifts',
        where: 'user_name = ? AND closed_at IS NULL',
        whereArgs: [userName],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Open shift found', details: 'ID: ${results.first['id']}');
        return results.first;
      } else {
        AppLogger.database('No open shift found', details: 'User: $userName');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch open shift',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil shift yang terbuka',
        operation: 'get open shift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Closes an open shift.
  ///
  /// [id] - The shift ID to close
  /// [closedAt] - The timestamp when shift was closed
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> closeShift(int id, int closedAt) async {
    try {
      AppLogger.database('Closing shift', details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'shifts',
        {'closed_at': closedAt},
        where: 'id = ?',
        whereArgs: [id],
      );

      AppLogger.database('Shift closed successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to close shift',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menutup shift',
        operation: 'close shift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts total number of shifts in database.
  ///
  /// Returns total count of shifts
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total shifts');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM shifts');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total shifts counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count shifts',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah shift',
        operation: 'count shifts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
