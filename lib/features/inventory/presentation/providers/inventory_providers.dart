import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/product.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/exceptions/app_exceptions.dart';

part 'inventory_providers.g.dart';

/// Sort options for product listing
enum ProductSortOption { nameAsc, nameDesc, priceAsc, priceDesc, stockLevel }

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
    // Load products when first built
    loadProducts();
    return [];
  }

  /// Getters for state properties
  String get searchQuery => _searchQuery;
  bool get inStockOnly => _inStockOnly;
  bool get isLoading => _isLoading;
  ProductSortOption get sortOption => _sortOption;
  bool get hasNoResults => state.isEmpty;

  /// Load all products from database
  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      final repository = ref.read(productRepositoryProvider);
      final products = await repository.getProducts();
      state = products;
      AppLogger.info('Products loaded successfully', tag: 'InventoryNotifier');
    } catch (e) {
      AppLogger.error(
        'Error loading products',
        error: e,
        tag: 'InventoryNotifier',
      );
      state = [];
    } finally {
      _isLoading = false;
    }
  }

  /// Add a new product
  Future<bool> addProduct({
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    String? imagePath,
    String? unitOfMeasurement,
    bool hasVariants = false,
  }) async {
    try {
      final repository = ref.read(productRepositoryProvider);

      final newProduct = Product(
        id: null,
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        categoryId: categoryId,
        supplierId: supplierId,
        barcode: barcode,
        imagePath: imagePath,
        unitOfMeasurement: unitOfMeasurement ?? 'pcs',
        hasVariants: hasVariants,
      );

      final createdProduct = await repository.addProduct(newProduct);
      state = [...state, createdProduct];
      AppLogger.info('Product added: $name', tag: 'InventoryNotifier');
      return true;
    } catch (e) {
      AppLogger.error(
        'Error adding product',
        error: e,
        tag: 'InventoryNotifier',
      );
      rethrow;
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(Product product) async {
    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.updateProduct(product);

      // Update the state with the updated product
      state = [
        for (final p in state)
          if (p.id == product.id) product else p,
      ];

      AppLogger.info(
        'Product updated: ${product.name}',
        tag: 'InventoryNotifier',
      );
      return true;
    } catch (e) {
      AppLogger.error(
        'Error updating product',
        error: e,
        tag: 'InventoryNotifier',
      );
      rethrow;
    }
  }

  /// Search products by name
  Future<void> searchProducts(String query) async {
    try {
      _searchQuery = query;
      if (query.isEmpty) {
        await loadProducts();
        return;
      }

      final repository = ref.read(productRepositoryProvider);
      final results = await repository.searchProducts(query);
      state = results;
      AppLogger.info('Products searched: $query', tag: 'InventoryNotifier');
    } catch (e) {
      AppLogger.error(
        'Error searching products',
        error: e,
        tag: 'InventoryNotifier',
      );
    }
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    await loadProducts();
  }

  /// Filter by category
  Future<void> filterByCategory(int? categoryId) async {
    try {
      await loadProducts();
      if (categoryId == null) return;

      state = state.where((p) => p.categoryId == categoryId).toList();
      AppLogger.info(
        'Filtered by category: $categoryId',
        tag: 'InventoryNotifier',
      );
    } catch (e) {
      AppLogger.error(
        'Error filtering by category',
        error: e,
        tag: 'InventoryNotifier',
      );
    }
  }

  /// Filter by supplier
  Future<void> filterBySupplier(int? supplierId) async {
    try {
      await loadProducts();
      if (supplierId == null) return;

      state = state.where((p) => p.supplierId == supplierId).toList();
      AppLogger.info(
        'Filtered by supplier: $supplierId',
        tag: 'InventoryNotifier',
      );
    } catch (e) {
      AppLogger.error(
        'Error filtering by supplier',
        error: e,
        tag: 'InventoryNotifier',
      );
    }
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    _inStockOnly = false;
    _sortOption = ProductSortOption.nameAsc;
    await loadProducts();
  }

  /// Toggle in-stock only filter
  Future<void> toggleInStockOnly() async {
    try {
      _inStockOnly = !_inStockOnly;
      await loadProducts();

      if (_inStockOnly) {
        state = state.where((p) => p.stock > 0).toList();
      }
      AppLogger.info(
        'In-stock filter toggled: $_inStockOnly',
        tag: 'InventoryNotifier',
      );
    } catch (e) {
      AppLogger.error(
        'Error toggling in-stock filter',
        error: e,
        tag: 'InventoryNotifier',
      );
    }
  }

  /// Set sort option
  Future<void> setSortOption(ProductSortOption option) async {
    try {
      _sortOption = option;
      _applySorting();
      AppLogger.info('Sort option set: $option', tag: 'InventoryNotifier');
    } catch (e) {
      AppLogger.error(
        'Error setting sort option',
        error: e,
        tag: 'InventoryNotifier',
      );
    }
  }

  /// Apply sorting to current state
  void _applySorting() {
    switch (_sortOption) {
      case ProductSortOption.nameAsc:
        state = [...state]..sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOption.nameDesc:
        state = [...state]..sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSortOption.priceAsc:
        state = [...state]..sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        state = [...state]..sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.stockLevel:
        state = [...state]..sort((a, b) => a.stock.compareTo(b.stock));
        break;
    }
  }

  /// Toggle view mode (list/grid)
  Future<void> toggleViewMode() async {
    // View mode is handled at screen level for now
  }

  /// Update product fields
  Future<bool> updateProductFields({
    required int productId,
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    String? imagePath,
    String? unitOfMeasurement,
  }) async {
    try {
      final existingProduct = state.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: productId.toString(),
        ),
      );

      final updatedProduct = existingProduct.copyWith(
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        categoryId: categoryId,
        supplierId: supplierId,
        barcode: barcode,
        imagePath: imagePath,
        unitOfMeasurement: unitOfMeasurement,
      );

      await updateProduct(updatedProduct);
      return true;
    } catch (e) {
      AppLogger.error(
        'Error updating product fields',
        error: e,
        tag: 'InventoryNotifier',
      );
      rethrow;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(int productId) async {
    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.deleteProduct(productId);

      state = state.where((p) => p.id != productId).toList();
      AppLogger.info('Product deleted: $productId', tag: 'InventoryNotifier');
      return true;
    } catch (e) {
      AppLogger.error(
        'Error deleting product',
        error: e,
        tag: 'InventoryNotifier',
      );
      rethrow;
    }
  }

  /// Import products from CSV
  Future<void> importProductsFromCsv(
    List<Product> products,
    String username,
  ) async {
    try {
      for (final product in products) {
        await addProduct(
          name: product.name,
          price: product.price,
          costPrice: product.costPrice,
          stock: product.stock,
          categoryId: product.categoryId,
          supplierId: product.supplierId,
          barcode: product.barcode,
          imagePath: product.imagePath,
          unitOfMeasurement: product.unitOfMeasurement,
          hasVariants: product.hasVariants,
        );
      }
      AppLogger.info(
        'Products imported: ${products.length}',
        tag: 'InventoryNotifier',
      );
    } catch (e) {
      AppLogger.error(
        'Error importing products',
        error: e,
        tag: 'InventoryNotifier',
      );
      rethrow;
    }
  }
}

/// Public provider for widgets
final inventoryProvider = inventoryNotifierProvider;
