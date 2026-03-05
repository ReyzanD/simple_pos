import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/exceptions/app_exceptions.dart' as app_exceptions;
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_constants.dart';

/// Helper class for database operations with comprehensive error handling
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      AppLogger.database('Initializing database', details: path);

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize database',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menginisialisasi database',
        operation: 'inisialisasi database',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future _createDB(Database db, int version) async {
    try {
      AppLogger.database('Creating database schema version $version');

      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const realType = 'REAL NOT NULL';
      const intType = 'INTEGER NOT NULL';
      const textNullable = 'TEXT';
      const intNullable = 'INTEGER';
      const realNullable = 'REAL';

      // Create categories table with unique constraint
      await db.execute('''
        CREATE TABLE categories (
          id $idType,
          name $textType UNIQUE,
          description $textNullable,
          discount_percentage $realNullable DEFAULT 0,
          created_at $textType
        )
      ''');

      // Create suppliers table with unique constraint
      await db.execute('''
        CREATE TABLE suppliers (
          id $idType,
          name $textType UNIQUE,
          contact_person $textNullable,
          phone $textNullable,
          email $textNullable,
          address $textNullable,
          created_at $textType
        )
      ''');

      // Create products table with new fields and unique constraint
      await db.execute('''
        CREATE TABLE products (
          id $idType,
          name $textType UNIQUE,
          price $realType,
          stock $intType,
          category_id $intNullable,
          supplier_id $intNullable,
          barcode $textNullable UNIQUE,
          cost_price $realNullable DEFAULT 0,
          image_path $textNullable,
          discount_percentage $realNullable DEFAULT 0,
          FOREIGN KEY (category_id) REFERENCES categories(id),
          FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
        )
      ''');

      // Create indexes for products
      await db.execute('CREATE INDEX idx_products_name ON products(name)');
      await db.execute('CREATE INDEX idx_products_category ON products(category_id)');
      await db.execute('CREATE INDEX idx_products_supplier ON products(supplier_id)');

      // Create transactions table
      await db.execute('''
        CREATE TABLE transactions (
          id $idType,
          transaction_date $textType,
          subtotal $realType,
          tax $realType DEFAULT 0,
          discount $realType DEFAULT 0,
          total_amount $realType,
          payment_method $textType,
          payment_status $textType DEFAULT 'completed',
          notes $textNullable,
          created_at $textType,
          updated_at $textType
        )
      ''');

      // Create transaction items table
      await db.execute('''
        CREATE TABLE transaction_items (
          id $idType,
          transaction_id $intType,
          product_id $intType,
          product_name $textType,
          quantity $intType,
          unit_price $realType,
          subtotal $realType,
          FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products(id)
        )
      ''');

      // Create payments table
      await db.execute('''
        CREATE TABLE payments (
          id $idType,
          transaction_id $intType,
          payment_method $textType,
          amount $realType,
          cash_received $realNullable,
          card_last_4_digits $textNullable,
          payment_date $textType,
          FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
        )
      ''');

      // Create promotions table
      await db.execute('''
        CREATE TABLE promotions (
          id $idType,
          name $textType,
          description $textType,
          discount_percentage $realType,
          start_date $textNullable,
          end_date $textNullable,
          is_enabled $intType DEFAULT 1,
          created_at $textType
        )
      ''');

      // Create discount_presets table
      await db.execute('''
        CREATE TABLE discount_presets (
          id $idType,
          name $textType,
          description $textType,
          discount_percentage $realType,
          created_at $textType
        )
      ''');

      // Create indexes for transactions
      await db.execute('CREATE INDEX idx_transactions_date ON transactions(transaction_date)');
      await db.execute('CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id)');

      // Create indexes for promotions and discount_presets
      await db.execute('CREATE INDEX idx_promotions_enabled ON promotions(is_enabled)');
      await db.execute('CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date)');

      AppLogger.database('Database schema created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create database schema',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal membuat skema database',
        operation: 'buat tabel',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Upgrades database from oldVersion to newVersion
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      AppLogger.database('Upgrading database from v$oldVersion to v$newVersion');

      if (oldVersion < 2) {
        // Migration from version 1 to 2
        await _migrateToV2(db);
      }

      if (oldVersion < 3) {
        // Migration from version 2 to 3
        await _migrateToV3(db);
      }

      if (oldVersion < 4) {
        // Migration from version 3 to 4
        await _migrateToV4(db);
      }

      if (oldVersion < 5) {
        // Migration from version 4 to 5
        await _migrateToV5(db);
      }

      if (oldVersion < 6) {
        // Migration from version 5 to 6
        await _migrateToV6(db);
      }

      if (oldVersion < 7) {
        // Migration from version 6 to 7
        await _migrateToV7(db);
      }

      AppLogger.database('Database upgrade completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to upgrade database',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengupgrade database',
        operation: 'upgrade database',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Migration from version 1 to 2
  Future _migrateToV2(Database db) async {
    AppLogger.database('Migrating database to v2');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create suppliers table
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_person TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Add new columns to products table
    await db.execute('ALTER TABLE products ADD COLUMN category_id INTEGER');
    await db.execute('ALTER TABLE products ADD COLUMN supplier_id INTEGER');
    await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT');
    await db.execute('ALTER TABLE products ADD COLUMN cost_price REAL DEFAULT 0');

    // Create indexes for products
    await db.execute('CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_products_supplier ON products(supplier_id)');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_date TEXT NOT NULL,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL DEFAULT 0,
        discount REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_status TEXT NOT NULL DEFAULT 'completed',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create transaction items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Create payments table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        amount REAL NOT NULL,
        cash_received REAL,
        card_last_4_digits TEXT,
        payment_date TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for transactions
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transaction_items_transaction ON transaction_items(transaction_id)');

    AppLogger.database('Database migration to v2 completed');
  }

  /// Migration from version 2 to 3
  Future _migrateToV3(Database db) async {
    AppLogger.database('Migrating database to v3');

    // Add image_path column to products table
    await db.execute('ALTER TABLE products ADD COLUMN image_path TEXT');

    AppLogger.database('Database migration to v3 completed');
  }

  /// Migration from version 3 to 4
  Future _migrateToV4(Database db) async {
    AppLogger.database('Migrating database to v4');

    // Add discount_percentage column to products table
    await db.execute('ALTER TABLE products ADD COLUMN discount_percentage REAL DEFAULT 0');

    AppLogger.database('Database migration to v4 completed');
  }

  /// Migration from version 4 to 5
  Future _migrateToV5(Database db) async {
    AppLogger.database('Migrating database to v5');

    // Add discount_percentage column to categories table
    await db.execute('ALTER TABLE categories ADD COLUMN discount_percentage REAL DEFAULT 0');

    // Create promotions table
    await db.execute('''
      CREATE TABLE promotions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        discount_percentage REAL NOT NULL,
        start_date TEXT,
        end_date TEXT,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Create discount_presets table
    await db.execute('''
      CREATE TABLE discount_presets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        discount_percentage REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for promotions and discount_presets
    await db.execute('CREATE INDEX IF NOT EXISTS idx_promotions_enabled ON promotions(is_enabled)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_promotions_dates ON promotions(start_date, end_date)');

    AppLogger.database('Database migration to v5 completed');
  }

  /// Migration from version 5 to 6
  Future _migrateToV6(Database db) async {
    AppLogger.database('Migrating database to v6');

    // Create held_carts table for cart persistence
    await db.execute('''
      CREATE TABLE held_carts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        cart_data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for faster queries
    await db.execute('CREATE INDEX IF NOT EXISTS idx_held_carts_created ON held_carts(created_at DESC)');

    AppLogger.database('Database migration to v6 completed');
  }

  /// Migration from version 6 to 7
  /// Adds support for product variants (e.g., Size S/M/L, Color Red/Blue)
  Future _migrateToV7(Database db) async {
    AppLogger.database('Migrating database to v7');

    // Add has_variants column to products table
    await db.execute('ALTER TABLE products ADD COLUMN has_variants INTEGER DEFAULT 0');

    // Create variant_attributes table for storing variant options (Size, Color, etc.)
    await db.execute('''
      CREATE TABLE variant_attributes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        attribute_name TEXT NOT NULL,
        attribute_values TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    // Create product_variants table for storing variant combinations
    await db.execute('''
      CREATE TABLE product_variants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        sku TEXT,
        barcode TEXT,
        price REAL NOT NULL,
        cost_price REAL DEFAULT 0,
        stock INTEGER DEFAULT 0,
        attributes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster variant queries
    await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON product_variants(barcode)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_variant_attributes_product_id ON variant_attributes(product_id)');

    AppLogger.database('Database migration to v7 completed');
  }

  /// Inserts a product into the database
  /// Returns the inserted product with generated ID
  Future<Map<String, dynamic>> insertProduct(Map<String, dynamic> product) async {
    try {
      final db = await instance.database;
      AppLogger.database('Inserting product', details: product['name']);

      final id = await db.insert('products', product);

      final result = Map<String, dynamic>.from(product);
      result['id'] = id;

      AppLogger.database('Product inserted', details: 'ID: $id');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to insert product',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan produk',
        operation: 'tambah produk',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all products from the database
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final db = await instance.database;
      AppLogger.database('Fetching all products');

      final result = await db.query(
        'products',
        orderBy: 'id DESC',
      );

      AppLogger.database('Products fetched', details: '${result.length} items');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch products',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil data produk',
        operation: 'ambil produk',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single product by ID
  Future<Map<String, dynamic>?> getProductById(int id) async {
    try {
      final db = await instance.database;
      AppLogger.database('Fetching product', details: 'ID: $id');

      final results = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        AppLogger.database('Product not found', details: 'ID: $id');
        return null;
      }

      AppLogger.database('Product fetched', details: 'ID: $id');
      return results.first;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch product by ID',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil data produk',
        operation: 'ambil produk by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates a product in the database
  /// Returns the number of rows affected
  Future<int> updateProduct(Map<String, dynamic> product) async {
    try {
      final db = await instance.database;
      final id = product['id'];

      AppLogger.database('Updating product', details: 'ID: $id');

      final rowsAffected = await db.update(
        'products',
        product,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.database('Product not found for update', details: 'ID: $id');
        throw app_exceptions.NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Product updated', details: 'ID: $id');
      return rowsAffected;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update product',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate produk',
        operation: 'update produk',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a product from the database
  /// Returns the number of rows affected
  Future<int> deleteProduct(int id) async {
    try {
      final db = await instance.database;
      AppLogger.database('Deleting product', details: 'ID: $id');

      final rowsAffected = await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.database('Product not found for deletion', details: 'ID: $id');
        throw app_exceptions.NotFoundException(
          'Produk tidak ditemukan',
          resourceType: 'Produk',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Product deleted', details: 'ID: $id');
      return rowsAffected;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete product',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menghapus produk',
        operation: 'hapus produk',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Searches for products by name
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final db = await instance.database;
      AppLogger.database('Searching products', details: 'Query: $query');

      final result = await db.query(
        'products',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'id DESC',
      );

      AppLogger.database('Search completed', details: '${result.length} results');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to search products',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mencari produk',
        operation: 'cari produk',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if a product exists by ID
  Future<bool> productExists(int id) async {
    try {
      final db = await instance.database;
      AppLogger.database('Checking product existence', details: 'ID: $id');

      final result = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      final exists = result.isNotEmpty;
      AppLogger.database('Product existence checked', details: 'Exists: $exists');
      return exists;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check product existence',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengecek keberadaan produk',
        operation: 'cek produk',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Category Methods ====================

  /// Inserts a category into the database
  Future<Map<String, dynamic>> insertCategory(Map<String, dynamic> category) async {
    try {
      final db = await instance.database;
      AppLogger.database('Inserting category', details: category['name']);

      final id = await db.insert('categories', category);
      final result = await getCategoryById(id);

      AppLogger.database('Category inserted', details: 'ID: $id');
      return result!;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to insert category',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan kategori',
        operation: 'insert category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all categories from the database
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final db = await instance.database;
      AppLogger.database('Fetching all categories');

      final result = await db.query(
        'categories',
        orderBy: 'name ASC',
      );

      AppLogger.database('Categories fetched', details: '${result.length} categories');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch categories',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil kategori',
        operation: 'get categories',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a category by ID
  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    try {
      final db = await instance.database;
      AppLogger.database('Fetching category', details: 'ID: $id');

      final result = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        AppLogger.database('Category not found', details: 'ID: $id');
        return null;
      }

      AppLogger.database('Category fetched', details: 'ID: $id');
      return result.first;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch category',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil kategori',
        operation: 'get category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates a category in the database
  Future<int> updateCategory(int id, Map<String, dynamic> values) async {
    try {
      final db = await instance.database;
      AppLogger.database('Updating category', details: 'ID: $id');

      final rowsAffected = await db.update(
        'categories',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.database('Category not found for update', details: 'ID: $id');
        throw app_exceptions.NotFoundException(
          'Kategori tidak ditemukan',
          resourceType: 'Kategori',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Category updated', details: 'ID: $id');
      return rowsAffected;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update category',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate kategori',
        operation: 'update category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a category from the database
  Future<int> deleteCategory(int id) async {
    try {
      final db = await instance.database;
      AppLogger.database('Deleting category', details: 'ID: $id');

      final rowsAffected = await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.database('Category not found for deletion', details: 'ID: $id');
        throw app_exceptions.NotFoundException(
          'Kategori tidak ditemukan',
          resourceType: 'Kategori',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Category deleted', details: 'ID: $id');
      return rowsAffected;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete category',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menghapus kategori',
        operation: 'hapus category',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Supplier Methods ====================

  /// Inserts a supplier into the database
  Future<Map<String, dynamic>> insertSupplier(Map<String, dynamic> supplier) async {
    try {
      final db = await instance.database;
      AppLogger.database('Inserting supplier', details: supplier['name']);

      final id = await db.insert('suppliers', supplier);
      final result = await getSupplierById(id);

      AppLogger.database('Supplier inserted', details: 'ID: $id');
      return result!;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to insert supplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan pemasok',
        operation: 'insert supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all suppliers from the database
  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
    try {
      final db = await instance.database;
      AppLogger.database('Fetching all suppliers');

      final result = await db.query(
        'suppliers',
        orderBy: 'name ASC',
      );

      AppLogger.database('Suppliers fetched', details: '${result.length} suppliers');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch suppliers',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pemasok',
        operation: 'get suppliers',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a supplier by ID
  Future<Map<String, dynamic>?> getSupplierById(int id) async {
    try {
      final db = await instance.database;
      AppLogger.database('Fetching supplier', details: 'ID: $id');

      final result = await db.query(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        AppLogger.database('Supplier not found', details: 'ID: $id');
        return null;
      }

      AppLogger.database('Supplier fetched', details: 'ID: $id');
      return result.first;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch supplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pemasok',
        operation: 'get supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates a supplier in the database
  Future<int> updateSupplier(int id, Map<String, dynamic> values) async {
    try {
      final db = await instance.database;
      AppLogger.database('Updating supplier', details: 'ID: $id');

      final rowsAffected = await db.update(
        'suppliers',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.database('Supplier not found for update', details: 'ID: $id');
        throw app_exceptions.NotFoundException(
          'Pemasok tidak ditemukan',
          resourceType: 'Pemasok',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Supplier updated', details: 'ID: $id');
      return rowsAffected;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update supplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate pemasok',
        operation: 'update supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a supplier from the database
  Future<int> deleteSupplier(int id) async {
    try {
      final db = await instance.database;
      AppLogger.database('Deleting supplier', details: 'ID: $id');

      final rowsAffected = await db.delete(
        'suppliers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.database('Supplier not found for deletion', details: 'ID: $id');
        throw app_exceptions.NotFoundException(
          'Pemasok tidak ditemukan',
          resourceType: 'Pemasok',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('Supplier deleted', details: 'ID: $id');
      return rowsAffected;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete supplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menghapus pemasok',
        operation: 'hapus supplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Clear all data from all tables
  Future<void> clearAllData() async {
    try {
      final db = await instance.database;
      AppLogger.database('Clearing all data');

      // Get all table names
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );

      // Delete all data from each table
      for (var table in tables) {
        final tableName = table['name'] as String;
        await db.delete(tableName);
        AppLogger.database('Cleared table: $tableName');
      }

      AppLogger.database('All data cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear all data',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menghapus semua data',
        operation: 'clearAllData',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    try {
      final db = await instance.database;
      await db.close();
      _database = null;
      AppLogger.database('Database connection closed');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to close database',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
    }
  }
}
