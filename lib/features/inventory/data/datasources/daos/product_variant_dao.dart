import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

class ProductVariantDao {
  final DatabaseHelper _dbHelper;
  ProductVariantDao(this._dbHelper);

  Future<Database> get _db async => await _dbHelper.database;

  Future<int> insert(Map<String, dynamic> variant) async {
    final db = await _db;
    return await db.insert('product_variants', variant);
  }

  Future<List<Map<String, dynamic>>> getByProductId(int productId) async {
    final db = await _db;
    return await db.query(
      'product_variants',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'id ASC',
    );
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _db;
    final res = await db.query(
      'product_variants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> update(Map<String, dynamic> variant) async {
    final db = await _db;
    return await db.update(
      'product_variants',
      variant,
      where: 'id = ?',
      whereArgs: [variant['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'product_variants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Inside ProductVariantDao
  Future<Map<String, dynamic>?> getByBarcode(String barcode) async =>
      (await (await _db).query(
        'product_variants',
        where: 'barcode = ?',
        whereArgs: [barcode],
        limit: 1,
      )).firstOrNull;

  Future<Map<String, dynamic>?> getBySku(String sku) async =>
      (await (await _db).query(
        'product_variants',
        where: 'sku = ?',
        whereArgs: [sku],
        limit: 1,
      )).firstOrNull;

  Future<int> updateStock(int id, int stock) async => await (await _db).update(
    'product_variants',
    {'stock': stock},
    where: 'id = ?',
    whereArgs: [id],
  );

  Future<int> deleteByProductId(int productId) async =>
      await (await _db).delete(
        'product_variants',
        where: 'product_id = ?',
        whereArgs: [productId],
      );

  Future<List<Map<String, dynamic>>> insertMany(
    List<Map<String, dynamic>> variants,
  ) async {
    final db = await _db;
    return await db.transaction((txn) async {
      List<Map<String, dynamic>> results = [];
      for (var v in variants) {
        final id = await txn.insert('product_variants', v);
        results.add({...v, 'id': id});
      }
      return results;
    });
  }
}
