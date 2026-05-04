/// Chart-related enums for Sales Analytics
/// These enums represent presentation options and are part of domain model
library;

/// Type of chart visualization
enum ChartType { line, bar, area }

/// Metric to display on sales charts
enum ChartMetric { revenue, profit, transactions }

/// Period for chart data grouping
enum ChartPeriod { daily, weekly, monthly }

/// Predefined date range options for analytics
enum DateRangePreset {
  today,
  thisWeek,
  last7Days,
  last30Days,
  last90Days,
  thisMonth,
  lastMonth,
  last3Months,
  thisQuarter,
  thisYear,
  custom,
}

/// Display name extension for ChartMetric
extension ChartMetricExtension on ChartMetric {
  String get displayName {
    switch (this) {
      case ChartMetric.revenue:
        return 'Pendapatan';
      case ChartMetric.profit:
        return 'Keuntungan';
      case ChartMetric.transactions:
        return 'Transaksi';
    }
  }
}
