import '../entities/transaction.dart';
import '../entities/payment_method.dart';
import '../entities/sales_report.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for generating sales reports
class GenerateSalesReportUseCase {
  final TransactionRepository transactionRepository;

  GenerateSalesReportUseCase({required this.transactionRepository});

  /// Executes the use case to generate sales report for a date range
  Future<SalesReport> execute(DateTime startDate, DateTime endDate) async {
    try {
      AppLogger.useCase('GenerateSalesReport', details: '$startDate to $endDate');

      // Validate date range
      if (startDate.isAfter(endDate)) {
        throw const ValidationException('Tanggal awal tidak boleh setelah tanggal akhir');
      }

      // Get transactions in date range
      final transactions = await transactionRepository.getTransactionsByDateRange(startDate, endDate);

      // Calculate metrics
      final totalTransactions = transactions.length;
      final totalRevenue = transactions.fold<double>(0, (sum, t) => sum + t.totalAmount);
      final totalProfit = _calculateTotalProfit(transactions);
      final averageTransactionValue =
          totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;

      // Group by date for daily breakdown
      final dailyBreakdown = _calculateDailyBreakdown(transactions);

      // Get top products
      final topProducts = _calculateTopProducts(transactions);

      // Get payment method breakdown
      final paymentBreakdown = _calculatePaymentBreakdown(transactions, totalRevenue);

      // Calculate total items sold
      final totalItemsSold = transactions.fold<int>(0, (sum, t) => sum + t.items.fold(0, (itemSum, item) => itemSum + item.quantity));

      final report = SalesReport(
        startDate: startDate,
        endDate: endDate,
        totalTransactions: totalTransactions,
        totalRevenue: totalRevenue,
        totalProfit: totalProfit,
        averageTransactionValue: averageTransactionValue,
        totalItemsSold: totalItemsSold,
        dailyBreakdown: dailyBreakdown,
        topProducts: topProducts,
        paymentBreakdown: paymentBreakdown,
      );

      AppLogger.info('Sales report generated: ${report.totalTransactions} transactions, ${report.totalRevenue} revenue');

      return report;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GenerateSalesReportUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuat laporan penjualan',
        operation: 'GenerateSalesReport',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total profit from transactions
  double _calculateTotalProfit(List<Transaction> transactions) {
    double profit = 0;
    for (final transaction in transactions) {
      for (final item in transaction.items) {
        // Assuming profit is calculated as 20% of revenue (adjust based on your business logic)
        profit += item.subtotal * 0.2;
      }
    }
    return profit;
  }

  /// Groups transactions by date
  List<DailySales> _calculateDailyBreakdown(List<Transaction> transactions) {
    final Map<String, DailySales> dailyMap = {};

    for (final transaction in transactions) {
      final dateKey = _dateKey(transaction.transactionDate);

      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = DailySales(
          date: DateTime(
            transaction.transactionDate.year,
            transaction.transactionDate.month,
            transaction.transactionDate.day,
          ),
          transactionCount: 0,
          revenue: 0,
          profit: 0,
        );
      }

      final daily = dailyMap[dateKey]!;
      dailyMap[dateKey] = DailySales(
        date: daily.date,
        transactionCount: daily.transactionCount + 1,
        revenue: daily.revenue + transaction.totalAmount,
        profit: daily.profit + (transaction.totalAmount * 0.2),
      );
    }

    // Sort by date
    final dailyList = dailyMap.values.toList();
    dailyList.sort((a, b) => a.date.compareTo(b.date));

    return dailyList;
  }

  /// Calculates top selling products
  List<ProductSales> _calculateTopProducts(List<Transaction> transactions) {
    final Map<int, ProductSales> productMap = {};

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        if (!productMap.containsKey(item.productId)) {
          productMap[item.productId] = ProductSales(
            productId: item.productId,
            productName: item.productName,
            quantitySold: 0,
            revenue: 0,
            profit: 0,
          );
        }

        final product = productMap[item.productId]!;
        productMap[item.productId] = ProductSales(
          productId: product.productId,
          productName: product.productName,
          quantitySold: product.quantitySold + item.quantity,
          revenue: product.revenue + item.subtotal,
          profit: product.profit + (item.subtotal * 0.2),
        );
      }
    }

    // Sort by revenue and take top 10
    final products = productMap.values.toList();
    products.sort((a, b) => b.revenue.compareTo(a.revenue));

    return products.take(10).toList();
  }

  /// Calculates payment method breakdown
  List<PaymentMethodBreakdown> _calculatePaymentBreakdown(
    List<Transaction> transactions,
    double totalRevenue,
  ) {
    final Map<PaymentMethod, PaymentMethodBreakdown> methodMap = {};

    for (final transaction in transactions) {
      final method = transaction.paymentMethod;

      if (!methodMap.containsKey(method)) {
        methodMap[method] = PaymentMethodBreakdown(
          paymentMethod: method,
          transactionCount: 0,
          totalAmount: 0,
          percentage: 0,
        );
      }

      final breakdown = methodMap[method]!;
      methodMap[method] = PaymentMethodBreakdown(
        paymentMethod: method,
        transactionCount: breakdown.transactionCount + 1,
        totalAmount: breakdown.totalAmount + transaction.totalAmount,
        percentage: 0, // Will calculate after
      );
    }

    // Calculate percentages
    final breakdowns = methodMap.values.toList();
    for (final breakdown in breakdowns) {
      final percentage = totalRevenue > 0
          ? (breakdown.totalAmount / totalRevenue * 100).toDouble()
          : 0.0;
      methodMap[breakdown.paymentMethod] = PaymentMethodBreakdown(
        paymentMethod: breakdown.paymentMethod,
        transactionCount: breakdown.transactionCount,
        totalAmount: breakdown.totalAmount,
        percentage: percentage,
      );
    }

    // Sort by transaction count
    breakdowns.sort((a, b) => b.transactionCount.compareTo(a.transactionCount));

    return breakdowns;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
