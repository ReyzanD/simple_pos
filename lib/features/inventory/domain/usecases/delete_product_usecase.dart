import '../repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';

/// Use case for deleting a product
class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase({required this.repository});

  /// Executes the use case
  Future<void> execute(int productId) async {
    try {
      AppLogger.useCase('DeleteProduct', details: 'ID: $productId');

      // Validate product ID
      Validators.validateProductId(productId);

      // Check if product exists
      final exists = await repository.productExists(productId);
      if (!exists) {
        throw NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: productId.toString(),
        );
      }

      await repository.deleteProduct(productId);

      AppLogger.info('Product deleted successfully', tag: 'DeleteProductUseCase');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DeleteProductUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'DeleteProductUseCase',
      );
      throw DatabaseException(
        'Gagal menghapus produk',
        operation: 'DeleteProduct',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
