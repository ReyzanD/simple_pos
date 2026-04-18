import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';
import 'package:simple_pos/features/sales/presentation/widgets/analytics/product_performance_item.dart';

/// Top Products Section Widget
class TopProductsWidget extends StatelessWidget {
  final List<ProductPerformance> products;

  const TopProductsWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final displayProducts = products.take(5).toList();
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
              const Icon(
                Icons.emoji_events,
                color: AppTheme.warningColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Produk Terlaris',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return ProductPerformanceItem(
              product: product,
              rank: index + 1,
            );
          }),
        ],
      ),
    );
  }
}