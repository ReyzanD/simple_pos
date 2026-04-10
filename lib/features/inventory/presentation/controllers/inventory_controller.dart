import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/import_products_from_csv_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/csv_import_helper.dart';

/// Sort options for product listing
enum ProductSortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  stockLevel,
}

/// View mode for product listing
enum ProductViewMode {
  list,
  grid,
}

/// Controller for managing inventory state and operations
class InventoryController extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final ImportProductsFromCsvUseCase importProductsFromCsvUseCase;

  bool _disposed = false;

  InventoryController({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.searchProductsUseCase,
    required this.importProductsFromCsvUseCase,
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  AppException? _error;
  String _searchQuery = '';
  int? _filterCategoryId;
  int? _filterSupplierId;
  Product? _lastDeletedProduct;
  bool _inStockOnly = false;
  ProductSortOption _sortOption = ProductSortOption.nameAsc;
  ProductViewMode _viewMode = ProductViewMode.list;

  // Getters
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  AppException? get error => _error;
  String get searchQuery => _searchQuery;
  int? get filterCategoryId => _filterCategoryId;
  int? get filterSupplierId => _filterSupplierId;
  bool get hasError => _error != null;
  bool get isEmpty => _products.isEmpty;
  bool get hasNoResults => _products.isNotEmpty && _filteredProducts.isEmpty;
  Product? get lastDeletedProduct => _lastDeletedProduct;
  bool get inStockOnly => _inStockOnly;
  ProductSortOption get sortOption => _sortOption;
  ProductViewMode get viewMode => _viewMode;

  /// Load all products
  Future<void> loadProducts() async {
    try {
      AppLogger.ui('Loading products', details: 'InventoryController');
      _setLoading(true);
      _clearError();

      _products = await getProductsUseCase.execute();
      _applySearch();

      AppLogger.info('Products loaded successfully - InventoryController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load products - InventoryController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat produk',
        operation: 'loadProducts',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading products - InventoryController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
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
    double? discountPercentage,
    bool hasVariants = false,
  }) async {
    try {
      AppLogger.ui('Adding product', details: 'InventoryController');
      _setLoading(true);
      _clearError();

      final product = Product(
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        categoryId: categoryId,
        supplierId: supplierId,
        barcode: barcode,
        imagePath: imagePath,
        discountPercentage: discountPercentage,
        hasVariants: hasVariants,
      );

      final created = await addProductUseCase.execute(product);

      _products.insert(0, created);
      _applySearch();

      AppLogger.info('Product added successfully - InventoryController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add product - InventoryController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan produk',
        operation: 'addProduct',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding product - InventoryController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(Product product) async {
    try {
      AppLogger.ui('Updating product', details: 'InventoryController');
      _setLoading(true);
      _clearError();

      await updateProductUseCase.execute(product);

      // Update in list
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applySearch();
      }

      AppLogger.info('Product updated successfully - InventoryController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to update product - InventoryController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengupdate produk',
        operation: 'updateProduct',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error updating product - InventoryController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update product fields directly
  Future<bool> updateProductFields({
    required int productId,
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    double? discountPercentage,
  }) async {
    try {
      AppLogger.ui('Updating product fields', details: 'InventoryController');
      _setLoading(true);
      _clearError();

      // Find existing product
      final existingProduct = _products.firstWhere((p) => p.id == productId);

      // Create updated product
      final updatedProduct = existingProduct.copyWith(
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        categoryId: categoryId,
        supplierId: supplierId,
        barcode: barcode,
        discountPercentage: discountPercentage,
      );

      await updateProductUseCase.execute(updatedProduct);

      // Update in list
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        _applySearch();
      }

      AppLogger.info('Product fields updated successfully - InventoryController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to update product fields - InventoryController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengupdate produk',
        operation: 'updateProductFields',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error updating product fields - InventoryController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(int productId) async {
    try {
      AppLogger.ui('Deleting product', details: 'InventoryController');
      _setLoading(true);
      _clearError();

      // Store the product for undo before deleting
      _lastDeletedProduct = _products.firstWhere((p) => p.id == productId);

      await deleteProductUseCase.execute(productId);

      _products.removeWhere((p) => p.id == productId);
      _applySearch();

      AppLogger.info('Product deleted successfully - InventoryController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete product - InventoryController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus produk',
        operation: 'deleteProduct',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error deleting product - InventoryController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Undo delete product - restore the last deleted product
  Future<bool> undoDeleteProduct() async {
    if (_lastDeletedProduct == null) return false;

    try {
      AppLogger.ui('Undoing product deletion', details: 'InventoryController');
      _setLoading(true);
      _clearError();

      // Restore the product
      final success = await addProduct(
        name: _lastDeletedProduct!.name,
        price: _lastDeletedProduct!.price,
        costPrice: _lastDeletedProduct!.costPrice,
        stock: _lastDeletedProduct!.stock,
        categoryId: _lastDeletedProduct!.categoryId,
        supplierId: _lastDeletedProduct!.supplierId,
        barcode: _lastDeletedProduct!.barcode,
        imagePath: _lastDeletedProduct!.imagePath,
        discountPercentage: _lastDeletedProduct!.discountPercentage,
      );

      if (success) {
        _lastDeletedProduct = null;
      }

      AppLogger.info('Product deletion undone successfully - InventoryController');
      return success;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to undo product deletion - InventoryController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memulihkan produk',
        operation: 'undoDeleteProduct',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error undoing product deletion - InventoryController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add stock to a product
  Future<bool> addStock({
    required int productId,
    required int quantity,
  }) async {
    try {
      AppLogger.ui('Adding stock to product', details: 'InventoryController');
      _setLoading(true);
      _clearError();

      // Find the product
      final product = _products.firstWhere(
        (p) => p.id == productId,
      );

      // Update stock using updateProductFields
      final newStock = product.stock + quantity;
      final success = await updateProductFields(
        productId: productId,
        name: product.name,
        price: product.price,
        costPrice: product.costPrice,
        stock: newStock,
        categoryId: product.categoryId,
        supplierId: product.supplierId,
        barcode: product.barcode,
        discountPercentage: product.discountPercentage,
      );

      if (success) {
        AppLogger.info('Stock added successfully - InventoryController');
      }

      return success;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambah stok',
        operation: 'addStock',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Failed to add stock - InventoryController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search products by name
  void searchProducts(String query) {
    AppLogger.ui('Searching products', details: 'InventoryController');
    _searchQuery = query;
    _applySearch();
  }

  /// Filter products by category
  void filterByCategory(int? categoryId) {
    AppLogger.ui('Filtering by category', details: 'InventoryController: $categoryId');
    _filterCategoryId = categoryId;
    _applySearch();
  }

  /// Filter products by supplier
  void filterBySupplier(int? supplierId) {
    AppLogger.ui('Filtering by supplier', details: 'InventoryController: $supplierId');
    _filterSupplierId = supplierId;
    _applySearch();
  }

  /// Toggle in-stock only filter
  void toggleInStockOnly() {
    AppLogger.ui('Toggling in-stock filter', details: 'InventoryController');
    _inStockOnly = !_inStockOnly;
    _applySearch();
  }

  /// Set sort option
  void setSortOption(ProductSortOption option) {
    AppLogger.ui('Setting sort option', details: 'InventoryController: $option');
    _sortOption = option;
    _applySearch();
  }

  /// Toggle view mode between list and grid
  void toggleViewMode() {
    AppLogger.ui('Toggling view mode', details: 'InventoryController');
    _viewMode = _viewMode == ProductViewMode.list
        ? ProductViewMode.grid
        : ProductViewMode.list;
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Clear all filters (search, category, supplier, in-stock-only, sort)
  void clearFilters() {
    AppLogger.ui('Clearing all filters', details: 'InventoryController');
    _searchQuery = '';
    _filterCategoryId = null;
    _filterSupplierId = null;
    _inStockOnly = false;
    _sortOption = ProductSortOption.nameAsc;
    _applySearch();
  }

  /// Clear search only (keeps category/supplier filters)
  void clearSearch() {
    AppLogger.ui('Clearing search', details: 'InventoryController');
    _searchQuery = '';
    _applySearch();
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  // Private methods

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setError(AppException error) {
    _error = error;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _clearError() {
    _error = null;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _applySearch() {
    _filteredProducts = _products.where((product) {
      // Search query filter
      bool matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Category filter
      bool matchesCategory = _filterCategoryId == null ||
          product.categoryId == _filterCategoryId;

      // Supplier filter
      bool matchesSupplier = _filterSupplierId == null ||
          product.supplierId == _filterSupplierId;

      // In-stock only filter
      bool matchesStock = !_inStockOnly || product.stock > 0;

      return matchesSearch && matchesCategory && matchesSupplier && matchesStock;
    }).toList();

    // Apply sorting
    switch (_sortOption) {
      case ProductSortOption.nameAsc:
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOption.nameDesc:
        _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSortOption.priceAsc:
        _filteredProducts.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case ProductSortOption.priceDesc:
        _filteredProducts.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case ProductSortOption.stockLevel:
        _filteredProducts.sort((a, b) => b.stock.compareTo(a.stock));
        break;
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Import products from CSV file
  /// Returns number of successfully imported products
  Future<int> importProductsFromCsv({
    required List<CsvProductData> products,
    required String username,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final count = await importProductsFromCsvUseCase.execute(
        products: products,
        username: username,
      );

      // Reload products to show newly imported items
      await loadProducts();

      return count;
    } on AppException catch (e) {
      _setError(e);
      rethrow;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengimpor produk',
        operation: 'importProductsFromCsv',
        originalError: e,
        stackTrace: stackTrace,
      ));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
