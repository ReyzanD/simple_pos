import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for adding a new product
class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase({required this.repository});

  /// Executes the use case
  /// Returns the created product with generated ID
  Future<Product> execute(Product product) async {
    try {
      AppLogger.useCase('AddProduct', details: product.name);

      // Validate product
      product.validate();

      // Check if product with same name already exists
      final existingProducts = await repository.searchProducts(product.name);
      if (existingProducts.any((p) => p.name.toLowerCase() == product.name.toLowerCase())) {
        throw ValidationException(
          'Produk dengan nama "${product.name}" sudah ada',
          field: 'Nama Produk',
        );
      }

      final result = await repository.addProduct(product);

      AppLogger.info('Product added successfully', tag: 'AddProductUseCase');
      return result;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddProductUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'AddProductUseCase',
      );
      throw DatabaseException(
        'Gagal menambahkan produk',
        operation: 'AddProduct',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
