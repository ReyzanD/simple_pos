import '../../domain/entities/product_variant.dart';
import '../../domain/entities/variant_attribute.dart';
import '../../domain/repositories/product_variant_repository.dart';
import '../datasources/product_variant_local_datasource.dart';
import '../models/product_variant_model.dart';
import '../models/variant_attribute_model.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of product variant repository
class ProductVariantRepositoryImpl implements ProductVariantRepository {
  final ProductVariantLocalDataSource dataSource;

  ProductVariantRepositoryImpl({required this.dataSource});

  @override
  Future<List<ProductVariant>> getVariants(int productId) async {
    try {
      AppLogger.debug('Getting variants for product $productId', tag: 'ProductVariantRepository');

      final models = await dataSource.getVariantsByProductId(productId);
      return models.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariants',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal mengambil varian produk',
        operation: 'getVariants',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProductVariant> getVariantById(int variantId) async {
    try {
      AppLogger.debug('Getting variant by ID: $variantId', tag: 'ProductVariantRepository');

      final model = await dataSource.getVariantById(variantId);
      if (model == null) {
        throw NotFoundException(
          'Varian produk tidak ditemukan',
          resourceType: 'Varian Produk',
          resourceId: variantId.toString(),
        );
      }
      return model.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariantById',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal mengambil varian produk',
        operation: 'getVariantById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProductVariant?> getVariantBySku(String sku) async {
    try {
      AppLogger.debug('Getting variant by SKU: $sku', tag: 'ProductVariantRepository');

      final model = await dataSource.getVariantBySku(sku);
      return model?.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariantBySku',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal mengambil varian produk',
        operation: 'getVariantBySku',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProductVariant?> getVariantByBarcode(String barcode) async {
    try {
      AppLogger.debug('Getting variant by barcode: $barcode', tag: 'ProductVariantRepository');

      final model = await dataSource.getVariantByBarcode(barcode);
      return model?.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariantByBarcode',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal mengambil varian produk',
        operation: 'getVariantByBarcode',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProductVariant> addVariant(ProductVariant variant) async {
    try {
      AppLogger.debug('Adding variant for product ${variant.productId}', tag: 'ProductVariantRepository');

      final model = ProductVariantModel.fromEntity(variant);
      final createdModel = await dataSource.createVariant(model);
      return createdModel.toEntity();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in addVariant',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal menambahkan varian produk',
        operation: 'addVariant',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateVariant(ProductVariant variant) async {
    try {
      AppLogger.debug('Updating variant ${variant.id}', tag: 'ProductVariantRepository');

      final model = ProductVariantModel.fromEntity(variant);
      await dataSource.updateVariant(model);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateVariant',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal mengupdate varian produk',
        operation: 'updateVariant',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteVariant(int variantId) async {
    try {
      AppLogger.debug('Deleting variant $variantId', tag: 'ProductVariantRepository');

      await dataSource.deleteVariant(variantId);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteVariant',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal menghapus varian produk',
        operation: 'deleteVariant',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteVariantsByProductId(int productId) async {
    try {
      AppLogger.debug('Deleting variants for product $productId', tag: 'ProductVariantRepository');

      await dataSource.deleteVariantsByProductId(productId);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteVariantsByProductId',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal menghapus varian produk',
        operation: 'deleteVariantsByProductId',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateVariantStock(int variantId, int stock) async {
    try {
      AppLogger.debug('Updating stock for variant $variantId to $stock', tag: 'ProductVariantRepository');

      await dataSource.updateVariantStock(variantId, stock);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateVariantStock',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal mengupdate stok varian',
        operation: 'updateVariantStock',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ProductVariant>> addVariants(List<ProductVariant> variants) async {
    try {
      AppLogger.debug('Adding ${variants.length} variants', tag: 'ProductVariantRepository');

      final models = variants.map((v) => ProductVariantModel.fromEntity(v)).toList();
      final createdModels = await dataSource.createVariants(models);
      return createdModels.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in addVariants',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantRepository',
      );
      throw DatabaseException(
        'Gagal menambahkan varian produk',
        operation: 'addVariants',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Implementation of variant attribute repository
class VariantAttributeRepositoryImpl implements VariantAttributeRepository {
  final VariantAttributeLocalDataSource dataSource;

  VariantAttributeRepositoryImpl({required this.dataSource});

  @override
  Future<List<VariantAttribute>> getAttributes(int productId) async {
    try {
      AppLogger.debug('Getting attributes for product $productId', tag: 'VariantAttributeRepository');

      final models = await dataSource.getAttributesByProductId(productId);
      return models.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getAttributes',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeRepository',
      );
      throw DatabaseException(
        'Gagal mengambil atribut varian',
        operation: 'getAttributes',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<VariantAttribute> addAttribute(VariantAttribute attribute) async {
    try {
      AppLogger.debug('Adding attribute for product ${attribute.productId}', tag: 'VariantAttributeRepository');

      final model = VariantAttributeModel.fromEntity(attribute);
      final createdModel = await dataSource.createAttribute(model);
      return createdModel.toEntity();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in addAttribute',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeRepository',
      );
      throw DatabaseException(
        'Gagal menambahkan atribut varian',
        operation: 'addAttribute',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateAttribute(VariantAttribute attribute) async {
    try {
      AppLogger.debug('Updating attribute ${attribute.id}', tag: 'VariantAttributeRepository');

      final model = VariantAttributeModel.fromEntity(attribute);
      await dataSource.updateAttribute(model);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateAttribute',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeRepository',
      );
      throw DatabaseException(
        'Gagal mengupdate atribut varian',
        operation: 'updateAttribute',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAttribute(int attributeId) async {
    try {
      AppLogger.debug('Deleting attribute $attributeId', tag: 'VariantAttributeRepository');

      await dataSource.deleteAttribute(attributeId);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteAttribute',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeRepository',
      );
      throw DatabaseException(
        'Gagal menghapus atribut varian',
        operation: 'deleteAttribute',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAttributesByProductId(int productId) async {
    try {
      AppLogger.debug('Deleting attributes for product $productId', tag: 'VariantAttributeRepository');

      await dataSource.deleteAttributesByProductId(productId);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteAttributesByProductId',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeRepository',
      );
      throw DatabaseException(
        'Gagal menghapus atribut varian',
        operation: 'deleteAttributesByProductId',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<VariantAttribute>> addAttributes(List<VariantAttribute> attributes) async {
    try {
      AppLogger.debug('Adding ${attributes.length} attributes', tag: 'VariantAttributeRepository');

      final models = attributes.map((a) => VariantAttributeModel.fromEntity(a)).toList();
      final createdModels = await dataSource.createAttributes(models);
      return createdModels.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in addAttributes',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeRepository',
      );
      throw DatabaseException(
        'Gagal menambahkan atribut varian',
        operation: 'addAttributes',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
