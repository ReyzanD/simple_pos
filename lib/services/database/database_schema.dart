import 'package:sqflite/sqflite.dart';
import '../../../core/utils/logger.dart';
import '../../../core/exceptions/app_exceptions.dart' as app_exceptions;

/// Manages database schema creation, migrations, and validation
///
/// This class is responsible for all database schema operations including:
/// - Creating tables
/// - Creating indexes
/// - Running migrations
/// - Validating schema
class DatabaseSchema {
  // Private constructor to prevent instantiation
  DatabaseSchema._();

  // SQLite column type constants
  static const String _idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String _textType = 'TEXT NOT NULL';
  static const String _realType = 'REAL NOT NULL';
  static const String _intType = 'INTEGER NOT NULL';
  static const String _textNullable = 'TEXT';
  static const String _intNullable = 'INTEGER';
  static const String _realNullable = 'REAL';

  // ==================== Table Creation Methods ====================

  /// Creates the categories table
  static Future<void> createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id $_idType,
        name $_textType UNIQUE,
        description $_textNullable,
        discount_percentage $_realNullable DEFAULT 0,
        created_at $_textType
      )
    ''');
    AppLogger.database('Categories table created');
  }

  /// Creates the suppliers table
  static Future<void> createSuppliersTable(Database db) async {
    await db.execute('''
      CREATE TABLE suppliers (
        id $_idType,
        name $_textType UNIQUE,
        contact_person $_textNullable,
        phone $_textNullable,
        email $_textNullable,
        address $_textNullable,
        created_at $_textType
      )
    ''');
    AppLogger.database('Suppliers table created');
  }

  /// Creates the products table
  static Future<void> createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE products (
        id $_idType,
        name $_textType UNIQUE,
        price $_realType,
        stock $_intType,
        category_id $_intNullable,
        supplier_id $_intNullable,
        barcode $_textNullable UNIQUE,
        cost_price $_realNullable DEFAULT 0,
        image_path $_textNullable,
        discount_percentage $_realNullable DEFAULT 0,
        has_variants $_intType DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
      )
    ''');
    AppLogger.database('Products table created');
  }

  /// Creates the transactions table
  static Future<void> createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id $_idType,
        transaction_date $_textType,
        subtotal $_realType,
        tax $_realType DEFAULT 0,
        discount $_realType DEFAULT 0,
        total_amount $_realType,
        payment_method $_textType,
        payment_status $_textType DEFAULT 'completed',
        notes $_textNullable,
        created_at $_textType,
        updated_at $_textType
      )
    ''');
    AppLogger.database('Transactions table created');
  }

  /// Creates the transaction_items table
  static Future<void> createTransactionItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transaction_items (
        id $_idType,
        transaction_id $_intType,
        product_id $_intType,
        product_name $_textType,
        quantity $_intType,
        unit_price $_realType,
        subtotal $_realType,
        cost_price $_realNullable DEFAULT 0,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
    AppLogger.database('Transaction items table created');
  }

  /// Creates the payments table
  static Future<void> createPaymentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE payments (
        id $_idType,
        transaction_id $_intType,
        payment_method $_textType,
        amount $_realType,
        cash_received $_realNullable,
        card_last_4_digits $_textNullable,
        payment_date $_textType,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
      )
    ''');
    AppLogger.database('Payments table created');
  }

  /// Creates the promotions table
  static Future<void> createPromotionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE promotions (
        id $_idType,
        name $_textType,
        description $_textType,
        discount_percentage $_realType,
        start_date $_textNullable,
        end_date $_textNullable,
        is_enabled $_intType DEFAULT 1,
        created_at $_textType
      )
    ''');
    AppLogger.database('Promotions table created');
  }

  /// Creates the discount_presets table
  static Future<void> createDiscountPresetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE discount_presets (
        id $_idType,
        name $_textType,
        description $_textType,
        discount_percentage $_realType,
        created_at $_textType
      )
    ''');
    AppLogger.database('Discount presets table created');
  }

  /// Creates the shifts table
  static Future<void> createShiftsTable(Database db) async {
    await db.execute('''
      CREATE TABLE shifts (
        id $_idType,
        user_name $_textType,
        opening_balance $_realType DEFAULT 0,
        closing_balance $_realNullable DEFAULT 0,
        cash_sales $_realType DEFAULT 0,
        card_sales $_realType DEFAULT 0,
        qr_sales $_realType DEFAULT 0,
        transfer_sales $_realType DEFAULT 0,
        total_transactions $_intType DEFAULT 0,
        opened_at $_intType NOT NULL,
        closed_at $_intNullable
      )
    ''');
    AppLogger.database('Shifts table created');
  }

  /// Creates the users table
  static Future<void> createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username $_textType UNIQUE,
        password_hash $_textType,
        full_name $_textType,
        role $_textType DEFAULT 'cashier',
        is_active $_intType DEFAULT 1,
        created_at $_intType NOT NULL,
        last_login $_intNullable
      )
    ''');
    AppLogger.database('Users table created');
  }

  /// Creates the user_sessions table
  static Future<void> createUserSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id $_intType NOT NULL,
        login_time $_intType NOT NULL,
        logout_time $_intNullable,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    AppLogger.database('User sessions table created');
  }

  /// Creates the expenses table
  static Future<void> createExpensesTable(Database db) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category $_textType,
        amount $_realType,
        description $_textNullable,
        payment_method $_textType DEFAULT 'cash',
        receipt_image $_textNullable,
        created_by $_intNullable,
        created_at $_intType NOT NULL,
        date $_intType NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');
    AppLogger.database('Expenses table created');
  }

  /// Creates the held_carts table
  static Future<void> createHeldCartsTable(Database db) async {
    await db.execute('''
      CREATE TABLE held_carts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name $_textType,
        cart_data $_textType,
        created_at $_textType,
        updated_at $_textType
      )
    ''');
    AppLogger.database('Held carts table created');
  }

  /// Creates the variant_attributes table
  static Future<void> createVariantAttributesTable(Database db) async {
    await db.execute('''
      CREATE TABLE variant_attributes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id $_intType NOT NULL,
        attribute_name $_textType,
        attribute_values $_textType,
        sort_order $_intType DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    AppLogger.database('Variant attributes table created');
  }

  /// Creates the product_variants table
  static Future<void> createProductVariantsTable(Database db) async {
    await db.execute('''
      CREATE TABLE product_variants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id $_intType NOT NULL,
        name $_textType,
        sku $_textNullable,
        barcode $_textNullable,
        price $_realType,
        cost_price $_realNullable DEFAULT 0,
        stock $_intType DEFAULT 0,
        attributes $_textNullable,
        is_active $_intType DEFAULT 1,
        created_at $_textType,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    AppLogger.database('Product variants table created');
  }

  /// Creates the cash_counts table
  static Future<void> createCashCountsTable(Database db) async {
    await db.execute('''
      CREATE TABLE cash_counts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shift_id $_intType NOT NULL,
        denomination $_intType NOT NULL,
        count $_intType DEFAULT 0,
        counted_at $_intType NOT NULL,
        counted_by $_textType,
        FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE
      )
    ''');
    AppLogger.database('Cash counts table created');
  }

  /// Creates the audit_logs table
  static Future<void> createAuditLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action $_textType,
        entity_type $_textType,
        entity_id $_textNullable,
        description $_textNullable,
        username $_textNullable,
        user_id $_textNullable,
        old_values $_textNullable,
        new_values $_textNullable,
        ip_address $_textNullable,
        user_agent $_textNullable,
        created_at $_intType NOT NULL
      )
    ''');
    AppLogger.database('Audit logs table created');
  }

  /// Creates the stock_adjustments table
  static Future<void> createStockAdjustmentsTable(Database db) async {
    await db.execute('''\
    CREATE TABLE stock_adjustments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      previous_quantity INTEGER NOT NULL,
      new_quantity INTEGER NOT NULL,
      adjustment_type TEXT NOT NULL,
      reason TEXT,
      created_by TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (product_id) REFERENCES products(id)
    )
  ''');
    AppLogger.database('Stock adjustments table created');
  }

  /// Creates all database tables
  static Future<void> createAllTables(Database db) async {
    AppLogger.database('Creating all database tables');

    await createCategoriesTable(db);
    await createSuppliersTable(db);
    await createProductsTable(db);
    await createTransactionsTable(db);
    await createTransactionItemsTable(db);
    await createPaymentsTable(db);
    await createPromotionsTable(db);
    await createDiscountPresetsTable(db);
    await createShiftsTable(db);
    await createUsersTable(db);
    await createUserSessionsTable(db);
    await createExpensesTable(db);
    await createHeldCartsTable(db);
    await createVariantAttributesTable(db);
    await createProductVariantsTable(db);
    await createCashCountsTable(db);
    await createAuditLogsTable(db);
    await createStockAdjustmentsTable(db);

    AppLogger.database('All tables created successfully');
  }

  // ==================== Index Creation Methods ====================

  /// Creates indexes for the products table
  static Future<void> createProductIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_products_name ON products(name)');
    await db.execute(
      'CREATE INDEX idx_products_category ON products(category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_products_supplier ON products(supplier_id)',
    );
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
    await db.execute('CREATE INDEX idx_products_stock ON products(stock)');
    await db.execute(
      'CREATE INDEX idx_products_has_variants ON products(has_variants)',
    );
    AppLogger.database('Product indexes created');
  }

  /// Creates indexes for the transactions and transaction_items tables
  static Future<void> createTransactionIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions(transaction_date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_created_at ON transactions(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_payment_method ON transactions(payment_method)',
    );
    await db.execute(
      'CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transaction_items_product ON transaction_items(product_id)',
    );
    AppLogger.database('Transaction indexes created');
  }

  /// Creates indexes for the promotions table
  static Future<void> createPromotionIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_promotions_enabled ON promotions(is_enabled)',
    );
    await db.execute(
      'CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date)',
    );
    AppLogger.database('Promotion indexes created');
  }

  /// Creates indexes for the shifts table
  static Future<void> createShiftIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX idx_shifts_opened_at ON shifts(opened_at DESC)',
    );
    await db.execute('CREATE INDEX idx_shifts_closed_at ON shifts(closed_at)');
    AppLogger.database('Shift indexes created');
  }

  /// Creates indexes for the users and user_sessions tables
  static Future<void> createUserIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON user_sessions(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_sessions_login_time ON user_sessions(login_time DESC)',
    );
    AppLogger.database('User indexes created');
  }

  /// Creates indexes for the expenses table
  static Future<void> createExpenseIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_created_by ON expenses(created_by)',
    );
    AppLogger.database('Expense indexes created');
  }

  /// Creates indexes for the held_carts table
  static Future<void> createHeldCartIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_held_carts_created ON held_carts(created_at DESC)',
    );
    AppLogger.database('Held cart indexes created');
  }

  /// Creates indexes for the variant tables
  static Future<void> createVariantIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON product_variants(barcode)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_variant_attributes_product_id ON variant_attributes(product_id)',
    );
    AppLogger.database('Variant indexes created');
  }

  /// Creates indexes for the cash_counts table
  static Future<void> createCashCountIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_counts_shift ON cash_counts(shift_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_counts_denomination ON cash_counts(denomination)',
    );
    AppLogger.database('Cash count indexes created');
  }

  /// Creates indexes for the audit_logs table
  static Future<void> createAuditLogIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(username)',
    );
    AppLogger.database('Audit log indexes created');
  }

  /// Creates all database indexes
  static Future<void> createAllIndexes(Database db) async {
    AppLogger.database('Creating all database indexes');

    await createProductIndexes(db);
    await createTransactionIndexes(db);
    await createPromotionIndexes(db);
    await createShiftIndexes(db);
    await createUserIndexes(db);
    await createExpenseIndexes(db);
    await createHeldCartIndexes(db);
    await createVariantIndexes(db);
    await createCashCountIndexes(db);
    await createAuditLogIndexes(db);

    AppLogger.database('All indexes created successfully');
  }

  // ==================== Schema Validation Methods ====================

  /// Checks if a table exists in the database
  static Future<bool> tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Checks if an index exists for a given table
  static Future<bool> indexExists(
    Database db,
    String indexName,
    String tableName,
  ) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND name=? AND tbl_name=?",
      [indexName, tableName],
    );
    return result.isNotEmpty;
  }

  // ==================== Migration Methods ====================

  /// Executes migration from oldVersion to newVersion
  static Future<void> executeMigration(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      AppLogger.database(
        'Upgrading database from v$oldVersion to v$newVersion',
      );

      if (oldVersion < 2) {
        await _migrateToV2(db);
      }

      if (oldVersion < 3) {
        await _migrateToV3(db);
      }

      if (oldVersion < 4) {
        await _migrateToV4(db);
      }

      if (oldVersion < 5) {
        await _migrateToV5(db);
      }

      if (oldVersion < 6) {
        await _migrateToV6(db);
      }

      if (oldVersion < 7) {
        await _migrateToV7(db);
      }

      if (oldVersion < 8) {
        await _migrateToV8(db);
      }

      if (oldVersion < 9) {
        await _migrateToV9(db);
      }

      if (oldVersion < 10) {
        await _migrateToV10(db);
      }

      if (oldVersion < 11) {
        await _migrateToV11(db);
      }

      if (oldVersion < 12) {
        await _migrateToV12(db);
      }

      if (oldVersion < 13) {
        await _migrateToV13(db);
      }

      if (oldVersion < 14) {
        await _migrateToV14(db);
      }

      if (oldVersion < 15) {
        await _migrateToV15(db);
      }

      if (oldVersion < 16) {
        await _migrateToV16(db);
      }

      AppLogger.database('Database upgrade completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to upgrade database',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseSchema',
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
  static Future<void> _migrateToV2(Database db) async {
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
    await db.execute(
      'ALTER TABLE products ADD COLUMN cost_price REAL DEFAULT 0',
    );

    // Create indexes for products
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_supplier ON products(supplier_id)',
    );

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
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_items_transaction ON transaction_items(transaction_id)',
    );

    AppLogger.database('Database migration to v2 completed');
  }

  /// Migration from version 2 to 3
  static Future<void> _migrateToV3(Database db) async {
    AppLogger.database('Migrating database to v3');
    await db.execute('ALTER TABLE products ADD COLUMN image_path TEXT');
    AppLogger.database('Database migration to v3 completed');
  }

  /// Migration from version 3 to 4
  static Future<void> _migrateToV4(Database db) async {
    AppLogger.database('Migrating database to v4');
    await db.execute(
      'ALTER TABLE products ADD COLUMN discount_percentage REAL DEFAULT 0',
    );
    AppLogger.database('Database migration to v4 completed');
  }

  /// Migration from version 4 to 5
  static Future<void> _migrateToV5(Database db) async {
    AppLogger.database('Migrating database to v5');

    // Add discount_percentage column to categories table
    await db.execute(
      'ALTER TABLE categories ADD COLUMN discount_percentage REAL DEFAULT 0',
    );

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
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_promotions_enabled ON promotions(is_enabled)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_promotions_dates ON promotions(start_date, end_date)',
    );

    AppLogger.database('Database migration to v5 completed');
  }

  /// Migration from version 5 to 6
  static Future<void> _migrateToV6(Database db) async {
    AppLogger.database('Migrating database to v6');

    await db.execute('''
      CREATE TABLE held_carts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        cart_data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_held_carts_created ON held_carts(created_at DESC)',
    );

    AppLogger.database('Database migration to v6 completed');
  }

  /// Migration from version 6 to 7
  static Future<void> _migrateToV7(Database db) async {
    AppLogger.database('Migrating database to v7');

    await db.execute(
      'ALTER TABLE products ADD COLUMN has_variants INTEGER DEFAULT 0',
    );

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

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON product_variants(barcode)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_variant_attributes_product_id ON variant_attributes(product_id)',
    );

    AppLogger.database('Database migration to v7 completed');
  }

  /// Migration from version 7 to 8
  static Future<void> _migrateToV8(Database db) async {
    AppLogger.database('Migrating database to v8');

    try {
      await db.execute(
        'ALTER TABLE products ADD COLUMN has_variants INTEGER DEFAULT 0',
      );
      AppLogger.database('Added has_variants column to products table');
    } catch (e) {
      AppLogger.database('has_variants column already exists or error: $e');
    }

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS held_carts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_name TEXT NOT NULL,
          cart_data TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_held_carts_created ON held_carts(created_at DESC)',
      );
      AppLogger.database('Ensured held_carts table exists');
    } catch (e) {
      AppLogger.database('held_carts table error: $e');
    }

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS variant_attributes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          attribute_name TEXT NOT NULL,
          attribute_values TEXT NOT NULL,
          sort_order INTEGER DEFAULT 0,
          FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS product_variants (
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

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON product_variants(barcode)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_variant_attributes_product_id ON variant_attributes(product_id)',
      );

      AppLogger.database('Ensured variant tables exist');
    } catch (e) {
      AppLogger.database('Variant tables error: $e');
    }

    AppLogger.database('Database migration to v8 completed');
  }

  /// Migration from version 8 to 9
  static Future<void> _migrateToV9(Database db) async {
    AppLogger.database('Migrating database to v9');

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS held_carts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_name TEXT NOT NULL,
          cart_data TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_held_carts_created ON held_carts(created_at DESC)',
      );
      AppLogger.database('Ensured held_carts table exists');
    } catch (e) {
      AppLogger.database('held_carts table error: $e');
    }

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS variant_attributes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          attribute_name TEXT NOT NULL,
          attribute_values TEXT NOT NULL,
          sort_order INTEGER DEFAULT 0,
          FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS product_variants (
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

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON product_variants(barcode)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_variant_attributes_product_id ON variant_attributes(product_id)',
      );

      AppLogger.database('Ensured variant tables exist');
    } catch (e) {
      AppLogger.database('Variant tables error: $e');
    }

    AppLogger.database('Database migration to v9 completed');
  }

  /// Migration from version 9 to 10
  static Future<void> _migrateToV10(Database db) async {
    AppLogger.database('Migrating database to v10');

    try {
      await db.execute(
        'ALTER TABLE transaction_items ADD COLUMN cost_price REAL DEFAULT 0',
      );
      AppLogger.database('Added cost_price column to transaction_items table');
    } catch (e) {
      AppLogger.database('cost_price column migration (may already exist): $e');
    }

    AppLogger.database('Database migration to v10 completed');
  }

  /// Migration from version 10 to 11
  static Future<void> _migrateToV11(Database db) async {
    AppLogger.database('Migrating database to v11');

    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_name TEXT NOT NULL,
        opening_balance REAL DEFAULT 0,
        closing_balance REAL DEFAULT 0,
        cash_sales REAL DEFAULT 0,
        card_sales REAL DEFAULT 0,
        qr_sales REAL DEFAULT 0,
        transfer_sales REAL DEFAULT 0,
        total_transactions INTEGER DEFAULT 0,
        opened_at INTEGER NOT NULL,
        closed_at INTEGER
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shifts_opened_at ON shifts(opened_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shifts_closed_at ON shifts(closed_at)',
    );

    AppLogger.database('Database migration to v11 completed');
  }

  /// Migration from version 11 to 12
  static Future<void> _migrateToV12(Database db) async {
    AppLogger.database('Migrating database to v12');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'cashier',
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        last_login INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        login_time INTEGER NOT NULL,
        logout_time INTEGER,
        opening_cash REAL DEFAULT 0,
        closing_cash REAL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON user_sessions(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_sessions_login_time ON user_sessions(login_time DESC)',
    );

    // Create default admin user
    final adminPasswordHash = _hashPassword('admin123');
    await db.insert('users', {
      'username': 'admin',
      'password_hash': adminPasswordHash,
      'full_name': 'Administrator',
      'role': 'admin',
      'is_active': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });

    AppLogger.database('Database migration to v12 completed');
  }

  /// Migration from version 12 to 13
  static Future<void> _migrateToV13(Database db) async {
    AppLogger.database('Migrating database to v13');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        payment_method TEXT DEFAULT 'cash',
        receipt_image TEXT,
        created_by INTEGER,
        created_at INTEGER NOT NULL,
        date INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_created_by ON expenses(created_by)',
    );

    AppLogger.database('Database migration to v13 completed');
  }

  /// Migration from version 13 to 14
  static Future<void> _migrateToV14(Database db) async {
    AppLogger.database('Migrating database to v14');

    await db.execute('''
      CREATE TABLE cash_counts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shift_id INTEGER NOT NULL,
        denomination INTEGER NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        counted_at INTEGER NOT NULL,
        counted_by TEXT NOT NULL,
        FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_counts_shift ON cash_counts(shift_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cash_counts_denomination ON cash_counts(denomination)',
    );

    AppLogger.database('Database migration to v14 completed');
  }

  /// Migration from version 14 to 15
  static Future<void> _migrateToV15(Database db) async {
    AppLogger.database(
      'Migrating database to v15 (adding performance indexes)',
    );

    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_stock ON products(stock)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_has_variants ON products(has_variants)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_payment_method ON transactions(payment_method)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transaction_items_product ON transaction_items(product_id)',
      );
      AppLogger.database('Performance indexes created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create performance indexes',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseSchema',
      );
      AppLogger.database('Continuing without some indexes');
    }

    AppLogger.database('Database migration to v15 completed');
  }

  /// Migration from version 15 to 16
  static Future<void> _migrateToV16(Database db) async {
    AppLogger.database('Migrating database to v16 (adding audit_logs table)');

    try {
      await db.execute('''
        CREATE TABLE audit_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT,
          description TEXT,
          username TEXT,
          user_id TEXT,
          old_values TEXT,
          new_values TEXT,
          ip_address TEXT,
          user_agent TEXT,
          created_at INTEGER NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(username)',
      );

      AppLogger.database('Audit logs table created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create audit_logs table',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseSchema',
      );
      AppLogger.database('Continuing without audit logs');
    }

    AppLogger.database('Database migration to v16 completed');
  }

  /// Simple password hash for demo purposes
  /// In production, use proper cryptographic hashing with salt
  static String _hashPassword(String password) {
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
  }
}
