import '../../../../core/exceptions/app_exceptions.dart';
import '../../../sales/domain/entities/transaction.dart';

/// Result type for checkout operation
class CheckoutResult {
  final bool success;
  final Transaction? transaction;
  final String? errorMessage;
  final double totalAmount;
  final int itemsProcessed;

  const CheckoutResult.success({
    required this.transaction,
    required this.totalAmount,
    required this.itemsProcessed,
  }) : success = true, errorMessage = null;

  const CheckoutResult.failure({
    required this.errorMessage,
  }) : success = false, transaction = null, totalAmount = 0, itemsProcessed = 0;

  /// Gets user-friendly message from result
  String get message => errorMessage ?? 'Checkout berhasil';
}
