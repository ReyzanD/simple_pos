import '../models/product_variant_model.dart';
import '../models/variant_attribute_model.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

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
  Future<List<ProductVariantModel>> createVariants(
    List<ProductVariantModel> variants,
  );
}

/// Interface for variant attribute local data source operations
abstract class VariantAttributeLocalDataSource {
  Future<VariantAttributeModel> createAttribute(
    VariantAttributeModel attribute,
  );
  Future<List<VariantAttributeModel>> getAttributesByProductId(int productId);
  Future<void> updateAttribute(VariantAttributeModel attribute);
  Future<void> deleteAttribute(int id);
  Future<void> deleteAttributesByProductId(int productId);
  Future<List<VariantAttributeModel>> createAttributes(
    List<VariantAttributeModel> attributes,
  );
}

/// Implementation of product variant local data source
class ProductVariantLocalDataSourceImpl
    implements ProductVariantLocalDataSource {
  final DatabaseHelper databaseHelper;

  ProductVariantLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<ProductVariantModel> createVariant(ProductVariantModel variant) async {
    try {
      final id = await databaseHelper.productVariants.insert(variant.toMap());
      return variant.copyWith(id: id);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'createVariant');
    }
  }

  @override
  Future<List<ProductVariantModel>> getVariantsByProductId(
    int productId,
  ) async {
    try {
      final data = await databaseHelper.productVariants.getByProductId(
        productId,
      );
      return data.map((map) => ProductVariantModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'getVariantsByProductId');
    }
  }

  @override
  Future<ProductVariantModel?> getVariantById(int id) async {
    try {
      final data = await databaseHelper.productVariants.getById(id);
      return data != null ? ProductVariantModel.fromMap(data) : null;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'getVariantById');
    }
  }

  @override
  Future<ProductVariantModel?> getVariantBySku(String sku) async {
    try {
      final data = await databaseHelper.productVariants.getBySku(sku);
      return data != null ? ProductVariantModel.fromMap(data) : null;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'getVariantBySku');
    }
  }

  @override
  Future<void> updateVariant(ProductVariantModel variant) async {
    try {
      final rows = await databaseHelper.productVariants.update(variant.toMap());
      if (rows == 0) throw _notFound('Varian Produk', variant.id);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'updateVariant');
    }
  }

  @override
  Future<void> deleteVariant(int id) async {
    try {
      final rows = await databaseHelper.productVariants.delete(id);
      if (rows == 0) throw _notFound('Varian Produk', id);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'deleteVariant');
    }
  }

  @override
  Future<void> updateVariantStock(int id, int stock) async {
    try {
      final rows = await databaseHelper.productVariants.updateStock(id, stock);
      if (rows == 0) throw _notFound('Varian Produk', id);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'updateVariantStock');
    }
  }

  @override
  Future<List<ProductVariantModel>> createVariants(
    List<ProductVariantModel> variants,
  ) async {
    try {
      final maps = variants.map((v) => v.toMap()).toList();
      final createdMaps = await databaseHelper.productVariants.insertMany(maps);
      return createdMaps.map((m) => ProductVariantModel.fromMap(m)).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'createVariants');
    }
  }

  // --- Helper Methods to keep it DRY ---
  app_exceptions.DatabaseException _handleError(
    dynamic e,
    StackTrace s,
    String op,
  ) {
    AppLogger.error(
      'Error in $op',
      error: e,
      stackTrace: s,
      tag: 'ProductVariantDataSource',
    );
    return app_exceptions.DatabaseException(
      'Gagal $op',
      operation: op,
      originalError: e,
      stackTrace: s,
    );
  }

  app_exceptions.NotFoundException _notFound(String type, dynamic id) =>
      app_exceptions.NotFoundException(
        '$type tidak ditemukan',
        resourceType: type,
        resourceId: id.toString(),
      );

  @override
  Future<void> deleteVariantsByProductId(int productId) async =>
      await databaseHelper.productVariants.deleteByProductId(productId);

  @override
  Future<ProductVariantModel?> getVariantByBarcode(String barcode) async {
    final data = await databaseHelper.productVariants.getByBarcode(barcode);
    return data != null ? ProductVariantModel.fromMap(data) : null;
  }
}

/// Implementation of variant attribute local data source
class VariantAttributeLocalDataSourceImpl
    implements VariantAttributeLocalDataSource {
  final DatabaseHelper databaseHelper;

  VariantAttributeLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<VariantAttributeModel> createAttribute(
    VariantAttributeModel attribute,
  ) async {
    final id = await databaseHelper.variantAttributes.insert(attribute.toMap());
    return attribute.copyWith(id: id);
  }

  @override
  Future<List<VariantAttributeModel>> getAttributesByProductId(
    int productId,
  ) async {
    final data = await databaseHelper.variantAttributes.getByProductId(
      productId,
    );
    return data.map((map) => VariantAttributeModel.fromMap(map)).toList();
  }

  @override
  Future<void> deleteAttribute(int id) async {
    final rows = await databaseHelper.productVariants.delete(id);
    if (rows == 0) {
      throw app_exceptions.NotFoundException(
        'Atribut tidak ditemukan',
        resourceType: 'Atribut',
        resourceId: id.toString(),
      );
    }
  }

  @override
  Future<void> deleteAttributesByProductId(int productId) async {
    await databaseHelper.variantAttributes.deleteByProductId(productId);
  }

  @override
  Future<List<VariantAttributeModel>> createAttributes(
    List<VariantAttributeModel> attributes,
  ) async {
    final maps = attributes.map((a) => a.toMap()).toList();
    final createdMaps = await databaseHelper.productVariants.insertMany(maps);
    return createdMaps.map((m) => VariantAttributeModel.fromMap(m)).toList();
  }

  @override
  Future<void> updateAttribute(VariantAttributeModel attribute) async {
    await databaseHelper.productVariants.update(attribute.toMap());
  }
}
