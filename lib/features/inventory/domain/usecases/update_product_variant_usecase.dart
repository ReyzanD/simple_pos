import '../entities/product_variant.dart';
import '../repositories/product_variant_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for updating an existing product variant
class UpdateProductVariantUseCase {
  final ProductVariantRepository repository;

  UpdateProductVariantUseCase({required this.repository});

  /// Executes the use case
  Future<void> execute(ProductVariant variant) async {
    try {
      AppLogger.useCase('UpdateProductVariant', details: 'Variant ID: ${variant.id}');

      if (variant.id == null) {
        throw const ValidationException('ID varian diperlukan untuk update', field: 'ID');
      }

      // Validate variant data
      if (variant.name.isEmpty) {
        throw const ValidationException('Nama varian tidak boleh kosong', field: 'Nama Varian');
      }
      if (variant.price <= 0) {
        throw const ValidationException('Harga varian harus lebih dari 0', field: 'Harga Varian');
      }
      if (variant.stock < 0) {
        throw const ValidationException('Stok tidak boleh negatif', field: 'Stok Varian');
      }

      await repository.updateVariant(variant);

      AppLogger.info(
        'Product variant updated successfully',
        tag: 'UpdateProductVariantUseCase',
      );
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in UpdateProductVariantUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'UpdateProductVariantUseCase',
      );
      throw DatabaseException(
        'Gagal mengupdate varian produk',
        operation: 'UpdateProductVariant',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Use case for updating variant stock
class UpdateVariantStockUseCase {
  final ProductVariantRepository repository;

  UpdateVariantStockUseCase({required this.repository});

  /// Executes the use case
  Future<void> execute(int variantId, int stock) async {
    try {
      AppLogger.useCase('UpdateVariantStock', details: 'Variant ID: $variantId, Stock: $stock');

      if (stock < 0) {
        throw const ValidationException('Stok tidak boleh negatif', field: 'Stok');
      }

      await repository.updateVariantStock(variantId, stock);

      AppLogger.info(
        'Variant stock updated successfully',
        tag: 'UpdateVariantStockUseCase',
      );
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in UpdateVariantStockUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'UpdateVariantStockUseCase',
      );
      throw DatabaseException(
        'Gagal mengupdate stok varian',
        operation: 'UpdateVariantStock',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
