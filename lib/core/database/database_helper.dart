import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/services/database/database_connection.dart';
// DAO Imports
import 'package:simple_pos/services/database/dao/product_dao.dart';
import 'package:simple_pos/services/database/dao/transaction_dao.dart';
import 'package:simple_pos/services/database/dao/payment_dao.dart';
import 'package:simple_pos/services/database/dao/category_dao.dart';
import 'package:simple_pos/services/database/dao/supplier_dao.dart';
import 'package:simple_pos/services/database/dao/shift_dao.dart';
import 'package:simple_pos/services/database/dao/expense_dao.dart';
import 'package:simple_pos/services/database/dao/user_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/product_variant_dao.dart';
import 'package:simple_pos/features/inventory/data/datasources/daos/variant_attribute_dao.dart';

import '../../services/database/migrations/database_migration.dart';

/// Main database helper class.
///
/// Responsibilities:
/// - Manage database connection lifecycle
/// - Provide access to database instance
/// - Coordinate initialization and migration (delegates to DatabaseMigration)
/// - Expose DAO instances for data operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // Delegate to DatabaseConnection for connection management
  final DatabaseConnection _connection = DatabaseConnection.instance;

  // Specialist DAOs
  final ProductDao products = ProductDao.instance;
  final TransactionDao transactions = TransactionDao.instance;
  final PaymentDao payments = PaymentDao.instance;
  final CategoryDao categories = CategoryDao.instance;
  final SupplierDao suppliers = SupplierDao.instance;
  final ShiftDao shifts = ShiftDao.instance;
  final ExpenseDao expenses = ExpenseDao.instance;
  final UserDao users = UserDao.instance;
  late final ProductVariantDao productVariants = ProductVariantDao(this);
  late final VariantAttributeDao variantAttributes = VariantAttributeDao(this);

  /// Gets the database instance with automatic setup and migrations.
  ///
  /// Handles:
  /// - Connection management via DatabaseConnection
  /// - Schema creation for new databases
  /// - Automatic migration for existing databases
  Future<Database> get database async {
    try {
      // Get database from connection manager
      final db = await _connection.database;

      // Handle setup (creation or migration)
      await _handleDatabaseSetup(db);

      return db;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal mendapatkan database',
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

  /// Handles database setup (creation or migration).
  ///
  /// Logic:
  /// - If database is new (version = 0): Create schema
  /// - If database is old: Run migrations
  /// - If database is newer: Log warning
  Future<void> _handleDatabaseSetup(Database db) async {
    try {
      // Get current database version
      final userVersion = await db.getVersion();

      if (userVersion == 0) {
        // New database - create schema at current version
        AppLogger.database(
          'Creating new database schema v${DatabaseMigration.currentVersion}',
        );
        await DatabaseMigration.createSchema(db);
        await db.setVersion(DatabaseMigration.currentVersion);
      } else if (userVersion < DatabaseMigration.currentVersion) {
        // Existing database - run migrations
        AppLogger.database(
          'Running migrations: v$userVersion -> v${DatabaseMigration.currentVersion}',
        );
        await DatabaseMigration.runMigrations(
          db,
          userVersion,
          DatabaseMigration.currentVersion,
        );
        await db.setVersion(DatabaseMigration.currentVersion);
      } else if (userVersion > DatabaseMigration.currentVersion) {
        AppLogger.warning(
          'Warn: Database version ($userVersion) is newer than app version (${DatabaseMigration.currentVersion})',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Database setup failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
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

  /// Clears all data from all tables (useful for testing/reset).
  /// WARNING: This deletes ALL data!
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
