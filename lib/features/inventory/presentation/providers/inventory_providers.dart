import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/product.dart';

part 'inventory_providers.g.dart';

/// Sort options for product listing
enum ProductSortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  stockLevel,
}

/// Inventory notifier - manages inventory state and operations
@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  // State properties for search and filters
  String _searchQuery = '';
  bool _inStockOnly = false;
  bool _isLoading = false;
  ProductSortOption _sortOption = ProductSortOption.nameAsc;

  @override
  List<Product> build() {
    // Initial empty state
    return [];
  }

  /// Getters for state properties
  String get searchQuery => _searchQuery;
  bool get inStockOnly => _inStockOnly;
  bool get isLoading => _isLoading;
  ProductSortOption get sortOption => _sortOption;
  bool get hasNoResults => state.isNotEmpty;

  /// Load all products from database
  Future<void> loadProducts() async {
    _isLoading = true;
    // TODO: Implement with use case after full migration
    state = [];
    _isLoading = false;
  }

  /// Add a new product
  Future<void> addProduct({
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    String? imagePath,
    bool hasVariants = false,
  }) async {
    // TODO: Implement with use case after full migration
  }

  /// Search products by name
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    // TODO: Implement search functionality when use case is ready
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    // TODO: Refresh products when search use case is ready
  }

  /// Filter by category
  Future<void> filterByCategory(int? categoryId) async {
    // TODO: Implement category filtering when use case is ready
  }

  /// Filter by supplier
  Future<void> filterBySupplier(int? supplierId) async {
    // TODO: Implement supplier filtering when use case is ready
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    // TODO: Reset filters when use cases are ready
  }

  /// Toggle in-stock only filter
  Future<void> toggleInStockOnly() async {
    _inStockOnly = !_inStockOnly;
    // TODO: Apply filter when use case is ready
  }

  /// Set sort option
  Future<void> setSortOption(ProductSortOption option) async {
    _sortOption = option;
    // TODO: Apply sort when use case is ready
  }

  /// Toggle view mode (list/grid)
  Future<void> toggleViewMode() async {
    // View mode is handled at screen level for now
  }

  /// Update product fields
  Future<void> updateProductFields({
    required int productId,
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
  }) async {
    // TODO: Implement with use case after full migration
  }

  /// Delete a product
  Future<void> deleteProduct(int productId) async {
    // TODO: Implement with use case after full migration
  }

  /// Import products from CSV
  Future<void> importProductsFromCsv(
    List<Product> products,
    String username,
  ) async {
    // TODO: Implement with use case after full migration
  }
}

/// Public provider for widgets
final inventoryProvider = inventoryNotifierProvider;
