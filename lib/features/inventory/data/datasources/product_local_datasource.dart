import '../models/product_model.dart';

/// Interface for local data source operations
abstract class ProductLocalDataSource {
  /// Creates a new product in the local database
  Future<ProductModel> createProduct(ProductModel product);

  /// Retrieves all products from the local database
  Future<List<ProductModel>> getAllProducts();

  /// Retrieves a single product by ID from the local database
  Future<ProductModel> getProductById(int id);

  /// Updates an existing product in the local database
  Future<void> updateProduct(ProductModel product);

  /// Deletes a product from the local database
  Future<void> deleteProduct(int id);

  /// Searches for products by name in the local database
  Future<List<ProductModel>> searchProducts(String query);

  /// Checks if a product exists in the local database
  Future<bool> productExists(int id);
}
