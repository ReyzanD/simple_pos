import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../../../core/utils/logger.dart';

/// Result class containing low stock and out of stock products
class LowStockResult {
  final List<Product> outOfStockProducts;
  final List<Product> lowStockProducts;

  const LowStockResult({
    required this.outOfStockProducts,
    required this.lowStockProducts,
  });

  int get totalOutOfStock => outOfStockProducts.length;
  int get totalLowStock => lowStockProducts.length;
  int get total => totalOutOfStock + totalLowStock;
}

/// Use case for getting products with low stock
/// Separates products into out of stock and low stock categories
class GetLowStockProductsUseCase {
  final ProductRepository _productRepository;

  GetLowStockProductsUseCase({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository;

  /// Execute the use case to get low stock products
  /// Returns a LowStockResult containing both out of stock and low stock products
  Future<LowStockResult> execute({
    int? categoryId,
    int? supplierId,
  }) async {
    try {
      AppLogger.useCase('GetLowStockProducts', details: 'Filters: categoryId=$categoryId, supplierId=$supplierId');

      // Get all products
      final allProducts = await _productRepository.getProducts();

      // Filter based on criteria
      var filteredProducts = allProducts;

      if (categoryId != null) {
        filteredProducts = filteredProducts
            .where((p) => p.categoryId == categoryId)
            .toList();
      }

      if (supplierId != null) {
        filteredProducts = filteredProducts
            .where((p) => p.supplierId == supplierId)
            .toList();
      }

      // Separate into out of stock and low stock
      final outOfStock = filteredProducts
          .where((p) => p.isOutOfStock)
          .toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));

      final lowStock = filteredProducts
          .where((p) => p.isLowStock)
          .toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));

      final result = LowStockResult(
        outOfStockProducts: outOfStock,
        lowStockProducts: lowStock,
      );

      AppLogger.info('Found ${result.total} products with stock issues (${result.totalOutOfStock} out of stock, ${result.totalLowStock} low stock)');

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get low stock products',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
