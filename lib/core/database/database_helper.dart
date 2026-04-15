import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/constants/app_constants.dart';

// DAO Imports
import 'package:simple_pos/features/inventory/data/datasources/daos/product_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/category_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/supplier_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/transaction_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/product_variant_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/variant_attribute_dao.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // Specialist sub-modules
  late final ProductDao products = ProductDao(this);
  late final CategoryDao categories = CategoryDao(this);
  late final SupplierDao suppliers = SupplierDao(this);
  late final TransactionDao transactions = TransactionDao(this);
  late final ProductVariantDao productVariants = ProductVariantDao(this);
  late final VariantAttributeDao variantAttributes = VariantAttributeDao(this);

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
      );
      throw app_exceptions.DatabaseException(
        'Gagal inisialisasi database',
        operation: 'init',
        originalError: e,
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

      // Tables
      await db.execute(
        'CREATE TABLE categories (id $idType, name $textType UNIQUE, description $textNullable, discount_percentage $realNullable DEFAULT 0, created_at $textType)',
      );
      await db.execute(
        'CREATE TABLE suppliers (id $idType, name $textType UNIQUE, contact_person $textNullable, phone $textNullable, email $textNullable, address $textNullable, created_at $textType)',
      );
      await db.execute(
        'CREATE TABLE products (id $idType, name $textType UNIQUE, price $realType, stock $intType, category_id $intNullable, supplier_id $intNullable, barcode $textNullable UNIQUE, cost_price $realNullable DEFAULT 0, image_path $textNullable, discount_percentage $realNullable DEFAULT 0, has_variants $intType DEFAULT 0, FOREIGN KEY (category_id) REFERENCES categories(id), FOREIGN KEY (supplier_id) REFERENCES suppliers(id))',
      );
      await db.execute(
        'CREATE TABLE transactions (id $idType, transaction_date $textType, subtotal $realType, tax $realType DEFAULT 0, discount $realType DEFAULT 0, total_amount $realType, payment_method $textType, payment_status $textType DEFAULT "completed", notes $textNullable, created_at $textType, updated_at $textType)',
      );
      await db.execute(
        'CREATE TABLE transaction_items (id $idType, transaction_id $intType, product_id $intType, product_name $textType, quantity $intType, unit_price $realType, subtotal $realType, FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE, FOREIGN KEY (product_id) REFERENCES products(id))',
      );
      await db.execute(
        'CREATE TABLE shifts (id $idType, user_name $textType, opening_balance $realType DEFAULT 0, opened_at $intType NOT NULL, closed_at $intNullable)',
      );
      await db.execute(
        'CREATE TABLE users (id $idType, username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, role TEXT NOT NULL DEFAULT "cashier", is_active INTEGER DEFAULT 1, created_at INTEGER NOT NULL)',
      );
      await db.execute(
        'CREATE TABLE expenses (id $idType, category TEXT NOT NULL, amount REAL NOT NULL, date INTEGER NOT NULL, created_by INTEGER, FOREIGN KEY (created_by) REFERENCES users(id))',
      );

      // Default Admin
      final adminPasswordHash = _hashPassword('admin123');
      await db.insert('users', {
        'username': 'admin',
        'password_hash': adminPasswordHash,
        'full_name': 'Administrator',
        'role': 'admin',
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });

      AppLogger.database('Schema created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Schema creation failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw app_exceptions.DatabaseException(
        'Gagal buat tabel',
        operation: 'onCreate',
        originalError: e,
      );
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
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
    } catch (e, stackTrace) {
      AppLogger.error('Upgrade failed', error: e, stackTrace: stackTrace);
    }
  }

  // --- MIGRATIONS ---
  Future _migrateToV2(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS suppliers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, contact_person TEXT, phone TEXT, email TEXT, address TEXT, created_at TEXT NOT NULL)',
    );
    await db.execute('ALTER TABLE products ADD COLUMN category_id INTEGER');
    await db.execute('ALTER TABLE products ADD COLUMN supplier_id INTEGER');
    await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT');
    await db.execute(
      'ALTER TABLE products ADD COLUMN cost_price REAL DEFAULT 0',
    );
  }

  Future _migrateToV3(Database db) async =>
      await db.execute('ALTER TABLE products ADD COLUMN image_path TEXT');
  Future _migrateToV4(Database db) async => await db.execute(
    'ALTER TABLE products ADD COLUMN discount_percentage REAL DEFAULT 0',
  );

  Future _migrateToV5(Database db) async {
    await db.execute(
      'ALTER TABLE categories ADD COLUMN discount_percentage REAL DEFAULT 0',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS promotions (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, start_date TEXT, end_date TEXT, is_enabled INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS discount_presets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, created_at TEXT NOT NULL)',
    );
  }

  Future _migrateToV6(Database db) async => await db.execute(
    'CREATE TABLE IF NOT EXISTS held_carts (id INTEGER PRIMARY KEY AUTOINCREMENT, customer_name TEXT NOT NULL, cart_data TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
  );

  Future _migrateToV7(Database db) async {
    await db.execute(
      'ALTER TABLE products ADD COLUMN has_variants INTEGER DEFAULT 0',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS variant_attributes (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, attribute_name TEXT NOT NULL, attribute_values TEXT NOT NULL, sort_order INTEGER DEFAULT 0, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS product_variants (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, name TEXT NOT NULL, sku TEXT, barcode TEXT, price REAL NOT NULL, cost_price REAL DEFAULT 0, stock INTEGER DEFAULT 0, attributes TEXT, is_active INTEGER DEFAULT 1, created_at TEXT NOT NULL, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );
  }

  Future _migrateToV8(Database db) async =>
      AppLogger.database('V8 catch-up done');
  Future _migrateToV9(Database db) async =>
      AppLogger.database('V9 catch-up done');
  Future _migrateToV10(Database db) async => await db.execute(
    'ALTER TABLE transaction_items ADD COLUMN cost_price REAL DEFAULT 0',
  );

  Future _migrateToV11(Database db) async => await db.execute(
    'CREATE TABLE IF NOT EXISTS shifts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name TEXT NOT NULL, opening_balance REAL DEFAULT 0, closing_balance REAL DEFAULT 0, cash_sales REAL DEFAULT 0, card_sales REAL DEFAULT 0, qr_sales REAL DEFAULT 0, transfer_sales REAL DEFAULT 0, total_transactions INTEGER DEFAULT 0, opened_at INTEGER NOT NULL, closed_at INTEGER)',
  );

  Future _migrateToV12(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, role TEXT NOT NULL DEFAULT "cashier", is_active INTEGER DEFAULT 1, created_at INTEGER NOT NULL, last_login INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, login_time INTEGER NOT NULL, logout_time INTEGER, opening_cash REAL DEFAULT 0, closing_cash REAL, FOREIGN KEY (user_id) REFERENCES users(id))',
    );
  }

  Future _migrateToV13(Database db) async => await db.execute(
    'CREATE TABLE IF NOT EXISTS expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, amount REAL NOT NULL, description TEXT, payment_method TEXT DEFAULT "cash", receipt_image TEXT, created_by INTEGER, created_at INTEGER NOT NULL, date INTEGER NOT NULL, FOREIGN KEY (created_by) REFERENCES users(id))',
  );

  Future _migrateToV14(Database db) async => await db.execute(
    'CREATE TABLE IF NOT EXISTS cash_counts (id INTEGER PRIMARY KEY AUTOINCREMENT, shift_id INTEGER NOT NULL, denomination INTEGER NOT NULL, count INTEGER NOT NULL DEFAULT 0, counted_at INTEGER NOT NULL, counted_by TEXT NOT NULL, FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE)',
  );

  Future _migrateToV15(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at)',
    );
  }

  Future _migrateToV16(Database db) async => await db.execute(
    'CREATE TABLE IF NOT EXISTS audit_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, action TEXT NOT NULL, entity_type TEXT NOT NULL, entity_id TEXT, description TEXT, username TEXT, user_id TEXT, old_values TEXT, new_values TEXT, ip_address TEXT, user_agent TEXT, created_at INTEGER NOT NULL)',
  );

  // Utilities
  String _hashPassword(String password) {
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    for (var table in tables) {
      await db.delete(table['name'] as String);
    }
  }

  Future<void> close() async {
    final db = _database; // Fix: No 'await' on non-future Database
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
