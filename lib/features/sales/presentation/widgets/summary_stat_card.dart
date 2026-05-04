import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';

/// Summary stat card for displaying key metrics in Sales Reports
/// Features:
/// - Matching colored icon and bold brutal border
/// - Title, value, and optional subtitle
/// - 8px brutal border radius (Neo-Brutalist)
/// - Chunky shadow for bold appearance
class SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const SummaryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: NeoBrutalTheme.chunkyShadow,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: NeoBrutalTheme.spaceSM),
              Expanded(
                child: Text(
                  title,
                  style: NeoBrutalTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            value,
            style: NeoBrutalTheme.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: NeoBrutalTheme.spaceXS),
            Text(
              subtitle!,
              style: NeoBrutalTheme.bodySmall.copyWith(
                color: secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
