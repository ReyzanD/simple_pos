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

/// Sales report containing aggregated sales data
class SalesReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;
  final double totalRevenue;
  final double totalProfit;
  final double averageTransactionValue;
  final List<DailySales> dailyBreakdown;
  final List<ProductSales> topProducts;
  final List<PaymentMethodBreakdown> paymentBreakdown;

  const SalesReport({
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.totalProfit,
    required this.averageTransactionValue,
    required this.dailyBreakdown,
    required this.topProducts,
    required this.paymentBreakdown,
  });

  /// Calculates profit margin percentage
  double get profitMargin {
    if (totalRevenue == 0) return 0;
    return (totalProfit / totalRevenue * 100);
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
