import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for Category table operations.
///
/// This class provides a clean abstraction layer for all Category-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for Category entities.
///
/// Usage:
/// ```dart
/// final dao = CategoryDao.instance;
/// final categories = await dao.getAll();
/// final category = await dao.insert({'name': 'Electronics'});
/// ```
class CategoryDao {
  // Private constructor to prevent instantiation
  CategoryDao._();

  // Singleton instance
  static final CategoryDao instance = CategoryDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== CRUD Operations ====================

  /// Inserts a new category into the database.
  ///
  /// [category] - A map containing category fields (name, description, discount_percentage, created_at)
  /// Returns the created category map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> insert(Map<String, dynamic> category) async {
    try {
      AppLogger.database('Inserting category', details: category['name']);

      final db = await _db;
      final id = await db.insert('categories', category);

      AppLogger.database('Category inserted', details: 'ID: $id');

      // Return the category with its ID
      return {...category, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert category',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan kategori',
        operation: 'insert category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all categories from database.
  ///
  /// Returns a list of category maps, ordered by name (A-Z)
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all categories from database');

      final db = await _db;
      final categories =
          await db.query('categories', orderBy: 'name ASC');

      AppLogger.database('Categories fetched successfully',
          details: 'Count: ${categories.length}');

      return categories;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all categories',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua kategori',
        operation: 'get all categories',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single category by its ID.
  ///
  /// [id] - The category ID to retrieve
  /// Returns category map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching category by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Category fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('Category not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch category by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil kategori',
        operation: 'get category by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing category in database.
  ///
  /// [id] - The category ID to update
  /// [values] - A map containing category fields to update
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if category not found
  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      AppLogger.database('Updating category in database',
          details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'categories',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Kategori tidak ditemukan',
          resourceType: 'Kategori',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Category updated successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update category',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate kategori',
        operation: 'update category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a category by ID.
  ///
  /// [id] - The category ID to delete
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if category not found
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Deleting category', details: 'ID: $id');

      final db = await _db;
      final count = await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Kategori tidak ditemukan',
          resourceType: 'Kategori',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Category deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete category',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus kategori',
        operation: 'delete category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Query Operations ====================

  /// Searches categories by name (case-insensitive partial match).
  ///
  /// [query] - The search query string
  /// Returns a list of matching category maps
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      AppLogger.database('Searching categories', details: 'Query: $query');

      final db = await _db;
      final categories = await db.query(
        'categories',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'name ASC',
      );

      AppLogger.database('Category search completed',
          details: 'Query: $query, Count: ${categories.length}');

      return categories;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to search categories',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mencari kategori',
        operation: 'search categories',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts total number of categories in database.
  ///
  /// Returns total count of categories
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total categories');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM categories');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total categories counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count categories',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah kategori',
        operation: 'count categories',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if a category name already exists (for validation).
  ///
  /// [name] - The category name to check
  /// [excludeId] - Optional ID to exclude from check (for updates)
  /// Returns true if name exists, false otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<bool> nameExists(String name, {int? excludeId}) async {
    try {
      AppLogger.database('Checking if category name exists', details: name);

      final db = await _db;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM categories WHERE name = ? AND id != ?',
        [name, excludeId ?? 0],
      );
      final count = Sqflite.firstIntValue(results) ?? 0;

      AppLogger.database('Category name check completed',
          details: 'Name: $name, Exists: ${count > 0}');

      return count > 0;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check category name',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal memeriksa nama kategori',
        operation: 'check category name',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
