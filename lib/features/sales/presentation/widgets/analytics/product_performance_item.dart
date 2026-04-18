import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';

/// Product Performance Item Widget
class ProductPerformanceItem extends StatelessWidget {
  final ProductPerformance product;
  final int rank;

  const ProductPerformanceItem({
    super.key,
    required this.product,
    required this.rank,
  });

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.warningColor; // 🥇 Gold
      case 2:
        return Colors.grey.shade400; // 🥈 Silver
      case 3:
        return Colors.orange.shade600; // 🥉 Bronze
      default:
        return NeoBrutalTheme.primary; // Default primary color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceSM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.quantitySold} terjual',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(product.revenue),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.rating.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.rating.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    color: product.rating.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}