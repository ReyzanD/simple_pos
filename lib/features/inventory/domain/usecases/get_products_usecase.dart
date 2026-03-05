import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for retrieving all products
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase({required this.repository});

  /// Executes the use case
  /// Returns a list of all products
  Future<List<Product>> execute() async {
    try {
      AppLogger.useCase('GetProducts');

      final products = await repository.getProducts();

      AppLogger.info(
        'Products retrieved successfully',
        tag: 'GetProductsUseCase',
      );
      return products;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetProductsUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'GetProductsUseCase',
      );
      throw DatabaseException(
        'Gagal mengambil data produk',
        operation: 'GetProducts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
