import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/import_products_from_csv_usecase.dart';
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

/// Get products use case provider
@riverpod
GetProductsUseCase getProductsUseCase(GetProductsUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository: repo);
}

/// Add product use case provider
@riverpod
AddProductUseCase addProductUseCase(AddProductUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return AddProductUseCase(repository: repo);
}

/// Update product use case provider
@riverpod
UpdateProductUseCase updateProductUseCase(UpdateProductUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return UpdateProductUseCase(repository: repo);
}

/// Delete product use case provider
@riverpod
DeleteProductUseCase deleteProductUseCase(DeleteProductUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return DeleteProductUseCase(repository: repo);
}

/// Search products use case provider
@riverpod
SearchProductsUseCase searchProductsUseCase(SearchProductsUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return SearchProductsUseCase(repository: repo);
}

/// Import from CSV use case provider
@riverpod
ImportProductsFromCsvUseCase importProductsFromCsvUseCase(ImportProductsFromCsvUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ImportProductsFromCsvUseCase(repository: repo);
}

/// Product repository provider
@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  final dataSource = ProductLocalDataSourceImpl(databaseHelper: db);
  return ProductRepositoryImpl(localDataSource: dataSource);
}

/// Product local data source provider
@riverpod
ProductLocalDataSourceImpl productLocalDataSource(ProductLocalDataSourceImplRef ref) {
  final db = ref.watch(databaseProvider);
  return ProductLocalDataSourceImpl(databaseHelper: db);
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
    final useCase = ref.read(getProductsUseCaseProvider);
    state = await useCase.execute();
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
    final useCase = ref.read(addProductUseCaseProvider);
    final product = Product(
      name: name,
      price: price,
      costPrice: costPrice,
      stock: stock,
      categoryId: categoryId,
      supplierId: supplierId,
      barcode: barcode,
      imagePath: imagePath,
      hasVariants: hasVariants,
    );

    await useCase.execute(product);
    await loadProducts();
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
    final useCase = ref.read(updateProductUseCaseProvider);
    final product = Product(
      id: productId,
      name: name,
      price: price,
      costPrice: costPrice,
      stock: stock,
      categoryId: categoryId,
      supplierId: supplierId,
      barcode: barcode,
    );

    await useCase.execute(product);
    await loadProducts();
  }

  /// Delete a product
  Future<void> deleteProduct(int productId) async {
    final useCase = ref.read(deleteProductUseCaseProvider);
    await useCase.execute(productId);
    await loadProducts();
  }

  /// Import products from CSV
  Future<void> importProductsFromCsv(
    List<Product> products,
    String username,
  ) async {
    final useCase = ref.read(importProductsFromCsvUseCaseProvider);
    await useCase.execute(products, username);
    await loadProducts();
  }
}

/// Public provider for widgets
final inventoryProvider = notifierProvider<InventoryNotifier, List<Product>>(InventoryNotifier.new);