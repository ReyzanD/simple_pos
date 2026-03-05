import '../models/product_variant_model.dart';
import '../models/variant_attribute_model.dart';
import '../../../../services/database/database_helper.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Interface for product variant local data source operations
abstract class ProductVariantLocalDataSource {
  Future<ProductVariantModel> createVariant(ProductVariantModel variant);
  Future<List<ProductVariantModel>> getVariantsByProductId(int productId);
  Future<ProductVariantModel?> getVariantById(int id);
  Future<ProductVariantModel?> getVariantBySku(String sku);
  Future<ProductVariantModel?> getVariantByBarcode(String barcode);
  Future<void> updateVariant(ProductVariantModel variant);
  Future<void> deleteVariant(int id);
  Future<void> deleteVariantsByProductId(int productId);
  Future<void> updateVariantStock(int id, int stock);
  Future<List<ProductVariantModel>> createVariants(List<ProductVariantModel> variants);
}

/// Interface for variant attribute local data source operations
abstract class VariantAttributeLocalDataSource {
  Future<VariantAttributeModel> createAttribute(VariantAttributeModel attribute);
  Future<List<VariantAttributeModel>> getAttributesByProductId(int productId);
  Future<void> updateAttribute(VariantAttributeModel attribute);
  Future<void> deleteAttribute(int id);
  Future<void> deleteAttributesByProductId(int productId);
  Future<List<VariantAttributeModel>> createAttributes(List<VariantAttributeModel> attributes);
}

/// Implementation of product variant local data source
class ProductVariantLocalDataSourceImpl implements ProductVariantLocalDataSource {
  final DatabaseHelper databaseHelper;

  ProductVariantLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<ProductVariantModel> createVariant(ProductVariantModel variant) async {
    try {
      AppLogger.debug('Creating product variant', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final id = await db.insert('product_variants', variant.toMap());

      AppLogger.info('Product variant created with ID: $id', tag: 'ProductVariantDataSource');
      return variant.copyWith(id: id);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createVariant',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
      );
      throw DatabaseException(
        'Gagal membuat varian produk',
        operation: 'createVariant',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ProductVariantModel>> getVariantsByProductId(int productId) async {
    try {
      AppLogger.debug('Fetching variants for product $productId', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final data = await db.query(
        'product_variants',
        where: 'product_id = ?',
        whereArgs: [productId],
        orderBy: 'id ASC',
      );

      AppLogger.info('Retrieved ${data.length} variants for product $productId', tag: 'ProductVariantDataSource');
      return data.map((map) => ProductVariantModel.fromMap(map)).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariantsByProductId',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
      );
      throw DatabaseException(
        'Gagal mengambil varian produk',
        operation: 'getVariantsByProductId',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProductVariantModel?> getVariantById(int id) async {
    try {
      AppLogger.debug('Fetching variant by ID: $id', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final data = await db.query(
        'product_variants',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (data.isEmpty) return null;
      return ProductVariantModel.fromMap(data.first);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariantById',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
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
  Future<ProductVariantModel?> getVariantBySku(String sku) async {
    try {
      AppLogger.debug('Fetching variant by SKU: $sku', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final data = await db.query(
        'product_variants',
        where: 'sku = ?',
        whereArgs: [sku],
        limit: 1,
      );

      if (data.isEmpty) return null;
      return ProductVariantModel.fromMap(data.first);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariantBySku',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
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
  Future<ProductVariantModel?> getVariantByBarcode(String barcode) async {
    try {
      AppLogger.debug('Fetching variant by barcode: $barcode', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final data = await db.query(
        'product_variants',
        where: 'barcode = ?',
        whereArgs: [barcode],
        limit: 1,
      );

      if (data.isEmpty) return null;
      return ProductVariantModel.fromMap(data.first);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getVariantByBarcode',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
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
  Future<void> updateVariant(ProductVariantModel variant) async {
    try {
      AppLogger.debug('Updating variant ${variant.id}', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final rowsAffected = await db.update(
        'product_variants',
        variant.toMap(),
        where: 'id = ?',
        whereArgs: [variant.id],
      );

      if (rowsAffected == 0) {
        throw NotFoundException(
          'Varian produk tidak ditemukan',
          resourceType: 'Varian Produk',
          resourceId: variant.id?.toString(),
        );
      }

      AppLogger.info('Variant ${variant.id} updated successfully', tag: 'ProductVariantDataSource');
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateVariant',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
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
  Future<void> deleteVariant(int id) async {
    try {
      AppLogger.debug('Deleting variant $id', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final rowsAffected = await db.delete(
        'product_variants',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw NotFoundException(
          'Varian produk tidak ditemukan',
          resourceType: 'Varian Produk',
          resourceId: id.toString(),
        );
      }

      AppLogger.info('Variant $id deleted successfully', tag: 'ProductVariantDataSource');
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteVariant',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
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
      AppLogger.debug('Deleting variants for product $productId', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      await db.delete(
        'product_variants',
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      AppLogger.info('Variants for product $productId deleted successfully', tag: 'ProductVariantDataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteVariantsByProductId',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
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
  Future<void> updateVariantStock(int id, int stock) async {
    try {
      AppLogger.debug('Updating stock for variant $id to $stock', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final rowsAffected = await db.update(
        'product_variants',
        {'stock': stock},
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw NotFoundException(
          'Varian produk tidak ditemukan',
          resourceType: 'Varian Produk',
          resourceId: id.toString(),
        );
      }

      AppLogger.info('Stock for variant $id updated to $stock', tag: 'ProductVariantDataSource');
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateVariantStock',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
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
  Future<List<ProductVariantModel>> createVariants(List<ProductVariantModel> variants) async {
    try {
      AppLogger.debug('Creating ${variants.length} variants', tag: 'ProductVariantDataSource');

      final db = await databaseHelper.database;
      final results = <ProductVariantModel>[];

      await db.transaction((txn) async {
        for (final variant in variants) {
          final id = await txn.insert('product_variants', variant.toMap());
          results.add(variant.copyWith(id: id));
        }
      });

      AppLogger.info('Created ${results.length} variants successfully', tag: 'ProductVariantDataSource');
      return results;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createVariants',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductVariantDataSource',
      );
      throw DatabaseException(
        'Gagal membuat varian produk',
        operation: 'createVariants',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Implementation of variant attribute local data source
class VariantAttributeLocalDataSourceImpl implements VariantAttributeLocalDataSource {
  final DatabaseHelper databaseHelper;

  VariantAttributeLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<VariantAttributeModel> createAttribute(VariantAttributeModel attribute) async {
    try {
      AppLogger.debug('Creating variant attribute', tag: 'VariantAttributeDataSource');

      final db = await databaseHelper.database;
      final id = await db.insert('variant_attributes', attribute.toMap());

      AppLogger.info('Variant attribute created with ID: $id', tag: 'VariantAttributeDataSource');
      return attribute.copyWith(id: id);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createAttribute',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeDataSource',
      );
      throw DatabaseException(
        'Gagal membuat atribut varian',
        operation: 'createAttribute',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<VariantAttributeModel>> getAttributesByProductId(int productId) async {
    try {
      AppLogger.debug('Fetching attributes for product $productId', tag: 'VariantAttributeDataSource');

      final db = await databaseHelper.database;
      final data = await db.query(
        'variant_attributes',
        where: 'product_id = ?',
        whereArgs: [productId],
        orderBy: 'sort_order ASC',
      );

      AppLogger.info('Retrieved ${data.length} attributes for product $productId', tag: 'VariantAttributeDataSource');
      return data.map((map) => VariantAttributeModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getAttributesByProductId',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeDataSource',
      );
      throw DatabaseException(
        'Gagal mengambil atribut varian',
        operation: 'getAttributesByProductId',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateAttribute(VariantAttributeModel attribute) async {
    try {
      AppLogger.debug('Updating attribute ${attribute.id}', tag: 'VariantAttributeDataSource');

      final db = await databaseHelper.database;
      final rowsAffected = await db.update(
        'variant_attributes',
        attribute.toMap(),
        where: 'id = ?',
        whereArgs: [attribute.id],
      );

      if (rowsAffected == 0) {
        throw NotFoundException(
          'Atribut varian tidak ditemukan',
          resourceType: 'Atribut Varian',
          resourceId: attribute.id?.toString(),
        );
      }

      AppLogger.info('Attribute ${attribute.id} updated successfully', tag: 'VariantAttributeDataSource');
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateAttribute',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeDataSource',
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
  Future<void> deleteAttribute(int id) async {
    try {
      AppLogger.debug('Deleting attribute $id', tag: 'VariantAttributeDataSource');

      final db = await databaseHelper.database;
      final rowsAffected = await db.delete(
        'variant_attributes',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw NotFoundException(
          'Atribut varian tidak ditemukan',
          resourceType: 'Atribut Varian',
          resourceId: id.toString(),
        );
      }

      AppLogger.info('Attribute $id deleted successfully', tag: 'VariantAttributeDataSource');
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteAttribute',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeDataSource',
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
      AppLogger.debug('Deleting attributes for product $productId', tag: 'VariantAttributeDataSource');

      final db = await databaseHelper.database;
      await db.delete(
        'variant_attributes',
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      AppLogger.info('Attributes for product $productId deleted successfully', tag: 'VariantAttributeDataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteAttributesByProductId',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeDataSource',
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
  Future<List<VariantAttributeModel>> createAttributes(List<VariantAttributeModel> attributes) async {
    try {
      AppLogger.debug('Creating ${attributes.length} attributes', tag: 'VariantAttributeDataSource');

      final db = await databaseHelper.database;
      final results = <VariantAttributeModel>[];

      await db.transaction((txn) async {
        for (final attribute in attributes) {
          final id = await txn.insert('variant_attributes', attribute.toMap());
          results.add(attribute.copyWith(id: id));
        }
      });

      AppLogger.info('Created ${results.length} attributes successfully', tag: 'VariantAttributeDataSource');
      return results;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createAttributes',
        error: e,
        stackTrace: stackTrace,
        tag: 'VariantAttributeDataSource',
      );
      throw DatabaseException(
        'Gagal membuat atribut varian',
        operation: 'createAttributes',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
