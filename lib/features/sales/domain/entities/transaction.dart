import 'transaction_item.dart';
import 'payment.dart';
import 'payment_method.dart';
import 'payment_status.dart';

/// Transaction entity representing a sales transaction
class Transaction {
  final int? id;
  final DateTime transactionDate;
  final double subtotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? notes;
  final List<TransactionItem> items;
  final Payment? payment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.transactionDate,
    required this.subtotal,
    this.tax = 0,
    this.discount = 0,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.notes,
    required this.items,
    this.payment,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this transaction with the given fields replaced
  Transaction copyWith({
    int? id,
    DateTime? transactionDate,
    double? subtotal,
    double? tax,
    double? discount,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? notes,
    List<TransactionItem>? items,
    Payment? payment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionDate: transactionDate ?? this.transactionDate,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      payment: payment ?? this.payment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculates total items in transaction
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Calculates total profit from all items (revenue - cost of goods sold)
  double get profit => items.fold(0, (sum, item) => sum + item.profit);

  /// Checks if transaction is completed
  bool get isCompleted => paymentStatus == PaymentStatus.completed;

  /// Checks if transaction is refundable
  bool get isRefundable =>
      paymentStatus == PaymentStatus.completed &&
      transactionDate.isAfter(DateTime.now().subtract(const Duration(days: 30)));

  /// Converts transaction to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_date': transactionDate.toIso8601String(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod.name,
      'payment_status': paymentStatus.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a Transaction from a database map
  factory Transaction.fromMap(
    Map<String, dynamic> map, {
    List<TransactionItem>? items,
    Payment? payment,
  }) {
    return Transaction(
      id: map['id'] as int?,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.fromString(map['payment_method'] as String),
      paymentStatus: PaymentStatus.fromString(map['payment_status'] as String),
      notes: map['notes'] as String?,
      items: items ?? [], // Items loaded separately or provided
      payment: payment,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Creates a Transaction with full details including items and payment
  factory Transaction.fromMapWithDetails(
    Map<String, dynamic> map,
    List<TransactionItem> items,
    Payment? payment,
  ) {
    return Transaction(
      id: map['id'] as int?,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.fromString(map['payment_method'] as String),
      paymentStatus: PaymentStatus.fromString(map['payment_status'] as String),
      notes: map['notes'] as String?,
      items: items,
      payment: payment,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, transactionDate: $transactionDate, totalAmount: $totalAmount, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, items: ${items.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction &&
        other.id == id &&
        other.transactionDate == transactionDate &&
        other.subtotal == subtotal &&
        other.tax == tax &&
        other.discount == discount &&
        other.totalAmount == totalAmount &&
        other.paymentMethod == paymentMethod &&
        other.paymentStatus == paymentStatus &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      transactionDate.hashCode ^
      subtotal.hashCode ^
      tax.hashCode ^
      discount.hashCode ^
      totalAmount.hashCode ^
      paymentMethod.hashCode ^
      paymentStatus.hashCode ^
      notes.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
