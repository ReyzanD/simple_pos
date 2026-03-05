import 'payment_method.dart';

/// Payment entity representing payment details for a transaction
class Payment {
  final int? id;
  final int transactionId;
  final PaymentMethod paymentMethod;
  final double amount;
  final double? cashReceived;
  final String? cardLast4Digits;
  final DateTime paymentDate;

  const Payment({
    this.id,
    required this.transactionId,
    required this.paymentMethod,
    required this.amount,
    this.cashReceived,
    this.cardLast4Digits,
    required this.paymentDate,
  });

  /// Creates a copy of this payment with the given fields replaced
  Payment copyWith({
    int? id,
    int? transactionId,
    PaymentMethod? paymentMethod,
    double? amount,
    double? cashReceived,
    String? cardLast4Digits,
    DateTime? paymentDate,
  }) {
    return Payment(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      cashReceived: cashReceived ?? this.cashReceived,
      cardLast4Digits: cardLast4Digits ?? this.cardLast4Digits,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  /// Calculates change for cash payments
  double? get change {
    if (paymentMethod == PaymentMethod.cash && cashReceived != null) {
      return cashReceived! - amount;
    }
    return null;
  }

  /// Converts payment to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'payment_method': paymentMethod.name,
      'amount': amount,
      'cash_received': cashReceived,
      'card_last_4_digits': cardLast4Digits,
      'payment_date': paymentDate.toIso8601String(),
    };
  }

  /// Creates a Payment from a database map
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
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
  String toString() =>
      'Payment(id: $id, transactionId: $transactionId, paymentMethod: $paymentMethod, amount: $amount, paymentDate: $paymentDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payment &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.paymentMethod == paymentMethod &&
        other.amount == amount &&
        other.cashReceived == cashReceived &&
        other.cardLast4Digits == cardLast4Digits &&
        other.paymentDate == paymentDate;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      transactionId.hashCode ^
      paymentMethod.hashCode ^
      amount.hashCode ^
      cashReceived.hashCode ^
      cardLast4Digits.hashCode ^
      paymentDate.hashCode;
}
