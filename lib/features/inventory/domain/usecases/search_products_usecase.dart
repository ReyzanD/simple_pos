import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for searching products by name
class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase({required this.repository});

  /// Executes the use case
  /// Returns a list of products matching the search query
  Future<List<Product>> execute(String query) async {
    try {
      AppLogger.useCase('SearchProducts', details: 'Query: $query');

      if (query.trim().isEmpty) {
        return [];
      }

      final products = await repository.searchProducts(query);

      AppLogger.info(
        'Product search completed',
        tag: 'SearchProductsUseCase',
      );
      return products;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in SearchProductsUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'SearchProductsUseCase',
      );
      throw DatabaseException(
        'Gagal mencari produk',
        operation: 'SearchProducts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
