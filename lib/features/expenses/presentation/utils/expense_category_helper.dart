import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../expenses/domain/constants/expense_categories.dart';

/// Helper class for expense category UI properties
/// Maps category names to colors and icons for display
class ExpenseCategoryHelper {
  ExpenseCategoryHelper._();

  /// Get color for a category name
  /// Returns AppTheme color based on the category's color name
  static Color getCategoryColor(String category) {
    final colorName = ExpenseCategories.getCategoryColor(category);

    return switch (colorName.toLowerCase()) {
      'red' => AppTheme.errorColor,
      'green' => AppTheme.successColor,
      'blue' => AppTheme.infoColor,
      'yellow' => AppTheme.warningColor,
      'purple' => const Color(0xFF9333EA),
      'orange' => const Color(0xFFF97316),
      'teal' => AppTheme.secondaryColor,
      'pink' => const Color(0xFFEC4899),
      'grey' => AppTheme.textSecondary,
      _ => AppTheme.textSecondary,
    };
  }

  /// Get icon data for a category name
  /// Returns IconData based on the category's icon name
  static IconData getCategoryIcon(String category) {
    final iconName = ExpenseCategories.getCategoryIcon(category);

    return switch (iconName) {
      'home' => Icons.home,
      'bolt' => Icons.bolt,
      'shopping_cart' => Icons.shopping_cart,
      'inventory' => Icons.inventory_2,
      'build' => Icons.build,
      'payments' => Icons.payments,
      'people' => Icons.people,
      'receipt' => Icons.receipt_long,
      'list' => Icons.list,
      _ => Icons.receipt_long,
    };
  }

  /// Get display name for a category (returns as-is since we use names directly)
  static String getCategoryDisplayName(String category) => category;
}
