import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';

/// Category Performance Item Widget
class CategoryPerformanceItem extends StatelessWidget {
  final CategoryPerformance category;

  const CategoryPerformanceItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
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
        SizedBox(height: NeoBrutalTheme.spaceXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          child: LinearProgressIndicator(
            value: category.profitMargin / 100,
            backgroundColor: Colors.black.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(category.rating.color),
            minHeight: 8,
          ),
        ),
        SizedBox(height: NeoBrutalTheme.spaceXS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Margin: ${category.profitMargin.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: NeoBrutalTheme.spaceSM,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: category.rating.color,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Text(
                category.rating.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}