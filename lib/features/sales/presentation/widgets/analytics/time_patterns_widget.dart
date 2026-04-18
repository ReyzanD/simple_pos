import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/responsive_helper.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';

/// Time Patterns Widget
class TimePatternsWidget extends StatelessWidget {
  final TimePatternAnalytics timePatterns;

  const TimePatternsWidget({
    super.key,
    required this.timePatterns,
  });

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

  @override
  Widget build(BuildContext context) {
    if (timePatterns.hourlyPatterns.isEmpty) {
      return const SizedBox.shrink();
    }

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
}