import '../entities/product.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Interface for product repository operations
abstract class ProductRepository {
  /// Retrieves all products from the data source
  /// Throws [DatabaseException] if retrieval fails
  Future<List<Product>> getProducts();

  /// Retrieves a single product by ID
  /// Throws [NotFoundException] if product doesn't exist
  /// Throws [DatabaseException] if retrieval fails
  Future<Product> getProductById(int id);

  /// Adds a new product to the data source
  /// Throws [ValidationException] if validation fails
  /// Throws [DatabaseException] if insertion fails
  Future<Product> addProduct(Product product);

  /// Updates an existing product in the data source
  /// Throws [NotFoundException] if product doesn't exist
  /// Throws [ValidationException] if validation fails
  /// Throws [DatabaseException] if update fails
  Future<void> updateProduct(Product product);

  /// Deletes a product from the data source
  /// Throws [NotFoundException] if product doesn't exist
  /// Throws [DatabaseException] if deletion fails
  Future<void> deleteProduct(int id);

  /// Searches for products by name
  /// Throws [DatabaseException] if search fails
  Future<List<Product>> searchProducts(String query);

  /// Checks if a product exists by ID
  /// Throws [DatabaseException] if check fails
  Future<bool> productExists(int id);
}
