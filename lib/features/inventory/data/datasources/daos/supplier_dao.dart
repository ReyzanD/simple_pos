import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

class SupplierDao {
  final DatabaseHelper _dbHelper;
  SupplierDao(this._dbHelper);

  Future<Database> get _db async => await _dbHelper.database;

  Future<Map<String, dynamic>> insert(Map<String, dynamic> supplier) async {
    try {
      final db = await _db;
      AppLogger.database('Inserting supplier', details: supplier['name']);

      final id = await db.insert('suppliers', supplier);
      final result = await getById(id);

      AppLogger.database('Supplier inserted', details: 'ID: $id');
      return result!;
    } catch (e, stackTrace) {
      throw _handleError(
        e,
        stackTrace,
        'menambahkan pemasok',
        'insert supplier',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await _db;
      AppLogger.database('Fetching all suppliers');

      final result = await db.query('suppliers', orderBy: 'name ASC');

      AppLogger.database(
        'Suppliers fetched',
        details: '${result.length} suppliers',
      );
      return result;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'mengambil pemasok', 'get suppliers');
    }
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      final db = await _db;
      final result = await db.query(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'mengambil pemasok', 'get supplier');
    }
  }

  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      final db = await _db;
      final rowsAffected = await db.update(
        'suppliers',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw app_exceptions.NotFoundException(
          'Pemasok tidak ditemukan',
          resourceType: 'Pemasok',
          resourceId: id.toString(),
        );
      }
      return rowsAffected;
    } catch (e, stackTrace) {
      if (e is app_exceptions.NotFoundException) rethrow;
      throw _handleError(
        e,
        stackTrace,
        'mengupdate pemasok',
        'update supplier',
      );
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await _db;
      final rowsAffected = await db.delete(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw app_exceptions.NotFoundException(
          'Pemasok tidak ditemukan',
          resourceType: 'Pemasok',
          resourceId: id.toString(),
        );
      }
      return rowsAffected;
    } catch (e, stackTrace) {
      if (e is app_exceptions.NotFoundException) rethrow;
      throw _handleError(e, stackTrace, 'menghapus pemasok', 'delete supplier');
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
      tag: 'SupplierDao',
    );
    return app_exceptions.DatabaseException(
      'Gagal $msg',
      operation: op,
      originalError: e,
      stackTrace: s,
    );
  }
}
