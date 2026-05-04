import '../entities/cart_item.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../sales/domain/entities/payment_method.dart';
import '../../../sales/domain/usecases/create_transaction_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../entities/checkout_result.dart';

/// Use case for processing checkout (completing a sale)
class CheckoutUseCase {
  final ProductRepository productRepository;
  final CreateTransactionUseCase createTransactionUseCase;

  CheckoutUseCase({
    required this.productRepository,
    required this.createTransactionUseCase,
  });

  /// Executes the use case
  /// Records transaction and updates stock levels for all products in the cart
  /// Returns the created transaction
  Future<CheckoutResult> execute({
    required List<CartItem> cart,
    required PaymentMethod paymentMethod,
    double? cashReceived,
    String? cardLast4Digits,
    String? notes,
    double tax = 0,
    double discount = 0,
    int? cashierId,
    String? cashierName,
  }) async {
    try {
      AppLogger.useCase('Checkout', details: '${cart.length} items');

      if (cart.isEmpty) {
        return CheckoutResult.failure(errorMessage: 'Keranjang kosong');
      }

      // Calculate total amount
      final subtotal = cart.fold<double>(
        0,
        (sum, item) =>
            sum +
            item.product.calculateCompoundTotalPrice(
              categoryDiscount: item.product.calculateCategoryDiscountAmount(
                cart,
              ),
              promotionDiscount: item.product.calculatePromotionDiscountAmount(
                cart,
              ),
            ),
      );
      final totalAmount = subtotal + tax - discount;

      // Create transaction with stock update
      final transaction = await createTransactionUseCase.execute(
        cart: cart,
        paymentMethod: paymentMethod,
        cashReceived: cashReceived,
        cardLast4Digits: cardLast4Digits,
        notes: notes,
        tax: tax,
        discount: discount,
        cashierId: cashierId,
        cashierName: cashierName,
      );

      AppLogger.info('Checkout completed successfully');

      return CheckoutResult.success(
        transaction: transaction,
        totalAmount: totalAmount,
        itemsProcessed: cart.length,
      );
    } on EmptyCartException {
      return CheckoutResult.failure(errorMessage: 'Keranjang kosong');
    } on InsufficientStockException catch (e) {
      return CheckoutResult.failure(errorMessage: e.message);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CheckoutUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal memproses checkout',
        operation: 'Checkout',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Executes the use case with default cash payment
  Future<CheckoutResult> executeWithCashPayment({
    required List<CartItem> cart,
    double tax = 0,
    double discount = 0,
    int? cashierId,
    String? cashierName,
  }) async {
    // Calculate total
    final total =
        cart.fold<double>(0, (sum, item) => sum + item.totalPrice) +
        tax -
        discount;

    // Use main execute method with cash payment
    return execute(
      cart: cart,
      paymentMethod: PaymentMethod.cash,
      cashReceived: total,
      tax: tax,
      discount: discount,
      cashierId: cashierId,
      cashierName: cashierName,
    );
  }

  /// Executes the use case with card payment
  Future<CheckoutResult> executeWithCardPayment({
    required List<CartItem> cart,
    String? cardLast4Digits,
    String? notes,
    double tax = 0,
    double discount = 0,
    int? cashierId,
    String? cashierName,
  }) async {
    // Calculate total
    cart.fold<double>(0, (sum, item) => sum + item.totalPrice);

    // Use main execute method with card payment
    return execute(
      cart: cart,
      paymentMethod: PaymentMethod.card,
      cardLast4Digits: cardLast4Digits,
      notes: notes,
      tax: tax,
      discount: discount,
      cashierId: cashierId,
      cashierName: cashierName,
    );
  }
}
