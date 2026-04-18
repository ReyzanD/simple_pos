import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/responsive_helper.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';

/// Trend Chart Widget
class TrendChartWidget extends StatelessWidget {
  final SalesTrendAnalysis trendAnalysis;

  const TrendChartWidget({
    super.key,
    required this.trendAnalysis,
  });

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
    return max * 1.2;
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

  @override
  Widget build(BuildContext context) {
    if (trendAnalysis.historicalData.isEmpty) {
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
            height: ResponsiveHelper.getChartHeight(context),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateYInterval(trendAnalysis),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
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
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}