import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/analytics_controller.dart';
import '../../domain/entities/sales_analytics.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_display.dart';

/// Screen displaying advanced sales analytics with rich visualizations
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsController>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor:
              NeoBrutalTheme.background, // ✅ Brutal white background
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Analitik Penjualan'),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: NeoBrutalTheme.spaceXS),
                child: Container(
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      NeoBrutalTheme.radiusSmall,
                    ),
                    border: Border.all(
                      color: Colors.black,
                      width: 4, // ✅ Bold 4px border
                    ),
                  ),
                  child: PopupMenuButton<DateRangePreset>(
                    icon: Icon(
                      Icons.date_range,
                      color: NeoBrutalTheme.secondary,
                    ),
                    onSelected: (preset) =>
                        controller.setPredefinedRange(preset),
                    itemBuilder: (context) => DateRangePreset.values
                        .map(
                          (preset) => PopupMenuItem(
                            value: preset,
                            child: Text(preset.displayName),
                          ),
                        )
                        .toList(),
                    color: NeoBrutalTheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusSmall,
                      ),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: NeoBrutalTheme.blockYellow, // ✅ Bold yellow background
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 6, // ✅ Extra thick bottom border
                  ),
                ),
              ),
            ),
          ),
          body: controller.isLoading && !controller.hasReport
              ? const LoadingIndicator(message: 'Memuat analitik...')
              : controller.hasError
              ? ErrorDisplay.fromException(
                  controller.error!,
                  onRetry: () => controller.loadAnalytics(),
                )
              : controller.hasReport
              ? _buildAnalyticsContent(context, controller.report!)
              : _buildEmptyState(),
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
              Icons.analytics_outlined,
              size: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada data analitik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih periode tanggal untuk melihat analitik',
            style: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    SalesAnalyticsReport report,
  ) {
    return RefreshIndicator(
      onRefresh: context.read<AnalyticsController>().refresh,
      color: NeoBrutalTheme.primary, // ✅ Brutal primary color
      backgroundColor: NeoBrutalTheme.blockYellow.withValues(alpha: 0.3),
      strokeWidth: 4, // ✅ Thicker indicator
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 140,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score Card
            _buildHealthScoreCard(context, report.kpis),
            const SizedBox(height: 16),

            // KPIs Grid
            _buildKPIsGrid(context, report.kpis),
            const SizedBox(height: 24),

            // Trend Chart
            _buildTrendChart(context, report.trendAnalysis),
            const SizedBox(height: 24),

            // Time Patterns
            if (report.timePatterns.hourlyPatterns.isNotEmpty)
              _buildTimePatternsSection(context, report.timePatterns),
            if (report.timePatterns.hourlyPatterns.isNotEmpty)
              const SizedBox(height: 24),

            // Top Products
            if (report.topProducts.isNotEmpty)
              _buildTopProductsSection(context, report.topProducts),
            if (report.topProducts.isNotEmpty) const SizedBox(height: 24),

            // Category Performance
            if (report.categoryPerformance.isNotEmpty)
              _buildCategoryPerformanceSection(
                context,
                report.categoryPerformance,
              ),
            if (report.categoryPerformance.isNotEmpty)
              const SizedBox(height: 24),

            // Comparative Analytics
            _buildComparativeAnalyticsSection(
              context,
              report.comparativeAnalytics,
            ),
            const SizedBox(height: 24),

            // Executive Summary
            if (report.executiveSummary.isNotEmpty)
              _buildExecutiveSummarySection(context, report.executiveSummary),
            if (report.executiveSummary.isNotEmpty) const SizedBox(height: 24),

            // Action Items
            if (report.actionItems.isNotEmpty)
              _buildActionItemsSection(context, report.actionItems),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, AnalyticsKPIs kpis) {
    final healthRating = kpis.healthRating;
    return Container(
          padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
          decoration: BoxDecoration(
            color: healthRating.color, // ✅ Solid bold color
            borderRadius: BorderRadius.circular(
              NeoBrutalTheme.radiusMedium,
            ), // ✅ Brutal 8px
            border: Border.all(
              color: Colors.black, // ✅ Bold black border
              width: 4, // ✅ Bold 4px border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white, // ✅ White container for contrast
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusMedium,
                  ),
                  border: Border.all(
                    color: Colors.black,
                    width: 3, // ✅ Bold 3px border
                  ),
                ),
                child: Icon(
                  healthRating.icon,
                  size: 32,
                  color: healthRating.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skor Kesehatan Bisnis',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          kpis.healthScore.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: healthRating.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/100',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: NeoBrutalTheme.spaceMD,
                            vertical: NeoBrutalTheme.spaceSM,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Colors.white, // ✅ White background for contrast
                            borderRadius: BorderRadius.circular(
                              NeoBrutalTheme.radiusMedium,
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 3, // ✅ Bold 3px border
                            ),
                          ),
                          child: Text(
                            healthRating.displayName,
                            style: TextStyle(
                              color: healthRating
                                  .color, // ✅ Colored text for contrast
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildKPIsGrid(BuildContext context, AnalyticsKPIs kpis) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveHelper.getWideGridColumns(context),
      mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
      crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
      childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.4 : 1.6,
      children: [
        _buildKPICard(
          context,
          icon: Icons.trending_up,
          title: 'Pertumbuhan',
          value: '${kpis.revenueGrowthRate.toStringAsFixed(1)}%',
          color: kpis.revenueGrowthRate >= 0
              ? AppTheme.successColor
              : AppTheme.errorColor,
          subtitle: 'Pendapatan',
        ),
        _buildKPICard(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Margin',
          value: '${kpis.profitMargin.toStringAsFixed(1)}%',
          color: kpis.profitMargin >= 20
              ? AppTheme.successColor
              : kpis.profitMargin >= 15
              ? AppTheme.warningColor
              : AppTheme.errorColor,
          subtitle: 'Keuntungan',
        ),
        _buildKPICard(
          context,
          icon: Icons.receipt_long,
          title: 'Rata-rata',
          value: CurrencyFormatter.format(kpis.averageTransactionValue),
          color: AppTheme.infoColor,
          subtitle: 'Per Transaksi',
        ),
        _buildKPICard(
          context,
          icon: Icons.shopping_cart,
          title: 'Item',
          value: kpis.itemsPerTransaction.toStringAsFixed(1),
          color: AppTheme.secondaryColor,
          subtitle: 'Per Transaksi',
        ),
      ],
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight; // 91.2px
        final iconSize = (maxHeight * 0.45).clamp(36.0, 44.0); // Responsive
        final valueSize = (maxHeight * 0.22).clamp(16.0, 20.0);
        final titleSize = (maxHeight * 0.13).clamp(10.0, 12.0);

        return Container(
              padding: EdgeInsets.all(
                NeoBrutalTheme.spaceMD * 0.8,
              ), // 👈 Responsive padding
              decoration: BoxDecoration(
                color: NeoBrutalTheme.background,
                borderRadius: BorderRadius.circular(
                  NeoBrutalTheme.radiusMedium,
                ),
                border: Border.all(
                  color: Colors.black,
                  width: 3, // 👈 Reduce from 4
                ),
                boxShadow: NeoBrutalTheme.chunkyShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 KEY FIX
                children: [
                  // Responsive Icon Row
                  Flexible(
                    child: Row(
                      children: [
                        // Responsive Icon Container
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(
                              NeoBrutalTheme.radiusSmall,
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ), // 👈 Reduce
                            boxShadow: NeoBrutalTheme.chunkyShadow,
                          ),
                          child: Icon(
                            icon,
                            size: iconSize * 0.55, // 👈 20-24px responsive
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          // 👈 Prevents overflow
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: titleSize,
                              color: AppTheme.getTextSecondaryColor(context),
                              overflow: TextOverflow.ellipsis, // 👈 Safety
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Responsive Value
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Responsive Subtitle
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: titleSize * 0.85,
                        color: AppTheme.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(
              begin: const Offset(0.95, 0.95),
              duration: 300.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildTrendChart(
    BuildContext context,
    SalesTrendAnalysis trendAnalysis,
  ) {
    if (trendAnalysis.historicalData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
          padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
          decoration: BoxDecoration(
            color: NeoBrutalTheme.background, // ✅ Brutal white background
            borderRadius: BorderRadius.circular(
              NeoBrutalTheme.radiusMedium,
            ), // ✅ Brutal 8px
            border: Border.all(
              color: Colors.black, // ✅ Bold black border
              width: 4, // ✅ Bold 4px border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    trendAnalysis.trendDirection.icon,
                    color: trendAnalysis.trendDirection.color,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tren Pendapatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextPrimaryColor(context),
                          ),
                        ),
                        Text(
                          trendAnalysis.insight,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: trendAnalysis.trendDirection.color.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: trendAnalysis.trendDirection.color.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          trendAnalysis.trendDirection.icon,
                          size: 16,
                          color: trendAnalysis.trendDirection.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trendAnalysis.growthRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: trendAnalysis.trendDirection.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: ResponsiveHelper.getChartHeight(context),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _calculateYInterval(trendAnalysis),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppTheme.getBorderColor(
                            context,
                          ).withValues(alpha: 0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: _calculateXInterval(trendAnalysis),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _formatDate(value.toInt()),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          interval: _calculateYInterval(trendAnalysis),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _formatCurrency(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Historical data
                      LineChartBarData(
                        spots: _createHistoricalSpots(trendAnalysis),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                              AppTheme.primaryColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      // Forecast data
                      if (trendAnalysis.forecastData.isNotEmpty)
                        LineChartBarData(
                          spots: _createForecastSpots(trendAnalysis),
                          isCurved: true,
                          color: AppTheme.warningColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          dashArray: [5, 5],
                        ),
                    ],
                    minX: _getMinX(trendAnalysis),
                    maxX: _getMaxX(trendAnalysis),
                    minY: 0,
                    maxY: _getMaxY(trendAnalysis),
                  ),
                ),
              ),
              if (trendAnalysis.forecastData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Aktual',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Forecast',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildTimePatternsSection(
    BuildContext context,
    TimePatternAnalytics timePatterns,
  ) {
    if (timePatterns.hourlyPatterns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background, // ✅ Brutal white background
        borderRadius: BorderRadius.circular(
          NeoBrutalTheme.radiusMedium,
        ), // ✅ Brutal 8px
        border: Border.all(
          color: Colors.black, // ✅ Bold black border
          width: 4, // ✅ Bold 4px border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pola Waktu',
            style: NeoBrutalTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceXS),
          Text(
            timePatterns.bestTimeSummary,
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          SizedBox(
            height: ResponsiveHelper.getChartHeight(context) * 0.75,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxTransactions(timePatterns),
                barGroups: _createHourlyBarGroups(context, timePatterns),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 3 != 0)
                          return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}:00',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection(
    BuildContext context,
    List<ProductPerformance> products,
  ) {
    final displayProducts = products.take(5).toList();
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background, // ✅ Brutal white background
        borderRadius: BorderRadius.circular(
          NeoBrutalTheme.radiusMedium,
        ), // ✅ Brutal 8px
        border: Border.all(
          color: Colors.black, // ✅ Bold black border
          width: 4, // ✅ Bold 4px border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppTheme.warningColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Produk Terlaris',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return _buildProductItem(context, product, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    ProductPerformance product,
    int rank,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceSM),
      child: Row(
        children: [
          Container(
            width: 40, // ✅ Larger rank container
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank), // ✅ Solid bold color
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(
                color: Colors.black, // ✅ Bold black border
                width: 3, // ✅ Bold 3px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white, // ✅ White text for contrast
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.quantitySold} terjual',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(product.revenue),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.rating.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.rating.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    color: product.rating.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformanceSection(
    BuildContext context,
    List<CategoryPerformance> categories,
  ) {
    final displayCategories = categories.take(5).toList();
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background, // ✅ Brutal white background
        borderRadius: BorderRadius.circular(
          NeoBrutalTheme.radiusMedium,
        ), // ✅ Brutal 8px
        border: Border.all(
          color: Colors.black, // ✅ Bold black border
          width: 4, // ✅ Bold 4px border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performa Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          ...displayCategories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryItem(context, category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryPerformance category,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.productCount} produk • ${category.quantitySold} terjual',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(category.revenue),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: NeoBrutalTheme.spaceXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          child: LinearProgressIndicator(
            value: category.profitMargin / 100,
            backgroundColor: Colors.black.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(category.rating.color),
            minHeight: 8, // ✅ Thicker progress bar
          ),
        ),
        SizedBox(height: NeoBrutalTheme.spaceXS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Margin: ${category.profitMargin.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: NeoBrutalTheme.spaceSM,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: category.rating.color, // ✅ Solid bold color
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: Colors.black,
                  width: 2, // ✅ Bold 2px border
                ),
              ),
              child: Text(
                category.rating.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white, // ✅ White text for contrast
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildComparativeAnalyticsSection(
    BuildContext context,
    ComparativeAnalytics comparative,
  ) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background, // ✅ Brutal white background
        borderRadius: BorderRadius.circular(
          NeoBrutalTheme.radiusMedium,
        ), // ✅ Brutal 8px
        border: Border.all(
          color: Colors.black, // ✅ Bold black border
          width: 4, // ✅ Bold 4px border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perbandingan Periode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          ...comparative.metricComparisons.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMetricComparison(context, metric),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricComparison(BuildContext context, MetricComparison metric) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.metricName,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(metric.currentValue),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMD,
            vertical: NeoBrutalTheme.spaceSM,
          ),
          decoration: BoxDecoration(
            color: metric.direction.color, // ✅ Solid bold color
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
            border: Border.all(
              color: Colors.black, // ✅ Bold black border
              width: 3, // ✅ Bold 3px border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Row(
            children: [
              Icon(
                metric.direction.icon,
                size: 14,
                color: Colors.white, // ✅ White icon for contrast
              ),
              SizedBox(width: NeoBrutalTheme.spaceXS),
              Text(
                '${metric.changePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white, // ✅ White text for contrast
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExecutiveSummarySection(
    BuildContext context,
    List<String> summary,
  ) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.infoColor, // ✅ Solid bold color
        borderRadius: BorderRadius.circular(
          NeoBrutalTheme.radiusMedium,
        ), // ✅ Brutal 8px
        border: Border.all(
          color: Colors.black, // ✅ Bold black border
          width: 4, // ✅ Bold 4px border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, // ✅ Larger icon container
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white, // ✅ White container for contrast
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                  border: Border.all(
                    color: Colors.black,
                    width: 3, // ✅ Bold 3px border
                  ),
                ),
                child: Icon(
                  Icons.summarize,
                  size: 24,
                  color: AppTheme.infoColor,
                ),
              ),
              SizedBox(width: NeoBrutalTheme.spaceSM),
              Text(
                'Ringkasan Eksekutif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // ✅ White text for contrast
                ),
              ),
            ],
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          ...summary.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceSM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    width: 8, // ✅ Larger bullet point
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ White bullet for contrast
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceSM),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white, // ✅ White text for contrast
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsSection(BuildContext context, List<String> actions) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.warningColor, // ✅ Solid bold color
        borderRadius: BorderRadius.circular(
          NeoBrutalTheme.radiusMedium,
        ), // ✅ Brutal 8px
        border: Border.all(
          color: Colors.black, // ✅ Bold black border
          width: 4, // ✅ Bold 4px border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, // ✅ Larger icon container
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white, // ✅ White container for contrast
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                  border: Border.all(
                    color: Colors.black,
                    width: 3, // ✅ Bold 3px border
                  ),
                ),
                child: Icon(
                  Icons.task_alt,
                  size: 24,
                  color: AppTheme.warningColor,
                ),
              ),
              SizedBox(width: NeoBrutalTheme.spaceSM),
              Text(
                'Rekomendasi Tindakan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // ✅ White text for contrast
                ),
              ),
            ],
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          ...actions.map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceSM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32, // ✅ Larger icon container
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ White container for contrast
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusSmall,
                      ),
                      border: Border.all(
                        color: Colors.black,
                        width: 2, // ✅ Bold 2px border
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_right,
                      size: 18,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceSM),
                  Expanded(
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white, // ✅ White text for contrast
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for charts

  List<FlSpot> _createHistoricalSpots(SalesTrendAnalysis analysis) {
    final spots = <FlSpot>[];
    for (int i = 0; i < analysis.historicalData.length; i++) {
      final data = analysis.historicalData[i];
      spots.add(
        FlSpot(data.date.millisecondsSinceEpoch.toDouble(), data.revenue),
      );
    }
    return spots;
  }

  List<FlSpot> _createForecastSpots(SalesTrendAnalysis analysis) {
    final spots = <FlSpot>[];
    for (int i = 0; i < analysis.forecastData.length; i++) {
      final data = analysis.forecastData[i];
      spots.add(
        FlSpot(data.date.millisecondsSinceEpoch.toDouble(), data.revenue),
      );
    }
    return spots;
  }

  double _getMinX(SalesTrendAnalysis analysis) {
    if (analysis.historicalData.isEmpty) return 0;
    return analysis.historicalData.first.date.millisecondsSinceEpoch.toDouble();
  }

  double _getMaxX(SalesTrendAnalysis analysis) {
    if (analysis.forecastData.isEmpty) {
      if (analysis.historicalData.isEmpty) return 0;
      return analysis.historicalData.last.date.millisecondsSinceEpoch
          .toDouble();
    }
    return analysis.forecastData.last.date.millisecondsSinceEpoch.toDouble();
  }

  double _getMaxY(SalesTrendAnalysis analysis) {
    double max = 0;
    for (final data in analysis.historicalData) {
      if (data.revenue > max) max = data.revenue;
    }
    for (final data in analysis.forecastData) {
      if (data.revenue > max) max = data.revenue;
    }
    return max * 1.2; // Add 20% headroom
  }

  double _calculateYInterval(SalesTrendAnalysis analysis) {
    final max = _getMaxY(analysis);
    if (max == 0) return 100000;
    return max / 5;
  }

  double _calculateXInterval(SalesTrendAnalysis analysis) {
    final minX = _getMinX(analysis);
    final maxX = _getMaxX(analysis);
    final diff = maxX - minX;
    final days = (diff / (1000 * 60 * 60 * 24)).round();
    if (days <= 7) return 1 * 24 * 60 * 60 * 1000;
    if (days <= 30) return 7 * 24 * 60 * 60 * 1000;
    return 30 * 24 * 60 * 60 * 1000;
  }

  String _formatDate(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${date.day}/${date.month}';
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }

  List<BarChartGroupData> _createHourlyBarGroups(
    BuildContext context,
    TimePatternAnalytics timePatterns,
  ) {
    final groups = <BarChartGroupData>[];
    for (final pattern in timePatterns.hourlyPatterns) {
      groups.add(
        BarChartGroupData(
          x: pattern.hour,
          barRods: [
            BarChartRodData(
              toY: pattern.transactionCount.toDouble(),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.7),
                ],
              ),
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  double _getMaxTransactions(TimePatternAnalytics timePatterns) {
    double max = 0;
    for (final pattern in timePatterns.hourlyPatterns) {
      if (pattern.transactionCount > max) {
        max = pattern.transactionCount.toDouble();
      }
    }
    return max * 1.2;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.primaryColor;
    }
  }
}
