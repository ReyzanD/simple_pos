import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import 'package:simple_pos/core/widgets/category_icons.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';

// Import the shared divider widget
import 'drawer_section_divider.dart';

/// Recent Products Section - Last 5 recently added/modified products
class DrawerRecentProducts extends StatelessWidget {
  const DrawerRecentProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final products = controller.allProducts;

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort by last modified (assuming newer products are added last)
        final recentProducts = products.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DrawerSectionDivider(
              title: 'Recent Products',
              icon: Icons.history,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: recentProducts.map((product) {
                  return _RecentProductTile(product: product);
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _RecentProductTile extends StatelessWidget {
  final Product product;

  const _RecentProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;
    final categoryColor = CategoryColors.getColor('Category ${product.categoryId ?? 0}');

    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        // Navigate to edit product - would need navigation implementation
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Category icon placeholder
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isOutOfStock
                              ? AppTheme.errorColor
                              : isLowStock
                                  ? AppTheme.warningColor
                                  : AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ],
        ),
      ),
    );
  }
}
