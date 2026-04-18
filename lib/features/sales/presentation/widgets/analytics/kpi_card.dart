import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';

/// KPI card widget for analytics
class KPICard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String subtitle;

  const KPICard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final iconSize = (maxHeight * 0.45).clamp(36.0, 44.0);
        final valueSize = (maxHeight * 0.22).clamp(16.0, 20.0);
        final titleSize = (maxHeight * 0.13).clamp(10.0, 12.0);

        return Container(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD * 0.8),
              decoration: BoxDecoration(
                color: NeoBrutalTheme.background,
                borderRadius: BorderRadius.circular(
                  NeoBrutalTheme.radiusMedium,
                ),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: NeoBrutalTheme.chunkyShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(
                              NeoBrutalTheme.radiusSmall,
                            ),
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: NeoBrutalTheme.chunkyShadow,
                          ),
                          child: Icon(
                            icon,
                            size: iconSize * 0.55,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: titleSize,
                              color: AppTheme.getTextSecondaryColor(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
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
}
