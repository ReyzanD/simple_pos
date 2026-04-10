import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/analytics_controller.dart';
import '../../domain/entities/sales_analytics.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../shared/presentation/main_navigation.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<AnalyticsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                final mainNavState = context
                    .findAncestorStateOfType<MainNavigationState>();
                mainNavState?.openDrawer();
              },
            ),
            title: const Text('Analitik Penjualan'),
            actions: [
              PopupMenuButton<DateRangePreset>(
                icon: const Icon(Icons.date_range),
                onSelected: (preset) => controller.setPredefinedRange(preset),
                itemBuilder: (context) => DateRangePreset.values
                    .map((preset) => PopupMenuItem(
                          value: preset,
                          child: Text(preset.displayName),
                        ))
                    .toList(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.isLoading ? null : controller.refresh,
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
                      : [AppTheme.primaryColor, AppTheme.primaryLight],
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
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, SalesAnalyticsReport report) {
    return RefreshIndicator(
      onRefresh: context.read<AnalyticsController>().refresh,
      color: AppTheme.primaryColor,
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
            if (report.topProducts.isNotEmpty)
              const SizedBox(height: 24),

            // Category Performance
            if (report.categoryPerformance.isNotEmpty)
              _buildCategoryPerformanceSection(context, report.categoryPerformance),
            if (report.categoryPerformance.isNotEmpty)
              const SizedBox(height: 24),

            // Comparative Analytics
            _buildComparativeAnalyticsSection(context, report.comparativeAnalytics),
            const SizedBox(height: 24),

            // Executive Summary
            if (report.executiveSummary.isNotEmpty)
              _buildExecutiveSummarySection(context, report.executiveSummary),
            if (report.executiveSummary.isNotEmpty)
              const SizedBox(height: 24),

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            healthRating.color.withValues(alpha: 0.2),
            healthRating.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: healthRating.color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: healthRating.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: healthRating.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        healthRating.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
    ).animate().fadeIn(duration: 400.ms).scale(
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
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildTrendChart(BuildContext context, SalesTrendAnalysis trendAnalysis) {
    if (trendAnalysis.historicalData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
                  color: trendAnalysis.trendDirection.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: trendAnalysis.trendDirection.color.withValues(alpha: 0.3),
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
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateYInterval(trendAnalysis),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.getBorderColor(context)
                          .withValues(alpha: 0.3),
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
                borderData: FlBorderData(
                  show: false,
                ),
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
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildTimePatternsSection(
    BuildContext context,
    TimePatternAnalytics timePatterns,
  ) {
    if (timePatterns.hourlyPatterns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pola Waktu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timePatterns.bestTimeSummary,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
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
                        if (value.toInt() % 3 != 0) return const SizedBox.shrink();
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getRankColor(rank).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(rank),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
          ...displayCategories.map((category) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryItem(context, category),
              )),
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
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: category.profitMargin / 100,
            backgroundColor: AppTheme.getBorderColor(context),
            valueColor: AlwaysStoppedAnimation<Color>(category.rating.color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Margin: ${category.profitMargin.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiary,
              ),
            ),
            Text(
              category.rating.displayName,
              style: TextStyle(
                fontSize: 10,
                color: category.rating.color,
                fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
          ...comparative.metricComparisons.map((metric) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMetricComparison(context, metric),
              )),
        ],
      ),
    );
  }

  Widget _buildMetricComparison(
    BuildContext context,
    MetricComparison metric,
  ) {
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
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: metric.direction.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: metric.direction.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                metric.direction.icon,
                size: 14,
                color: metric.direction.color,
              ),
              const SizedBox(width: 4),
              Text(
                '${metric.changePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: metric.direction.color,
                  fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.infoColor.withValues(alpha: 0.1),
            AppTheme.infoColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.infoColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.summarize,
                  size: 18,
                  color: AppTheme.infoColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Eksekutif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...summary.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getTextPrimaryColor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionItemsSection(
    BuildContext context,
    List<String> actions,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warningColor.withValues(alpha: 0.1),
            AppTheme.warningColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.task_alt,
                  size: 18,
                  color: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rekomendasi Tindakan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 16,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getTextPrimaryColor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Helper methods for charts

  List<FlSpot> _createHistoricalSpots(SalesTrendAnalysis analysis) {
    final spots = <FlSpot>[];
    for (int i = 0; i < analysis.historicalData.length; i++) {
      final data = analysis.historicalData[i];
      spots.add(FlSpot(
        data.date.millisecondsSinceEpoch.toDouble(),
        data.revenue,
      ));
    }
    return spots;
  }

  List<FlSpot> _createForecastSpots(SalesTrendAnalysis analysis) {
    final spots = <FlSpot>[];
    for (int i = 0; i < analysis.forecastData.length; i++) {
      final data = analysis.forecastData[i];
      spots.add(FlSpot(
        data.date.millisecondsSinceEpoch.toDouble(),
        data.revenue,
      ));
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
      return analysis.historicalData.last.date.millisecondsSinceEpoch.toDouble();
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
