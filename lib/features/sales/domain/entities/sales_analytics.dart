import 'package:flutter/material.dart';
import 'sales_report.dart';

/// Sales trend data point for time-series analysis
class SalesTrendData {
  final DateTime date;
  final double revenue;
  final double profit;
  final int transactions;
  final double averageTransactionValue;
  final int itemsSold;

  const SalesTrendData({
    required this.date,
    required this.revenue,
    required this.profit,
    required this.transactions,
    required this.averageTransactionValue,
    required this.itemsSold,
  });

  /// Calculate profit margin for this data point
  double get profitMargin {
    if (revenue == 0) return 0;
    return (profit / revenue * 100);
  }

  @override
  String toString() =>
      'SalesTrendData(date: $date, revenue: $revenue, transactions: $transactions)';
}

/// Sales trend analysis with forecasting
class SalesTrendAnalysis {
  final List<SalesTrendData> historicalData;
  final List<SalesTrendData> forecastData;
  final TrendDirection trendDirection;
  final double growthRate;
  final double confidence;
  final String insight;

  const SalesTrendAnalysis({
    required this.historicalData,
    required this.forecastData,
    required this.trendDirection,
    required this.growthRate,
    required this.confidence,
    required this.insight,
  });

  /// Get the latest actual data point
  SalesTrendData? get latestData =>
      historicalData.isNotEmpty ? historicalData.last : null;

  /// Get the last forecast data point
  SalesTrendData? get lastForecast =>
      forecastData.isNotEmpty ? forecastData.last : null;

  @override
  String toString() =>
      'SalesTrendAnalysis(trend: $trendDirection, growth: $growthRate%)';
}

/// Product performance analytics
class ProductPerformance {
  final int productId;
  final String productName;
  final int categoryId;
  final String categoryName;
  final int quantitySold;
  final double revenue;
  final double profit;
  final double profitMargin;
  final int transactions;
  final double averageQuantityPerTransaction;
  final PerformanceRating rating;
  final int rank;

  const ProductPerformance({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
    required this.profitMargin,
    required this.transactions,
    required this.averageQuantityPerTransaction,
    required this.rating,
    required this.rank,
  });

  /// Get contribution percentage to total revenue
  double calculateContribution(double totalRevenue) {
    if (totalRevenue == 0) return 0;
    return (revenue / totalRevenue * 100);
  }

  @override
  String toString() =>
      'ProductPerformance(product: $productName, rank: $rank, revenue: $revenue)';
}

/// Category performance analytics
class CategoryPerformance {
  final int categoryId;
  final String categoryName;
  final int quantitySold;
  final double revenue;
  final double profit;
  final double profitMargin;
  final int transactions;
  final int productCount;
  final double averagePrice;
  final PerformanceRating rating;
  final List<ProductPerformance> topProducts;

  const CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
    required this.profitMargin,
    required this.transactions,
    required this.productCount,
    required this.averagePrice,
    required this.rating,
    required this.topProducts,
  });

  /// Get contribution percentage to total revenue
  double calculateContribution(double totalRevenue) {
    if (totalRevenue == 0) return 0;
    return (revenue / totalRevenue * 100);
  }

  @override
  String toString() =>
      'CategoryPerformance(category: $categoryName, revenue: $revenue, products: $productCount)';
}

/// Time-based analytics (hourly, daily, weekly patterns)
class TimePatternAnalytics {
  final List<HourlyPattern> hourlyPatterns;
  final List<DailyPattern> dailyPatterns;
  final List<WeeklyPattern> weeklyPatterns;
  final List<MonthlyPattern> monthlyPatterns;
  final String bestTimeSummary;
  final List<String> insights;

  const TimePatternAnalytics({
    required this.hourlyPatterns,
    required this.dailyPatterns,
    required this.weeklyPatterns,
    required this.monthlyPatterns,
    required this.bestTimeSummary,
    required this.insights,
  });

  /// Get peak hour (most transactions)
  HourlyPattern? get peakHour {
    if (hourlyPatterns.isEmpty) return null;
    hourlyPatterns.sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
    return hourlyPatterns.first;
  }

  /// Get best day of week (most revenue)
  DailyPattern? get bestDayOfWeek {
    if (dailyPatterns.isEmpty) return null;
    dailyPatterns.sort((a, b) => b.revenue.compareTo(a.revenue));
    return dailyPatterns.first;
  }

  @override
  String toString() =>
      'TimePatternAnalytics(peakHour: ${peakHour?.hour}, bestDay: ${bestDayOfWeek?.dayName})';
}

/// Hourly sales pattern
class HourlyPattern {
  final int hour; // 0-23
  final int transactionCount;
  final double revenue;
  final double profit;
  final double averageTransactionValue;

  const HourlyPattern({
    required this.hour,
    required this.transactionCount,
    required this.revenue,
    required this.profit,
    required this.averageTransactionValue,
  });

  String get formattedHour => '${hour.toString().padLeft(2, '0')}:00';

  @override
  String toString() => 'HourlyPattern(hour: $formattedHour, transactions: $transactionCount)';
}

/// Daily sales pattern (day of week)
class DailyPattern {
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final String dayName;
  final int transactionCount;
  final double revenue;
  final double profit;
  final double averageTransactionValue;

  const DailyPattern({
    required this.dayOfWeek,
    required this.dayName,
    required this.transactionCount,
    required this.revenue,
    required this.profit,
    required this.averageTransactionValue,
  });

  @override
  String toString() => 'DailyPattern(day: $dayName, revenue: $revenue)';
}

/// Weekly sales pattern
class WeeklyPattern {
  final int weekNumber;
  final int year;
  final int transactionCount;
  final double revenue;
  final double profit;

  const WeeklyPattern({
    required this.weekNumber,
    required this.year,
    required this.transactionCount,
    required this.revenue,
    required this.profit,
  });

  @override
  String toString() => 'WeeklyPattern(week: $weekNumber, revenue: $revenue)';
}

/// Monthly sales pattern
class MonthlyPattern {
  final int month;
  final int year;
  final int transactionCount;
  final double revenue;
  final double profit;
  final double averageTransactionValue;

  const MonthlyPattern({
    required this.month,
    required this.year,
    required this.transactionCount,
    required this.revenue,
    required this.profit,
    required this.averageTransactionValue,
  });

  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  String toString() => 'MonthlyPattern(month: $monthName $year, revenue: $revenue)';
}

/// Comparative analytics (period-over-period)
class ComparativeAnalytics {
  final PeriodComparison currentVsPrevious;
  final List<MetricComparison> metricComparisons;
  final List<String> insights;
  final List<String> recommendations;

  const ComparativeAnalytics({
    required this.currentVsPrevious,
    required this.metricComparisons,
    required this.insights,
    required this.recommendations,
  });

  @override
  String toString() =>
      'ComparativeAnalytics(revenueChange: ${currentVsPrevious.revenueChange}%)';
}

/// Metric comparison between periods
class MetricComparison {
  final String metricName;
  final double currentValue;
  final double previousValue;
  final double changePercentage;
  final TrendDirection direction;
  final bool isPositive;

  const MetricComparison({
    required this.metricName,
    required this.currentValue,
    required this.previousValue,
    required this.changePercentage,
    required this.direction,
    required this.isPositive,
  });

  @override
  String toString() =>
      'MetricComparison($metricName: $currentValue vs $previousValue ($changePercentage%))';
}

/// Key Performance Indicators (KPIs)
class AnalyticsKPIs {
  final double revenueGrowthRate;
  final double profitMargin;
  final double averageTransactionValue;
  final double itemsPerTransaction;
  final double customerRetentionRate; // Returning customers
  final int totalProducts;
  final int activeProducts; // Products with sales
  final int lowStockProducts;
  final int outOfStockProducts;
  final double inventoryTurnover;
  final List<String> alerts;
  final List<String> achievements;

  const AnalyticsKPIs({
    required this.revenueGrowthRate,
    required this.profitMargin,
    required this.averageTransactionValue,
    required this.itemsPerTransaction,
    required this.customerRetentionRate,
    required this.totalProducts,
    required this.activeProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.inventoryTurnover,
    required this.alerts,
    required this.achievements,
  });

  /// Get overall health score (0-100)
  double get healthScore {
    double score = 0;

    // Profit margin (0-25 points)
    score += (profitMargin / 100 * 25).clamp(0, 25);

    // Revenue growth (0-25 points)
    if (revenueGrowthRate > 0) {
      score += (revenueGrowthRate / 20 * 25).clamp(0, 25);
    }

    // Inventory health (0-25 points)
    final stockHealth = (totalProducts > 0)
        ? ((totalProducts - lowStockProducts - outOfStockProducts) / totalProducts * 25)
        : 0;
    score += stockHealth;

    // Product activity (0-25 points)
    final productActivity = (totalProducts > 0)
        ? (activeProducts / totalProducts * 25)
        : 0;
    score += productActivity;

    return score;
  }

  /// Get health rating
  HealthRating get healthRating {
    final score = healthScore;
    if (score >= 80) return HealthRating.excellent;
    if (score >= 60) return HealthRating.good;
    if (score >= 40) return HealthRating.fair;
    return HealthRating.poor;
  }

  @override
  String toString() =>
      'AnalyticsKPIs(healthScore: ${healthScore.toStringAsFixed(1)}, healthRating: $healthRating)';
}

/// Comprehensive sales analytics report
class SalesAnalyticsReport {
  final DateTime generatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final AnalyticsKPIs kpis;
  final SalesTrendAnalysis trendAnalysis;
  final List<ProductPerformance> topProducts;
  final List<ProductPerformance> bottomProducts;
  final List<CategoryPerformance> categoryPerformance;
  final TimePatternAnalytics timePatterns;
  final ComparativeAnalytics comparativeAnalytics;
  final List<String> executiveSummary;
  final List<String> actionItems;

  const SalesAnalyticsReport({
    required this.generatedAt,
    required this.startDate,
    required this.endDate,
    required this.kpis,
    required this.trendAnalysis,
    required this.topProducts,
    required this.bottomProducts,
    required this.categoryPerformance,
    required this.timePatterns,
    required this.comparativeAnalytics,
    required this.executiveSummary,
    required this.actionItems,
  });

  @override
  String toString() =>
      'SalesAnalyticsReport(period: $startDate - $endDate, healthScore: ${kpis.healthScore.toStringAsFixed(1)})';
}

/// Trend direction
enum TrendDirection {
  up,
  down,
  stable,
  volatile,
}

/// Performance rating
enum PerformanceRating {
  excellent,
  good,
  average,
  poor,
}

/// Health rating
enum HealthRating {
  excellent,
  good,
  fair,
  poor,
}

/// Extensions for enum display names
extension TrendDirectionExtension on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.up:
        return 'Meningkat';
      case TrendDirection.down:
        return 'Menurun';
      case TrendDirection.stable:
        return 'Stabil';
      case TrendDirection.volatile:
        return 'Fluktuatif';
    }
  }

  IconData get icon {
    switch (this) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
      case TrendDirection.volatile:
        return Icons.show_chart;
    }
  }

  Color get color {
    switch (this) {
      case TrendDirection.up:
        return const Color(0xFF10B981); // Success green
      case TrendDirection.down:
        return const Color(0xFFEF4444); // Error red
      case TrendDirection.stable:
        return const Color(0xFF3B82F6); // Info blue
      case TrendDirection.volatile:
        return const Color(0xFFF59E0B); // Warning amber
    }
  }
}

extension PerformanceRatingExtension on PerformanceRating {
  String get displayName {
    switch (this) {
      case PerformanceRating.excellent:
        return 'Sangat Baik';
      case PerformanceRating.good:
        return 'Baik';
      case PerformanceRating.average:
        return 'Rata-rata';
      case PerformanceRating.poor:
        return 'Buruk';
    }
  }

  Color get color {
    switch (this) {
      case PerformanceRating.excellent:
        return const Color(0xFF10B981); // Success green
      case PerformanceRating.good:
        return const Color(0xFF14B8A6); // Secondary teal
      case PerformanceRating.average:
        return const Color(0xFFF59E0B); // Warning amber
      case PerformanceRating.poor:
        return const Color(0xFFEF4444); // Error red
    }
  }
}

extension HealthRatingExtension on HealthRating {
  String get displayName {
    switch (this) {
      case HealthRating.excellent:
        return 'Sangat Sehat';
      case HealthRating.good:
        return 'Sehat';
      case HealthRating.fair:
        return 'Cukup';
      case HealthRating.poor:
        return 'Perlu Perhatian';
    }
  }

  Color get color {
    switch (this) {
      case HealthRating.excellent:
        return const Color(0xFF10B981); // Success green
      case HealthRating.good:
        return const Color(0xFF14B8A6); // Secondary teal
      case HealthRating.fair:
        return const Color(0xFFF59E0B); // Warning amber
      case HealthRating.poor:
        return const Color(0xFFEF4444); // Error red
    }
  }

  IconData get icon {
    switch (this) {
      case HealthRating.excellent:
        return Icons.sentiment_very_satisfied;
      case HealthRating.good:
        return Icons.sentiment_satisfied;
      case HealthRating.fair:
        return Icons.sentiment_neutral;
      case HealthRating.poor:
        return Icons.sentiment_dissatisfied;
    }
  }
}
