import '../entities/cart_item.dart';

/// Repository interface for cart persistence operations
abstract class CartRepository {
  /// Save cart to database with customer name
  /// Returns the ID of the created held cart
  Future<int> saveCart({
    required String customerName,
    required List<CartItem> items,
  });

  /// Get all held carts ordered by creation date (newest first)
  Future<List<Map<String, dynamic>>> getHeldCarts();

  /// Get a specific held cart by ID
  /// Returns null if not found
  Future<Map<String, dynamic>?> getHeldCart(int id);

  /// Delete a held cart by ID
  /// Throws NotFoundException if cart not found
  Future<void> deleteHeldCart(int id);
}
