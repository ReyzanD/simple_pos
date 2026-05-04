import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chart_enums.dart';
import '../controllers/analytics_controller.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../../l10n/app_localizations.dart';

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
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsControllerProvider).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(analyticsControllerProvider);
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final backgroundColor = NeoBrutalTheme.getBackgroundColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.sales_analytics_title),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: NeoBrutalTheme.spaceXS),
            child: Container(
              decoration: BoxDecoration(
                color: NeoBrutalTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(color: borderColor, width: 4),
              ),
              child: PopupMenuButton<DateRangePreset>(
                icon: Icon(Icons.date_range, color: NeoBrutalTheme.secondary),
                onSelected: (preset) => controller.setPredefinedRange(preset),
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
                  side: BorderSide(color: borderColor, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
      body: controller.isLoading && !controller.hasReport
          ? LoadingIndicator(
              message: AppLocalizations.of(context)!.common_loading,
            )
          : controller.hasError
          ? ErrorDisplay.fromException(
              controller.error!,
              onRetry: () => controller.loadAnalytics(),
            )
          : controller.hasReport
          ? _buildAnalyticsContent(context, controller)
          : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return const AnalyticsEmptyState();
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    AnalyticsController controller,
  ) {
    final report = controller.report!;
    return RefreshIndicator(
      onRefresh: ref.read(analyticsControllerProvider).refresh,
      color: NeoBrutalTheme.primary,
      backgroundColor: NeoBrutalTheme.blockBlue.withValues(alpha: 0.3),
      strokeWidth: 4,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: ResponsiveHelper.getScreenPadding(context).left,
          right: ResponsiveHelper.getScreenPadding(context).right,
          top: ResponsiveHelper.getScreenPadding(context).top,
          bottom: ResponsiveHelper.getBottomPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HealthScoreCard(kpis: report.kpis),
            const SizedBox(height: 16),

            KPIsGrid(kpis: report.kpis),
            const SizedBox(height: 24),

            if (report.trendAnalysis.historicalData.isNotEmpty) ...[
              TrendChartWidget(
                trendAnalysis: report.trendAnalysis,
                selectedMetric: controller.selectedMetric,
                onMetricChanged: (metric) => controller.setMetric(metric),
              ),
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
              CategoryPerformanceWidget(categories: report.categoryPerformance),
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
