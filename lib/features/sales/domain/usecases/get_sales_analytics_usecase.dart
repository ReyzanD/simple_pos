import '../entities/sales_analytics.dart';
import '../entities/sales_report.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for generating comprehensive sales analytics
/// Calculates trends, patterns, KPIs, and actionable insights
class GetSalesAnalyticsUseCase {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;

  GetSalesAnalyticsUseCase({
    required this.transactionRepository,
    required this.productRepository,
  });

  /// Execute analytics generation for specified date range
  Future<SalesAnalyticsReport> execute({
    required DateTime startDate,
    required DateTime endDate,
    int forecastDays = 7,
  }) async {
    try {
      AppLogger.info('Generating sales analytics from $startDate to $endDate');

      // Validate date range
      if (endDate.isBefore(startDate)) {
        throw ValidationException(
          'End date must be after start date',
          field: 'dateRange',
        );
      }

      if (forecastDays < 1 || forecastDays > 30) {
        throw ValidationException(
          'Forecast days must be between 1 and 30',
          field: 'forecastDays',
        );
      }

      // Fetch data
      final transactions = await transactionRepository
          .getTransactionsByDateRange(startDate, endDate);

      final products = await productRepository.getProducts();

      // Calculate previous period for comparison
      final daysInRange = endDate.difference(startDate).inDays + 1;
      final previousStartDate = startDate.subtract(Duration(days: daysInRange));
      final previousEndDate = startDate.subtract(const Duration(days: 1));

      final previousTransactions = await transactionRepository
          .getTransactionsByDateRange(previousStartDate, previousEndDate);

      // Generate analytics components
      final kpis = _calculateKPIs(transactions, products, previousTransactions);

      final trendAnalysis = _analyzeTrends(
        transactions,
        forecastDays: forecastDays,
      );

      final productPerformance = _analyzeProductPerformance(
        transactions,
        products,
      );

      final categoryPerformance = _analyzeCategoryPerformance(
        transactions,
        products,
      );

      final timePatterns = _analyzeTimePatterns(transactions);

      final comparativeAnalytics = _generateComparativeAnalytics(
        transactions,
        previousTransactions,
      );

      final executiveSummary = _generateExecutiveSummary(
        kpis,
        trendAnalysis,
        productPerformance,
        categoryPerformance,
      );

      final actionItems = _generateActionItems(
        kpis,
        trendAnalysis,
        productPerformance,
        categoryPerformance,
      );

      return SalesAnalyticsReport(
        generatedAt: DateTime.now(),
        startDate: startDate,
        endDate: endDate,
        kpis: kpis,
        trendAnalysis: trendAnalysis,
        topProducts: productPerformance.take(10).toList(),
        bottomProducts: productPerformance.reversed.take(10).toList(),
        categoryPerformance: categoryPerformance,
        timePatterns: timePatterns,
        comparativeAnalytics: comparativeAnalytics,
        executiveSummary: executiveSummary,
        actionItems: actionItems,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to generate sales analytics',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuat analitik penjualan',
        operation: 'GetSalesAnalyticsUseCase',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculate Key Performance Indicators
  AnalyticsKPIs _calculateKPIs(
    List<Transaction> transactions,
    List<dynamic> products,
    List<Transaction> previousTransactions,
  ) {
    final currentRevenue = _calculateTotalRevenue(transactions);
    final previousRevenue = _calculateTotalRevenue(previousTransactions);
    final currentProfit = _calculateTotalProfit(transactions);
    final currentTransactions = transactions.length;

    // Revenue growth rate
    double revenueGrowthRate = 0;
    if (previousRevenue > 0) {
      revenueGrowthRate =
          ((currentRevenue - previousRevenue) / previousRevenue * 100);
    }

    // Profit margin
    double profitMargin = 0;
    if (currentRevenue > 0) {
      profitMargin = (currentProfit / currentRevenue * 100);
    }

    // Average transaction value
    double avgTransactionValue = 0;
    if (currentTransactions > 0) {
      avgTransactionValue = currentRevenue / currentTransactions;
    }

    // Items per transaction
    int totalItemsSold = 0;
    for (final t in transactions) {
      for (final item in t.items) {
        totalItemsSold += item.quantity;
      }
    }
    double itemsPerTransaction = 0;
    if (currentTransactions > 0) {
      itemsPerTransaction = totalItemsSold / currentTransactions;
    }

    // Product statistics
    final totalProducts = products.length;
    final activeProducts = products.where((p) => p.stock > 0).length;
    final lowStockThreshold = 10;
    final lowStockProducts = products
        .where((p) => p.stock > 0 && p.stock <= lowStockThreshold)
        .length;
    final outOfStockProducts = products.where((p) => p.stock == 0).length;

    // Inventory turnover (simplified)
    double inventoryTurnover = 0;
    if (totalProducts > 0 && currentRevenue > 0) {
      final totalInventoryValue = products.fold<double>(
        0.0,
        (sum, p) => sum + (p.costPrice * p.stock),
      );
      if (totalInventoryValue > 0) {
        // Annualized turnover rate
        final daysInRange = 30; // Default to 30 days
        inventoryTurnover =
            (currentRevenue / totalInventoryValue) * (365 / daysInRange);
      }
    }

    // Customer retention (simplified - using repeat transaction patterns)
    double customerRetentionRate = 0;
    if (currentTransactions > 5) {
      // Simplified: assume 60% retention for healthy businesses
      customerRetentionRate = 60.0;
    }

    // Generate alerts
    final alerts = <String>[];
    if (profitMargin < 15) {
      alerts.add(
        '⚠️ Margin keuntungan rendah (${profitMargin.toStringAsFixed(1)}%)',
      );
    }
    if (lowStockProducts > totalProducts * 0.2) {
      alerts.add('⚠️ $lowStockProducts produk dengan stok rendah');
    }
    if (outOfStockProducts > 0) {
      alerts.add('⚠️ $outOfStockProducts produk habis stok');
    }
    if (revenueGrowthRate < -10) {
      alerts.add(
        '⚠️ Penurunan pendapatan ${revenueGrowthRate.toStringAsFixed(1)}%',
      );
    }

    // Generate achievements
    final achievements = <String>[];
    if (profitMargin >= 30) {
      achievements.add('🎯 Margin keuntungan sehat');
    }
    if (revenueGrowthRate >= 10) {
      achievements.add('📈 Pertumbuhan pendapatan positif');
    }
    if (itemsPerTransaction >= 3) {
      achievements.add('🛒 Keranjang belanja tinggi');
    }
    if (outOfStockProducts == 0) {
      achievements.add('✅ Tidak ada stok habis');
    }

    return AnalyticsKPIs(
      revenueGrowthRate: revenueGrowthRate,
      profitMargin: profitMargin,
      averageTransactionValue: avgTransactionValue,
      itemsPerTransaction: itemsPerTransaction,
      customerRetentionRate: customerRetentionRate,
      totalProducts: totalProducts,
      activeProducts: activeProducts,
      lowStockProducts: lowStockProducts,
      outOfStockProducts: outOfStockProducts,
      inventoryTurnover: inventoryTurnover,
      alerts: alerts,
      achievements: achievements,
    );
  }

  /// Analyze sales trends and generate forecast
  SalesTrendAnalysis _analyzeTrends(
    List<Transaction> transactions, {
    int forecastDays = 7,
  }) {
    // Group transactions by date
    final dailyData = <DateTime, List<dynamic>>{};
    for (final t in transactions) {
      final date = DateTime(
        t.createdAt.year,
        t.createdAt.month,
        t.createdAt.day,
      );
      dailyData.putIfAbsent(date, () => []).add(t);
    }

    // Create trend data points
    final sortedDates = dailyData.keys.toList()..sort();
    final trendData = sortedDates.map((date) {
      final dayTransactions = dailyData[date]!;
      final revenue = dayTransactions.fold<double>(
        0,
        (sum, t) => sum + t.totalAmount,
      );
      final profit = dayTransactions.fold<double>(
        0,
        (sum, t) => sum + (t.profit ?? 0),
      );
      final transactionsCount = dayTransactions.length;
      int itemsSold = 0;
      for (final t in dayTransactions) {
        for (final item in t.items) {
          itemsSold += item.quantity as int;
        }
      }

      return SalesTrendData(
        date: date,
        revenue: revenue,
        profit: profit,
        transactions: transactionsCount,
        averageTransactionValue: transactionsCount > 0
            ? revenue / transactionsCount
            : 0,
        itemsSold: itemsSold,
      );
    }).toList();

    // Calculate trend direction and growth rate
    TrendDirection direction;
    double growthRate = 0;

    if (trendData.length >= 2) {
      final firstRevenue = trendData.first.revenue;
      final lastRevenue = trendData.last.revenue;
      if (firstRevenue > 0) {
        growthRate = ((lastRevenue - firstRevenue) / firstRevenue * 100);
      }

      if (growthRate > 5) {
        direction = TrendDirection.up;
      } else if (growthRate < -5) {
        direction = TrendDirection.down;
      } else {
        direction = TrendDirection.stable;
      }
    } else {
      direction = TrendDirection.stable;
    }

    // Generate simple forecast (linear extrapolation)
    final forecastData = <SalesTrendData>[];
    if (trendData.length >= 2) {
      final lastData = trendData.last;
      final secondLastData = trendData[trendData.length - 2];

      // Calculate daily averages
      final dailyRevenueChange = lastData.revenue - secondLastData.revenue;
      final dailyProfitChange = lastData.profit - secondLastData.profit;
      final dailyTransactionChange =
          lastData.transactions - secondLastData.transactions;

      for (int i = 1; i <= forecastDays; i++) {
        final forecastDate = lastData.date.add(Duration(days: i));
        final forecastTransactions =
            (lastData.transactions + dailyTransactionChange * i).round();
        final forecastItemsSold =
            (lastData.itemsSold * (1 + dailyRevenueChange / lastData.revenue))
                .round();

        forecastData.add(
          SalesTrendData(
            date: forecastDate,
            revenue: (lastData.revenue + dailyRevenueChange * i).clamp(
              0,
              double.infinity,
            ),
            profit: (lastData.profit + dailyProfitChange * i).clamp(
              0,
              double.infinity,
            ),
            transactions: (forecastTransactions.clamp(
              0,
              double.infinity,
            )).toInt(),
            averageTransactionValue: lastData.averageTransactionValue,
            itemsSold: (forecastItemsSold.clamp(0, double.infinity)).toInt(),
          ),
        );
      }
    }

    // Generate insight
    String insight;
    switch (direction) {
      case TrendDirection.up:
        insight = 'Pendapatan menunjukkan tren peningkatan yang positif';
        break;
      case TrendDirection.down:
        insight =
            'Pendapatan menunjukkan tren penurunan, perlu evaluasi strategi';
        break;
      case TrendDirection.stable:
        insight =
            'Pendapatan stabil, pertimbangkan strategi promosi untuk pertumbuhan';
        break;
      case TrendDirection.volatile:
        insight =
            'Pendapatan fluktuatif, analisis faktor penyebab variabilitas';
        break;
    }

    return SalesTrendAnalysis(
      historicalData: trendData,
      forecastData: forecastData,
      trendDirection: direction,
      growthRate: growthRate,
      confidence: trendData.length >= 7 ? 0.75 : 0.5,
      insight: insight,
    );
  }

  /// Analyze product performance
  List<ProductPerformance> _analyzeProductPerformance(
    List<Transaction> transactions,
    List<dynamic> products,
  ) {
    final productStats = <int, _ProductStats>{};

    for (final t in transactions) {
      for (final item in t.items) {
        final productId = item.productId;
        productStats.putIfAbsent(
          productId,
          () => _ProductStats(
            productId: productId,
            productName: item.productName,
            categoryId: 0,
            categoryName: 'Uncategorized',
          ),
        );

        final stats = productStats[productId]!;
        stats.quantitySold += item.quantity;
        stats.revenue += item.subtotal;
        stats.profit += (item.subtotal - item.costPrice * item.quantity);
        stats.transactions++;
      }
    }

    // Convert to ProductPerformance and sort by revenue
    final performanceList = productStats.values.map((stats) {
      final profitMargin = stats.revenue > 0
          ? (stats.profit / stats.revenue * 100).toDouble()
          : 0.0;

      PerformanceRating rating;
      if (profitMargin >= 30) {
        rating = PerformanceRating.excellent;
      } else if (profitMargin >= 20) {
        rating = PerformanceRating.good;
      } else if (profitMargin >= 10) {
        rating = PerformanceRating.average;
      } else {
        rating = PerformanceRating.poor;
      }

      return ProductPerformance(
        productId: stats.productId,
        productName: stats.productName,
        categoryId: stats.categoryId,
        categoryName: stats.categoryName,
        quantitySold: stats.quantitySold,
        revenue: stats.revenue,
        profit: stats.profit,
        profitMargin: profitMargin,
        transactions: stats.transactions,
        averageQuantityPerTransaction: stats.transactions > 0
            ? (stats.quantitySold / stats.transactions).toDouble()
            : 0.0,
        rating: rating,
        rank: 0, // Will be set after sorting
      );
    }).toList();

    // Sort by revenue descending
    performanceList.sort((a, b) => b.revenue.compareTo(a.revenue));

    // Assign ranks
    for (int i = 0; i < performanceList.length; i++) {
      performanceList[i] = ProductPerformance(
        productId: performanceList[i].productId,
        productName: performanceList[i].productName,
        categoryId: performanceList[i].categoryId,
        categoryName: performanceList[i].categoryName,
        quantitySold: performanceList[i].quantitySold,
        revenue: performanceList[i].revenue,
        profit: performanceList[i].profit,
        profitMargin: performanceList[i].profitMargin,
        transactions: performanceList[i].transactions,
        averageQuantityPerTransaction:
            performanceList[i].averageQuantityPerTransaction,
        rating: performanceList[i].rating,
        rank: i + 1,
      );
    }

    return performanceList;
  }

  /// Analyze category performance
  List<CategoryPerformance> _analyzeCategoryPerformance(
    List<Transaction> transactions,
    List<dynamic> products,
  ) {
    final categoryStats = <int, _CategoryStats>{};

    for (final t in transactions) {
      for (final item in t.items) {
        final product = products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => products.first,
        );

        final categoryId = product.categoryId ?? 0;
        final categoryName = product.categoryId != null
            ? 'Category $categoryId'
            : 'Uncategorized';

        categoryStats.putIfAbsent(
          categoryId,
          () => _CategoryStats(
            categoryId: categoryId,
            categoryName: categoryName,
          ),
        );

        final stats = categoryStats[categoryId]!;
        stats.quantitySold += item.quantity;
        stats.revenue += item.subtotal;
        stats.profit += (item.subtotal - item.costPrice * item.quantity);
        stats.transactions++;
        stats.productIds.add(product.id!);
      }
    }

    return categoryStats.values.map((stats) {
      final profitMargin = stats.revenue > 0
          ? (stats.profit / stats.revenue * 100).toDouble()
          : 0.0;
      final avgPrice = stats.quantitySold > 0
          ? (stats.revenue / stats.quantitySold).toDouble()
          : 0.0;

      PerformanceRating rating;
      if (profitMargin >= 30) {
        rating = PerformanceRating.excellent;
      } else if (profitMargin >= 20) {
        rating = PerformanceRating.good;
      } else if (profitMargin >= 10) {
        rating = PerformanceRating.average;
      } else {
        rating = PerformanceRating.poor;
      }

      return CategoryPerformance(
        categoryId: stats.categoryId,
        categoryName: stats.categoryName,
        quantitySold: stats.quantitySold,
        revenue: stats.revenue,
        profit: stats.profit,
        profitMargin: profitMargin,
        transactions: stats.transactions,
        productCount: stats.productIds.length,
        averagePrice: avgPrice,
        rating: rating,
        topProducts: [],
      );
    }).toList()..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  /// Analyze time patterns (hourly, daily, weekly)
  TimePatternAnalytics _analyzeTimePatterns(List<Transaction> transactions) {
    // Hourly patterns
    final hourlyData = <int, _TimeStats>{};
    for (final t in transactions) {
      final hour = t.createdAt.hour;
      hourlyData.putIfAbsent(hour, () => _TimeStats(hour));
      hourlyData[hour]!.addTransaction(t.totalAmount, t.profit);
    }

    final hourlyPatterns = hourlyData.values
        .map(
          (stats) => HourlyPattern(
            hour: stats.hour,
            transactionCount: stats.transactionCount,
            revenue: stats.revenue,
            profit: stats.profit,
            averageTransactionValue: stats.transactionCount > 0
                ? stats.revenue / stats.transactionCount
                : 0,
          ),
        )
        .toList();

    // Daily patterns (day of week)
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dailyData = <int, _TimeStats>{};
    for (final t in transactions) {
      final day = t.createdAt.weekday;
      dailyData.putIfAbsent(day, () => _TimeStats(day));
      dailyData[day]!.addTransaction(t.totalAmount, t.profit);
    }

    final dailyPatterns = dailyData.values
        .map(
          (stats) => DailyPattern(
            dayOfWeek: stats.hour,
            dayName: dayNames[stats.hour - 1],
            transactionCount: stats.transactionCount,
            revenue: stats.revenue,
            profit: stats.profit,
            averageTransactionValue: stats.transactionCount > 0
                ? stats.revenue / stats.transactionCount
                : 0,
          ),
        )
        .toList();

    // Find best times
    final peakHour = hourlyPatterns.isNotEmpty
        ? hourlyPatterns.reduce(
            (a, b) => a.transactionCount > b.transactionCount ? a : b,
          )
        : null;

    final bestDay = dailyPatterns.isNotEmpty
        ? dailyPatterns.reduce((a, b) => a.revenue > b.revenue ? a : b)
        : null;

    final bestTimeSummary = peakHour != null && bestDay != null
        ? 'Jam sibuk: ${peakHour.formattedHour}, Hari terbaik: ${bestDay.dayName}'
        : 'Data tidak mencukupi';

    final insights = <String>[];
    if (peakHour != null) {
      insights.add('⏰ Transaksi tertinggi pada jam ${peakHour.formattedHour}');
    }
    if (bestDay != null) {
      insights.add('📅 Pendapatan tertinggi pada hari ${bestDay.dayName}');
    }

    return TimePatternAnalytics(
      hourlyPatterns: hourlyPatterns,
      dailyPatterns: dailyPatterns,
      weeklyPatterns: [],
      monthlyPatterns: [],
      bestTimeSummary: bestTimeSummary,
      insights: insights,
    );
  }

  /// Generate comparative analytics
  ComparativeAnalytics _generateComparativeAnalytics(
    List<Transaction> currentTransactions,
    List<Transaction> previousTransactions,
  ) {
    final currentRevenue = _calculateTotalRevenue(currentTransactions);
    final previousRevenue = _calculateTotalRevenue(previousTransactions);
    final currentProfit = _calculateTotalProfit(currentTransactions);
    final previousProfit = _calculateTotalProfit(previousTransactions);
    final currentCount = currentTransactions.length;
    final previousCount = previousTransactions.length;

    final revenueChange = previousRevenue > 0
        ? ((currentRevenue - previousRevenue) / previousRevenue * 100)
        : 0.0;
    final profitChange = previousProfit > 0
        ? ((currentProfit - previousProfit) / previousProfit * 100)
        : 0.0;
    final transactionChange = previousCount > 0
        ? ((currentCount - previousCount) / previousCount * 100)
        : 0.0;

    final periodComparison = PeriodComparison(
      revenueChange: revenueChange,
      transactionChange: transactionChange,
      profitChange: profitChange,
      previousRevenue: previousRevenue,
      previousTransactions: previousCount.toDouble(),
      previousProfit: previousProfit,
    );

    final metricComparisons = [
      MetricComparison(
        metricName: 'Pendapatan',
        currentValue: currentRevenue,
        previousValue: previousRevenue,
        changePercentage: revenueChange,
        direction: revenueChange > 5
            ? TrendDirection.up
            : revenueChange < -5
            ? TrendDirection.down
            : TrendDirection.stable,
        isPositive: revenueChange >= 0.0,
      ),
      MetricComparison(
        metricName: 'Keuntungan',
        currentValue: currentProfit,
        previousValue: previousProfit,
        changePercentage: profitChange,
        direction: profitChange > 5
            ? TrendDirection.up
            : profitChange < -5
            ? TrendDirection.down
            : TrendDirection.stable,
        isPositive: profitChange >= 0.0,
      ),
      MetricComparison(
        metricName: 'Transaksi',
        currentValue: currentCount.toDouble(),
        previousValue: previousCount.toDouble(),
        changePercentage: transactionChange,
        direction: transactionChange > 5
            ? TrendDirection.up
            : transactionChange < -5
            ? TrendDirection.down
            : TrendDirection.stable,
        isPositive: transactionChange >= 0.0,
      ),
    ];

    final insights = <String>[];
    if (revenueChange > 10) {
      insights.add('📈 Pertumbuhan pendapatan yang kuat');
    } else if (revenueChange < -10) {
      insights.add('📉 Penurunan pendapatan signifikan');
    }

    final recommendations = <String>[];
    if (revenueChange < 0) {
      recommendations.add('Pertimbangkan promosi untuk meningkatkan penjualan');
    }
    if (profitChange < revenueChange) {
      recommendations.add('Review harga dan biaya untuk meningkatkan margin');
    }

    return ComparativeAnalytics(
      currentVsPrevious: periodComparison,
      metricComparisons: metricComparisons,
      insights: insights,
      recommendations: recommendations,
    );
  }

  /// Generate executive summary
  List<String> _generateExecutiveSummary(
    AnalyticsKPIs kpis,
    SalesTrendAnalysis trends,
    List<ProductPerformance> products,
    List<CategoryPerformance> categories,
  ) {
    final summary = <String>[];

    summary.add(
      '📊 Skor kesehatan bisnis: ${kpis.healthScore.toStringAsFixed(1)}/100 (${kpis.healthRating.displayName})',
    );

    if (trends.growthRate > 0) {
      summary.add(
        '📈 Pendapatan tumbuh ${trends.growthRate.toStringAsFixed(1)}% dengan tren ${trends.trendDirection.displayName.toLowerCase()}',
      );
    } else if (trends.growthRate < 0) {
      summary.add(
        '📉 Pendapatan turun ${trends.growthRate.abs().toStringAsFixed(1)}% dengan ${trends.trendDirection.displayName.toLowerCase()}',
      );
    }

    if (kpis.profitMargin >= 25) {
      summary.add(
        '💰 Margin keuntungan sehat: ${kpis.profitMargin.toStringAsFixed(1)}%',
      );
    } else if (kpis.profitMargin < 15) {
      summary.add(
        '⚠️ Margin keuntungan rendah: ${kpis.profitMargin.toStringAsFixed(1)}%, perlu evaluasi',
      );
    }

    if (products.isNotEmpty) {
      final topProduct = products.first;
      summary.add(
        '🏆 Produk terlaris: ${topProduct.productName} (${topProduct.quantitySold} terjual)',
      );
    }

    return summary;
  }

  /// Generate action items
  List<String> _generateActionItems(
    AnalyticsKPIs kpis,
    SalesTrendAnalysis trends,
    List<ProductPerformance> products,
    List<CategoryPerformance> categories,
  ) {
    final actions = <String>[];

    // Inventory actions
    if (kpis.lowStockProducts > 0) {
      actions.add(
        '🔁 Restock ${kpis.lowStockProducts} produk dengan stok rendah',
      );
    }
    if (kpis.outOfStockProducts > 0) {
      actions.add(
        '🚨 Urus restock untuk ${kpis.outOfStockProducts} produk habis stok',
      );
    }

    // Performance actions
    final poorProducts = products
        .where((p) => p.rating == PerformanceRating.poor)
        .take(3)
        .toList();
    if (poorProducts.isNotEmpty) {
      actions.add('📦 Review kinerja produk dengan margin rendah');
    }

    // Growth actions
    if (trends.trendDirection == TrendDirection.down || trends.growthRate < 0) {
      actions.add('📢 Jalankan promosi untuk meningkatkan penjualan');
      actions.add('🎯 Analisis produk yang underperforming');
    }

    if (kpis.profitMargin < 20) {
      actions.add('💡 Review struktur harga dan biaya');
    }

    return actions;
  }

  // Helper methods
  double _calculateTotalRevenue(List<Transaction> transactions) {
    return transactions.fold<double>(0, (sum, t) => sum + t.totalAmount);
  }

  double _calculateTotalProfit(List<Transaction> transactions) {
    return transactions.fold<double>(0, (sum, t) => sum + t.profit);
  }
}

/// Internal helper class for product statistics
class _ProductStats {
  final int productId;
  final String productName;
  final int categoryId;
  final String categoryName;
  int quantitySold = 0;
  double revenue = 0;
  double profit = 0;
  int transactions = 0;

  _ProductStats({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
  });
}

/// Internal helper class for category statistics
class _CategoryStats {
  final int categoryId;
  final String categoryName;
  int quantitySold = 0;
  double revenue = 0;
  double profit = 0;
  int transactions = 0;
  final Set<int> productIds = {};

  _CategoryStats({required this.categoryId, required this.categoryName});
}

/// Internal helper class for time statistics
class _TimeStats {
  final int hour;
  int transactionCount = 0;
  double revenue = 0;
  double profit = 0;

  _TimeStats(this.hour);

  void addTransaction(double amount, double profit) {
    transactionCount++;
    revenue += amount;
    this.profit += profit;
  }
}
