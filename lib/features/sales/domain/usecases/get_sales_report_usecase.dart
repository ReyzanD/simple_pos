import '../entities/sales_report.dart';
import '../repositories/transaction_repository.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../../core/utils/logger.dart';

/// Reporting period enumeration
enum ReportPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

/// Use case for generating sales reports
class GetSalesReportUseCase {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;

  GetSalesReportUseCase({
    required this.transactionRepository,
    required this.productRepository,
  });

  Future<SalesReport> execute({
    required DateTime startDate,
    required DateTime endDate,
    required ReportPeriod period,
  }) async {
    try {
      AppLogger.useCase('GetSalesReport',
        details: '${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      // Get transactions for the date range
      final transactions = await transactionRepository.getTransactions();

      // Get all products to access cost prices
      final products = await productRepository.getProducts();
      final productMap = {for (var p in products) p.id!: p};

      // Filter by date range
      final filtered = transactions.where((t) {
        final date = t.transactionDate;
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        return date.isAfter(start) && date.isBefore(end);
      }).toList();

      // Calculate totals and actual profit
      double totalRevenue = 0;
      double totalProfit = 0;

      for (final transaction in filtered) {
        totalRevenue += transaction.totalAmount;

        // Calculate profit for each item
        for (final item in transaction.items) {
          final product = productMap[item.productId];
          if (product != null) {
            final itemRevenue = item.unitPrice * item.quantity;
            final itemCost = product.costPrice * item.quantity;
            final itemProfit = itemRevenue - itemCost;

            totalProfit += itemProfit;
          }
        }
      }

      // Return a basic sales report with actual profit
      // TODO: Implement full report with daily breakdown, top products, etc.
      return SalesReport(
        startDate: startDate,
        endDate: endDate,
        totalTransactions: filtered.length,
        totalRevenue: totalRevenue,
        totalProfit: totalProfit,
        averageTransactionValue: filtered.isEmpty ? 0 : totalRevenue / filtered.length,
        dailyBreakdown: [],
        topProducts: [],
        paymentBreakdown: [],
      );
    } catch (e, stackTrace) {
      AppLogger.error('GetSalesReport failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
