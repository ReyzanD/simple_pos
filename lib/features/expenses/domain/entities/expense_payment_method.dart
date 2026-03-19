/// Payment methods for expenses
enum ExpensePaymentMethod {
  cash,
  transfer,
  card,
  other,
}

/// Extension for ExpensePaymentMethod
extension ExpensePaymentMethodExtension on ExpensePaymentMethod {
  /// Get display name (Indonesian)
  String get displayName {
    switch (this) {
      case ExpensePaymentMethod.cash:
        return 'Tunai';
      case ExpensePaymentMethod.transfer:
        return 'Transfer';
      case ExpensePaymentMethod.card:
        return 'Kartu';
      case ExpensePaymentMethod.other:
        return 'Lainnya';
    }
  }

  /// Convert string to enum
  static ExpensePaymentMethod fromString(String value) {
    return ExpensePaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpensePaymentMethod.cash,
    );
  }
}
