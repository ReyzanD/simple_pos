import '../entities/product_variant.dart';
import '../repositories/product_variant_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for retrieving all variants for a product
class GetProductVariantsUseCase {
  final ProductVariantRepository repository;

  GetProductVariantsUseCase({required this.repository});

  /// Executes the use case
  /// Returns a list of all variants for the specified product
  Future<List<ProductVariant>> execute(int productId) async {
    try {
      AppLogger.useCase('GetProductVariants', details: 'Product ID: $productId');

      final variants = await repository.getVariants(productId);

      AppLogger.info(
        'Product variants retrieved successfully',
        tag: 'GetProductVariantsUseCase',
      );
      return variants;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetProductVariantsUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'GetProductVariantsUseCase',
      );
      throw DatabaseException(
        'Gagal mengambil data varian produk',
        operation: 'GetProductVariants',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
