import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neo_brutal_theme.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../core/widgets/category_icons.dart';
import '../../inventory/presentation/controllers/inventory_controller.dart';
import '../../inventory/presentation/screens/low_stock_dashboard_screen.dart';
import '../../sales/presentation/controllers/discount_controller.dart';
import '../../sales/presentation/screens/discount_management_screen.dart';
import '../../sales/presentation/controllers/sales_report_controller.dart';
import '../../sales/presentation/screens/analytics_screen.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../inventory/domain/entities/product.dart';
import '../../expenses/presentation/screens/expense_screen.dart';
import '../../shifts/presentation/screens/shift_management_screen.dart';
import '../../users/presentation/screens/user_management_screen.dart';
import '../../backup/presentation/screens/backup_screen.dart';
import '../../backup/presentation/controllers/backup_controller.dart';

/// Section divider for drawer content
class DrawerSectionDivider extends StatelessWidget {
  final String title;
  final IconData? icon;

  const DrawerSectionDivider({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceSM,
      ),
      padding: EdgeInsets.all(NeoBrutalTheme.spaceSM),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue, // ✅ Bold blue background
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 4, // ✅ Bold border
        ),
        boxShadow: NeoBrutalTheme.softShadow,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(width: NeoBrutalTheme.spaceSM),
          ],
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Quick Links Section - Horizontal scrollable chips
class DrawerCategoryChips extends StatelessWidget {
  const DrawerCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryController = context.watch<InventoryController>();
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

/// Store Stats Card - Today's sales, transaction count, low stock
class DrawerStoreStats extends StatelessWidget {
  const DrawerStoreStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Consumer2<InventoryController, SalesReportController>(
        builder: (context, inventory, salesReport, _) {
          final lowStockCount = inventory.allProducts
              .where((p) => p.isLowStock || p.isOutOfStock)
              .length;

          return Container(
            padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
            decoration: BoxDecoration(
              color: NeoBrutalTheme.blockCoral, // ✅ Bold coral background
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              border: Border.all(
                color: Colors.black, // ✅ Bold black border
                width: 4, // ✅ Bold 4px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow, // ✅ Chunky brutal shadow
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.storefront,
                        size: 16,
                        color: NeoBrutalTheme.primary,
                      ),
                    ),
                    SizedBox(width: NeoBrutalTheme.spaceXS),
                    Text(
                      'Store Stats',
                      style: NeoBrutalTheme.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: NeoBrutalTheme.spaceSM),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.payments_rounded,
                        label: 'Today\'s Sales',
                        value: 'Rp 0',
                        color: AppTheme.successColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.getBorderColor(context),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.receipt_long,
                        label: 'Transactions',
                        value: '0',
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: AppTheme.getBorderColor(context),
                ),
                const SizedBox(height: 8),
                _LowStockAlert(count: lowStockCount),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }
}

class _LowStockAlert extends StatelessWidget {
  final int count;

  const _LowStockAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    final hasLowStock = count > 0;

    return Row(
      children: [
        Icon(
          hasLowStock ? Icons.warning_amber : Icons.check_circle,
          size: 16,
          color: hasLowStock ? AppTheme.warningColor : AppTheme.successColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hasLowStock
                ? '$count items with low stock'
                : 'All stock levels healthy',
            style: TextStyle(
              fontSize: 12,
              color: hasLowStock
                  ? AppTheme.warningColor
                  : AppTheme.getTextSecondaryColor(context),
              fontWeight: hasLowStock ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

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

/// App Info Section - Version, help, about
class DrawerAppInfo extends StatelessWidget {
  const DrawerAppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.help_outline,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          title: Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          onTap: () {
            HapticHelper.lightImpact();
            // Show help dialog
          },
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline_rounded,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          title: Text(
            'About',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          onTap: () {
            HapticHelper.lightImpact();
            // Show about dialog
          },
        ),
      ],
    );
  }
}

/// Modern Low Stock Dashboard Item with Badge
class DrawerLowStockItem extends StatelessWidget {
  const DrawerLowStockItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final lowStockCount = controller.allProducts
            .where((p) => p.isLowStock || p.isOutOfStock)
            .length;

        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMD,
            vertical: NeoBrutalTheme.spaceXS,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.warningColor, // ✅ Solid bold color - no alpha
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              border: Border.all(
                color: Colors.black, // ✅ Bold black border for contrast
                width: 4, // ✅ Bold 4px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow, // ✅ Chunky brutal shadow
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white, // ✅ White icons for contrast
              size: 26,
            ),
          ),
          title: Text(
            'Low Stock Dashboard',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          subtitle: Text(
            'View products with low stock',
            style: NeoBrutalTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          trailing: lowStockCount > 0
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: NeoBrutalTheme.spaceSM, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.warningColor,
                      width: 2, // ✅ Bold border
                    ),
                  ),
                  child: Text(
                    lowStockCount.toString(),
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
          onTap: () {
            HapticHelper.lightImpact();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: controller,
                  child: const LowStockDashboardScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Modern Discount Management Item
class DrawerDiscountItem extends StatelessWidget {
  const DrawerDiscountItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscountController>(
      builder: (context, controller, _) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMD,
            vertical: NeoBrutalTheme.spaceXS,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.successColor, // ✅ Solid bold color
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              border: Border.all(
                color: Colors.black, // ✅ Bold black border
                width: 4, // ✅ Bold 4px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.discount_outlined,
              color: Colors.white, // ✅ White icon
              size: 26,
            ),
          ),
          title: Text(
            'Discount Management',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          subtitle: Text(
            'Manage promotions & discounts',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 20,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          onTap: () {
            HapticHelper.lightImpact();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: controller,
                  child: const DiscountManagementScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Modern Backup Item
class DrawerBackupItem extends StatelessWidget {
  const DrawerBackupItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BackupController>(
      builder: (context, controller, _) {
        final backupCount = controller.backups.length;

        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMD,
            vertical: NeoBrutalTheme.spaceXS,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor, // ✅ Solid bold color
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              border: Border.all(
                color: Colors.black, // ✅ Bold black border
                width: 4, // ✅ Bold 4px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.backup_outlined,
              color: Colors.white, // ✅ White icon
              size: 26,
            ),
          ),
          title: Text(
            'Backup & Restore',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          subtitle: Text(
            'Kelola backup data',
            style: NeoBrutalTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          trailing: backupCount > 0
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: NeoBrutalTheme.spaceSM, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2, // ✅ Bold border
                    ),
                  ),
                  child: Text(
                    backupCount.toString(),
                    style: NeoBrutalTheme.labelSmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
          onTap: () {
            HapticHelper.lightImpact();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: controller,
                  child: const BackupScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Modern Expenses Item
class DrawerExpensesItem extends StatelessWidget {
  const DrawerExpensesItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceXS,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor, // ✅ Solid bold color
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
          border: Border.all(
            color: Colors.black, // ✅ Bold black border
            width: 4, // ✅ Bold 4px border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Icon(
          Icons.receipt_long_outlined,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        'Pengeluaran',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Kelola pengeluaran operasional',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: AppTheme.getTextSecondaryColor(context),
      ),
      onTap: () {
        HapticHelper.lightImpact();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpenseScreen(),
          ),
        );
      },
    );
  }
}

/// Modern Shifts Item
class DrawerShiftsItem extends StatelessWidget {
  const DrawerShiftsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceXS,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.infoColor, // ✅ Solid bold color
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
          border: Border.all(
            color: Colors.black, // ✅ Bold black border
            width: 4, // ✅ Bold 4px border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Icon(
          Icons.schedule_outlined,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        'Shift',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Kelola shift kasir',
        style: NeoBrutalTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: AppTheme.getTextSecondaryColor(context),
      ),
      onTap: () {
        HapticHelper.lightImpact();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShiftManagementScreen(),
          ),
        );
      },
    );
  }
}

/// Modern Users Item
class DrawerUsersItem extends StatelessWidget {
  const DrawerUsersItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceXS,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor, // ✅ Solid bold color
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
          border: Border.all(
            color: Colors.black, // ✅ Bold black border
            width: 4, // ✅ Bold 4px border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Icon(
          Icons.people_outline,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        'Pengguna',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Kelola pengguna aplikasi',
        style: NeoBrutalTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: AppTheme.getTextSecondaryColor(context),
      ),
      onTap: () {
        HapticHelper.lightImpact();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserManagementScreen(),
          ),
        );
      },
    );
  }
}

/// Modern Analytics Item
class DrawerAnalyticsItem extends StatelessWidget {
  const DrawerAnalyticsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceXS,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NeoBrutalTheme.primary, // ✅ Solid bold gradient
              NeoBrutalTheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
          border: Border.all(
            color: Colors.black, // ✅ Bold black border
            width: 4, // ✅ Bold 4px border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: const Icon(
          Icons.analytics_outlined,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        'Analitik Penjualan',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Tren & insight penjualan',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: AppTheme.getTextSecondaryColor(context),
      ),
      onTap: () {
        HapticHelper.lightImpact();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnalyticsScreen(),
          ),
        );
      },
    );
  }
}

/// Theme Toggle Item
class DrawerThemeToggle extends StatelessWidget {
  const DrawerThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMD,
            vertical: NeoBrutalTheme.spaceXS,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.getTextSecondaryColor(context), // ✅ Solid bold color
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              border: Border.all(
                color: Colors.black, // ✅ Bold black border
                width: 4, // ✅ Bold 4px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              themeController.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Colors.white, // ✅ White icon
              size: 26,
            ),
          ),
          title: Text(
            themeController.isDarkMode ? 'Light Mode' : 'Dark Mode',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          subtitle: Text(
            'Toggle app theme',
            style: NeoBrutalTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          trailing: Switch(
            value: themeController.isDarkMode,
            onChanged: (_) => themeController.toggleTheme(),
          ),
          onTap: () {
            HapticHelper.lightImpact();
            themeController.toggleTheme();
          },
        );
      },
    );
  }
}
