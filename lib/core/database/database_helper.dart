import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/constants/app_constants.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/services/database/migrations/database_migration.dart';

// DAO Imports
import 'package:simple_pos/services/database/dao/product_dao.dart';
import 'package:simple_pos/services/database/dao/transaction_dao.dart';
import 'package:simple_pos/services/database/dao/category_dao.dart';
import 'package:simple_pos/services/database/dao/supplier_dao.dart';
import 'package:simple_pos/services/database/dao/shift_dao.dart';
import 'package:simple_pos/services/database/dao/expense_dao.dart';
import 'package:simple_pos/services/database/dao/user_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/product_variant_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/variant_attribute_dao.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // Delegate to DatabaseConnection for connection management
  final DatabaseConnection _connection = DatabaseConnection.instance;

  // Specialist sub-modules
  final ProductDao products = ProductDao.instance;
  final TransactionDao transactions = TransactionDao.instance;
  final CategoryDao categories = CategoryDao.instance;
  final SupplierDao suppliers = SupplierDao.instance;
  final ShiftDao shifts = ShiftDao.instance;
  final ExpenseDao expenses = ExpenseDao.instance;
  final UserDao users = UserDao.instance;
  late final ProductVariantDao productVariants = ProductVariantDao(this);
  late final VariantAttributeDao variantAttributes = VariantAttributeDao(this);

  /// Gets the database instance.
  ///
  /// This method now delegates to DatabaseConnection for connection management,
  /// providing retry logic and better error handling.
  Future<Database> get database async {
    try {
      // Get database from connection manager
      final db = await _connection.database;

      // Check if schema exists, create if not (for new databases)
      if (!await _isSchemaCreated(db)) {
        await _createDB(db, AppConstants.databaseVersion);
      }

      return db;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get database',
        error: e,
        stackTrace: stackTrace,
      );
      throw app_exceptions.DatabaseException(
        'Gagal mendapatkan database',
        operation: 'getDatabase',
        originalError: e,
      );
    }
  }

  /// Upgrade database to new version.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final migration = DatabaseMigration();
    await migration.upgrade(db, oldVersion: oldVersion, newVersion: newVersion);
  }

  /// Check if database schema has been created.
  Future<bool> _isSchemaCreated(Database db) async {
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      return tables.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Initialize database with specific path (for testing or custom paths).
  ///
  /// @deprecated Use DatabaseConnection.initialize() directly for new code.
  Future<Database> initialize(String filePath) async {
    return _connection.initialize(filePath);
  }

  /// Close the database connection.
  ///
  /// @deprecated Use DatabaseConnection.close() directly for new code.
  Future<void> close() async {
    return _connection.close();
  }

  /// Reset the database connection (useful for testing).
  ///
  /// @deprecated Use DatabaseConnection.reset() directly for new code.
  Future<void> reset() async {
    return _connection.reset();
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
}
