import '../../../../core/data/models/cart_model.dart';
import '../repositories/cart_repository.dart';
import '../../../../core/utils/logger.dart';

/// Result class containing held cart information
class HeldCart {
  final int id;
  final String customerName;
  final CartModel cartData;

  const HeldCart({
    required this.id,
    required this.customerName,
    required this.cartData,
  });

  /// Get display name
  String get displayName => customerName.isEmpty ? 'Pelanggan #$id' : customerName;

  /// Get item count
  int get itemCount => cartData.items.length;

  /// Get total amount
  double get totalAmount => cartData.totalAmount;

  /// Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(cartData.createdAt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else {
      return '${diff.inDays} hari yang lalu';
    }
  }
}

/// Use case for fetching all held carts
class GetHeldCartsUseCase {
  final CartRepository _cartRepository;

  GetHeldCartsUseCase({required CartRepository cartRepository})
      : _cartRepository = cartRepository;

  /// Execute the use case to get all held carts
  Future<List<HeldCart>> execute() async {
    try {
      AppLogger.useCase('GetHeldCarts');

      final results = await _cartRepository.getHeldCarts();

      final heldCarts = results.map((data) {
        final cartModel = CartModel.fromJsonString(data['cart_data'] as String);
        return HeldCart(
          id: data['id'] as int,
          customerName: data['customer_name'] as String,
          cartData: cartModel,
        );
      }).toList();

      AppLogger.info('Retrieved ${heldCarts.length} held carts');
      return heldCarts;
    } catch (e) {
      AppLogger.error('Failed to get held carts', error: e);
      rethrow;
    }
  }
}
