import 'package:simple_pos/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

class CategoryDao {
  final DatabaseHelper _dbHelper;
  CategoryDao(this._dbHelper);

  Future<Database> get _db async => await _dbHelper.database;

  Future<Map<String, dynamic>> insert(Map<String, dynamic> category) async {
    try {
      final db = await _db;
      AppLogger.database('Inserting category', details: category['name']);

      final id = await db.insert('categories', category);
      final result = await getById(id);

      AppLogger.database('Category inserted', details: 'ID: $id');
      return result!;
    } catch (e, stackTrace) {
      throw _handleError(
        e,
        stackTrace,
        'menambahkan kategori',
        'insert category',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await _db;
      AppLogger.database('Fetching all categories');

      final result = await db.query('categories', orderBy: 'name ASC');

      AppLogger.database(
        'Categories fetched',
        details: '${result.length} categories',
      );
      return result;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'mengambil kategori', 'get categories');
    }
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      final db = await _db;
      final result = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'mengambil kategori', 'get category');
    }
  }

  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      final db = await _db;
      final rowsAffected = await db.update(
        'categories',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw app_exceptions.NotFoundException(
          'Kategori tidak ditemukan',
          resourceType: 'Kategori',
          resourceId: id.toString(),
        );
      }
      return rowsAffected;
    } catch (e, stackTrace) {
      if (e is app_exceptions.NotFoundException) rethrow;
      throw _handleError(
        e,
        stackTrace,
        'mengupdate kategori',
        'update category',
      );
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await _db;
      final rowsAffected = await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw app_exceptions.NotFoundException(
          'Kategori tidak ditemukan',
          resourceType: 'Kategori',
          resourceId: id.toString(),
        );
      }
      return rowsAffected;
    } catch (e, stackTrace) {
      if (e is app_exceptions.NotFoundException) rethrow;
      throw _handleError(
        e,
        stackTrace,
        'menghapus kategori',
        'delete category',
      );
    }
  }

  app_exceptions.DatabaseException _handleError(
    dynamic e,
    StackTrace s,
    String msg,
    String op,
  ) {
    AppLogger.error(
      'Failed to $op',
      error: e,
      stackTrace: s,
      tag: 'CategoryDao',
    );
    return app_exceptions.DatabaseException(
      'Gagal $msg',
      operation: op,
      originalError: e,
      stackTrace: s,
    );
  }
}
