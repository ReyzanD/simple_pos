import '../entities/cart_item.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../sales/domain/entities/payment_method.dart';
import '../../../sales/domain/usecases/create_transaction_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

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
  }) async {
    try {
      AppLogger.useCase('Checkout', details: '${cart.length} items');

      if (cart.isEmpty) {
        return CheckoutResult.failure('Keranjang kosong');
      }

      // Calculate total amount
      final subtotal = cart.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
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
      );

      AppLogger.info('Checkout completed successfully');

      return CheckoutResult.success(
        transaction: transaction,
        totalAmount: totalAmount,
        itemsProcessed: cart.length,
      );
    } on EmptyCartException {
      return CheckoutResult.failure('Keranjang kosong');
    } on InsufficientStockException catch (e) {
      return CheckoutResult.failure(e.message);
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
  }) async {
    // Calculate total
    final total = cart.fold<double>(0, (sum, item) => sum + item.totalPrice) + tax - discount;

    return execute(
      cart: cart,
      paymentMethod: PaymentMethod.cash,
      cashReceived: total,
      tax: tax,
      discount: discount,
    );
  }
}

/// Result of checkout operation
class CheckoutResult {
  final bool success;
  final String? message;
  final double totalAmount;
  final int itemsProcessed;
  final dynamic transaction; // Transaction entity (optional import to avoid circular dependency)

  const CheckoutResult({
    required this.success,
    this.message,
    required this.totalAmount,
    required this.itemsProcessed,
    this.transaction,
  });

  factory CheckoutResult.success({
    required dynamic transaction,
    required double totalAmount,
    required int itemsProcessed,
  }) {
    return CheckoutResult(
      success: true,
      message: 'Checkout berhasil!',
      totalAmount: totalAmount,
      itemsProcessed: itemsProcessed,
      transaction: transaction,
    );
  }

  factory CheckoutResult.failure(String message) {
    return const CheckoutResult(
      success: false,
      totalAmount: 0,
      itemsProcessed: 0,
      transaction: null,
    );
  }
}
