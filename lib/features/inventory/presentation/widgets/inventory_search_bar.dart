import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';

/// Modern Material 3 search bar with filters for inventory screen
///
/// Material 3 Features:
/// - Rounded with 30px border radius
/// - Light grey filled background (#F1F5F9)
/// - Subtle border
/// - Category and supplier filter chips
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
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategoryId != null || selectedSupplierId != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
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
                borderSide: BorderSide(color: AppTheme.cardBorder, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppTheme.cardBorder, width: 0.5),
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

          // Filter chips
          if (categories.isNotEmpty || suppliers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Category filter
                if (categories.isNotEmpty) ...[
                  _buildFilterChip(
                    icon: Icons.category,
                    label: selectedCategoryId == null
                        ? 'Semua Kategori'
                        : categories.firstWhere(
                            (c) => c.id == selectedCategoryId,
                            orElse: () => categories.first,
                          ).name,
                    isSelected: selectedCategoryId != null,
                    onTap: () => _showCategoryFilter(context),
                  ),
                  const SizedBox(width: 8),
                ],

                // Supplier filter
                if (suppliers.isNotEmpty) ...[
                  _buildFilterChip(
                    icon: Icons.local_shipping,
                    label: selectedSupplierId == null
                        ? 'Semua Pemasok'
                        : suppliers.firstWhere(
                            (s) => s.id == selectedSupplierId,
                            orElse: () => suppliers.first,
                          ).name,
                    isSelected: selectedSupplierId != null,
                    onTap: () => _showSupplierFilter(context),
                  ),
                  const SizedBox(width: 8),
                ],

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
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.backgroundColor,
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
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
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
          color: AppTheme.cardColor,
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
          color: AppTheme.cardColor,
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
