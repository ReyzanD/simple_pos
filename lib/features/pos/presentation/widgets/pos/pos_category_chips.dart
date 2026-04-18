import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/widgets/category_icons.dart';
import 'package:simple_pos/core/widgets/brutal_widgets.dart';
import 'package:simple_pos/features/pos/presentation/controllers/pos_controller.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/category_controller.dart';

/// POS Category Chips - Horizontal scrollable category filter
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

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          // First item is "All" category
          if (index == 0) {
            final isSelected = selectedCategory == null;
            return POSCategoryChip(
              label: 'Semua',
              icon: Icons.apps_rounded,
              color: AppTheme.primaryColor,
              isSelected: isSelected,
              onTap: () => posController.setCategoryFilter(null),
            );
          }

          // Rest are actual categories
          final category = categories[index - 1];
          final isSelected = selectedCategory?.id == category.id;
          // Use dynamic icon from CategoryIcons
          final categoryIcon = CategoryIcons.getIcon(category.name);
          final categoryColor = CategoryColors.getColor(category.name);
          return POSCategoryChip(
            label: category.name,
            icon: categoryIcon,
            color: categoryColor,
            isSelected: isSelected,
            onTap: () => posController.setCategoryFilter(category),
          );
        },
      ),
    );
  }
}

/// Individual category chip widget
class POSCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const POSCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: BrutalActionChip(
        label: label,
        icon: icon,
        onTap: onTap,
        isSelected: isSelected,
        backgroundColor: isSelected ? color : NeoBrutalTheme.surface,
      ),
    );
  }
}
