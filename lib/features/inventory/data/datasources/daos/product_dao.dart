import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

class ProductDao {
  final DatabaseHelper _dbHelper;
  ProductDao(this._dbHelper);

  Future<Database> get _db async => await _dbHelper.database;

  // --- Methods moved from DatabaseHelper ---

  Future<Map<String, dynamic>> insert(Map<String, dynamic> product) async {
    try {
      final db = await _db;
      final id = await db.insert('products', product);
      return {...product, 'id': id};
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'tambah produk');
    }
  }

  /// Checks if a product exists by ID
  /// Checks if a product exists by ID
  Future<bool> exists(int id) async {
    try {
      final db = await _db;
      AppLogger.database(
        'Checking product existence in DAO',
        details: 'ID: $id',
      );

      final result = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e, stackTrace) {
      // FIXED: Removed the 4th argument to match your _handleError definition
      throw _handleError(e, stackTrace, 'mengecek keberadaan produk');
    }
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _db;
    return await db.query('products', orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _db;
    final results = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(Map<String, dynamic> product) async {
    final db = await _db;
    return await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await _db;
    return await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'id DESC',
    );
  }

  app_exceptions.DatabaseException _handleError(
    dynamic e,
    StackTrace s,
    String op,
  ) {
    return app_exceptions.DatabaseException(
      'Gagal $op',
      operation: op,
      originalError: e,
      stackTrace: s,
    );
  }
}
