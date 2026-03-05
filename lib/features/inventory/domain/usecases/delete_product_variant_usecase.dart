import '../repositories/product_variant_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for deleting a product variant
class DeleteProductVariantUseCase {
  final ProductVariantRepository repository;

  DeleteProductVariantUseCase({required this.repository});

  /// Executes the use case
  Future<void> execute(int variantId) async {
    try {
      AppLogger.useCase('DeleteProductVariant', details: 'Variant ID: $variantId');

      await repository.deleteVariant(variantId);

      AppLogger.info(
        'Product variant deleted successfully',
        tag: 'DeleteProductVariantUseCase',
      );
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DeleteProductVariantUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'DeleteProductVariantUseCase',
      );
      throw DatabaseException(
        'Gagal menghapus varian produk',
        operation: 'DeleteProductVariant',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Use case for deleting all variants for a product
class DeleteProductVariantsByProductIdUseCase {
  final ProductVariantRepository repository;

  DeleteProductVariantsByProductIdUseCase({required this.repository});

  /// Executes the use case
  Future<void> execute(int productId) async {
    try {
      AppLogger.useCase('DeleteProductVariantsByProductId', details: 'Product ID: $productId');

      await repository.deleteVariantsByProductId(productId);

      AppLogger.info(
        'Product variants deleted successfully',
        tag: 'DeleteProductVariantsByProductIdUseCase',
      );
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DeleteProductVariantsByProductIdUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'DeleteProductVariantsByProductIdUseCase',
      );
      throw DatabaseException(
        'Gagal menghapus varian produk',
        operation: 'DeleteProductVariantsByProductId',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
