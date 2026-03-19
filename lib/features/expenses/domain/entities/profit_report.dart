/// Profit report entity containing financial metrics
/// Used for calculating net profit after expenses
class ProfitReport {
  /// Gross profit from sales (before expenses)
  final double grossProfit;

  /// Total revenue from sales
  final double totalRevenue;

  /// Total expenses for the period
  final double totalExpenses;

  /// Net profit (gross profit - expenses)
  final double netProfit;

  /// Profit margin as a percentage (net profit / revenue)
  final double profitMargin;

  /// Expense ratio as a percentage (expenses / revenue)
  final double expenseRatio;

  const ProfitReport({
    required this.grossProfit,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.expenseRatio,
  });

  @override
  String toString() {
    return 'ProfitReport(grossProfit: $grossProfit, totalRevenue: $totalRevenue, '
        'totalExpenses: $totalExpenses, netProfit: $netProfit, '
        'profitMargin: $profitMargin, expenseRatio: $expenseRatio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfitReport &&
        other.grossProfit == grossProfit &&
        other.totalRevenue == totalRevenue &&
        other.totalExpenses == totalExpenses &&
        other.netProfit == netProfit &&
        other.profitMargin == profitMargin &&
        other.expenseRatio == expenseRatio;
  }

  @override
  int get hashCode {
    return grossProfit.hashCode ^
        totalRevenue.hashCode ^
        totalExpenses.hashCode ^
        netProfit.hashCode ^
        profitMargin.hashCode ^
        expenseRatio.hashCode;
  }

  /// Create a copy with some fields replaced
  ProfitReport copyWith({
    double? grossProfit,
    double? totalRevenue,
    double? totalExpenses,
    double? netProfit,
    double? profitMargin,
    double? expenseRatio,
  }) {
    return ProfitReport(
      grossProfit: grossProfit ?? this.grossProfit,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netProfit: netProfit ?? this.netProfit,
      profitMargin: profitMargin ?? this.profitMargin,
      expenseRatio: expenseRatio ?? this.expenseRatio,
    );
  }
}
