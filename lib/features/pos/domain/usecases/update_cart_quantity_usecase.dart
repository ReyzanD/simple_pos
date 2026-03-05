import '../entities/cart_item.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';

/// Use case for updating the quantity of a product in the shopping cart
class UpdateCartQuantityUseCase {
  UpdateCartQuantityUseCase();

  /// Executes the use case
  /// Returns the updated cart with the item quantity updated
  List<CartItem> execute({
    required List<CartItem> currentCart,
    required Product product,
    required int newQuantity,
  }) {
    try {
      AppLogger.useCase('UpdateCartQuantity', details: '${product.name}: $newQuantity');

      if (newQuantity < 0) {
        throw const ValidationException(
          'Quantity tidak boleh negatif',
          field: 'Quantity',
        );
      }

      // Validate stock availability
      if (newQuantity > 0) {
        Validators.validateStockAvailability(newQuantity, product.stock);
      }

      final existingIndex = currentCart.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex == -1) {
        // Product not in cart, can't update
        throw const ValidationException(
          'Produk tidak ada di keranjang',
          field: 'Cart',
        );
      }

      final updatedCart = List<CartItem>.from(currentCart);

      if (newQuantity == 0) {
        // Remove item if quantity is 0
        updatedCart.removeAt(existingIndex);
        AppLogger.info('Item removed from cart (quantity set to 0)');
      } else {
        // Update quantity
        updatedCart[existingIndex] =
            currentCart[existingIndex].copyWith(quantity: newQuantity);
        AppLogger.info('Cart quantity updated');
      }

      return updatedCart;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in UpdateCartQuantityUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
