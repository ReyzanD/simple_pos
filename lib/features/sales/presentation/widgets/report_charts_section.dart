/// ReportChartsSection
///
/// **Purpose:** Renders all graphical data including trends and payment breakdowns.
/// **Dependencies:** fl_chart, SalesReportController
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/chart_enums.dart';
import '../../../shared/presentation/providers.dart';

class ReportChartsSection extends StatelessWidget {
  final SalesReport report;

  const ReportChartsSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DailySalesTrend(report: report),
        const SizedBox(height: 24),
        _PaymentMethodsWidget(report: report),
      ],
    );
  }
}

// --- 1. DAILY SALES TREND WIDGET ---

class _DailySalesTrend extends ConsumerWidget {
  final SalesReport report;
  const _DailySalesTrend({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyData = report.dailyBreakdown;
    final controller = ref.watch(salesReportControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tren Penjualan',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildChartTypeSelector(controller),
        const SizedBox(height: 12),
        _buildMetricSelector(controller),
        const SizedBox(height: 16),
        Container(
          height: ResponsiveHelper.getChartHeight(context),
          padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: _buildActualChart(context, controller, dailyData),
        ),
        const SizedBox(height: 16),
        _buildComparisonCards(context, report),
      ],
    );
  }

  Widget _buildActualChart(
    BuildContext context,
    dynamic controller,
    List<DailySales> dailyData,
  ) {
    if (dailyData.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    switch (controller.chartType) {
      case ChartType.line:
        return _LineChart(dailyData: dailyData, metric: controller.chartMetric);
      case ChartType.bar:
        return _BarChart(dailyData: dailyData, metric: controller.chartMetric);
      case ChartType.area:
        return _AreaChart(dailyData: dailyData, metric: controller.chartMetric);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Selectors ---

  Widget _buildChartTypeSelector(dynamic controller) {
    return Wrap(
      spacing: NeoBrutalTheme.spaceSM,
      children: ChartType.values.map((type) {
        final isSelected = controller.chartType == type;
        return _ChoiceChip(
          label: _getChartTypeLabel(type),
          isSelected: isSelected,
          onTap: () => controller.setChartType(type),
          activeColor: NeoBrutalTheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildMetricSelector(dynamic controller) {
    return Wrap(
      spacing: NeoBrutalTheme.spaceSM,
      children: ChartMetric.values.map((metric) {
        final isSelected = controller.chartMetric == metric;
        return _ChoiceChip(
          label: _getMetricLabel(metric),
          isSelected: isSelected,
          onTap: () => controller.setChartMetric(metric),
          activeColor: NeoBrutalTheme.secondary,
        );
      }).toList(),
    );
  }
}

// --- 2. PAYMENT METHODS WIDGET ---

class _PaymentMethodsWidget extends StatelessWidget {
  final SalesReport report;
  const _PaymentMethodsWidget({required this.report});

  @override
  Widget build(BuildContext context) {
    final paymentData = report.paymentBreakdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: ResponsiveHelper.isMobile(context) ? 280 : 220,
          padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 45,
                    sections: _generatePieSections(paymentData),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: paymentData
                      .map((data) => _PaymentLegendItem(data: data))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generatePieSections(
    List<PaymentMethodBreakdown> data,
  ) {
    return data.map((item) {
      return PieChartSectionData(
        value: item.totalAmount,
        title: '',
        color: _getPaymentColor(item.paymentMethod),
        radius: 50,
      );
    }).toList();
  }
}

// --- HELPER PRIVATE COMPONENTS ---

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(color: Colors.black, width: isSelected ? 3 : 2),
          boxShadow: isSelected ? NeoBrutalTheme.chunkyShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PaymentLegendItem extends StatelessWidget {
  final PaymentMethodBreakdown data;
  const _PaymentLegendItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _getPaymentColor(data.paymentMethod);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.paymentMethod.name.toUpperCase(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '${data.percentage.toStringAsFixed(1)}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// --- CORE CHART RENDERING (Line/Bar/Area) ---
// These are extracted versions of your fl_chart configurations

class _LineChart extends StatelessWidget {
  final List<DailySales> dailyData;
  final ChartMetric metric;
  const _LineChart({required this.dailyData, required this.metric});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: _buildTitles(dailyData),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black12),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: dailyData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), _getVal(e.value, metric)))
                .toList(),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<DailySales> dailyData;
  final ChartMetric metric;
  const _BarChart({required this.dailyData, required this.metric});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: _buildTitles(dailyData),
        borderData: FlBorderData(show: false),
        barGroups: dailyData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: _getVal(e.value, metric),
                color: AppTheme.primaryColor,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AreaChart extends StatelessWidget {
  final List<DailySales> dailyData;
  final ChartMetric metric;
  const _AreaChart({required this.dailyData, required this.metric});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: _buildTitles(dailyData),
        lineBarsData: [
          LineChartBarData(
            spots: dailyData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), _getVal(e.value, metric)))
                .toList(),
            isCurved: true,
            color: AppTheme.secondaryColor,
            barWidth: 0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondaryColor.withValues(alpha: 0.5),
                  AppTheme.secondaryColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- LOGIC HELPERS ---

double _getVal(DailySales data, ChartMetric metric) {
  switch (metric) {
    case ChartMetric.revenue:
      return data.revenue;
    case ChartMetric.profit:
      return data.profit;
    case ChartMetric.transactions:
      return data.transactionCount.toDouble();
  }
}

String _getChartTypeLabel(ChartType type) => type == ChartType.line
    ? 'Garis'
    : type == ChartType.bar
    ? 'Batang'
    : 'Area';

String _getMetricLabel(ChartMetric metric) => metric == ChartMetric.revenue
    ? 'Pendapatan'
    : metric == ChartMetric.profit
    ? 'Laba'
    : 'Transaksi';

Color _getPaymentColor(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return AppTheme.successColor;
    case PaymentMethod.card:
      return AppTheme.infoColor;
    case PaymentMethod.qr:
      return AppTheme.primaryColor;
    case PaymentMethod.transfer:
      return AppTheme.warningColor;
  }
}

FlTitlesData _buildTitles(List<DailySales> dailyData) {
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (val, meta) {
          if (val.toInt() >= dailyData.length) return const Text('');
          final date = dailyData[val.toInt()].date;
          return Text(
            '${date.day}/${date.month}',
            style: const TextStyle(fontSize: 10),
          );
        },
      ),
    ),
  );
}

Widget _buildComparisonCards(BuildContext context, SalesReport report) {
  final hasMoM = report.monthOverMonth != null;
  final hasYoY = report.yearOverYear != null;

  if (!hasMoM && !hasYoY) {
    return _buildSimpleComparison(context, report);
  }

  return Column(
    children: [
      if (hasMoM)
        _buildPeriodComparisonCard(
          context,
          title: 'Bulan Sebelumnya',
          comparison: report.monthOverMonth!,
          icon: Icons.calendar_month,
        ),
      if (hasMoM && hasYoY) const SizedBox(height: 12),
      if (hasYoY)
        _buildPeriodComparisonCard(
          context,
          title: 'Tahun Sebelumnya',
          comparison: report.yearOverYear!,
          icon: Icons.calendar_today,
        ),
    ],
  );
}

Widget _buildPeriodComparisonCard(
  BuildContext context, {
  required String title,
  required PeriodComparison comparison,
  required IconData icon,
}) {
  final revenueColor = comparison.isRevenueGrowth
      ? AppTheme.successColor
      : AppTheme.errorColor;
  final profitColor = comparison.isProfitGrowth
      ? AppTheme.successColor
      : AppTheme.errorColor;
  final txnColor = comparison.isTransactionGrowth
      ? AppTheme.successColor
      : AppTheme.errorColor;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.getCardColor(context),
      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
      border: Border.all(color: Colors.black, width: 4),
      boxShadow: NeoBrutalTheme.chunkyShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildComparisonMetric(
                'Pendapatan',
                comparison.revenueChange,
                revenueColor,
                comparison.previousRevenue != null
                    ? _compactCurrency(comparison.previousRevenue!)
                    : null,
                _compactCurrency(
                  comparison.previousRevenue != null
                      ? comparison.previousRevenue! *
                            (1 + comparison.revenueChange / 100)
                      : 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonMetric(
                'Keuntungan',
                comparison.profitChange,
                profitColor,
                comparison.previousProfit != null
                    ? _compactCurrency(comparison.previousProfit!)
                    : null,
                _compactCurrency(
                  comparison.previousProfit != null
                      ? comparison.previousProfit! *
                            (1 + comparison.profitChange / 100)
                      : 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonMetric(
                'Transaksi',
                comparison.transactionChange,
                txnColor,
                comparison.previousTransactions != null
                    ? comparison.previousTransactions!.toInt().toString()
                    : null,
                (comparison.previousTransactions != null
                        ? comparison.previousTransactions! *
                              (1 + comparison.transactionChange / 100)
                        : 0)
                    .toInt()
                    .toString(),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildComparisonMetric(
  String label,
  double change,
  Color color,
  String? previousValue,
  String currentValue,
) {
  final isPositive = change >= 0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        currentValue,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 16,
            color: color,
          ),
          Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
      if (previousValue != null)
        Text(
          'Sebelumnya: $previousValue',
          style: const TextStyle(fontSize: 9, color: AppTheme.textTertiary),
        ),
    ],
  );
}

Widget _buildSimpleComparison(BuildContext context, SalesReport report) {
  final dailyData = report.dailyBreakdown;
  if (dailyData.length < 14) return const SizedBox.shrink();

  final recentTotal = dailyData
      .sublist(0, 7)
      .fold<double>(0, (s, d) => s + d.revenue);
  final prevTotal = dailyData
      .sublist(7, 14)
      .fold<double>(0, (s, d) => s + d.revenue);
  final change = prevTotal > 0
      ? ((recentTotal - prevTotal) / prevTotal * 100)
      : 0.0;
  final isPos = change >= 0;

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: (isPos ? AppTheme.successColor : AppTheme.errorColor).withValues(
        alpha: 0.1,
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isPos ? AppTheme.successColor : AppTheme.errorColor,
        width: 2,
      ),
    ),
    child: Row(
      children: [
        Icon(
          isPos ? Icons.trending_up : Icons.trending_down,
          color: isPos ? AppTheme.successColor : AppTheme.errorColor,
        ),
        const SizedBox(width: 12),
        Text(
          '${isPos ? 'Naik' : 'Turun'} ${change.abs().toStringAsFixed(1)}% dari minggu lalu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPos ? AppTheme.successColor : AppTheme.errorColor,
          ),
        ),
      ],
    ),
  );
}

String _compactCurrency(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}jt';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}rb';
  }
  return value.toStringAsFixed(0);
}
