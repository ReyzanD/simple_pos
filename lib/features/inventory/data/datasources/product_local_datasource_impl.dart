import '../models/product_model.dart';
import 'product_local_datasource.dart';
import '../../../../services/database/database_helper.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of product local data source
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseHelper databaseHelper;

  ProductLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      AppLogger.debug('Creating product in local data source', tag: 'ProductDataSource');

      final result = await databaseHelper.insertProduct(product.toMap());

      AppLogger.info('Product created successfully', tag: 'ProductDataSource');
      return ProductModel.fromMap(result);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createProduct',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductDataSource',
      );
      throw DatabaseException(
        'Gagal membuat produk',
        operation: 'createProduct',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      AppLogger.debug('Fetching all products from local data source', tag: 'ProductDataSource');

      final data = await databaseHelper.getAllProducts();

      AppLogger.info('Products fetched successfully', tag: 'ProductDataSource');
      return data.map((map) => ProductModel.fromMap(map)).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getAllProducts',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductDataSource',
      );
      throw DatabaseException(
        'Gagal mengambil semua produk',
        operation: 'getAllProducts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      AppLogger.debug('Fetching product by ID', tag: 'ProductDataSource');

      final data = await databaseHelper.getProductById(id);

      if (data == null) {
        throw NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: id.toString(),
        );
      }

      AppLogger.info('Product fetched successfully', tag: 'ProductDataSource');
      return ProductModel.fromMap(data);
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getProductById',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductDataSource',
      );
      throw DatabaseException(
        'Gagal mengambil produk',
        operation: 'getProductById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      AppLogger.debug('Updating product', tag: 'ProductDataSource');

      await databaseHelper.updateProduct(product.toMap());

      AppLogger.info('Product updated successfully', tag: 'ProductDataSource');
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateProduct',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductDataSource',
      );
      throw DatabaseException(
        'Gagal mengupdate produk',
        operation: 'updateProduct',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      AppLogger.debug('Deleting product', tag: 'ProductDataSource');

      await databaseHelper.deleteProduct(id);

      AppLogger.info('Product deleted successfully', tag: 'ProductDataSource');
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteProduct',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductDataSource',
      );
      throw DatabaseException(
        'Gagal menghapus produk',
        operation: 'deleteProduct',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      AppLogger.debug('Searching products', tag: 'ProductDataSource');

      final data = await databaseHelper.searchProducts(query);

      AppLogger.info('Products searched successfully', tag: 'ProductDataSource');
      return data.map((map) => ProductModel.fromMap(map)).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in searchProducts',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductDataSource',
      );
      throw DatabaseException(
        'Gagal mencari produk',
        operation: 'searchProducts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> productExists(int id) async {
    try {
      AppLogger.debug('Checking product existence', tag: 'ProductDataSource');

      final exists = await databaseHelper.productExists(id);

      AppLogger.info('Product existence checked', tag: 'ProductDataSource');
      return exists;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in productExists',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductDataSource',
      );
      throw DatabaseException(
        'Gagal mengecek keberadaan produk',
        operation: 'productExists',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
