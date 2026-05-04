import 'package:simple_pos/features/sales/domain/entities/payment.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart'; // Added this
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.transactionDate,
    required super.subtotal,
    super.tax,
    super.discount,
    required super.totalAmount,
    required super.paymentMethod,
    required super.paymentStatus,
    super.notes,
    required super.items,
    super.payment,
    super.cashierId,
    super.cashierName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> map, {
    List<TransactionItem>? items,
    Payment? payment,
  }) {
    return TransactionModel(
      id: map['id'] as int? ?? 0,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.fromString(map['payment_method'] as String),
      paymentStatus: PaymentStatus.fromString(map['payment_status'] as String),
      notes: map['notes'] as String?,
      items: items ?? [],
      payment: payment,
      cashierId: map['cashier_id'] as int?,
      cashierName: map['cashier_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
