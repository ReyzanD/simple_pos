import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for Supplier table operations.
///
/// This class provides a clean abstraction layer for all Supplier-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for Supplier entities.
///
/// Usage:
/// ```dart
/// final dao = SupplierDao.instance;
/// final suppliers = await dao.getAll();
/// final supplier = await dao.insert({'name': 'Acme Corp'});
/// ```
class SupplierDao {
  // Private constructor to prevent instantiation
  SupplierDao._();

  // Singleton instance
  static final SupplierDao instance = SupplierDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== CRUD Operations ====================

  /// Inserts a new supplier into the database.
  ///
  /// [supplier] - A map containing supplier fields (name, contact_person, phone, email, address, created_at)
  /// Returns the created supplier map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> insert(Map<String, dynamic> supplier) async {
    try {
      AppLogger.database('Inserting supplier', details: supplier['name']);

      final db = await _db;
      final id = await db.insert('suppliers', supplier);

      AppLogger.database('Supplier inserted', details: 'ID: $id');

      // Return the supplier with its ID
      return {...supplier, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert supplier',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan pemasok',
        operation: 'insert supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all suppliers from database.
  ///
  /// Returns a list of supplier maps, ordered by name (A-Z)
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all suppliers from database');

      final db = await _db;
      final suppliers =
          await db.query('suppliers', orderBy: 'name ASC');

      AppLogger.database('Suppliers fetched successfully',
          details: 'Count: ${suppliers.length}');

      return suppliers;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all suppliers',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua pemasok',
        operation: 'get all suppliers',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single supplier by its ID.
  ///
  /// [id] - The supplier ID to retrieve
  /// Returns supplier map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching supplier by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Supplier fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('Supplier not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch supplier by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pemasok',
        operation: 'get supplier by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing supplier in database.
  ///
  /// [id] - The supplier ID to update
  /// [values] - A map containing supplier fields to update
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if supplier not found
  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      AppLogger.database('Updating supplier in database',
          details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'suppliers',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Pemasok tidak ditemukan',
          resourceType: 'Pemasok',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Supplier updated successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update supplier',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate pemasok',
        operation: 'update supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a supplier by ID.
  ///
  /// [id] - The supplier ID to delete
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if supplier not found
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Deleting supplier', details: 'ID: $id');

      final db = await _db;
      final count = await db.delete(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Pemasok tidak ditemukan',
          resourceType: 'Pemasok',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Supplier deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete supplier',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus pemasok',
        operation: 'delete supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Query Operations ====================

  /// Searches suppliers by name or contact person (case-insensitive partial match).
  ///
  /// [query] - The search query string
  /// Returns a list of matching supplier maps
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      AppLogger.database('Searching suppliers', details: 'Query: $query');

      final db = await _db;
      final suppliers = await db.query(
        'suppliers',
        where: 'name LIKE ? OR contact_person LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      AppLogger.database('Supplier search completed',
          details: 'Query: $query, Count: ${suppliers.length}');

      return suppliers;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to search suppliers',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mencari pemasok',
        operation: 'search suppliers',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts total number of suppliers in database.
  ///
  /// Returns total count of suppliers
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total suppliers');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM suppliers');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total suppliers counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count suppliers',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah pemasok',
        operation: 'count suppliers',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if a supplier name already exists (for validation).
  ///
  /// [name] - The supplier name to check
  /// [excludeId] - Optional ID to exclude from check (for updates)
  /// Returns true if name exists, false otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<bool> nameExists(String name, {int? excludeId}) async {
    try {
      AppLogger.database('Checking if supplier name exists', details: name);

      final db = await _db;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM suppliers WHERE name = ? AND id != ?',
        [name, excludeId ?? 0],
      );
      final count = Sqflite.firstIntValue(results) ?? 0;

      AppLogger.database('Supplier name check completed',
          details: 'Name: $name, Exists: ${count > 0}');

      return count > 0;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check supplier name',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal memeriksa nama pemasok',
        operation: 'check supplier name',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
