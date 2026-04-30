import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/widgets/category_icons.dart';
import 'package:simple_pos/core/widgets/brutal_widgets.dart';
import 'package:simple_pos/features/pos/presentation/controllers/pos_controller.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/category_controller.dart';

/// POS Category Chips - Horizontal scrollable category filter
///
/// Fully responsive layout that adapts to all screen sizes
class POSCategoryChips extends StatelessWidget {
  final CategoryController categoryController;
  final POSController posController;

  const POSCategoryChips({
    super.key,
    required this.categoryController,
    required this.posController,
  });

  @override
  Widget build(BuildContext context) {
    final categories = categoryController.categories;
    final selectedCategory = posController.selectedCategory;
    final isSemuaSelected = selectedCategory == null;

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // "SEMUA" button
            ResponsiveCategoryChip(
              label: 'Semua',
              icon: Icons.apps_rounded,
              color: AppTheme.primaryColor,
              isSelected: isSemuaSelected,
              onTap: () => posController.setCategoryFilter(null),
            ),
            const SizedBox(width: 8),
            // All category chips
            ...categories.map((category) {
              final isSelected = selectedCategory?.id == category.id;
              final categoryIcon = CategoryIcons.getIcon(category.name);
              final categoryColor = CategoryColors.getColor(category.name);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ResponsiveCategoryChip(
                  label: category.name,
                  icon: categoryIcon,
                  color: categoryColor,
                  isSelected: isSelected,
                  onTap: () => posController.setCategoryFilter(category),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
