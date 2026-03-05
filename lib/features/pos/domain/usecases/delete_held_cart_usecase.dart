import '../repositories/cart_repository.dart';
import '../../../../core/utils/logger.dart';

/// Use case for deleting a held cart
class DeleteHeldCartUseCase {
  final CartRepository _cartRepository;

  DeleteHeldCartUseCase({required CartRepository cartRepository})
      : _cartRepository = cartRepository;

  /// Execute the use case to delete a held cart
  Future<void> execute(int cartId) async {
    try {
      AppLogger.useCase('DeleteHeldCart', details: 'ID: $cartId');

      await _cartRepository.deleteHeldCart(cartId);

      AppLogger.info('Deleted held cart: $cartId');
    } catch (e) {
      AppLogger.error('Failed to delete held cart', error: e);
      rethrow;
    }
  }
}
