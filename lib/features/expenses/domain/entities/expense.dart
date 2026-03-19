import '../constants/expense_categories.dart';
import 'expense_payment_method.dart';

/// Expense entity representing a business expense
class Expense {
  final int? id;
  final String category;
  final double amount;
  final String? description;
  final ExpensePaymentMethod paymentMethod;
  final String? receiptImagePath;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime date;

  Expense({
    this.id,
    required this.category,
    required this.amount,
    this.description,
    this.paymentMethod = ExpensePaymentMethod.cash,
    this.receiptImagePath,
    this.createdBy,
    DateTime? createdAt,
    DateTime? date,
  })  : createdAt = createdAt ?? DateTime.now(),
        date = date ?? DateTime.now();

  /// Create a copy with some fields replaced
  Expense copyWith({
    int? id,
    String? category,
    double? amount,
    String? description,
    ExpensePaymentMethod? paymentMethod,
    String? receiptImagePath,
    int? createdBy,
    DateTime? createdAt,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
    );
  }

  /// Check if category is predefined
  bool get isPredefinedCategory {
    return ExpenseCategories.isPredefined(category);
  }

  /// Check if expense has receipt
  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;

  @override
  String toString() {
    return 'Expense(id: $id, category: $category, amount: $amount, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Expense &&
        other.id == id &&
        other.category == category &&
        other.amount == amount &&
        other.description == description &&
        other.paymentMethod == paymentMethod &&
        other.receiptImagePath == receiptImagePath &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        category.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        paymentMethod.hashCode ^
        receiptImagePath.hashCode ^
        createdBy.hashCode ^
        createdAt.hashCode ^
        date.hashCode;
  }
}
