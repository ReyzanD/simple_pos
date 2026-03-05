import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/payment_method.dart';
import '../controllers/sales_report_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme.dart';
import '../widgets/summary_stat_card.dart';
import '../../../shared/presentation/main_navigation.dart';

/// Screen displaying sales reports with charts
class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesReportController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
                mainNavState?.openDrawer();
              },
            ),
            title: const Text('Laporan Penjualan'),
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () => _selectDateRange(context, controller),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refresh,
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.report == null
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Range
                          _buildDateRangeSelector(context, controller),
                          const SizedBox(height: 24),

                          // Summary Cards
                          _buildSummarySection(context, controller.report!),
                          const SizedBox(height: 24),

                          // Daily Sales Chart
                          _buildDailySalesChart(context, controller.report!),
                          const SizedBox(height: 24),

                          // Payment Methods Chart
                          _buildPaymentMethodsChart(context, controller.report!),
                          const SizedBox(height: 24),

                          // Top Products Table
                          _buildTopProductsTable(context, controller.report!),
                          const SizedBox(height: 24),

                          // Export Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: controller.isExporting
                                  ? null
                                  : () => _exportReport(context, controller),
                              icon: controller.isExporting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(controller.isExporting
                                  ? 'Mengekspor...'
                                  : 'Ekspor Laporan'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assessment_outlined,
              size: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada data laporan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih periode tanggal untuk melihat laporan',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, SalesReportController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Periode Laporan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatDate(controller.dateRange.start)} - ${_formatDate(controller.dateRange.end)}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () => _selectDateRange(context, controller),
            tooltip: 'Ubah Periode',
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, SalesReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // 2x2 grid of summary cards
        Row(
          children: [
            Expanded(
              child: SummaryStatCard(
                title: 'Total Transaksi',
                value: '${report.totalTransactions}',
                icon: Icons.receipt_long_outlined,
                color: AppTheme.infoColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryStatCard(
                title: 'Total Pendapatan',
                value: CurrencyFormatter.format(report.totalRevenue),
                icon: Icons.payments_outlined,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryStatCard(
                title: 'Total Laba',
                value: CurrencyFormatter.format(report.totalProfit),
                icon: Icons.trending_up,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryStatCard(
                title: 'Margin Laba',
                value: '${report.profitMargin.toStringAsFixed(1)}%',
                icon: Icons.show_chart,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailySalesChart(BuildContext context, SalesReport report) {
    final dailyData = report.dailyBreakdown;

    return Consumer<SalesReportController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tren Penjualan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chart type selector
            _buildChartTypeSelector(context, controller),
            const SizedBox(height: 12),

            // Metric selector
            _buildMetricSelector(context, controller),
            const SizedBox(height: 16),

            // Chart
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: _buildChart(context, controller, dailyData),
            ),

            // Comparison info
            const SizedBox(height: 16),
            _buildComparisonCard(context, report),
          ],
        );
      },
    );
  }

  Widget _buildChartTypeSelector(BuildContext context, SalesReportController controller) {
    return Wrap(
      spacing: 8,
      children: ChartType.values.map((type) {
        final isSelected = controller.chartType == type;
        return FilterChip(
          label: Text(_getChartTypeLabel(type)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              controller.setChartType(type);
            }
          },
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricSelector(BuildContext context, SalesReportController controller) {
    return Wrap(
      spacing: 8,
      children: ChartMetric.values.map((metric) {
        final isSelected = controller.chartMetric == metric;
        return FilterChip(
          label: Text(_getMetricLabel(metric)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              controller.setChartMetric(metric);
            }
          },
          selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.secondaryColor,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.secondaryColor : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppTheme.secondaryColor : AppTheme.borderColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart(
    BuildContext context,
    SalesReportController controller,
    List<DailySales> dailyData,
  ) {
    switch (controller.chartType) {
      case ChartType.line:
        return _buildLineChart(context, controller, dailyData);
      case ChartType.bar:
        return _buildBarChart(context, controller, dailyData);
      case ChartType.area:
        return _buildAreaChart(context, controller, dailyData);
    }
  }

  Widget _buildLineChart(
    BuildContext context,
    SalesReportController controller,
    List<DailySales> dailyData,
  ) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateYInterval(dailyData, controller.chartMetric),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= dailyData.length) return const Text('');
                final date = dailyData[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatYAxis(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.borderColor),
        ),
        minX: 0,
        maxX: (dailyData.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxYForMetric(dailyData, controller.chartMetric),
        lineBarsData: [
          LineChartBarData(
            spots: _generateLineSpotsForMetric(dailyData, controller.chartMetric),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: AppTheme.cardColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                  AppTheme.primaryColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsChart(BuildContext context, SalesReport report) {
    final paymentData = report.paymentBreakdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _generatePieSections(paymentData),
                  ),
                ),
              ),

              // Legend
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: paymentData.map((data) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPaymentColor(data.paymentMethod),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data.paymentMethod.displayNameId,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            '${data.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsTable(BuildContext context, SalesReport report) {
    final topProducts = report.topProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produk Terlaris',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Produk', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      flex: 2,
                      child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Pendapatan', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Rows
              ...topProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${index + 1}. ${product.productName}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${product.quantitySold}',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          CurrencyFormatter.format(product.revenue),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generatePieSections(List<PaymentMethodBreakdown> data) {
    return data.map((item) {
      return PieChartSectionData(
        value: item.totalAmount,
        title: '',
        color: _getPaymentColor(item.paymentMethod),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  String _formatYAxis(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDateRange(BuildContext context, SalesReportController controller) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.dateRange.start,
        end: controller.dateRange.end,
      ),
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }

  Future<void> _exportReport(BuildContext context, SalesReportController controller) async {
    try {
      final file = await controller.exportSalesReport();

      if (file != null && context.mounted) {
        // Show success message and share file
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan berhasil diekspor: ${file.path.split('/').last}'),
            backgroundColor: AppTheme.successColor,
            action: SnackBarAction(
              label: 'Bagikan',
              textColor: Colors.white,
              onPressed: () => _shareFile(file),
            ),
          ),
        );

        // Automatically share the file
        await _shareFile(file);
      } else if (context.mounted && controller.exportErrorMessage != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.exportErrorMessage!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        controller.clearExportError();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor laporan: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _shareFile(File file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Laporan Penjualan',
        text: 'Laporan penjualan dari aplikasi POS',
      );
    } catch (e) {
      // If sharing fails, just show the file path
      debugPrint('Failed to share file: $e');
    }
  }

  void _openSettings(BuildContext context) {
    // Navigate to settings tab (index 4)
    final mainNavigationState = context.findAncestorStateOfType<MainNavigationState>();
    mainNavigationState?.navigateToSettings();
  }

  String _getChartTypeLabel(ChartType type) {
    switch (type) {
      case ChartType.line:
        return 'Garis';
      case ChartType.bar:
        return 'Batang';
      case ChartType.area:
        return 'Area';
    }
  }

  String _getMetricLabel(ChartMetric metric) {
    switch (metric) {
      case ChartMetric.revenue:
        return 'Pendapatan';
      case ChartMetric.profit:
        return 'Laba';
      case ChartMetric.transactions:
        return 'Transaksi';
    }
  }

  double _getMetricValue(DailySales data, ChartMetric metric) {
    switch (metric) {
      case ChartMetric.revenue:
        return data.revenue;
      case ChartMetric.profit:
        return data.profit;
      case ChartMetric.transactions:
        return data.transactionCount.toDouble();
    }
  }

  Widget _buildBarChart(
    BuildContext context,
    SalesReportController controller,
    List<DailySales> dailyData,
  ) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxYForMetric(dailyData, controller.chartMetric),
        minY: 0,
        groupsSpace: 12,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateYInterval(dailyData, controller.chartMetric),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.dividerColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= dailyData.length) return const Text('');
                final date = dailyData[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatYAxis(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.borderColor),
        ),
        barGroups: List.generate(
          dailyData.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _getMetricValue(dailyData[index], controller.chartMetric),
                color: AppTheme.primaryColor,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaChart(
    BuildContext context,
    SalesReportController controller,
    List<DailySales> dailyData,
  ) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateYInterval(dailyData, controller.chartMetric),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.dividerColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= dailyData.length) return const Text('');
                final date = dailyData[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatYAxis(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.borderColor),
        ),
        minX: 0,
        maxX: (dailyData.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxYForMetric(dailyData, controller.chartMetric),
        lineBarsData: [
          LineChartBarData(
            spots: _generateLineSpotsForMetric(dailyData, controller.chartMetric),
            isCurved: true,
            color: AppTheme.secondaryColor,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.secondaryColor.withValues(alpha: 0.4),
                  AppTheme.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, SalesReport report) {
    if (report.dailyBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate simple comparison (last 7 days vs previous 7 days)
    final totalDays = report.dailyBreakdown.length;
    final recentWeek = totalDays >= 14
        ? report.dailyBreakdown.sublist(0, 7)
        : report.dailyBreakdown;
    final previousWeek = totalDays >= 14
        ? report.dailyBreakdown.sublist(7, 14)
        : <DailySales>[];

    if (previousWeek.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentTotal = recentWeek.fold<double>(
        0, (sum, day) => sum + day.revenue);
    final previousTotal = previousWeek.fold<double>(
        0, (sum, day) => sum + day.revenue);

    final percentageChange = previousTotal > 0
        ? ((recentTotal - previousTotal) / previousTotal * 100)
        : 0.0;

    final isPositive = percentageChange >= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isPositive ? AppTheme.successColor : AppTheme.errorColor)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isPositive ? AppTheme.successColor : AppTheme.errorColor)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${isPositive ? 'Naik' : 'Turun'} ${percentageChange.abs().toStringAsFixed(1)}% dari minggu lalu',
              style: TextStyle(
                color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxYForMetric(List<DailySales> dailyData, ChartMetric metric) {
    if (dailyData.isEmpty) return 100000;

    double maxValue;
    switch (metric) {
      case ChartMetric.revenue:
        maxValue = dailyData.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);
        break;
      case ChartMetric.profit:
        maxValue = dailyData.map((d) => d.profit).reduce((a, b) => a > b ? a : b);
        break;
      case ChartMetric.transactions:
        maxValue = dailyData.map((d) => d.transactionCount.toDouble()).reduce((a, b) => a > b ? a : b);
        break;
    }

    return maxValue * 1.2;
  }

  List<FlSpot> _generateLineSpotsForMetric(
    List<DailySales> dailyData,
    ChartMetric metric,
  ) {
    return dailyData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        _getMetricValue(entry.value, metric),
      );
    }).toList();
  }

  double _calculateYInterval(List<DailySales> dailyData, ChartMetric metric) {
    if (dailyData.isEmpty) return 50000;

    double maxValue;
    switch (metric) {
      case ChartMetric.revenue:
        maxValue = dailyData.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);
        break;
      case ChartMetric.profit:
        maxValue = dailyData.map((d) => d.profit).reduce((a, b) => a > b ? a : b);
        break;
      case ChartMetric.transactions:
        maxValue = dailyData.map((d) => d.transactionCount.toDouble()).reduce((a, b) => a > b ? a : b);
        break;
    }

    return maxValue / 5;
  }
}
