import '../entities/transaction.dart';
import '../entities/payment_method.dart';
import '../entities/payment_status.dart';
import '../entities/transaction_item.dart';
import '../entities/payment.dart';
import '../repositories/transaction_repository.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../pos/domain/entities/cart_item.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for creating a new transaction
class CreateTransactionUseCase {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;

  CreateTransactionUseCase({
    required this.transactionRepository,
    required this.productRepository,
  });

  /// Executes the use case
  /// Creates a transaction from cart items and updates stock
  Future<Transaction> execute({
    required List<CartItem> cart,
    required PaymentMethod paymentMethod,
    double? cashReceived,
    String? cardLast4Digits,
    String? notes,
    double tax = 0,
    double discount = 0,
  }) async {
    try {
      AppLogger.useCase('CreateTransaction', details: '${cart.length} items');

      if (cart.isEmpty) {
        throw const EmptyCartException('Keranjang kosong');
      }

      // Validate all cart items have sufficient stock
      for (final cartItem in cart) {
        if (cartItem.quantity > cartItem.product.stock) {
          throw InsufficientStockException(
            'Stok tidak mencukupi untuk ${cartItem.product.name}',
            requested: cartItem.quantity,
            available: cartItem.product.stock,
          );
        }
      }

      final now = DateTime.now();

      // Calculate totals
      final subtotal = cart.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

      final totalAmount = subtotal + tax - discount;

      // Create transaction items
      final items = cart.map((cartItem) => TransactionItem(
        transactionId: 0, // Will be set after transaction creation
        productId: cartItem.product.id!,
        productName: cartItem.product.name,
        quantity: cartItem.quantity,
        unitPrice: cartItem.product.price,
        subtotal: cartItem.totalPrice,
      )).toList();

      // Create payment
      final payment = Payment(
        transactionId: 0, // Will be set after transaction creation
        paymentMethod: paymentMethod,
        amount: totalAmount,
        cashReceived: cashReceived,
        cardLast4Digits: cardLast4Digits,
        paymentDate: now,
      );

      // Create transaction
      final transaction = Transaction(
        transactionDate: now,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        paymentStatus: PaymentStatus.completed,
        notes: notes,
        items: items,
        payment: payment,
        createdAt: now,
        updatedAt: now,
      );

      // Create transaction in database
      final createdTransaction = await transactionRepository.createTransaction(transaction);

      // Update stock for each product
      for (final cartItem in cart) {
        final updatedProduct = cartItem.product.copyWith(
          stock: cartItem.product.stock - cartItem.quantity,
        );

        await productRepository.updateProduct(updatedProduct);

        AppLogger.info(
          'Stock updated for ${updatedProduct.name}: ${cartItem.product.stock} -> ${updatedProduct.stock}',
        );
      }

      AppLogger.info('Transaction created successfully: ${createdTransaction.id}');

      return createdTransaction;
    } on EmptyCartException {
      rethrow;
    } on InsufficientStockException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CreateTransactionUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuat transaksi',
        operation: 'CreateTransaction',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
