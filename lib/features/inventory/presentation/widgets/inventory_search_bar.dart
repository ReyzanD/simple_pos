import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';
import '../controllers/inventory_controller.dart';
/// Modern Material 3 search bar with filters for inventory screen
///
/// Material 3 Features:
/// - Rounded with 30px border radius
/// - Light grey filled background (#F1F5F9)
/// - Subtle border
/// - Category and supplier filter chips
/// - In-stock only toggle
/// - Sort dropdown
class InventorySearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final List<entities.Category> categories;
  final List<Supplier> suppliers;
  final int? selectedCategoryId;
  final int? selectedSupplierId;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<int?> onSupplierChanged;
  final VoidCallback onClearFilters;
  final bool inStockOnly;
  final VoidCallback onToggleInStockOnly;
  final ProductSortOption sortOption;
  final ValueChanged<ProductSortOption> onSortChanged;

  const InventorySearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    required this.categories,
    required this.suppliers,
    required this.selectedCategoryId,
    required this.selectedSupplierId,
    required this.onCategoryChanged,
    required this.onSupplierChanged,
    required this.onClearFilters,
    this.inStockOnly = false,
    required this.onToggleInStockOnly,
    required this.sortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategoryId != null || selectedSupplierId != null || inStockOnly;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar with sort button
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                            onPressed: onClear,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              // Sort dropdown
              _buildSortDropdown(context),
            ],
          ),

          // Filter chips
          if (categories.isNotEmpty || suppliers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // In-stock only filter
                _buildInStockChip(),
                // Category filter
                if (categories.isNotEmpty)
                  _buildFilterChip(
                    context: context,
                    label: selectedCategoryId == null
                        ? 'Semua Kategori'
                        : categories.firstWhere(
                            (c) => c.id == selectedCategoryId,
                            orElse: () => categories.first,
                          ).name,
                    isSelected: selectedCategoryId != null,
                    onTap: () => _showCategoryFilter(context),
                  ),
                // Supplier filter
                if (suppliers.isNotEmpty)
                  _buildFilterChip(
                    context: context,
                    label: selectedSupplierId == null
                        ? 'Semua Pemasok'
                        : suppliers.firstWhere(
                            (s) => s.id == selectedSupplierId,
                            orElse: () => suppliers.first,
                          ).name,
                    isSelected: selectedSupplierId != null,
                    onTap: () => _showSupplierFilter(context),
                  ),
                // Clear filters button
                if (hasFilters)
                  _buildClearFiltersChip(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final chipColor = icon != null
        ? AppTheme.primaryColor
        : (isSelected ? AppTheme.primaryColor : AppTheme.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInStockChip() {
    return GestureDetector(
      onTap: onToggleInStockOnly,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: inStockOnly
              ? AppTheme.successColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: inStockOnly
                ? AppTheme.successColor
                : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              inStockOnly ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: inStockOnly
                  ? AppTheme.successColor
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Ada Stok',
              style: TextStyle(
                fontSize: 13,
                fontWeight: inStockOnly ? FontWeight.w600 : FontWeight.normal,
                color: inStockOnly
                    ? AppTheme.successColor
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    IconData sortIcon;

    switch (sortOption) {
      case ProductSortOption.nameAsc:
        sortIcon = Icons.sort_by_alpha;
        break;
      case ProductSortOption.nameDesc:
        sortIcon = Icons.sort_by_alpha;
        break;
      case ProductSortOption.priceAsc:
        sortIcon = Icons.arrow_upward;
        break;
      case ProductSortOption.priceDesc:
        sortIcon = Icons.arrow_downward;
        break;
      case ProductSortOption.stockLevel:
        sortIcon = Icons.inventory_2_outlined;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 0.5,
        ),
      ),
      child: PopupMenuButton<ProductSortOption>(
        icon: Icon(sortIcon, color: AppTheme.textSecondary, size: 20),
        tooltip: 'Urutkan',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppTheme.getCardColor(context),
        onSelected: onSortChanged,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ProductSortOption.nameAsc,
            child: _buildSortMenuItem(
              label: 'Nama (A-Z)',
              icon: Icons.sort_by_alpha,
              isSelected: sortOption == ProductSortOption.nameAsc,
            ),
          ),
          PopupMenuItem(
            value: ProductSortOption.nameDesc,
            child: _buildSortMenuItem(
              label: 'Nama (Z-A)',
              icon: Icons.sort_by_alpha,
              isSelected: sortOption == ProductSortOption.nameDesc,
            ),
          ),
          PopupMenuItem(
            value: ProductSortOption.priceAsc,
            child: _buildSortMenuItem(
              label: 'Harga (Rendah-Tinggi)',
              icon: Icons.arrow_upward,
              isSelected: sortOption == ProductSortOption.priceAsc,
            ),
          ),
          PopupMenuItem(
            value: ProductSortOption.priceDesc,
            child: _buildSortMenuItem(
              label: 'Harga (Tinggi-Rendah)',
              icon: Icons.arrow_downward,
              isSelected: sortOption == ProductSortOption.priceDesc,
            ),
          ),
          PopupMenuItem(
            value: ProductSortOption.stockLevel,
            child: _buildSortMenuItem(
              label: 'Tingkat Stok',
              icon: Icons.inventory_2_outlined,
              isSelected: sortOption == ProductSortOption.stockLevel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortMenuItem({
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check,
            size: 18,
            color: AppTheme.primaryColor,
          ),
      ],
    );
  }

  Widget _buildClearFiltersChip() {
    return GestureDetector(
      onTap: onClearFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.clear,
              size: 16,
              color: AppTheme.errorColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Hapus Filter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (selectedCategoryId != null)
                    TextButton(
                      onPressed: () {
                        onCategoryChanged(null);
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
            ),

            // Category list
            ...[
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  selectedCategoryId == null
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: selectedCategoryId == null
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
                title: const Text('Semua Kategori'),
                onTap: () {
                  onCategoryChanged(null);
                  Navigator.pop(sheetContext);
                },
              ),
            ],

            ...categories.map((category) {
              final isSelected = category.id == selectedCategoryId;
              final categoryIcon = CategoryIcons.getIcon(category.name);
              final categoryColor = CategoryColors.getColor(category.name);
              return Column(
                children: [
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                    title: Text(category.name),
                    onTap: () {
                      onCategoryChanged(category.id);
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              );
            }),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSupplierFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter Pemasok',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (selectedSupplierId != null)
                    TextButton(
                      onPressed: () {
                        onSupplierChanged(null);
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
            ),

            // Supplier list
            ...[
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  selectedSupplierId == null
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: selectedSupplierId == null
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
                title: const Text('Semua Pemasok'),
                onTap: () {
                  onSupplierChanged(null);
                  Navigator.pop(sheetContext);
                },
              ),
            ],

            ...suppliers.map((supplier) {
              final isSelected = supplier.id == selectedSupplierId;
              return Column(
                children: [
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                    title: Text(supplier.name),
                    onTap: () {
                      onSupplierChanged(supplier.id);
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              );
            }),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
