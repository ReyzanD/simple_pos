import 'payment_method.dart';

/// Daily sales breakdown
class DailySales {
  final DateTime date;
  final int transactionCount;
  final double revenue;
  final double profit;

  const DailySales({
    required this.date,
    required this.transactionCount,
    required this.revenue,
    required this.profit,
  });

  @override
  String toString() => 'DailySales(date: $date, transactions: $transactionCount, revenue: $revenue)';
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

  @override
  String toString() => 'ProductSales(product: $productName, quantity: $quantitySold, revenue: $revenue)';
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
  String toString() => 'PaymentMethodBreakdown(method: $paymentMethod, count: $transactionCount, amount: $totalAmount)';
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
  String toString() => 'CategorySales(category: $categoryName, quantity: $quantitySold, revenue: $revenue)';
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
  String toString() => 'PeakHourData(hour: $formattedHour, transactions: $transactionCount, revenue: $revenue)';
}

/// Sales report containing aggregated sales data
class SalesReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;
  final double totalRevenue;
  final double totalProfit;
  final double averageTransactionValue;
  final int totalItemsSold;
  final List<DailySales> dailyBreakdown;
  final List<ProductSales> topProducts;
  final List<PaymentMethodBreakdown> paymentBreakdown;
  final List<CategorySales> categoryBreakdown;
  final PeriodComparison? monthOverMonth;
  final PeriodComparison? yearOverYear;
  final List<PeakHourData> peakHours;

  const SalesReport({
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalProfit,
    required this.averageTransactionValue,
    required this.totalItemsSold,
    required this.dailyBreakdown,
    required this.topProducts,
    required this.paymentBreakdown,
    this.categoryBreakdown = const [],
    this.monthOverMonth,
    this.yearOverYear,
    this.peakHours = const [],
  });

  /// Calculates profit margin percentage
  double get profitMargin {
    if (totalRevenue == 0) return 0;
    return (totalProfit / totalRevenue * 100);
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
