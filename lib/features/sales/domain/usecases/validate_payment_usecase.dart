import '../entities/payment_method.dart';
import '../../../../core/utils/logger.dart';

/// Result of payment validation
class PaymentValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PaymentValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory PaymentValidationResult.success() {
    return const PaymentValidationResult(isValid: true);
  }

  factory PaymentValidationResult.failure(String message) {
    return PaymentValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }
}

/// Use case for validating payment details
class ValidatePaymentUseCase {
  /// Executes the use case to validate payment
  PaymentValidationResult execute({
    required PaymentMethod paymentMethod,
    required double totalAmount,
    double? cashReceived,
    String? cardLast4Digits,
  }) {
    AppLogger.useCase('ValidatePayment', details: paymentMethod.name);

    // Validate total amount
    if (totalAmount <= 0) {
      return PaymentValidationResult.failure('Total pembayaran harus lebih dari 0');
    }

    switch (paymentMethod) {
      case PaymentMethod.cash:
        return _validateCashPayment(totalAmount, cashReceived);

      case PaymentMethod.card:
        return _validateCardPayment(cardLast4Digits);

      case PaymentMethod.qr:
      case PaymentMethod.transfer:
        // QR and transfer are always considered valid (assumes confirmation)
        return PaymentValidationResult.success();
    }
  }

  PaymentValidationResult _validateCashPayment(double totalAmount, double? cashReceived) {
    if (cashReceived == null) {
      return PaymentValidationResult.failure('Jumlah uang diterima harus diisi');
    }

    if (cashReceived < totalAmount) {
      return PaymentValidationResult.failure(
        'Jumlah uang diterima kurang dari total pembayaran',
      );
    }

    return PaymentValidationResult.success();
  }

  PaymentValidationResult _validateCardPayment(String? cardLast4Digits) {
    if (cardLast4Digits != null && cardLast4Digits.isNotEmpty) {
      // If provided, must be exactly 4 digits
      if (cardLast4Digits.length != 4 || int.tryParse(cardLast4Digits) == null) {
        return PaymentValidationResult.failure(
          '4 digit terakhir kartu harus berupa 4 angka',
        );
      }
    }

    // Card is valid even without last 4 digits (optional)
    return PaymentValidationResult.success();
  }
}
