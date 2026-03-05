import '../entities/cart_item.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';

/// Use case for adding a product to the shopping cart
class AddToCartUseCase {
  final ProductRepository productRepository;

  AddToCartUseCase({required this.productRepository});

  /// Executes the use case
  /// Returns the updated cart with the new item added
  Future<List<CartItem>> execute({
    required List<CartItem> currentCart,
    required Product product,
  }) async {
    try {
      AppLogger.useCase('AddToCart', details: product.name);

      // Validate stock availability
      Validators.validateStockAvailability(1, product.stock);

      // Check if product already exists in cart
      final existingIndex = currentCart.indexWhere(
        (item) => item.product.id == product.id,
      );

      List<CartItem> updatedCart;

      if (existingIndex != -1) {
        // Product already in cart, increment quantity
        final existingItem = currentCart[existingIndex];
        final newQuantity = existingItem.quantity + 1;

        // Validate stock availability for new quantity
        Validators.validateStockAvailability(newQuantity, product.stock);

        updatedCart = List<CartItem>.from(currentCart);
        updatedCart[existingIndex] = existingItem.copyWith(quantity: newQuantity);

        AppLogger.info('Cart item quantity updated');
      } else {
        // Add new item to cart
        updatedCart = List<CartItem>.from(currentCart)
          ..add(CartItem(product: product));

        AppLogger.info('New item added to cart');
      }

      return updatedCart;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddToCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menambahkan ke keranjang',
        operation: 'AddToCart',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
