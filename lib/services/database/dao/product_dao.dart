import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for Product table operations.
///
/// This class provides a clean abstraction layer for all Product-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for the Product entity.
///
/// Usage:
/// ```dart
/// final dao = ProductDao();
/// final productMap = await dao.insert({'name': 'Product 1', 'price': 100.0});
/// final allProducts = await dao.getAll();
/// ```
class ProductDao {
  // Private constructor to prevent instantiation
  ProductDao._();

  // Singleton instance
  static final ProductDao instance = ProductDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets the database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== CRUD Operations ====================

  /// Creates a new product in the database.
  ///
  /// [product] - A map containing product fields (name, price, stock, etc.)
  /// Returns the created product map with the generated ID
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<Map<String, dynamic>> insert(Map<String, dynamic> product) async {
    try {
      AppLogger.database('Inserting product into database',
          details: 'Name: ${product['name']}');

      final db = await _db;
      final id = await db.insert('products', product);

      AppLogger.database('Product inserted successfully',
          details: 'ID: $id');

      return {...product, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert product', error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan produk',
        operation: 'insert product',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all products from the database.
  ///
  /// Returns a list of product maps, ordered by ID (newest first)
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all products from database');

      final db = await _db;
      final products = await db.query('products', orderBy: 'id DESC');

      AppLogger.database('Products fetched successfully',
          details: 'Count: ${products.length}');

      return products;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all products', error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua produk',
        operation: 'get all products',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single product by its ID.
  ///
  /// [id] - The product ID to retrieve
  /// Returns the product map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching product by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Product fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('Product not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch product by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil produk',
        operation: 'get product by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing product in the database.
  ///
  /// [product] - A map containing product fields including the 'id' field
  /// Returns the number of rows affected
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<int> update(Map<String, dynamic> product) async {
    try {
      AppLogger.database('Updating product in database',
          details: 'ID: ${product['id']}');

      if (product['id'] == null) {
        throw const app_exceptions.ValidationException(
          'ID produk diperlukan untuk update',
          field: 'id',
        );
      }

      final db = await _db;
      final count = await db.update(
        'products',
        product,
        where: 'id = ?',
        whereArgs: [product['id']],
      );

      AppLogger.database('Product updated successfully',
          details: 'ID: ${product['id']}, Affected rows: $count');

      return count;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update product', error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate produk',
        operation: 'update product',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a product from the database by its ID.
  ///
  /// [id] - The product ID to delete
  /// Returns the number of rows affected
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Deleting product from database', details: 'ID: $id');

      final db = await _db;
      final count = await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );

      AppLogger.database('Product deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete product', error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus produk',
        operation: 'delete product',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Query Operations ====================

  /// Checks if a product exists by its ID.
  ///
  /// [id] - The product ID to check
  /// Returns true if the product exists, false otherwise
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<bool> exists(int id) async {
    try {
      AppLogger.database('Checking product existence', details: 'ID: $id');

      final db = await _db;
      final result = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      final exists = result.isNotEmpty;
      AppLogger.database('Product existence checked',
          details: 'ID: $id, Exists: $exists');

      return exists;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check product existence',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengecek keberadaan produk',
        operation: 'check product existence',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Searches for products by name (case-insensitive partial match).
  ///
  /// [query] - The search query string
  /// Returns a list of matching product maps, ordered by ID (newest first)
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      AppLogger.database('Searching products', details: 'Query: $query');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'id DESC',
      );

      AppLogger.database('Product search completed',
          details: 'Query: $query, Results: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to search products', error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mencari produk',
        operation: 'search products',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Searches for products by barcode.
  ///
  /// [barcode] - The barcode to search for
  /// Returns the product map if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<Map<String, dynamic>?> getByBarcode(String barcode) async {
    try {
      AppLogger.database('Searching product by barcode',
          details: 'Barcode: $barcode');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'barcode = ?',
        whereArgs: [barcode],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Product found by barcode',
            details: 'Barcode: $barcode, ID: ${results.first['id']}');
        return results.first;
      } else {
        AppLogger.database('Product not found by barcode',
            details: 'Barcode: $barcode');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to search product by barcode',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mencari produk berdasarkan barcode',
        operation: 'search product by barcode',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves products with low stock (stock <= threshold).
  ///
  /// [threshold] - The low stock threshold (default: 10)
  /// Returns a list of product maps with low stock
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<List<Map<String, dynamic>>> getLowStockProducts(
      {int threshold = 10}) async {
    try {
      AppLogger.database('Fetching low stock products',
          details: 'Threshold: $threshold');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'stock <= ?',
        whereArgs: [threshold],
        orderBy: 'stock ASC',
      );

      AppLogger.database('Low stock products fetched',
          details: 'Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch low stock products',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil produk dengan stok rendah',
        operation: 'get low stock products',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves products that are out of stock (stock = 0).
  ///
  /// Returns a list of product maps that are out of stock
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<List<Map<String, dynamic>>> getOutOfStockProducts() async {
    try {
      AppLogger.database('Fetching out of stock products');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'stock = ?',
        whereArgs: [0],
        orderBy: 'name ASC',
      );

      AppLogger.database('Out of stock products fetched',
          details: 'Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch out of stock products',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil produk yang habis',
        operation: 'get out of stock products',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves products by category ID.
  ///
  /// [categoryId] - The category ID to filter by
  /// Returns a list of product maps in the specified category
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<List<Map<String, dynamic>>> getByCategoryId(int categoryId) async {
    try {
      AppLogger.database('Fetching products by category',
          details: 'Category ID: $categoryId');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'name ASC',
      );

      AppLogger.database('Products by category fetched',
          details: 'Category ID: $categoryId, Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch products by category',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil produk berdasarkan kategori',
        operation: 'get products by category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves products by supplier ID.
  ///
  /// [supplierId] - The supplier ID to filter by
  /// Returns a list of product maps from the specified supplier
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<List<Map<String, dynamic>>> getBySupplierId(int supplierId) async {
    try {
      AppLogger.database('Fetching products by supplier',
          details: 'Supplier ID: $supplierId');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'supplier_id = ?',
        whereArgs: [supplierId],
        orderBy: 'name ASC',
      );

      AppLogger.database('Products by supplier fetched',
          details: 'Supplier ID: $supplierId, Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch products by supplier',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil produk berdasarkan supplier',
        operation: 'get products by supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Stock Management ====================

  /// Updates the stock quantity for a product.
  ///
  /// [productId] - The product ID to update
  /// [newStock] - The new stock quantity
  /// Returns the number of rows affected
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<int> updateStock(int productId, int newStock) async {
    try {
      AppLogger.database('Updating product stock',
          details: 'Product ID: $productId, New Stock: $newStock');

      final db = await _db;
      final count = await db.update(
        'products',
        {'stock': newStock},
        where: 'id = ?',
        whereArgs: [productId],
      );

      AppLogger.database('Product stock updated successfully',
          details: 'Product ID: $productId, Affected rows: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update product stock',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate stok produk',
        operation: 'update product stock',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Adjusts the stock quantity for a product by a delta (positive or negative).
  ///
  /// [productId] - The product ID to adjust
  /// [delta] - The amount to add (positive) or subtract (negative) from stock
  /// Returns the number of rows affected
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<int> adjustStock(int productId, int delta) async {
    try {
      AppLogger.database('Adjusting product stock',
          details: 'Product ID: $productId, Delta: $delta');

      final db = await _db;
      final count = await db.rawUpdate(
        'UPDATE products SET stock = stock + ? WHERE id = ?',
        [delta, productId],
      );

      AppLogger.database('Product stock adjusted successfully',
          details: 'Product ID: $productId, Delta: $delta, Affected rows: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to adjust product stock',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menyesuaikan stok produk',
        operation: 'adjust product stock',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves products that have variants enabled.
  ///
  /// Returns a list of product maps with variants
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<List<Map<String, dynamic>>> getProductsWithVariants() async {
    try {
      AppLogger.database('Fetching products with variants');

      final db = await _db;
      final results = await db.query(
        'products',
        where: 'has_variants = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );

      AppLogger.database('Products with variants fetched',
          details: 'Count: ${results.length}');

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch products with variants',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil produk dengan varian',
        operation: 'get products with variants',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts the total number of products in the database.
  ///
  /// Returns the total count of products
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total products');

      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total products counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count products', error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah produk',
        operation: 'count products',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the total stock value (sum of price * stock for all products).
  ///
  /// Returns the total stock value
  /// Throws [app_exceptions.DatabaseException] if the operation fails
  Future<double> getTotalStockValue() async {
    try {
      AppLogger.database('Calculating total stock value');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT SUM(price * stock) as total FROM products');
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;

      AppLogger.database('Total stock value calculated', details: 'Total: $total');

      return total;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total stock value',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung nilai stok total',
        operation: 'calculate total stock value',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
