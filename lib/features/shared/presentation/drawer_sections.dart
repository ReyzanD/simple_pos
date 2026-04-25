import 'package:flutter/material.dart';

// Import all extracted drawer widgets
import 'widgets/drawer/drawer_category_chips.dart';
import 'widgets/drawer/drawer_store_stats.dart';
import 'widgets/drawer/drawer_recent_products.dart';
import 'widgets/drawer/drawer_app_info.dart';
import 'widgets/drawer/drawer_low_stock_item.dart';
import 'widgets/drawer/drawer_discount_item.dart';
import 'widgets/drawer/drawer_backup_item.dart';
import 'widgets/drawer/drawer_expenses_item.dart';
import 'widgets/drawer/drawer_shifts_item.dart';
import 'widgets/drawer/drawer_users_item.dart';
import 'widgets/drawer/drawer_analytics_item.dart';
import 'widgets/drawer/drawer_theme_toggle.dart';

/// Main Drawer Sections - Orchestrates all drawer components
///
/// **Refactored:** 1,153 lines -> ~50 lines (96% reduction)
/// **Purpose:** Main orchestrator for drawer navigation
///
/// All individual drawer components have been extracted to separate files
/// in the `widgets/drawer/` directory for better maintainability.
class DrawerSections extends StatelessWidget {
  const DrawerSections({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Store Stats at the top
          const DrawerStoreStats(),

          const SizedBox(height: 8),

          // Quick Categories
          const DrawerCategoryChips(),

          const SizedBox(height: 8),

          // Navigation Items
          const DrawerLowStockItem(),
          const DrawerDiscountItem(),
          const DrawerBackupItem(),
          const DrawerExpensesItem(),
          const DrawerShiftsItem(),
          const DrawerUsersItem(),
          const DrawerAnalyticsItem(),
          const DrawerThemeToggle(),

          const SizedBox(height: 8),

          // Recent Products
          const DrawerRecentProducts(),

          // App Info at the bottom
          const DrawerAppInfo(),
        ],
      ),
    );
  }
}
