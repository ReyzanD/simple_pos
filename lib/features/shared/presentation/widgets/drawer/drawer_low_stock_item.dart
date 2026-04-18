import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:simple_pos/features/inventory/presentation/screens/low_stock_dashboard_screen.dart';

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
