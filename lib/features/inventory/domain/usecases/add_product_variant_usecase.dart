import '../entities/product_variant.dart';
import '../repositories/product_variant_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for adding a new product variant
class AddProductVariantUseCase {
  final ProductVariantRepository repository;

  AddProductVariantUseCase({required this.repository});

  /// Executes the use case
  /// Returns the created variant with generated ID
  Future<ProductVariant> execute(ProductVariant variant) async {
    try {
      AppLogger.useCase('AddProductVariant', details: 'Product: ${variant.productId}');

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

      final result = await repository.addVariant(variant);

      AppLogger.info(
        'Product variant added successfully',
        tag: 'AddProductVariantUseCase',
      );
      return result;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddProductVariantUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'AddProductVariantUseCase',
      );
      throw DatabaseException(
        'Gagal menambahkan varian produk',
        operation: 'AddProductVariant',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Use case for batch adding product variants
class AddProductVariantsBatchUseCase {
  final ProductVariantRepository repository;

  AddProductVariantsBatchUseCase({required this.repository});

  /// Executes the use case
  /// Returns the list of created variants with generated IDs
  Future<List<ProductVariant>> execute(List<ProductVariant> variants) async {
    try {
      AppLogger.useCase('AddProductVariantsBatch', details: '${variants.length} variants');

      if (variants.isEmpty) {
        throw const ValidationException('Daftar varian tidak boleh kosong');
      }

      final results = await repository.addVariants(variants);

      AppLogger.info(
        'Product variants batch added successfully',
        tag: 'AddProductVariantsBatchUseCase',
      );
      return results;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddProductVariantsBatchUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'AddProductVariantsBatchUseCase',
      );
      throw DatabaseException(
        'Gagal menambahkan varian produk',
        operation: 'AddProductVariantsBatch',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
