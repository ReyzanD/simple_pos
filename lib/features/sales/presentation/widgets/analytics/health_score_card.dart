import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';

/// Health score card widget for analytics
class HealthScoreCard extends StatelessWidget {
  final AnalyticsKPIs kpis;

  const HealthScoreCard({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    final healthRating = kpis.healthRating;
    return Container(
          padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
          decoration: BoxDecoration(
            color: healthRating.color,
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusMedium,
                  ),
                  border: Border.all(color: Colors.black, width: 3),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              NeoBrutalTheme.radiusMedium,
                            ),
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: Text(
                            healthRating.displayName,
                            style: TextStyle(
                              color: healthRating.color,
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
}
