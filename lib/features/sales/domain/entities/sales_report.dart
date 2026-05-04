import 'payment_method.dart';
import '../../../expenses/domain/entities/profit_report.dart';

/// Daily sales breakdown
class DailySales {
  final DateTime date;
  final int transactionCount;
  final double revenue;
  final double profit;
  final double tax;

  const DailySales({
    required this.date,
    required this.transactionCount,
    required this.revenue,
    required this.profit,
    this.tax = 0,
  });

  @override
  String toString() =>
      'DailySales(date: $date, transactions: $transactionCount, revenue: $revenue)';
}

/// Product sales statistics
class ProductSales {
  final int productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double profit;

  const ProductSales({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
  });

  /// Calculate profit margin percentage
  double get profitMargin {
    if (revenue == 0) return 0;
    return (profit / revenue * 100);
  }

  @override
  String toString() =>
      'ProductSales(product: $productName, quantity: $quantitySold, revenue: $revenue)';
}

/// Payment method breakdown
class PaymentMethodBreakdown {
  final PaymentMethod paymentMethod;
  final int transactionCount;
  final double totalAmount;
  final double percentage;

  const PaymentMethodBreakdown({
    required this.paymentMethod,
    required this.transactionCount,
    required this.totalAmount,
    required this.percentage,
  });

  @override
  String toString() =>
      'PaymentMethodBreakdown(method: $paymentMethod, count: $transactionCount, amount: $totalAmount)';
}

/// Category sales breakdown
class CategorySales {
  final int categoryId;
  final String categoryName;
  final int quantitySold;
  final double revenue;
  final double profit;
  final double profitMargin;

  const CategorySales({
    required this.categoryId,
    required this.categoryName,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
    required this.profitMargin,
  });

  @override
  String toString() =>
      'CategorySales(category: $categoryName, quantity: $quantitySold, revenue: $revenue)';
}

/// Cashier sales breakdown
class CashierSales {
  final int? cashierId;
  final String cashierName;
  final int transactionCount;
  final double revenue;
  final double profit;
  final double profitMargin;

  const CashierSales({
    this.cashierId,
    required this.cashierName,
    required this.transactionCount,
    required this.revenue,
    required this.profit,
    required this.profitMargin,
  });

  @override
  String toString() =>
      'CashierSales(cashier: $cashierName, transactions: $transactionCount, revenue: $revenue)';
}

/// Discount summary for the reporting period
class DiscountSummary {
  final double totalDiscount;
  final int discountedTransactionCount;
  final int totalTransactionCount;
  final double averageDiscountPerTransaction;
  final double discountRate;

  const DiscountSummary({
    required this.totalDiscount,
    required this.discountedTransactionCount,
    required this.totalTransactionCount,
    required this.averageDiscountPerTransaction,
    required this.discountRate,
  });

  @override
  String toString() =>
      'DiscountSummary(total: $totalDiscount, rate: ${discountRate.toStringAsFixed(1)}%)';
}

/// Period comparison data for comparing current period with previous period
class PeriodComparison {
  final double revenueChange;
  final double transactionChange;
  final double profitChange;
  final double? previousRevenue;
  final double? previousTransactions;
  final double? previousProfit;

  const PeriodComparison({
    required this.revenueChange,
    required this.transactionChange,
    required this.profitChange,
    this.previousRevenue,
    this.previousTransactions,
    this.previousProfit,
  });

  /// Returns positive growth indicator for revenue
  bool get isRevenueGrowth => revenueChange >= 0;

  /// Returns positive growth indicator for transactions
  bool get isTransactionGrowth => transactionChange >= 0;

  /// Returns positive growth indicator for profit
  bool get isProfitGrowth => profitChange >= 0;

  @override
  String toString() =>
      'PeriodComparison(revenue: $revenueChange%, transactions: $transactionChange%, profit: $profitChange%)';
}

/// Peak hour sales data
class PeakHourData {
  final int hour; // 0-23
  final int transactionCount;
  final double revenue;
  final double averageTransactionValue;

  const PeakHourData({
    required this.hour,
    required this.transactionCount,
    required this.revenue,
    required this.averageTransactionValue,
  });

  /// Returns formatted hour string (e.g., "09:00", "14:00")
  String get formattedHour => '${hour.toString().padLeft(2, '0')}:00';

  /// Returns period of day label
  String get periodOfDay {
    if (hour >= 5 && hour < 12) return 'Pagi';
    if (hour >= 12 && hour < 15) return 'Siang';
    if (hour >= 15 && hour < 18) return 'Sore';
    if (hour >= 18 && hour < 22) return 'Malam';
    return 'Larut Malam';
  }

  @override
  String toString() =>
      'PeakHourData(hour: $formattedHour, transactions: $transactionCount, revenue: $revenue)';
}

/// Sales report containing aggregated sales data
class SalesReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;
  final double totalRevenue;
  final double totalProfit;
  final double totalTax;
  final double averageTransactionValue;
  final int totalItemsSold;
  final List<DailySales> dailyBreakdown;
  final List<ProductSales> topProducts;
  final List<PaymentMethodBreakdown> paymentBreakdown;
  final List<CategorySales> categoryBreakdown;
  final List<CashierSales> cashierBreakdown;
  final DiscountSummary? discountSummary;
  final PeriodComparison? monthOverMonth;
  final PeriodComparison? yearOverYear;
  final List<PeakHourData> peakHours;
  final ProfitReport? profitReport;

  const SalesReport({
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalProfit,
    this.totalTax = 0,
    required this.averageTransactionValue,
    required this.totalItemsSold,
    required this.dailyBreakdown,
    required this.topProducts,
    required this.paymentBreakdown,
    this.categoryBreakdown = const [],
    this.cashierBreakdown = const [],
    this.discountSummary,
    this.monthOverMonth,
    this.yearOverYear,
    this.peakHours = const [],
    this.profitReport,
  });

  /// Calculates profit margin percentage (gross profit margin)
  double get profitMargin {
    if (totalRevenue == 0) return 0;
    return (totalProfit / totalRevenue * 100);
  }

  /// Returns net profit (gross profit minus expenses)
  /// Returns gross profit if no expense data available
  double get netProfit {
    return profitReport?.netProfit ?? totalProfit;
  }

  /// Returns total expenses
  double get totalExpenses {
    return profitReport?.totalExpenses ?? 0;
  }

  /// Returns net profit margin (after expenses)
  double get netProfitMargin {
    if (totalRevenue == 0) return 0;
    return (netProfit / totalRevenue * 100);
  }

  /// Returns expense ratio (expenses as percentage of revenue)
  double get expenseRatio {
    return profitReport?.expenseRatio ?? 0;
  }

  /// Calculates average items per transaction (basket size)
  double get itemsPerTransaction {
    if (totalTransactions == 0) return 0;
    return totalItemsSold / totalTransactions;
  }

  @override
  String toString() =>
      'SalesReport(transactions: $totalTransactions, revenue: $totalRevenue, profit: $totalProfit)';
}

/// Sales report summary for quick overview
class SalesReportSummary {
  final int totalTransactions;
  final double totalRevenue;
  final double totalProfit;
  final double averageTransactionValue;
  final int lowStockProducts;

  const SalesReportSummary({
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalProfit,
    required this.averageTransactionValue,
    required this.lowStockProducts,
  });

  @override
  String toString() =>
      'SalesReportSummary(transactions: $totalTransactions, revenue: $totalRevenue, profit: $totalProfit)';
}
