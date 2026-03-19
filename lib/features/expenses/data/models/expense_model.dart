import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_payment_method.dart';

/// ExpenseModel for data transfer between database and domain layer
class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final String? description;
  final String paymentMethod;
  final String? receiptImagePath;
  final int? createdBy;
  final int createdAt;
  final int date;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    this.description,
    required this.paymentMethod,
    this.receiptImagePath,
    this.createdBy,
    required this.createdAt,
    required this.date,
  });

  /// Create ExpenseModel from database map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      receiptImagePath: map['receipt_image'] as String?,
      createdBy: map['created_by'] as int?,
      createdAt: map['created_at'] as int,
      date: map['date'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'payment_method': paymentMethod,
      'receipt_image': receiptImagePath,
      'created_by': createdBy,
      'created_at': createdAt,
      'date': date,
    };
  }

  /// Convert to domain entity
  Expense toEntity() {
    return Expense(
      id: id,
      category: category,
      amount: amount,
      description: description,
      paymentMethod: ExpensePaymentMethodExtension.fromString(paymentMethod),
      receiptImagePath: receiptImagePath,
      createdBy: createdBy,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt * 1000),
      date: DateTime.fromMillisecondsSinceEpoch(date * 1000),
    );
  }

  /// Create ExpenseModel from domain entity
  static ExpenseModel fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      category: expense.category,
      amount: expense.amount,
      description: expense.description,
      paymentMethod: expense.paymentMethod.name,
      receiptImagePath: expense.receiptImagePath,
      createdBy: expense.createdBy,
      createdAt: expense.createdAt.millisecondsSinceEpoch ~/ 1000,
      date: expense.date.millisecondsSinceEpoch ~/ 1000,
    );
  }
}
