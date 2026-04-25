import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import 'package:simple_pos/core/widgets/category_icons.dart';
import '../../providers.dart';

// Import the shared divider widget
import 'drawer_section_divider.dart';

/// Category Quick Links Section - Horizontal scrollable chips
class DrawerCategoryChips extends ConsumerWidget {
  const DrawerCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryController = ref.watch(inventoryControllerProvider);
    final products = inventoryController.allProducts;

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get unique category IDs and count products per category
    final categoryMap = <int, int>{};
    for (final product in products) {
      if (product.categoryId != null) {
        categoryMap[product.categoryId!] = (categoryMap[product.categoryId!] ?? 0) + 1;
      }
    }

    if (categoryMap.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DrawerSectionDivider(
          title: 'Quick Categories',
          icon: Icons.category_outlined,
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categoryMap.length > 5 ? 5 : categoryMap.length,
            itemBuilder: (context, index) {
              final categoryId = categoryMap.keys.elementAt(index);
              final count = categoryMap[categoryId]!;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  categoryId: categoryId,
                  productCount: count,
                  onTap: () {
                    HapticHelper.lightImpact();
                    Navigator.pop(context);
                    // Navigate to inventory with category filter
                    // This would require adding filter support to InventoryScreen
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final int categoryId;
  final int productCount;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.categoryId,
    required this.productCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Generate color based on category ID
    final color = CategoryColors.getColor('Category $categoryId');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: NeoBrutalTheme.spaceSM, vertical: NeoBrutalTheme.spaceXS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall), // ✅ Brutal radius
          border: Border.all(
            color: color, // ✅ Bold colored border
            width: 2, // ✅ Bold 2px border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category, size: 16, color: color),
            SizedBox(width: NeoBrutalTheme.spaceXS),
            Text(
              'Category $categoryId',
              style: NeoBrutalTheme.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(width: NeoBrutalTheme.spaceXS),
            Text(
              '($productCount)',
              style: NeoBrutalTheme.labelSmall.copyWith(
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
