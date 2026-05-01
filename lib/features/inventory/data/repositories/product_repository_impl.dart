import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';

/// Implementation of product repository
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getProducts() async {
    try {
      AppLogger.useCase('GetProducts');

      final productModels = await localDataSource.getAllProducts();

      return productModels.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getProducts',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
      );
      throw DatabaseException(
        'Gagal mengambil data produk',
        operation: 'getProducts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      AppLogger.useCase('GetProductById', details: 'ID: $id');

      Validators.validateProductId(id);

      final productModel = await localDataSource.getProductById(id);

      return productModel.toEntity();
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getProductById',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
      );
      throw DatabaseException(
        'Gagal mengambil data produk',
        operation: 'getProductById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    try {
      AppLogger.useCase('AddProduct', details: product.name);

      // Validate product data
      product.validate();

      final productModel = ProductModel.fromEntity(product);

      final createdModel = await localDataSource.createProduct(productModel);

      AppLogger.info('Product added successfully', tag: 'ProductRepository');
      return createdModel.toEntity();
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in addProduct',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
      );
      throw DatabaseException(
        'Gagal menambahkan produk',
        operation: 'addProduct',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      AppLogger.useCase('UpdateProduct', details: 'ID: ${product.id}');

      if (product.id == null) {
        throw const ValidationException(
          'ID produk diperlukan untuk update',
          field: 'ID',
        );
      }

      // Validate product data
      product.validate();

      // Check if product exists
      final exists = await localDataSource.productExists(product.id!);
      if (!exists) {
        throw NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: product.id.toString(),
        );
      }

      final productModel = ProductModel.fromEntity(product);

      await localDataSource.updateProduct(productModel);

      AppLogger.info('Product updated successfully', tag: 'ProductRepository');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateProduct',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
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
      AppLogger.useCase('DeleteProduct', details: 'ID: $id');

      Validators.validateProductId(id);

      // Check if product exists
      final exists = await localDataSource.productExists(id);
      if (!exists) {
        throw NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: id.toString(),
        );
      }

      await localDataSource.deleteProduct(id);

      AppLogger.info('Product deleted successfully', tag: 'ProductRepository');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteProduct',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
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
  Future<List<Product>> searchProducts(String query) async {
    try {
      AppLogger.useCase('SearchProducts', details: 'Query: $query');

      if (query.trim().isEmpty) {
        return [];
      }

      final productModels = await localDataSource.searchProducts(query);

      return productModels.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in searchProducts',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
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
      AppLogger.useCase('ProductExists', details: 'ID: $id');

      return await localDataSource.productExists(id);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in productExists',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
      );
      throw DatabaseException(
        'Gagal mengecek keberadaan produk',
        operation: 'productExists',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getStock(int productId) async {
    try {
      AppLogger.useCase('GetStock', details: 'Product ID: $productId');

      Validators.validateProductId(productId);

      final productModel = await localDataSource.getProductById(productId);

      return productModel.stock;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getStock',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
      );
      throw DatabaseException(
        'Gagal mengambil stok produk',
        operation: 'getStock',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateStock(int productId, int newStock) async {
    try {
      AppLogger.useCase('UpdateStock', details: 'Product ID: $productId, New Stock: $newStock');

      Validators.validateProductId(productId);

      if (newStock < 0) {
        throw ValidationException(
          'Stok tidak boleh negatif',
          field: 'stock',
        );
      }

      final productModel = await localDataSource.getProductById(productId);

      final updatedProduct = ProductModel(
        id: productModel.id,
        name: productModel.name,
        price: productModel.price,
        costPrice: productModel.costPrice,
        stock: newStock,
        categoryId: productModel.categoryId,
        supplierId: productModel.supplierId,
        barcode: productModel.barcode,
        imagePath: productModel.imagePath,
        discountPercentage: productModel.discountPercentage,
        hasVariants: productModel.hasVariants,
        unitOfMeasurement: productModel.unitOfMeasurement,
      );

      await localDataSource.updateProduct(updatedProduct);

      AppLogger.info('Stock updated successfully', tag: 'ProductRepository');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateStock',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProductRepository',
      );
      throw DatabaseException(
        'Gagal mengupdate stok produk',
        operation: 'updateStock',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
