import '../entities/sales_report.dart';
import '../entities/transaction.dart';
import '../entities/payment_method.dart';
import '../entities/payment_status.dart';
import '../repositories/transaction_repository.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../inventory/domain/repositories/category_repository.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/entities/category.dart';
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
  final CategoryRepository categoryRepository;

  GetSalesReportUseCase({
    required this.transactionRepository,
    required this.productRepository,
    required this.categoryRepository,
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

      // Get all categories for category breakdown
      final categories = await categoryRepository.getCategories();
      final categoryMap = {for (var c in categories) c.id!: c};

      // Filter by date range AND only include completed transactions
      final filtered = transactions.where((t) {
        final date = t.transactionDate;
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        return t.paymentStatus == PaymentStatus.completed &&
            date.isAfter(start) &&
            date.isBefore(end);
      }).toList();

      // Calculate totals and actual profit
      double totalRevenue = 0;
      double totalProfit = 0;
      int totalItemsSold = 0;

      for (final transaction in filtered) {
        totalRevenue += transaction.totalAmount;

        // Calculate profit for each item
        for (final item in transaction.items) {
          totalItemsSold += item.quantity;
          final product = productMap[item.productId];
          if (product != null) {
            final itemRevenue = item.unitPrice * item.quantity;
            final itemCost = product.costPrice * item.quantity;
            final itemProfit = itemRevenue - itemCost;

            totalProfit += itemProfit;
          }
        }
      }

      // Generate daily breakdown
      final dailyBreakdown = _generateDailyBreakdown(filtered, productMap);

      // Generate top products
      final topProducts = _generateTopProducts(filtered, productMap);

      // Generate payment method breakdown
      final paymentBreakdown = _generatePaymentBreakdown(filtered, totalRevenue);

      // Generate category breakdown
      final categoryBreakdown = _generateCategoryBreakdown(filtered, productMap, categoryMap);

      // Generate period comparisons
      final allTransactions = await transactionRepository.getTransactions();
      final monthOverMonth = _generatePeriodComparison(
        allTransactions,
        startDate,
        endDate,
        totalRevenue,
        totalProfit,
        filtered.length,
        productMap,
        isMonthOverMonth: true,
      );
      final yearOverYear = _generatePeriodComparison(
        allTransactions,
        startDate,
        endDate,
        totalRevenue,
        totalProfit,
        filtered.length,
        productMap,
        isMonthOverMonth: false,
      );

      // Generate peak hours
      final peakHours = _generatePeakHours(filtered);

      return SalesReport(
        startDate: startDate,
        endDate: endDate,
        totalTransactions: filtered.length,
        totalRevenue: totalRevenue,
        totalProfit: totalProfit,
        averageTransactionValue: filtered.isEmpty ? 0 : totalRevenue / filtered.length,
        totalItemsSold: totalItemsSold,
        dailyBreakdown: dailyBreakdown,
        topProducts: topProducts,
        paymentBreakdown: paymentBreakdown,
        categoryBreakdown: categoryBreakdown,
        monthOverMonth: monthOverMonth,
        yearOverYear: yearOverYear,
        peakHours: peakHours,
      );
    } catch (e, stackTrace) {
      AppLogger.error('GetSalesReport failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Generate daily sales breakdown from transactions
  List<DailySales> _generateDailyBreakdown(
    List<Transaction> transactions,
    Map<int, Product> productMap,
  ) {
    // Group transactions by date
    final Map<String, List<Transaction>> groupedByDate = {};

    for (final transaction in transactions) {
      final dateKey = '${transaction.transactionDate.year}-${transaction.transactionDate.month}-${transaction.transactionDate.day}';
      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(transaction);
    }

    // Generate DailySales for each date
    final dailySales = <DailySales>[];
    for (final entry in groupedByDate.entries) {
      final parts = entry.key.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final dayTransactions = entry.value;
      double dayRevenue = 0;
      double dayProfit = 0;

      for (final transaction in dayTransactions) {
        dayRevenue += transaction.totalAmount;

        // Calculate profit for each item
        for (final item in transaction.items) {
          final product = productMap[item.productId];
          if (product != null) {
            final itemRevenue = item.unitPrice * item.quantity;
            final itemCost = product.costPrice * item.quantity;
            dayProfit += (itemRevenue - itemCost);
          }
        }
      }

      dailySales.add(DailySales(
        date: date,
        transactionCount: dayTransactions.length,
        revenue: dayRevenue,
        profit: dayProfit,
      ));
    }

    // Sort by date (newest first for the report)
    dailySales.sort((a, b) => b.date.compareTo(a.date));
    return dailySales;
  }

  /// Generate top products from transaction items
  List<ProductSales> _generateTopProducts(
    List<Transaction> transactions,
    Map<int, Product> productMap,
  ) {
    final Map<int, ProductSalesData> productSalesMap = {};

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        if (!productSalesMap.containsKey(item.productId)) {
          productSalesMap[item.productId] = ProductSalesData(
            productId: item.productId,
            productName: item.productName,
            quantitySold: 0,
            revenue: 0,
            profit: 0,
          );
        }

        final data = productSalesMap[item.productId]!;
        data.quantitySold += item.quantity;
        data.revenue += item.subtotal;

        // Calculate profit for this item
        final product = productMap[item.productId];
        if (product != null) {
          final itemCost = product.costPrice * item.quantity;
          data.profit += (item.subtotal - itemCost);
        }
      }
    }

    // Convert to ProductSales and sort by quantity sold
    final productSalesList = productSalesMap.values
        .map((data) => ProductSales(
              productId: data.productId,
              productName: data.productName,
              quantitySold: data.quantitySold,
              revenue: data.revenue,
              profit: data.profit,
            ))
        .toList();

    // Sort by quantity sold (descending) and take top 10
    productSalesList.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    return productSalesList.take(10).toList();
  }

  /// Generate payment method breakdown
  List<PaymentMethodBreakdown> _generatePaymentBreakdown(
    List<Transaction> transactions,
    double totalRevenue,
  ) {
    final Map<String, PaymentData> paymentDataMap = {};

    for (final transaction in transactions) {
      final methodName = transaction.paymentMethod.name;
      if (!paymentDataMap.containsKey(methodName)) {
        paymentDataMap[methodName] = PaymentData(
          paymentMethod: transaction.paymentMethod,
          count: 0,
          amount: 0,
        );
      }
      paymentDataMap[methodName]!.count++;
      paymentDataMap[methodName]!.amount += transaction.totalAmount;
    }

    // Convert to PaymentMethodBreakdown
    final breakdown = paymentDataMap.values.map((data) {
      final percentage = totalRevenue > 0
          ? (data.amount / totalRevenue * 100)
          : 0.0;
      return PaymentMethodBreakdown(
        paymentMethod: data.paymentMethod,
        transactionCount: data.count,
        totalAmount: data.amount,
        percentage: percentage,
      );
    }).toList();

    // Sort by amount (descending)
    breakdown.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return breakdown;
  }

  /// Generate category breakdown from transaction items
  List<CategorySales> _generateCategoryBreakdown(
    List<Transaction> transactions,
    Map<int, Product> productMap,
    Map<int, Category> categoryMap,
  ) {
    final Map<int, CategorySalesData> categorySalesMap = {};

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        final product = productMap[item.productId];
        if (product == null || product.categoryId == null) continue;

        final categoryId = product.categoryId!;
        final category = categoryMap[categoryId];
        if (category == null) continue;

        if (!categorySalesMap.containsKey(categoryId)) {
          categorySalesMap[categoryId] = CategorySalesData(
            categoryId: categoryId,
            categoryName: category.name,
            quantitySold: 0,
            revenue: 0,
            profit: 0,
          );
        }

        final data = categorySalesMap[categoryId]!;
        data.quantitySold += item.quantity;
        data.revenue += item.subtotal;

        // Calculate profit for this item
        final itemCost = product.costPrice * item.quantity;
        data.profit += (item.subtotal - itemCost);
      }
    }

    // Convert to CategorySales and sort by revenue
    final categorySalesList = categorySalesMap.values
        .map((data) => CategorySales(
              categoryId: data.categoryId,
              categoryName: data.categoryName,
              quantitySold: data.quantitySold,
              revenue: data.revenue,
              profit: data.profit,
              profitMargin: data.revenue > 0
                  ? (data.profit / data.revenue * 100)
                  : 0.0,
            ))
        .toList();

    // Sort by revenue (descending)
    categorySalesList.sort((a, b) => b.revenue.compareTo(a.revenue));
    return categorySalesList;
  }

  /// Generate period comparison (Month-over-Month or Year-over-Year)
  PeriodComparison? _generatePeriodComparison(
    List<Transaction> allTransactions,
    DateTime currentStart,
    DateTime currentEnd,
    double currentRevenue,
    double currentProfit,
    int currentTransactionCount,
    Map<int, Product> productMapParam, {
    required bool isMonthOverMonth,
  }) {
    // Calculate previous period dates
    final periodDuration = currentEnd.difference(currentStart);
    DateTime previousStart;
    DateTime previousEnd;

    if (isMonthOverMonth) {
      // Previous month (same period last month)
      previousStart = DateTime(
        currentStart.year,
        currentStart.month - 1,
        currentStart.day,
      );
      // Add days to match current period length
      previousEnd = previousStart.add(periodDuration);
    } else {
      // Previous year (same period last year)
      previousStart = DateTime(
        currentStart.year - 1,
        currentStart.month,
        currentStart.day,
      );
      previousEnd = DateTime(
        currentStart.year - 1,
        currentEnd.month,
        currentEnd.day,
        23, 59, 59,
      );
    }

    // Filter transactions for previous period (completed only)
    final previousTransactions = allTransactions.where((t) {
      final date = t.transactionDate;
      final start = DateTime(previousStart.year, previousStart.month, previousStart.day);
      final end = DateTime(previousEnd.year, previousEnd.month, previousEnd.day, 23, 59, 59);
      return t.paymentStatus == PaymentStatus.completed &&
          date.isAfter(start) &&
          date.isBefore(end);
    }).toList();

    if (previousTransactions.isEmpty) {
      return null;
    }

    // Calculate previous period totals
    double previousRevenue = 0;
    double previousProfit = 0;

    for (final transaction in previousTransactions) {
      previousRevenue += transaction.totalAmount;
      for (final item in transaction.items) {
        final product = productMapParam[item.productId];
        if (product != null) {
          final itemCost = product.costPrice * item.quantity;
          previousProfit += (item.subtotal - itemCost);
        }
      }
    }

    final previousTransactionCount = previousTransactions.length;

    // Calculate percentage changes
    final revenueChange = previousRevenue > 0
        ? ((currentRevenue - previousRevenue) / previousRevenue * 100)
        : (currentRevenue > 0 ? 100.0 : 0.0);

    final transactionChange = previousTransactionCount > 0
        ? ((currentTransactionCount - previousTransactionCount) / previousTransactionCount * 100)
        : (currentTransactionCount > 0 ? 100.0 : 0.0);

    final profitChange = previousProfit > 0
        ? ((currentProfit - previousProfit) / previousProfit * 100)
        : (currentProfit > 0 ? 100.0 : 0.0);

    return PeriodComparison(
      revenueChange: revenueChange,
      transactionChange: transactionChange,
      profitChange: profitChange,
      previousRevenue: previousRevenue,
      previousTransactions: previousTransactionCount.toDouble(),
      previousProfit: previousProfit,
    );
  }

  /// Generate peak hours analysis from transactions
  List<PeakHourData> _generatePeakHours(List<Transaction> transactions) {
    final Map<int, PeakHourData> hourlyMap = {};

    for (final transaction in transactions) {
      final hour = transaction.transactionDate.hour;

      if (!hourlyMap.containsKey(hour)) {
        hourlyMap[hour] = PeakHourData(
          hour: hour,
          transactionCount: 0,
          revenue: 0,
          averageTransactionValue: 0,
        );
      }

      final data = hourlyMap[hour]!;
      hourlyMap[hour] = PeakHourData(
        hour: hour,
        transactionCount: data.transactionCount + 1,
        revenue: data.revenue + transaction.totalAmount,
        averageTransactionValue: 0, // Will calculate after
      );
    }

    // Calculate average transaction value for each hour
    final peakHours = hourlyMap.values.map((data) {
      return PeakHourData(
        hour: data.hour,
        transactionCount: data.transactionCount,
        revenue: data.revenue,
        averageTransactionValue: data.transactionCount > 0
            ? data.revenue / data.transactionCount
            : 0,
      );
    }).toList();

    // Sort by transaction count (descending) and take top hours
    peakHours.sort((a, b) => b.transactionCount.compareTo(a.transactionCount));

    // Return top 12 hours or all if less
    return peakHours.take(12).toList();
  }
}

/// Internal data class for product sales aggregation
class ProductSalesData {
  final int productId;
  final String productName;
  int quantitySold;
  double revenue;
  double profit;

  ProductSalesData({
    required this.productId,
    required this.productName,
    this.quantitySold = 0,
    this.revenue = 0,
    this.profit = 0,
  });
}

/// Internal data class for payment aggregation
class PaymentData {
  final PaymentMethod paymentMethod;
  int count;
  double amount;

  PaymentData({
    required this.paymentMethod,
    this.count = 0,
    this.amount = 0,
  });
}

/// Internal data class for category sales aggregation
class CategorySalesData {
  final int categoryId;
  final String categoryName;
  int quantitySold;
  double revenue;
  double profit;

  CategorySalesData({
    required this.categoryId,
    required this.categoryName,
    this.quantitySold = 0,
    this.revenue = 0,
    this.profit = 0,
  });
}
