import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for updating an existing product
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase({required this.repository});

  /// Executes the use case
  Future<void> execute(Product product) async {
    try {
      AppLogger.useCase('UpdateProduct', details: 'ID: ${product.id}');

      if (product.id == null) {
        throw const ValidationException(
          'ID produk diperlukan untuk update',
          field: 'ID',
        );
      }

      // Validate product
      product.validate();

      // Check if product exists
      final exists = await repository.productExists(product.id!);
      if (!exists) {
        throw NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: product.id.toString(),
        );
      }

      await repository.updateProduct(product);

      AppLogger.info('Product updated successfully', tag: 'UpdateProductUseCase');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in UpdateProductUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'UpdateProductUseCase',
      );
      throw DatabaseException(
        'Gagal mengupdate produk',
        operation: 'UpdateProduct',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
