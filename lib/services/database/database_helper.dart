/*import 'package:sqflite/sqflite.dart';
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
          has_variants $intType DEFAULT 0,
          FOREIGN KEY (category_id) REFERENCES categories(id),
          FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
        )
      ''');

      // Create indexes for products
      await db.execute('CREATE INDEX idx_products_name ON products(name)');
      await db.execute('CREATE INDEX idx_products_category ON products(category_id)');
      await db.execute('CREATE INDEX idx_products_supplier ON products(supplier_id)');
      await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)'); // For fast barcode lookups
      await db.execute('CREATE INDEX idx_products_stock ON products(stock)'); // For low stock queries
      await db.execute('CREATE INDEX idx_products_has_variants ON products(has_variants)'); // For variant filtering

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
      await db.execute('CREATE INDEX idx_transactions_created_at ON transactions(created_at)'); // For sales reports
      await db.execute('CREATE INDEX idx_transactions_payment_method ON transactions(payment_method)'); // For payment method reports
      await db.execute('CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id)');
      await db.execute('CREATE INDEX idx_transaction_items_product ON transaction_items(product_id)'); // For product sales history

      // Create indexes for promotions and discount_presets
      await db.execute('CREATE INDEX idx_promotions_enabled ON promotions(is_enabled)');
      await db.execute('CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date)');

      // Create shifts table for shift management
      await db.execute('''
        CREATE TABLE shifts (
          id $idType,
          user_name $textType,
          opening_balance $realType DEFAULT 0,
          closing_balance $realNullable DEFAULT 0,
          cash_sales $realType DEFAULT 0,
          card_sales $realType DEFAULT 0,
          qr_sales $realType DEFAULT 0,
          transfer_sales $realType DEFAULT 0,
          total_transactions $intType DEFAULT 0,
          opened_at $intType NOT NULL,
          closed_at $intNullable
        )
      ''');

      // Create indexes for shifts
      await db.execute('CREATE INDEX idx_shifts_opened_at ON shifts(opened_at DESC)');
      await db.execute('CREATE INDEX idx_shifts_closed_at ON shifts(closed_at)');

      // Create users table for user management and authentication
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

      // Create user_sessions table
      await db.execute('''
        CREATE TABLE user_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          login_time INTEGER NOT NULL,
          logout_time INTEGER,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for faster queries
      await db.execute('CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON user_sessions(user_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_user_sessions_login_time ON user_sessions(login_time DESC)');

      // Create expenses table for expense tracking
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

      // Create indexes for faster queries
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_created_by ON expenses(created_by)');

      // Create default admin user
      // Password: admin123 (hashed using simple hash for demo)
      final adminPasswordHash = _hashPassword('admin123');
      await db.insert('users', {
        'username': 'admin',
        'password_hash': adminPasswordHash,
        'full_name': 'Administrator',
        'role': 'admin',
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });

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

      if (oldVersion < 8) {
        // Migration from version 7 to 8
        await _migrateToV8(db);
      }

      if (oldVersion < 9) {
        // Migration from version 8 to 9 (ensures all tables exist)
        await _migrateToV9(db);
      }

      if (oldVersion < 10) {
        // Migration from version 9 to 10 (add cost_price to transaction_items)
        await _migrateToV10(db);
      }

      if (oldVersion < 11) {
        // Migration from version 10 to 11 (add shifts table)
        await _migrateToV11(db);
      }

      if (oldVersion < 12) {
        // Migration from version 11 to 12 (add users and user_sessions tables)
        await _migrateToV12(db);
      }

      if (oldVersion < 13) {
        // Migration from version 12 to 13 (add expenses table)
        await _migrateToV13(db);
      }

      if (oldVersion < 14) {
        // Migration from version 13 to 14 (add cash_counts table)
        await _migrateToV14(db);
      }

      if (oldVersion < 15) {
        // Migration from version 14 to 15 (add performance indexes)
        await _migrateToV15(db);
      }

      if (oldVersion < 16) {
        // Migration from version 15 to 16 (add audit_logs table)
        await _migrateToV16(db);
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

  /// Migration from version 7 to 8
  /// Ensures has_variants column and held_carts table exist (catch-up migration)
  Future _migrateToV8(Database db) async {
    AppLogger.database('Migrating database to v8');

    // Safely add has_variants column if it doesn't exist
    try {
      await db.execute('ALTER TABLE products ADD COLUMN has_variants INTEGER DEFAULT 0');
      AppLogger.database('Added has_variants column to products table');
    } catch (e) {
      // Column might already exist, which is fine
      AppLogger.database('has_variants column already exists or error: $e');
    }

    // Ensure held_carts table exists (from v6 migration)
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
      await db.execute('CREATE INDEX IF NOT EXISTS idx_held_carts_created ON held_carts(created_at DESC)');
      AppLogger.database('Ensured held_carts table exists');
    } catch (e) {
      AppLogger.database('held_carts table error: $e');
    }

    // Ensure variant tables exist (from v7 migration)
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

      // Create indexes if they don't exist
      await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON product_variants(barcode)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_variant_attributes_product_id ON variant_attributes(product_id)');

      AppLogger.database('Ensured variant tables exist');
    } catch (e) {
      AppLogger.database('Variant tables error: $e');
    }

    AppLogger.database('Database migration to v8 completed');
  }

  /// Migration from version 8 to 9
  /// Catch-up migration ensuring all tables from v6 and v7 exist
  Future _migrateToV9(Database db) async {
    AppLogger.database('Migrating database to v9');

    // Ensure held_carts table exists (from v6 migration)
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
      await db.execute('CREATE INDEX IF NOT EXISTS idx_held_carts_created ON held_carts(created_at DESC)');
      AppLogger.database('Ensured held_carts table exists');
    } catch (e) {
      AppLogger.database('held_carts table error: $e');
    }

    // Ensure variant tables exist (from v7 migration)
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

      // Create indexes if they don't exist
      await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_sku ON product_variants(sku)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_product_variants_barcode ON product_variants(barcode)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_variant_attributes_product_id ON variant_attributes(product_id)');

      AppLogger.database('Ensured variant tables exist');
    } catch (e) {
      AppLogger.database('Variant tables error: $e');
    }

    AppLogger.database('Database migration to v9 completed');
  }

  /// Migration from version 9 to 10
  /// Add cost_price column to transaction_items table for profit calculation
  Future _migrateToV10(Database db) async {
    AppLogger.database('Migrating database to v10');

    try {
      // Add cost_price column to transaction_items table
      await db.execute('''
        ALTER TABLE transaction_items ADD COLUMN cost_price REAL DEFAULT 0
      ''');
      AppLogger.database('Added cost_price column to transaction_items table');
    } catch (e) {
      // Column might already exist, log but don't fail
      AppLogger.database('cost_price column migration (may already exist): $e');
    }

    AppLogger.database('Database migration to v10 completed');
  }

  /// Migration from version 10 to 11
  /// Add shifts table for shift management
  Future _migrateToV11(Database db) async {
    AppLogger.database('Migrating database to v11');

    // Create shifts table
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

    // Create indexes for faster queries
    await db.execute('CREATE INDEX IF NOT EXISTS idx_shifts_opened_at ON shifts(opened_at DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_shifts_closed_at ON shifts(closed_at)');

    AppLogger.database('Database migration to v11 completed');
  }

  /// Migration from version 11 to 12
  /// Add users and user_sessions tables for user management and authentication
  Future _migrateToV12(Database db) async {
    AppLogger.database('Migrating database to v12');

    // Create users table
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

    // Create user_sessions table
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

    // Create indexes for faster queries
    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON user_sessions(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_sessions_login_time ON user_sessions(login_time DESC)');

    // Create default admin user
    // Password: admin123 (hashed using crypt - this is a simple hash for demo)
    // In production, use proper bcrypt with proper salt
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
  /// Add expenses table for expense tracking
  Future _migrateToV13(Database db) async {
    AppLogger.database('Migrating database to v13');

    // Create expenses table
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

    // Create indexes for faster queries
    await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_created_by ON expenses(created_by)');

    AppLogger.database('Database migration to v13 completed');
  }

  /// Migration from version 13 to 14
  /// Add cash_counts table for detailed bill denomination tracking
  Future _migrateToV14(Database db) async {
    AppLogger.database('Migrating database to v14');

    // Create cash_counts table
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

    // Create indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_cash_counts_shift ON cash_counts(shift_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_cash_counts_denomination ON cash_counts(denomination)');

    AppLogger.database('Database migration to v14 completed');
  }

  /// Migration from version 14 to 15
  /// Add performance indexes for frequently queried fields
  Future _migrateToV15(Database db) async {
    AppLogger.database('Migrating database to v15 (adding performance indexes)');

    try {
      // Add indexes for products table (if they don't exist)
      await db.execute('CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_products_stock ON products(stock)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_products_has_variants ON products(has_variants)');

      // Add indexes for transactions table (if they don't exist)
      await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_payment_method ON transactions(payment_method)');

      // Add indexes for transaction_items table (if they don't exist)
      await db.execute('CREATE INDEX IF NOT EXISTS idx_transaction_items_product ON transaction_items(product_id)');

      AppLogger.database('Performance indexes created successfully');
      AppLogger.database('Database migration to v15 completed');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create performance indexes',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      // Don't throw - indexes are nice to have but not critical
      AppLogger.database('Continuing without some indexes');
    }
  }

  /// Migration from version 15 to 16
  /// Add audit_logs table for tracking sensitive operations
  Future _migrateToV16(Database db) async {
    AppLogger.database('Migrating database to v16 (adding audit_logs table)');

    try {
      // Create audit_logs table
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

      // Create indexes for audit_logs
      await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(username)');

      AppLogger.database('Audit logs table created successfully');
      AppLogger.database('Database migration to v16 completed');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create audit_logs table',
        error: e,
        stackTrace: stackTrace,
        tag: 'DatabaseHelper',
      );
      // Don't throw - audit logs are important but not critical
      AppLogger.database('Continuing without audit logs');
    }
  }

  /// Simple password hash for demo purposes
  /// In production, use proper cryptographic hashing with salt
  String _hashPassword(String password) {
    // Simple hash - DO NOT use in production
    // This is just for demo to get the feature working
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(
        0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
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
*/
