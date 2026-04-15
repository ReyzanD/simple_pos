import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/database/database_helper.dart';

class VariantAttributeDao {
  final DatabaseHelper _dbHelper;
  VariantAttributeDao(this._dbHelper);

  Future<Database> get _db async => await _dbHelper.database;

  Future<int> insert(Map<String, dynamic> attribute) async {
    final db = await _db;
    return await db.insert('variant_attributes', attribute);
  }

  Future<List<Map<String, dynamic>>> getByProductId(int productId) async {
    final db = await _db;
    return await db.query(
      'variant_attributes',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'sort_order ASC',
    );
  }

  Future<int> deleteByProductId(int productId) async {
    final db = await _db;
    return await db.delete(
      'variant_attributes',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
}
