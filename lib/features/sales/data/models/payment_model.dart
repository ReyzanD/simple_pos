import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    super.id,
    required super.transactionId,
    required super.paymentMethod,
    required super.amount,
    super.cashReceived,
    super.cardLast4Digits,
    required super.paymentDate,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      paymentMethod: PaymentMethod.fromString(map['payment_method'] as String),
      amount: (map['amount'] as num).toDouble(),
      cashReceived: (map['cash_received'] as num?)?.toDouble(),
      cardLast4Digits: map['card_last_4_digits'] as String?,
      paymentDate: DateTime.parse(map['payment_date'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'transaction_id': transactionId,
      'payment_method': paymentMethod.name,
      'amount': amount,
      'cash_received': cashReceived,
      'card_last_4_digits': cardLast4Digits,
      'payment_date': paymentDate.toIso8601String(),
    };
  }
}
