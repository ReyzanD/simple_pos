#!/bin/bash
# Script to replace controller references in inventory_screen.dart

FILE="lib/features/inventory/presentation/screens/inventory_screen.dart"
BACKUP="lib/features/inventory/presentation/screens/inventory_screen.dart.bak"

# Create backup
cp "$FILE" "$BACKUP"

# Replace inventory controller references
sed -i 's/onRefresh: () => inventoryController\.loadProducts()/onRefresh: () => ref.read(inventoryProvider.notifier).loadProducts()/g' "$FILE"
sed -i 's/searchQuery: inventoryController\.searchQuery/searchQuery: ref.read(inventoryProvider.notifier).searchQuery/g' "$FILE"
sed -i 's/onChanged: (query) => inventoryController\.searchProducts(query)/onChanged: (query) => ref.read(inventoryProvider.notifier).searchProducts(query)/g' "$FILE"
sed -i 's/onClear: () => inventoryController\.clearSearch()/onClear: () => ref.read(inventoryProvider.notifier).clearSearch()/g' "$FILE"
sed -i 's/selectedCategoryId: inventoryController\.filterCategoryId/selectedCategoryId: ref.read(inventoryProvider.notifier).filterCategoryId/g' "$FILE"
sed -i 's/selectedSupplierId: inventoryController\.filterSupplierId/selectedSupplierId: ref.read(inventoryProvider.notifier).filterSupplierId/g' "$FILE"
sed -i 's/onCategoryChanged: (id) => inventoryController\.filterByCategory(id)/onCategoryChanged: (id) => ref.read(inventoryProvider.notifier).filterByCategory(id)/g' "$FILE"
sed -i 's/onSupplierChanged: (id) => inventoryController\.filterBySupplier(id)/onSupplierChanged: (id) => ref.read(inventoryProvider.notifier).filterBySupplier(id)/g' "$FILE"
sed -i 's/onClearFilters: () => inventoryController\.clearFilters()/onClearFilters: () => ref.read(inventoryProvider.notifier).clearFilters()/g' "$FILE"
sed -i 's/inStockOnly: inventoryController\.inStockOnly/inStockOnly: ref.read(inventoryProvider.notifier).inStockOnly/g' "$FILE"
sed -i 's/onToggleInStockOnly:\n\s*inventoryController\.toggleInStockOnly()/onToggleInStockOnly:\n      () => ref.read(inventoryProvider.notifier).toggleInStockOnly()/g' "$FILE"
sed -i 's/sortOption: inventoryController\.sortOption/sortOption: ref.read(inventoryProvider.notifier).sortOption/g' "$FILE"
sed -i 's/onSortChanged: (option) => inventoryController\.setSortOption(option)/onSortChanged: (option) => ref.read(inventoryProvider.notifier).setSortOption(option)/g' "$FILE"

echo "Controller references replaced successfully"
