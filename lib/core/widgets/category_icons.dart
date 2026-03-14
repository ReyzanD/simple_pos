import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Category icons and colors for consistent display across the app
///
/// Usage:
/// ```dart
/// final iconData = CategoryIcons.getIcon('Electronics');
/// final color = CategoryColors.getColor('Electronics');
/// ```
class CategoryIcons {
  // Private constructor
  CategoryIcons._();

  static const Map<String, IconData> _icons = {
    // Default
    'default': Icons.category,

    // Food & Beverages
    'food': Icons.restaurant,
    'beverage': Icons.local_drink,
    'coffee': Icons.coffee,
    'bakery': Icons.bakery_dining,
    'snack': Icons.fastfood,

    // Electronics
    'electronics': Icons.devices,
    'phone': Icons.phone_android,
    'laptop': Icons.laptop,
    'tablet': Icons.tablet_android,
    'accessories': Icons.cable,

    // Clothing
    'clothing': Icons.checkroom,
    'shoes': Icons.shopping_bag,
    'accessories_fashion': Icons.diamond,

    // Home & Living
    'home': Icons.home,
    'furniture': Icons.chair,
    'decor': Icons.vignette,

    // Sports & Outdoors
    'sports': Icons.sports_basketball,
    'fitness': Icons.fitness_center,
    'outdoor': Icons.hiking,

    // Beauty & Health
    'beauty': Icons.face,
    'health': Icons.medical_services,
    'personal_care': Icons.spa,

    // Office & Stationery
    'office': Icons.business_center,
    'stationery': Icons.edit,

    // Automotive
    'automotive': Icons.directions_car,
    'motorcycle': Icons.two_wheeler,

    // Books & Media
    'books': Icons.menu_book,
    'music': Icons.headphones,
    'games': Icons.sports_esports,

    // Pet Supplies
    'pets': Icons.pets,

    // Baby & Kids
    'baby': Icons.child_care,
    'toys': Icons.toys,

    // Services
    'services': Icons.construction,
    'subscription': Icons.card_membership,
  };

  /// Get icon for a category by name
  static IconData getIcon(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) {
      return _icons['default']!;
    }

    // Try exact match (case-insensitive)
    final lowerName = categoryName.toLowerCase();
    if (_icons.containsKey(lowerName)) {
      return _icons[lowerName]!;
    }

    // Try partial match
    for (final key in _icons.keys) {
      if (lowerName.contains(key) || key.contains(lowerName)) {
        return _icons[key]!;
      }
    }

    // Generate icon based on first letter
    return _getIconForLetter(categoryName[0].toUpperCase());
  }

  static IconData _getIconForLetter(String letter) {
    switch (letter) {
      case 'A':
        return Icons.abc;
      case 'B':
        return Icons.bookmark;
      case 'C':
        return Icons.category;
      case 'D':
        return Icons.dashboard;
      case 'E':
        return Icons.electrical_services;
      case 'F':
        return Icons.fastfood;
      case 'G':
        return Icons.games;
      case 'H':
        return Icons.home;
      case 'I':
        return Icons.info;
      case 'J':
        return Icons.sports_esports;
      case 'K':
        return Icons.key;
      case 'L':
        return Icons.label;
      case 'M':
        return Icons.music_note;
      case 'N':
        return Icons.notifications;
      case 'O':
        return Icons.outlet;
      case 'P':
        return Icons.phone;
      case 'Q':
        return Icons.question_mark;
      case 'R':
        return Icons.receipt;
      case 'S':
        return Icons.star;
      case 'T':
        return Icons.tag;
      case 'U':
        return Icons.upload;
      case 'V':
        return Icons.video_library;
      case 'W':
        return Icons.watch;
      case 'X':
        return Icons.close;
      case 'Y':
        return Icons.yard;
      case 'Z':
        return Icons.zoom_in;
      default:
        return Icons.category;
    }
  }
}

/// Category colors for consistent theming
class CategoryColors {
  // Private constructor
  CategoryColors._();

  static const List<Color> _presetColors = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF14B8A6), // Teal
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF10B981), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFF6366F1), // Indigo Light
    Color(0xFF84CC16), // Lime
    Color(0xFF06B6D4), // Cyan
    Color(0xFFD946EF), // Fuchsia
  ];

  /// Get color for a category by name (consistent based on name hash)
  static Color getColor(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) {
      return AppTheme.primaryColor;
    }

    // Generate consistent color based on name hash
    final hash = categoryName.hashCode.abs();
    return _presetColors[hash % _presetColors.length];
  }

  /// Get lighter version of color for backgrounds
  static Color getLightColor(String? categoryName) {
    final baseColor = getColor(categoryName);
    return baseColor.withValues(alpha: 0.15);
  }
}

/// Widget displaying category icon with background
class CategoryIconBadge extends StatelessWidget {
  final String categoryName;
  final double size;
  final VoidCallback? onTap;

  const CategoryIconBadge({
    super.key,
    required this.categoryName,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIcons.getIcon(categoryName);
    final color = CategoryColors.getColor(categoryName);
    final lightColor = CategoryColors.getLightColor(categoryName);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          // HapticHelper.lightImpact();
          onTap!();
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(size * 0.25),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: color,
        ),
      ),
    );
  }
}

/// Widget displaying category pill/chip
class CategoryPill extends StatelessWidget {
  final String categoryName;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showIcon;

  const CategoryPill({
    super.key,
    required this.categoryName,
    this.onTap,
    this.isSelected = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIcons.getIcon(categoryName);
    final color = CategoryColors.getColor(categoryName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : CategoryColors.getLightColor(categoryName),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable category chips
class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;
  final bool showIcon;

  const CategoryChips({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" option
            final isSelected = selectedCategory == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryPill(
                categoryName: 'Semua',
                isSelected: isSelected,
                showIcon: false,
                onTap: () => onCategorySelected(null),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryPill(
              categoryName: category,
              isSelected: isSelected,
              showIcon: showIcon,
              onTap: () => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}

/// Category card with icon and stats
class CategoryCard extends StatelessWidget {
  final String name;
  final int productCount;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.productCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryColors.getColor(name);
    final icon = CategoryIcons.getIcon(name);

    return GestureDetector(
      onTap: () {
        // HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: CategoryColors.getLightColor(name),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '$productCount produk',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
