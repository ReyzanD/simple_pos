import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';
import 'package:simple_pos/features/sales/presentation/widgets/analytics/metric_comparison_widget.dart';

/// Comparative Analytics Section Widget
class ComparativeAnalyticsWidget extends StatelessWidget {
  final ComparativeAnalytics comparative;

  const ComparativeAnalyticsWidget({
    super.key,
    required this.comparative,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 4,
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
              child: MetricComparisonWidget(metric: metric),
            ),
          ),
        ],
      ),
    );
  }
}