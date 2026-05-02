import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Handles all database schema migrations.
///
/// Responsible for:
/// - Managing database versions
/// - Running incremental migrations
/// - Creating backups before migrations
/// - Adding columns safely
class DatabaseMigration {
  static const int currentVersion = 20;

  /// Runs migrations from oldVersion to newVersion
  static Future<void> runMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      if (oldVersion == newVersion) {
        AppLogger.database('Database version $oldVersion is up to date');
        return;
      }

      AppLogger.database('Running migrations: v$oldVersion -> v$newVersion');

      // Create backup before migration
      await _createBackup(db);

      // Run migrations step by step
      if (oldVersion < 2) await _migrateToV2(db);
      if (oldVersion < 3) await _migrateToV3(db);
      if (oldVersion < 4) await _migrateToV4(db);
      if (oldVersion < 5) await _migrateToV5(db);
      if (oldVersion < 6) await _migrateToV6(db);
      if (oldVersion < 7) await _migrateToV7(db);
      if (oldVersion < 8) await _migrateToV8(db);
      if (oldVersion < 9) await _migrateToV9(db);
      if (oldVersion < 10) await _migrateToV10(db);
      if (oldVersion < 11) await _migrateToV11(db);
      if (oldVersion < 12) await _migrateToV12(db);
      if (oldVersion < 13) await _migrateToV13(db);
      if (oldVersion < 14) await _migrateToV14(db);
      if (oldVersion < 15) await _migrateToV15(db);
      if (oldVersion < 16) await _migrateToV16(db);
      if (oldVersion < 17) await _migrateToV17(db);
      if (oldVersion < 18) await _migrateToV18(db);
      if (oldVersion < 19) await _migrateToV19(db);
      if (oldVersion < 20) await _migrateToV20(db);

      AppLogger.database('Migrations completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Migration failed', error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal melakukan migrasi database',
        operation: 'migration',
        originalError: e,
      );
    }
  }

  /// Creates initial database schema for new databases
  static Future<void> createSchema(Database db) async {
    try {
      AppLogger.database('Creating database schema v$currentVersion');

      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const realType = 'REAL NOT NULL';
      const intType = 'INTEGER NOT NULL';
      const textNullable = 'TEXT';
      const intNullable = 'INTEGER';
      const realNullable = 'REAL';

      // Categories
      await db.execute(
        'CREATE TABLE categories (id $idType, name $textType UNIQUE, description $textNullable, discount_percentage $realNullable DEFAULT 0, created_at $textType)',
      );

      // Suppliers
      await db.execute(
        'CREATE TABLE suppliers (id $idType, name $textType UNIQUE, contact_person $textNullable, phone $textNullable, email $textNullable, address $textNullable, created_at $textType)',
      );

      // Products (dengan unit_of_measurement dari awal)
      await db.execute(
        'CREATE TABLE products (id $idType, name $textType UNIQUE, price $realType, stock $intType, category_id $intNullable, supplier_id $intNullable, barcode $textNullable UNIQUE, cost_price $realNullable DEFAULT 0, image_path $textNullable, discount_percentage $realNullable DEFAULT 0, has_variants $intType DEFAULT 0, unit_of_measurement $textNullable DEFAULT "pcs", FOREIGN KEY (category_id) REFERENCES categories(id), FOREIGN KEY (supplier_id) REFERENCES suppliers(id))',
      );

      // Transactions
      await db.execute(
        'CREATE TABLE transactions (id $idType, transaction_date $textType, subtotal $realType, tax $realType DEFAULT 0, discount $realType DEFAULT 0, total_amount $realType, payment_method $textType, payment_status $textType DEFAULT "completed", notes $textNullable, created_at $textType, updated_at $textType)',
      );

      // Transaction Items
      await db.execute(
        'CREATE TABLE transaction_items (id $idType, transaction_id $intType, product_id $intType, variant_id $intNullable, product_name $textType, quantity $intType, unit_price $realType, subtotal $realType, cost_price $realNullable DEFAULT 0, FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE, FOREIGN KEY (product_id) REFERENCES products(id))',
      );

      // Payments
      await db.execute(
        'CREATE TABLE IF NOT EXISTS payments (id $idType, transaction_id $intType, payment_method $textType, amount $realType, cash_received $realNullable, card_last_4_digits $textNullable, payment_date $textType, FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE)',
      );

      // Shifts
      await db.execute(
        'CREATE TABLE shifts (id $idType, user_name $textType, opening_balance $realType DEFAULT 0, closing_balance $realType DEFAULT 0, cash_sales $realType DEFAULT 0, card_sales $realType DEFAULT 0, qr_sales $realType DEFAULT 0, transfer_sales $realType DEFAULT 0, total_transactions $intType DEFAULT 0, opened_at $intType NOT NULL, closed_at $intNullable)',
      );

      // Users
      await db.execute(
        'CREATE TABLE users (id $idType, username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, role TEXT NOT NULL DEFAULT "cashier", is_active INTEGER DEFAULT 1, created_at INTEGER NOT NULL, last_login INTEGER)',
      );

      // Expenses
      await db.execute(
        'CREATE TABLE expenses (id $idType, category TEXT NOT NULL, amount REAL NOT NULL, description TEXT, payment_method TEXT DEFAULT "cash", receipt_image TEXT, created_by INTEGER, created_at INTEGER NOT NULL, date INTEGER NOT NULL, FOREIGN KEY (created_by) REFERENCES users(id))',
      );

      // Promotions
      await db.execute(
        'CREATE TABLE IF NOT EXISTS promotions (id $idType, name $textType, description $textType, discount_percentage $realType NOT NULL, start_date $textNullable, end_date $textNullable, is_enabled $intType NOT NULL DEFAULT 1, created_at $textType)',
      );

      // Discount Presets
      await db.execute(
        'CREATE TABLE IF NOT EXISTS discount_presets (id $idType, name $textType, description $textType, discount_percentage $realType NOT NULL, created_at $textType)',
      );

      // Held Carts
      await db.execute(
        'CREATE TABLE IF NOT EXISTS held_carts (id $idType, customer_name $textType, cart_data $textType, created_at $textType, updated_at $textType)',
      );

      // Variant Attributes
      await db.execute(
        'CREATE TABLE IF NOT EXISTS variant_attributes (id $idType, product_id $intType NOT NULL, attribute_name $textType, attribute_values $textType, sort_order $intType DEFAULT 0, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
      );

      // Product Variants
      await db.execute(
        'CREATE TABLE IF NOT EXISTS product_variants (id $idType, product_id $intType NOT NULL, name $textType, sku $textNullable, barcode $textNullable, price $realType NOT NULL, cost_price $realNullable DEFAULT 0, stock $intType DEFAULT 0, attributes $textNullable, is_active $intType DEFAULT 1, created_at $textType, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
      );

      // Cash Counts
      await db.execute(
        'CREATE TABLE IF NOT EXISTS cash_counts (id $idType, shift_id $intType NOT NULL, denomination $intType NOT NULL, count $intType NOT NULL DEFAULT 0, counted_at $intType NOT NULL, counted_by $textType, FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE)',
      );

      // Audit Logs
      await db.execute(
        'CREATE TABLE IF NOT EXISTS audit_logs (id $idType, action $textType, entity_type $textType, entity_id $textNullable, description $textNullable, username $textNullable, user_id $textNullable, old_values $textNullable, new_values $textNullable, ip_address $textNullable, user_agent $textNullable, created_at $intType NOT NULL)',
      );

      // Stock Adjustments
      await db.execute(
        'CREATE TABLE IF NOT EXISTS stock_adjustments (id $idType, product_id $intType NOT NULL, previous_quantity $intType NOT NULL, new_quantity $intType NOT NULL, adjustment_type $textType NOT NULL, reason $textNullable, created_by $textNullable, created_at $textType NOT NULL, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
      );

      // Create indexes
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at)',
      );

      // Default Admin User
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
        'Schema creation failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw app_exceptions.DatabaseException(
        'Gagal membuat schema database',
        operation: 'createSchema',
        originalError: e,
      );
    }
  }

  // ==================== MIGRATION STEPS ====================

  static Future<void> _migrateToV2(Database db) async {
    AppLogger.database('Migrasi ke v2: Add categories, suppliers');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS suppliers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, contact_person TEXT, phone TEXT, email TEXT, address TEXT, created_at TEXT NOT NULL)',
    );
    await _addColumnIfNotExists(db, 'products', 'category_id', 'INTEGER');
    await _addColumnIfNotExists(db, 'products', 'supplier_id', 'INTEGER');
    await _addColumnIfNotExists(db, 'products', 'barcode', 'TEXT');
    await _addColumnIfNotExists(db, 'products', 'cost_price', 'REAL DEFAULT 0');
  }

  static Future<void> _migrateToV3(Database db) async {
    AppLogger.database('Migrasi ke v3: Add image_path');
    await _addColumnIfNotExists(db, 'products', 'image_path', 'TEXT');
  }

  static Future<void> _migrateToV4(Database db) async {
    AppLogger.database('Migrasi ke v4: Add discount_percentage');
    await _addColumnIfNotExists(
      db,
      'products',
      'discount_percentage',
      'REAL DEFAULT 0',
    );
  }

  static Future<void> _migrateToV5(Database db) async {
    AppLogger.database('Migrasi ke v5: Add promotions and presets');
    await _addColumnIfNotExists(
      db,
      'categories',
      'discount_percentage',
      'REAL DEFAULT 0',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS promotions (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, start_date TEXT, end_date TEXT, is_enabled INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS discount_presets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, created_at TEXT NOT NULL)',
    );
  }

  static Future<void> _migrateToV6(Database db) async {
    AppLogger.database('Migrasi ke v6: Add held_carts table');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS held_carts (id INTEGER PRIMARY KEY AUTOINCREMENT, customer_name TEXT NOT NULL, cart_data TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
    );
  }

  static Future<void> _migrateToV7(Database db) async {
    AppLogger.database('Migrasi ke v7: Add product variants support');
    await _addColumnIfNotExists(
      db,
      'products',
      'has_variants',
      'INTEGER DEFAULT 0',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS variant_attributes (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, attribute_name TEXT NOT NULL, attribute_values TEXT NOT NULL, sort_order INTEGER DEFAULT 0, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS product_variants (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, name TEXT NOT NULL, sku TEXT, barcode TEXT, price REAL NOT NULL, cost_price REAL DEFAULT 0, stock INTEGER DEFAULT 0, attributes TEXT, is_active INTEGER DEFAULT 1, created_at TEXT NOT NULL, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );
  }

  static Future<void> _migrateToV8(Database db) async {
    AppLogger.database('Migrasi ke v8: Catch-up (no schema changes)');
  }

  static Future<void> _migrateToV9(Database db) async {
    AppLogger.database('Migrasi ke v9: Catch-up (no schema changes)');
  }

  static Future<void> _migrateToV10(Database db) async {
    AppLogger.database('Migrasi ke v10: Add cost_price to transaction_items');
    await _addColumnIfNotExists(
      db,
      'transaction_items',
      'cost_price',
      'REAL DEFAULT 0',
    );
  }

  static Future<void> _migrateToV11(Database db) async {
    AppLogger.database('Migrasi ke v11: Enhanced shifts table');
    try {
      await db.execute('DROP TABLE IF EXISTS shifts_old');
      final shiftsList = await db.query('shifts');
      if (shiftsList.isNotEmpty) {
        await db.execute('ALTER TABLE shifts RENAME TO shifts_old');
      }
    } catch (e) {
      AppLogger.warning('Shifts migration warning: $e');
    }

    await db.execute(
      'CREATE TABLE IF NOT EXISTS shifts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name TEXT NOT NULL, opening_balance REAL DEFAULT 0, closing_balance REAL DEFAULT 0, cash_sales REAL DEFAULT 0, card_sales REAL DEFAULT 0, qr_sales REAL DEFAULT 0, transfer_sales REAL DEFAULT 0, total_transactions INTEGER DEFAULT 0, opened_at INTEGER NOT NULL, closed_at INTEGER)',
    );
  }

  static Future<void> _migrateToV12(Database db) async {
    AppLogger.database('Migrasi ke v12: Add users table');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, role TEXT NOT NULL DEFAULT "cashier", is_active INTEGER DEFAULT 1, created_at INTEGER NOT NULL, last_login INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, login_time INTEGER NOT NULL, logout_time INTEGER, opening_cash REAL DEFAULT 0, closing_cash REAL, FOREIGN KEY (user_id) REFERENCES users(id))',
    );
  }

  static Future<void> _migrateToV13(Database db) async {
    AppLogger.database('Migrasi ke v13: Add expenses table');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, amount REAL NOT NULL, description TEXT, payment_method TEXT DEFAULT "cash", receipt_image TEXT, created_by INTEGER, created_at INTEGER NOT NULL, date INTEGER NOT NULL, FOREIGN KEY (created_by) REFERENCES users(id))',
    );
  }

  static Future<void> _migrateToV14(Database db) async {
    AppLogger.database('Migrasi ke v14: Add cash_counts table');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS cash_counts (id INTEGER PRIMARY KEY AUTOINCREMENT, shift_id INTEGER NOT NULL, denomination INTEGER NOT NULL, count INTEGER NOT NULL DEFAULT 0, counted_at INTEGER NOT NULL, counted_by TEXT NOT NULL, FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE)',
    );
  }

  static Future<void> _migrateToV15(Database db) async {
    AppLogger.database('Migrasi ke v15: Add indexes');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at)',
    );
  }

  static Future<void> _migrateToV16(Database db) async {
    AppLogger.database('Migrasi ke v16: Add audit_logs table');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS audit_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, action TEXT NOT NULL, entity_type TEXT NOT NULL, entity_id TEXT, description TEXT, username TEXT, user_id TEXT, old_values TEXT, new_values TEXT, ip_address TEXT, user_agent TEXT, created_at INTEGER NOT NULL)',
    );
  }

  static Future<void> _migrateToV17(Database db) async {
    AppLogger.database('Migrasi ke v17: Add variant_id to transaction_items');
    await _addColumnIfNotExists(
      db,
      'transaction_items',
      'variant_id',
      'INTEGER DEFAULT 0',
    );
  }

  /// CRITICAL: Migration to v18 - Add unit_of_measurement column
  /// This fixes the "no such column: unit_of_measurement" error
  static Future<void> _migrateToV18(Database db) async {
    AppLogger.database('Migrasi ke v18: Add unit_of_measurement to products');
    await _addColumnIfNotExists(
      db,
      'products',
      'unit_of_measurement',
      "TEXT DEFAULT 'pcs'",
    );
    AppLogger.database('unit_of_measurement column added successfully');
  }

  /// Migration to v19 - Add stock_adjustments table
  /// This creates the table for tracking stock adjustments
  static Future<void> _migrateToV19(Database db) async {
    AppLogger.database('Migrasi ke v19: Add stock_adjustments table');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS stock_adjustments (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, previous_quantity INTEGER NOT NULL, new_quantity INTEGER NOT NULL, adjustment_type TEXT NOT NULL, reason TEXT, created_by TEXT, created_at TEXT NOT NULL, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );
    AppLogger.database('stock_adjustments table created successfully');
  }

  /// Migration to v20 - Ensure payments table exists
  /// The payments table was missing in createSchema
  static Future<void> _migrateToV20(Database db) async {
    AppLogger.database('Migrasi ke v20: Ensure payments table exists');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
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
    AppLogger.database('payments table ensured successfully');
  }

  // ==================== HELPERS ====================

  /// Helper method to add column if it doesn't exist
  static Future<void> _addColumnIfNotExists(
    Database db,
    String tableName,
    String columnName,
    String columnType,
  ) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info($tableName)');
      final columnExists = columns.any((col) => col['name'] == columnName);

      if (!columnExists) {
        await db.execute(
          'ALTER TABLE $tableName ADD COLUMN $columnName $columnType',
        );
        AppLogger.database('Added column $columnName to $tableName');
      }
    } catch (e) {
      AppLogger.warning(
        'Column addition warning: $columnName to $tableName: $e',
      );
    }
  }

  /// Creates a backup of all database tables
  static Future<Map<String, List<Map<String, dynamic>>>> _createBackup(
    Database db,
  ) async {
    try {
      AppLogger.database('Creating database backup before migration');
      final backup = <String, List<Map<String, dynamic>>>{};
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      for (final table in tables) {
        final tableName = table['name'] as String;
        final data = await db.query(tableName);
        backup[tableName] = data;
      }

      AppLogger.database('Backup created: ${backup.keys.length} tables');
      return backup;
    } catch (e) {
      AppLogger.warning('Backup creation failed: $e');
      return {};
    }
  }

  static String _hashPassword(String password) {
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
  }
}
