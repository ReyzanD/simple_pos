import '../entities/cart_item.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../../core/utils/logger.dart';

/// Use case for removing a product from the shopping cart
class RemoveFromCartUseCase {
  RemoveFromCartUseCase();

  /// Executes the use case
  /// Returns the updated cart with the item removed
  List<CartItem> execute({
    required List<CartItem> currentCart,
    required Product product,
  }) {
    try {
      AppLogger.useCase('RemoveFromCart', details: product.name);

      final updatedCart = currentCart
          .where((item) => item.product.id != product.id)
          .toList();

      AppLogger.info('Item removed from cart');

      return updatedCart;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in RemoveFromCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
