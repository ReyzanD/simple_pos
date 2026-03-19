import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/payment_method.dart';
import '../controllers/sales_report_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../widgets/summary_stat_card.dart';

/// Screen displaying sales reports with charts
class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppTheme.darkSurface,
                          AppTheme.darkSurface.withValues(alpha: 0.95),
                        ]
                      : [
                          AppTheme.primaryColor,
                          AppTheme.primaryLight,
                        ],
                ),
              ),
            ),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.report == null
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: controller.refresh,
                      color: AppTheme.primaryColor,
                      displacement: 80,
                      strokeWidth: 3,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content is small
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 140, // Space for floating nav
                        ),
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

                            // Expense Breakdown (if expense data available)
                            if (controller.report!.profitReport != null &&
                                controller.report!.totalExpenses > 0)
                              _buildExpenseBreakdownSection(context, controller.report!),
                            if (controller.report!.profitReport != null &&
                                controller.report!.totalExpenses > 0)
                              const SizedBox(height: 24),

                            // Top Products Table
                            _buildTopProductsTable(context, controller.report!),
                            const SizedBox(height: 24),

                            // Category Performance
                            if (controller.report!.categoryBreakdown.isNotEmpty)
                              _buildCategoryPerformanceSection(context, controller.report!),
                            if (controller.report!.categoryBreakdown.isNotEmpty)
                              const SizedBox(height: 24),

                            // Period Comparison (MoM / YoY)
                            _buildPeriodComparisonSection(context, controller.report!),
                            const SizedBox(height: 24),

                            // Peak Hours Analysis
                            _buildPeakHoursSection(context, controller.report!),
                            if (controller.report!.peakHours.isNotEmpty)
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
    final hasExpenseData = report.profitReport != null;
    final showNetProfit = hasExpenseData && report.totalExpenses > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Ringkasan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
          ),
        ),
        const SizedBox(height: 16),
        // 2x3 grid of summary cards with staggered animation
        Row(
          children: [
            Expanded(
              child: SummaryStatCard(
                title: 'Total Transaksi',
                value: '${report.totalTransactions}',
                icon: Icons.receipt_long_rounded,
                color: AppTheme.infoColor,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryStatCard(
                title: 'Total Pendapatan',
                value: CurrencyFormatter.format(report.totalRevenue),
                icon: Icons.payments_outlined,
                color: AppTheme.successColor,
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryStatCard(
                title: 'Laba Kotor',
                value: CurrencyFormatter.format(report.totalProfit),
                icon: Icons.trending_up_rounded,
                color: AppTheme.warningColor,
                subtitle: 'Sebelum pengeluaran',
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryStatCard(
                title: 'Pengeluaran',
                value: CurrencyFormatter.format(report.totalExpenses),
                icon: Icons.shopping_cart_outlined,
                color: AppTheme.errorColor,
                subtitle: hasExpenseData ? '${report.expenseRatio.toStringAsFixed(1)}% dari pendapatan' : null,
              ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryStatCard(
                title: 'Laba Bersih',
                value: CurrencyFormatter.format(report.netProfit),
                icon: Icons.account_balance_wallet_outlined,
                color: AppTheme.successColor,
                subtitle: showNetProfit ? 'Setelah pengeluaran' : null,
              ).animate(delay: 400.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryStatCard(
                title: 'Margin Bersih',
                value: '${report.netProfitMargin.toStringAsFixed(1)}%',
                icon: Icons.show_chart,
                color: AppTheme.primaryColor,
                subtitle: showNetProfit ? 'Margin bersih' : 'Margin kotor',
              ).animate(delay: 500.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
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
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
                  width: 0.5,
                ),
                boxShadow: AppShadows.shadowSm,
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
                  strokeColor: AppTheme.getCardColor(context),
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
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: AppShadows.shadowSm,
          ),
          child: Row(
            children: [
              // Pie Chart
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

              // Legend with spacing
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: paymentData.map((data) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildPaymentLegendItem(context, data),
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

  Widget _buildPaymentLegendItem(
    BuildContext context,
    PaymentMethodBreakdown data,
  ) {
    final color = _getPaymentColor(data.paymentMethod);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              data.paymentMethod.displayNameId,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ),
          Text(
            '${data.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: AppShadows.shadowSm,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
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
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.transparent
                        : (isDark
                            ? AppTheme.darkSurfaceVariant.withValues(alpha: 0.3)
                            : AppTheme.lightSurfaceVariant),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
                      ),
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

  Widget _buildCategoryPerformanceSection(BuildContext context, SalesReport report) {
    final categoryData = report.categoryBreakdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performa Kategori',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: AppShadows.shadowSm,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      flex: 2,
                      child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Pendapatan', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Margin', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Rows
              ...categoryData.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final marginColor = category.profitMargin >= 20
                    ? AppTheme.successColor
                    : category.profitMargin >= 10
                        ? AppTheme.warningColor
                        : AppTheme.errorColor;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.transparent
                        : (isDark
                            ? AppTheme.darkSurfaceVariant.withValues(alpha: 0.3)
                            : AppTheme.lightSurfaceVariant),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          category.categoryName,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${category.quantitySold}',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          CurrencyFormatter.format(category.revenue),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${category.profitMargin.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: marginColor,
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

  Widget _buildPeriodComparisonSection(BuildContext context, SalesReport report) {
    final hasMonthOverMonth = report.monthOverMonth != null;
    final hasYearOverYear = report.yearOverYear != null;

    if (!hasMonthOverMonth && !hasYearOverYear) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perbandingan Periode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada data periode sebelumnya',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih periode yang memiliki data bulan/tahun lalu',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perbandingan Periode',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (hasMonthOverMonth) ...[
              Expanded(
                child: _buildPeriodComparisonCard(
                  context,
                  'Bulan Lalu',
                  report.monthOverMonth!,
                ),
              ),
              if (hasYearOverYear) const SizedBox(width: 16),
            ],
            if (hasYearOverYear)
              Expanded(
                child: _buildPeriodComparisonCard(
                  context,
                  'Tahun Lalu',
                  report.yearOverYear!,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodComparisonCard(
    BuildContext context,
    String title,
    PeriodComparison comparison,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
        boxShadow: AppShadows.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 12),
          _buildComparisonMetric(
            'Pendapatan',
            comparison.revenueChange,
            comparison.isRevenueGrowth,
            comparison.previousRevenue,
          ),
          const SizedBox(height: 8),
          _buildComparisonMetric(
            'Transaksi',
            comparison.transactionChange,
            comparison.isTransactionGrowth,
            comparison.previousTransactions?.toInt(),
          ),
          const SizedBox(height: 8),
          _buildComparisonMetric(
            'Laba',
            comparison.profitChange,
            comparison.isProfitGrowth,
            comparison.previousProfit,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMetric(
    String label,
    double change,
    bool isPositive,
    num? previousValue,
  ) {
    final color = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (previousValue != null)
              Text(
                label == 'Transaksi'
                    ? '$previousValue'
                    : CurrencyFormatter.format(previousValue.toDouble()),
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textTertiary,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppTheme.textTertiary,
                ),
              ),
            if (previousValue == null)
              const Spacer(),
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeakHoursSection(BuildContext context, SalesReport report) {
    final peakHours = report.peakHours.take(8).toList();

    if (peakHours.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jam Sibuk',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada data transaksi',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data jam sibuk akan muncul setelah ada transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jam Sibuk',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: AppShadows.shadowSm,
          ),
          child: Column(
            children: [
              ...peakHours.asMap().entries.map((entry) {
                final index = entry.key;
                final hour = entry.value;
                final maxTransactions = peakHours.first.transactionCount;
                final barWidth = hour.transactionCount / maxTransactions;

                return Padding(
                  padding: EdgeInsets.only(bottom: index < peakHours.length - 1 ? 12 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hour.formattedHour,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${hour.transactionCount} trans',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Avg: ${CurrencyFormatter.format(hour.averageTransactionValue)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: barWidth,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hour.periodOfDay,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(hour.revenue),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                          ),
                        ],
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

  Widget _buildExpenseBreakdownSection(BuildContext context, SalesReport report) {
    final profitReport = report.profitReport!;
    final netProfitIsPositive = profitReport.netProfit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analisis Pengeluaran',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: AppShadows.shadowSm,
          ),
          child: Column(
            children: [
              // Header with net profit indicator
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: netProfitIsPositive
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      netProfitIsPositive
                          ? Icons.account_balance_wallet_outlined
                          : Icons.warning_amber_rounded,
                      color: netProfitIsPositive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          netProfitIsPositive ? 'Keuntungan Bersih' : 'Kerugian Bersih',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(profitReport.netProfit),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: netProfitIsPositive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: AppTheme.getBorderColor(context),
              ),
              const SizedBox(height: 20),

              // Breakdown bars
              _buildProfitBreakdownBar(
                context,
                'Pendapatan Kotor',
                profitReport.grossProfit,
                report.totalRevenue,
                AppTheme.successColor,
              ),
              const SizedBox(height: 12),
              _buildProfitBreakdownBar(
                context,
                'Pengeluaran',
                profitReport.totalExpenses,
                report.totalRevenue,
                AppTheme.errorColor,
                isNegative: true,
              ),
              const SizedBox(height: 12),
              _buildProfitBreakdownBar(
                context,
                'Laba Bersih',
                profitReport.netProfit,
                report.totalRevenue,
                netProfitIsPositive ? AppTheme.successColor : AppTheme.errorColor,
                showPercentage: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfitBreakdownBar(
    BuildContext context,
    String label,
    double value,
    double totalRevenue,
    Color color, {
    bool isNegative = false,
    bool showPercentage = false,
  }) {
    final percentage = totalRevenue > 0 ? (value.abs() / totalRevenue * 100) : 0.0;
    final barWidth = totalRevenue > 0 ? (value.abs() / totalRevenue) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            Row(
              children: [
                Text(
                  CurrencyFormatter.format(value),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (showPercentage) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: barWidth,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
