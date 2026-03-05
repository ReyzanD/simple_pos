import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Use case for saving the current cart to database
class SaveCartUseCase {
  final CartRepository _cartRepository;

  SaveCartUseCase({required CartRepository cartRepository})
      : _cartRepository = cartRepository;

  /// Execute the use case to save cart
  /// Returns the ID of the created held cart
  Future<int> execute({
    required String customerName,
    required List<CartItem> items,
  }) async {
    try {
      AppLogger.useCase('SaveCart', details: 'Customer: $customerName, Items: ${items.length}');

      if (items.isEmpty) {
        throw ValidationException('Keranjang belanja tidak boleh kosong', field: 'Cart');
      }

      if (customerName.trim().isEmpty) {
        throw ValidationException('Nama pelanggan wajib diisi', field: 'Customer Name');
      }

      final id = await _cartRepository.saveCart(
        customerName: customerName.trim(),
        items: items,
      );

      AppLogger.info('Cart saved successfully with ID: $id');
      return id;
    } catch (e) {
      AppLogger.error('Failed to save cart', error: e);
      rethrow;
    }
  }
}
