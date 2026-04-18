import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';
import 'package:simple_pos/features/sales/presentation/widgets/analytics/category_performance_item.dart';

/// Category Performance Section Widget
class CategoryPerformanceWidget extends StatelessWidget {
  final List<CategoryPerformance> categories;

  const CategoryPerformanceWidget({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final displayCategories = categories.take(5).toList();
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
            'Performa Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          ...displayCategories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CategoryPerformanceItem(category: category),
            ),
          ),
        ],
      ),
    );
  }
}