import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';

/// Metric Comparison Widget
class MetricComparisonWidget extends StatelessWidget {
  final MetricComparison metric;

  const MetricComparisonWidget({
    super.key,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
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
            color: metric.direction.color,
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
            border: Border.all(
              color: Colors.black,
              width: 3,
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Row(
            children: [
              Icon(
                metric.direction.icon,
                size: 14,
                color: Colors.white,
              ),
              SizedBox(width: NeoBrutalTheme.spaceXS),
              Text(
                '${metric.changePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white,
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
}