import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing inventory state and operations
class InventoryController extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  bool _disposed = false;

  InventoryController({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.searchProductsUseCase,
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

  /// Clear all filters (search, category, supplier)
  void clearFilters() {
    AppLogger.ui('Clearing all filters', details: 'InventoryController');
    _searchQuery = '';
    _filterCategoryId = null;
    _filterSupplierId = null;
    _filteredProducts = List.from(_products);
    if (!_disposed) {
      notifyListeners();
    }
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

      return matchesSearch && matchesCategory && matchesSupplier;
    }).toList();

    if (!_disposed) {
      notifyListeners();
    }
  }
}
