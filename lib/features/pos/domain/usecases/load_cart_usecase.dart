import '../../../../core/data/models/cart_model.dart';
import '../repositories/cart_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Use case for loading a specific held cart
class LoadCartUseCase {
  final CartRepository _cartRepository;

  LoadCartUseCase({required CartRepository cartRepository})
      : _cartRepository = cartRepository;

  /// Execute the use case to load a held cart
  /// Returns the CartModel if found
  /// Throws NotFoundException if cart not found
  Future<CartModel> execute(int cartId) async {
    try {
      AppLogger.useCase('LoadCart', details: 'ID: $cartId');

      final result = await _cartRepository.getHeldCart(cartId);

      if (result == null) {
        throw NotFoundException(
          'Pesanan tertahan tidak ditemukan',
          resourceType: 'Pesanan Tertahan',
          resourceId: cartId.toString(),
        );
      }

      final cartModel = CartModel.fromJsonString(result['cart_data'] as String);

      AppLogger.info('Loaded cart with ${cartModel.items.length} items');
      return cartModel;
    } catch (e) {
      AppLogger.error('Failed to load cart', error: e);
      rethrow;
    }
  }
}
