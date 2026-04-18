import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/analytics_controller.dart';
import '../../domain/entities/sales_analytics.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_display.dart';

// Import extracted analytics widgets
import '../widgets/analytics/analytics_empty_state.dart';
import '../widgets/analytics/health_score_card.dart';
import '../widgets/analytics/kpis_grid.dart';
import '../widgets/analytics/trend_chart_widget.dart';
import '../widgets/analytics/time_patterns_widget.dart';
import '../widgets/analytics/top_products_widget.dart';
import '../widgets/analytics/category_performance_widget.dart';
import '../widgets/analytics/comparative_analytics_widget.dart';
import '../widgets/analytics/executive_summary_widget.dart';
import '../widgets/analytics/action_items_widget.dart';

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
          backgroundColor: NeoBrutalTheme.background,
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
                      width: 4,
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
                color: NeoBrutalTheme.blockYellow,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 6,
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
    return const AnalyticsEmptyState();
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    SalesAnalyticsReport report,
  ) {
    return RefreshIndicator(
      onRefresh: context.read<AnalyticsController>().refresh,
      color: NeoBrutalTheme.primary,
      backgroundColor: NeoBrutalTheme.blockYellow.withValues(alpha: 0.3),
      strokeWidth: 4,
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
            HealthScoreCard(kpis: report.kpis),
            const SizedBox(height: 16),

            KPIsGrid(kpis: report.kpis),
            const SizedBox(height: 24),

            if (report.trendAnalysis.historicalData.isNotEmpty) ...[
              TrendChartWidget(trendAnalysis: report.trendAnalysis),
              const SizedBox(height: 24),
            ],

            if (report.timePatterns.hourlyPatterns.isNotEmpty) ...[
              TimePatternsWidget(timePatterns: report.timePatterns),
              const SizedBox(height: 24),
            ],

            if (report.topProducts.isNotEmpty) ...[
              TopProductsWidget(products: report.topProducts),
              const SizedBox(height: 24),
            ],

            if (report.categoryPerformance.isNotEmpty) ...[
              CategoryPerformanceWidget(
                categories: report.categoryPerformance,
              ),
              const SizedBox(height: 24),
            ],

            ComparativeAnalyticsWidget(
              comparative: report.comparativeAnalytics,
            ),
            const SizedBox(height: 24),

            if (report.executiveSummary.isNotEmpty) ...[
              ExecutiveSummaryWidget(summary: report.executiveSummary),
              const SizedBox(height: 24),
            ],

            if (report.actionItems.isNotEmpty)
              ActionItemsWidget(actions: report.actionItems),
          ],
        ),
      ),
    );
  }
}
