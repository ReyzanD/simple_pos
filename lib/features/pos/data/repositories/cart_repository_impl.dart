import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/exceptions/app_exceptions.dart' as app_exceptions;
import '../../../../core/data/models/cart_model.dart';

/// Implementation of CartRepository for persisting held carts
class CartRepositoryImpl implements CartRepository {
  final DatabaseHelper _databaseHelper;

  CartRepositoryImpl({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper;

  @override
  Future<int> saveCart({
    required String customerName,
    required List<CartItem> items,
  }) async {
    try {
      AppLogger.database(
        'Saving held cart',
        details: 'Customer: $customerName, Items: ${items.length}',
      );

      final db = await _databaseHelper.database;

      final cartModel = CartModel.fromCartItems(
        customerName: customerName,
        items: items,
      );

      final cartJson = cartModel.toJsonString();
      final now = DateTime.now().toIso8601String();

      final data = {
        'customer_name': customerName,
        'cart_data': cartJson,
        'created_at': now,
        'updated_at': now,
      };

      final id = await db.insert('held_carts', data);

      AppLogger.database('Held cart saved', details: 'ID: $id');
      return id;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save held cart',
        error: e,
        stackTrace: stackTrace,
        tag: 'CartRepositoryImpl',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menyimpan pesanan',
        operation: 'save held cart',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHeldCarts() async {
    try {
      AppLogger.database('Fetching held carts');

      final db = await _databaseHelper.database;

      final results = await db.query('held_carts', orderBy: 'created_at DESC');

      AppLogger.database(
        'Held carts fetched',
        details: 'Count: ${results.length}',
      );
      return results;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch held carts',
        error: e,
        stackTrace: stackTrace,
        tag: 'CartRepositoryImpl',
      );
      throw app_exceptions.DatabaseException(
        'Gagal memuat pesanan tertahan',
        operation: 'get held carts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getHeldCart(int id) async {
    try {
      AppLogger.database('Fetching held cart', details: 'ID: $id');

      final db = await _databaseHelper.database;

      final results = await db.query(
        'held_carts',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        AppLogger.database('Held cart not found', details: 'ID: $id');
        return null;
      }

      AppLogger.database('Held cart fetched', details: 'ID: $id');
      return results.first;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch held cart',
        error: e,
        stackTrace: stackTrace,
        tag: 'CartRepositoryImpl',
      );
      throw app_exceptions.DatabaseException(
        'Gagal memuat pesanan tertahan',
        operation: 'get held cart',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteHeldCart(int id) async {
    try {
      AppLogger.database('Deleting held cart', details: 'ID: $id');

      final db = await _databaseHelper.database;

      final count = await db.delete(
        'held_carts',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'Pesanan tertahan tidak ditemukan',
          resourceType: 'Pesanan Tertahan',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Held cart deleted', details: 'ID: $id');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete held cart',
        error: e,
        stackTrace: stackTrace,
        tag: 'CartRepositoryImpl',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menghapus pesanan tertahan',
        operation: 'delete held cart',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
