import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';

/// Database migration orchestrator.
///
/// This class manages database schema migrations, providing:
/// - Version tracking
/// - Rollback support
/// - Data backup before migrations
/// - Step-by-step migration execution with error handling
///
/// Usage:
/// ```dart
/// final migration = DatabaseMigration();
/// await migration.upgrade(db, oldVersion: 1, newVersion: 2);
/// ```
class DatabaseMigration {
  /// Upgrades database from old version to new version.
  ///
  /// This method runs migrations sequentially for each version step
  /// between [oldVersion] and [newVersion].
  ///
  /// [db] - The database instance to upgrade
  /// [oldVersion] - Current database version
  /// [newVersion] - Target database version
  ///
  /// Throws [app_exceptions.DatabaseException] if migration fails
  Future<void> upgrade(
    Database db, {
    required int oldVersion,
    required int newVersion,
  }) async {
    try {
      AppLogger.database(
        'Starting database migration',
        details: 'From v$oldVersion to v$newVersion',
      );

      // Backup data before migration
      final backup = await _createBackup(db);

      try {
        // Run migrations for each version step
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

        AppLogger.database(
          'Database migration completed successfully',
          details: 'From v$oldVersion to v$newVersion',
        );
      } catch (e) {
        // Rollback if migration fails
        AppLogger.error('Migration failed, attempting rollback', error: e);
        await _restoreBackup(db, backup);
        rethrow;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Database migration failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw app_exceptions.DatabaseException(
        'Gagal melakukan migrasi database dari versi $oldVersion ke $newVersion',
        operation: 'database migration',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Creates a backup of all database tables.
  ///
  /// Returns a map of table names to their data.
  Future<Map<String, List<Map<String, dynamic>>>> _createBackup(
    Database db,
  ) async {
    AppLogger.database('Creating database backup');

    final backup = <String, List<Map<String, dynamic>>>{};
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    for (final table in tables) {
      final tableName = table['name'] as String;
      final data = await db.query(tableName);
      backup[tableName] = data;
    }

    AppLogger.database(
      'Backup created',
      details: 'Tables: ${backup.keys.length}',
    );
    return backup;
  }

  /// Restores database from backup.
  ///
  /// [db] - The database instance to restore to
  /// [backup] - The backup data to restore
  Future<void> _restoreBackup(
    Database db,
    Map<String, List<Map<String, dynamic>>> backup,
  ) async {
    AppLogger.database('Restoring database from backup');

    try {
      await db.transaction((txn) async {
        // Clear all tables
        final tables = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        );

        for (final table in tables) {
          final tableName = table['name'] as String;
          await txn.delete(tableName);
        }

        // Restore data
        for (final entry in backup.entries) {
          final tableName = entry.key;
          final data = entry.value;

          for (final row in data) {
            await txn.insert(tableName, row);
          }
        }
      });

      AppLogger.database('Database restored from backup');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to restore database from backup',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - we're already in an error state
    }
  }

  // ==================== MIGRATION STEPS ====================

  /// Migration to version 2: Add categories, suppliers, and product fields.
  Future<void> _migrateToV2(Database db) async {
    AppLogger.database('Migrating to version 2');

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

    AppLogger.database('Migration to version 2 completed');
  }

  /// Migration to version 3: Add image_path to products.
  Future<void> _migrateToV3(Database db) async {
    AppLogger.database('Migrating to version 3');
    await db.execute('ALTER TABLE products ADD COLUMN image_path TEXT');
    AppLogger.database('Migration to version 3 completed');
  }

  /// Migration to version 4: Add discount_percentage to products.
  Future<void> _migrateToV4(Database db) async {
    AppLogger.database('Migrating to version 4');
    await db.execute(
      'ALTER TABLE products ADD COLUMN discount_percentage REAL DEFAULT 0',
    );
    AppLogger.database('Migration to version 4 completed');
  }

  /// Migration to version 5: Add discounts, promotions, and presets.
  Future<void> _migrateToV5(Database db) async {
    AppLogger.database('Migrating to version 5');

    await db.execute(
      'ALTER TABLE categories ADD COLUMN discount_percentage REAL DEFAULT 0',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS promotions (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, start_date TEXT, end_date TEXT, is_enabled INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS discount_presets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, created_at TEXT NOT NULL)',
    );

    AppLogger.database('Migration to version 5 completed');
  }

  /// Migration to version 6: Add held_carts table.
  Future<void> _migrateToV6(Database db) async {
    AppLogger.database('Migrating to version 6');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS held_carts (id INTEGER PRIMARY KEY AUTOINCREMENT, customer_name TEXT NOT NULL, cart_data TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
    );
    AppLogger.database('Migration to version 6 completed');
  }

  /// Migration to version 7: Add product variants support.
  Future<void> _migrateToV7(Database db) async {
    AppLogger.database('Migrating to version 7');

    await db.execute(
      'ALTER TABLE products ADD COLUMN has_variants INTEGER DEFAULT 0',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS variant_attributes (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, attribute_name TEXT NOT NULL, attribute_values TEXT NOT NULL, sort_order INTEGER DEFAULT 0, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS product_variants (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, name TEXT NOT NULL, sku TEXT, barcode TEXT, price REAL NOT NULL, cost_price REAL DEFAULT 0, stock INTEGER DEFAULT 0, attributes TEXT, is_active INTEGER DEFAULT 1, created_at TEXT NOT NULL, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );

    AppLogger.database('Migration to version 7 completed');
  }

  /// Migration to version 8: Catch-up migration (no schema changes).
  Future<void> _migrateToV8(Database db) async {
    AppLogger.database('Migration to version 8 (catch-up)');
    // No schema changes
  }

  /// Migration to version 9: Catch-up migration (no schema changes).
  Future<void> _migrateToV9(Database db) async {
    AppLogger.database('Migration to version 9 (catch-up)');
    // No schema changes
  }

  /// Migration to version 10: Add cost_price to transaction_items.
  Future<void> _migrateToV10(Database db) async {
    AppLogger.database('Migrating to version 10');
    await db.execute(
      'ALTER TABLE transaction_items ADD COLUMN cost_price REAL DEFAULT 0',
    );
    AppLogger.database('Migration to version 10 completed');
  }

  /// Migration to version 11: Add shifts table with enhanced fields.
  Future<void> _migrateToV11(Database db) async {
    AppLogger.database('Migrating to version 11');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS shifts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name TEXT NOT NULL, opening_balance REAL DEFAULT 0, closing_balance REAL DEFAULT 0, cash_sales REAL DEFAULT 0, card_sales REAL DEFAULT 0, qr_sales REAL DEFAULT 0, transfer_sales REAL DEFAULT 0, total_transactions INTEGER DEFAULT 0, opened_at INTEGER NOT NULL, closed_at INTEGER)',
    );
    AppLogger.database('Migration to version 11 completed');
  }

  /// Migration to version 12: Add users and user_sessions tables.
  Future<void> _migrateToV12(Database db) async {
    AppLogger.database('Migrating to version 12');

    await db.execute(
      'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, role TEXT NOT NULL DEFAULT "cashier", is_active INTEGER DEFAULT 1, created_at INTEGER NOT NULL, last_login INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, login_time INTEGER NOT NULL, logout_time INTEGER, opening_cash REAL DEFAULT 0, closing_cash REAL, FOREIGN KEY (user_id) REFERENCES users(id))',
    );

    AppLogger.database('Migration to version 12 completed');
  }

  /// Migration to version 13: Add expenses table.
  Future<void> _migrateToV13(Database db) async {
    AppLogger.database('Migrating to version 13');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, amount REAL NOT NULL, description TEXT, payment_method TEXT DEFAULT "cash", receipt_image TEXT, created_by INTEGER, created_at INTEGER NOT NULL, date INTEGER NOT NULL, FOREIGN KEY (created_by) REFERENCES users(id))',
    );
    AppLogger.database('Migration to version 13 completed');
  }

  /// Migration to version 14: Add cash_counts table.
  Future<void> _migrateToV14(Database db) async {
    AppLogger.database('Migrating to version 14');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS cash_counts (id INTEGER PRIMARY KEY AUTOINCREMENT, shift_id INTEGER NOT NULL, denomination INTEGER NOT NULL, count INTEGER NOT NULL DEFAULT 0, counted_at INTEGER NOT NULL, counted_by TEXT NOT NULL, FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE)',
    );
    AppLogger.database('Migration to version 14 completed');
  }

  /// Migration to version 15: Add indexes for better query performance.
  Future<void> _migrateToV15(Database db) async {
    AppLogger.database('Migrating to version 15');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at)',
    );

    AppLogger.database('Migration to version 15 completed');
  }

  /// Migration to version 16: Add audit_logs table.
  Future<void> _migrateToV16(Database db) async {
    AppLogger.database('Migrating to version 16');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS audit_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, action TEXT NOT NULL, entity_type TEXT NOT NULL, entity_id TEXT, description TEXT, username TEXT, user_id TEXT, old_values TEXT, new_values TEXT, ip_address TEXT, user_agent TEXT, created_at INTEGER NOT NULL)',
    );
    AppLogger.database('Migration to version 16 completed');
  }

  Future<void> _migrateToV17(Database db) async {
    AppLogger.database('Migrating to version 17');
    try {
      await db.execute(
        'ALTER TABLE transaction_items ADD COLUMN variant_id INTEGER DEFAULT 0',
      );
      AppLogger.database('Added variant_id column to transaction_items');
    } catch (e) {
      AppLogger.database('variant_id column migration (may already exist): $e');
    }
    AppLogger.database('Migration to version 17 completed');
  }
}
