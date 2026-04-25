import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/constants/app_constants.dart';
import 'package:simple_pos/services/database/migrations/database_migration.dart';

/// Manages database connections with singleton pattern, connection pooling,
/// and retry logic with exponential backoff.
///
/// This class extracts the database connection logic from DatabaseHelper,
/// providing a clean separation of concerns and making testing easier.
class DatabaseConnection {
  // Singleton instance
  static final DatabaseConnection instance = DatabaseConnection._internal();

  // Private constructor to enforce singleton pattern
  DatabaseConnection._internal() {
    AppLogger.database('DatabaseConnection singleton created');
  }

  // Database instance cache
  Database? _database;
  bool _isInitialized = false;

  // Retry configuration
  static const int _maxRetries = 4;
  static const List<int> _retryDelays = [
    1000,
    2000,
    4000,
    8000,
  ]; // Exponential backoff

  // Queue for managing database operations during initialization
  final List<Completer<Database>> _pendingRequests = [];

  /// Gets the database instance, initializing if necessary.
  ///
  /// This method provides connection pooling by reusing the existing
  /// database connection. If the database is not yet initialized,
  /// it will be initialized automatically.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      AppLogger.database('Returning cached database connection');
      return _database!;
    }

    // If initialization is in progress, queue the request
    if (_isInitialized) {
      AppLogger.database(
        'Database initialization in progress, queueing request',
      );
      final completer = Completer<Database>();
      _pendingRequests.add(completer);
      return completer.future;
    }

    // Initialize database with retry logic
    return _initializeWithRetry(AppConstants.databaseName);
  }

  /// Initializes the database with the given path.
  ///
  /// This method creates a new database connection and sets up the schema.
  /// It includes retry logic with exponential backoff for handling
  /// transient failures.
  ///
  /// [filePath] - The name or path of the database file. Use ':memory:'
  /// for in-memory databases (useful for testing).
  Future<Database> initialize(String filePath) async {
    return _initializeWithRetry(filePath);
  }

  /// Initializes the database with retry logic and exponential backoff.
  Future<Database> _initializeWithRetry(String filePath) async {
    dynamic lastException;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        AppLogger.database(
          'Initializing database (attempt ${attempt + 1}/$_maxRetries)',
          details: filePath,
        );

        final db = await _initDB(filePath);

        // Successfully initialized
        _database = db;
        _isInitialized = false; // Reset initialization flag

        // Complete any pending requests
        for (final completer in _pendingRequests) {
          if (!completer.isCompleted) {
            completer.complete(db);
          }
        }
        _pendingRequests.clear();

        AppLogger.database('Database initialized successfully');
        return db;
      } on DatabaseException catch (e, stackTrace) {
        lastException = e;
        AppLogger.error(
          'Database initialization failed (attempt ${attempt + 1}/$_maxRetries)',
          error: e,
          stackTrace: stackTrace,
        );

        // If this is not the last attempt, wait before retrying
        if (attempt < _maxRetries - 1) {
          final delay = _retryDelays[attempt];
          AppLogger.database('Retrying after ${delay}ms delay');
          await Future.delayed(Duration(milliseconds: delay));
        }
      } catch (e, stackTrace) {
        // Preserve the original error
        lastException = e;
        AppLogger.error(
          'Unexpected error during database initialization',
          error: e,
          stackTrace: stackTrace,
        );

        // If this is not the last attempt, wait before retrying
        if (attempt < _maxRetries - 1) {
          final delay = _retryDelays[attempt];
          AppLogger.database('Retrying after ${delay}ms delay');
          await Future.delayed(Duration(milliseconds: delay));
        }
      }
    }

    // All retries exhausted
    AppLogger.error(
      'Database initialization failed after $_maxRetries attempts',
      error: lastException,
    );

    throw app_exceptions.DatabaseException(
      'Gagal inisialisasi database setelah $_maxRetries percobaan',
      operation: 'init',
      originalError: lastException,
    );
  }

  /// Internal method to initialize the database.
  Future<Database> _initDB(String filePath) async {
    try {
      String path;

      // Handle in-memory databases for testing
      if (filePath == ':memory:') {
        path = filePath;
        AppLogger.database('Opening in-memory database');
      } else {
        final dbPath = await getDatabasesPath();
        path = join(dbPath, filePath);
        AppLogger.database('Opening database at path: $path');
      }

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to open database file',
        error: e,
        stackTrace: stackTrace,
      );

      throw app_exceptions.DatabaseException(
        'Gagal membuka database',
        operation: 'init',
        originalError: e,
      );
    }
  }

  /// Create database schema for new installations.
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.database('Creating new database schema (version $version)');

    // Delegate schema creation to DatabaseHelper
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
      'CREATE TABLE transaction_items (id $idType, transaction_id $intType, product_id $intType, product_name $textType, quantity $intType, unit_price $realType, subtotal $realType, cost_price $realNullable DEFAULT 0, FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE, FOREIGN KEY (product_id) REFERENCES products(id))',
    );
    await db.execute(
      'CREATE TABLE shifts (id $idType, user_name $textType, opening_balance $realType DEFAULT 0, closing_balance $realType DEFAULT 0, cash_sales $realType DEFAULT 0, card_sales $realType DEFAULT 0, qr_sales $realType DEFAULT 0, transfer_sales $realType DEFAULT 0, total_transactions INTEGER DEFAULT 0, opened_at INTEGER NOT NULL, closed_at INTEGER)',
    );
    await db.execute(
      'CREATE TABLE users (id $idType, username TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL, full_name TEXT NOT NULL, role TEXT NOT NULL DEFAULT "cashier", is_active INTEGER DEFAULT 1, created_at INTEGER NOT NULL, last_login INTEGER)',
    );
    await db.execute(
      'CREATE TABLE user_sessions (id $idType, user_id INTEGER NOT NULL, login_time INTEGER NOT NULL, logout_time INTEGER, opening_cash REAL DEFAULT 0, closing_cash REAL, FOREIGN KEY (user_id) REFERENCES users(id))',
    );
    await db.execute(
      'CREATE TABLE expenses (id $idType, category TEXT NOT NULL, amount REAL NOT NULL, description TEXT, payment_method TEXT DEFAULT "cash", receipt_image TEXT, created_by INTEGER, created_at INTEGER NOT NULL, date INTEGER NOT NULL, FOREIGN KEY (created_by) REFERENCES users(id))',
    );
    await db.execute(
      'CREATE TABLE cash_counts (id $idType, shift_id INTEGER NOT NULL, denomination INTEGER NOT NULL, count INTEGER NOT NULL DEFAULT 0, counted_at INTEGER NOT NULL, counted_by TEXT NOT NULL, FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE audit_logs (id $idType, action TEXT NOT NULL, entity_type TEXT NOT NULL, entity_id TEXT, description TEXT, username TEXT, user_id TEXT, old_values TEXT, new_values TEXT, ip_address TEXT, user_agent TEXT, created_at INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE held_carts (id $idType, customer_name TEXT NOT NULL, cart_data TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE promotions (id $idType, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, start_date TEXT, end_date TEXT, is_enabled INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE discount_presets (id $idType, name TEXT NOT NULL, description TEXT NOT NULL, discount_percentage REAL NOT NULL, created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE variant_attributes (id $idType, product_id INTEGER NOT NULL, attribute_name TEXT NOT NULL, attribute_values TEXT NOT NULL, sort_order INTEGER DEFAULT 0, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE product_variants (id $idType, product_id INTEGER NOT NULL, name TEXT NOT NULL, sku TEXT, barcode TEXT, price REAL NOT NULL, cost_price REAL DEFAULT 0, stock INTEGER DEFAULT 0, attributes TEXT, is_active INTEGER DEFAULT 1, created_at TEXT NOT NULL, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)',
    );

    // Indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at)',
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

    AppLogger.database('Database schema created successfully');
  }

  /// Upgrade existing database to new version.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.database('Upgrading database from v$oldVersion to v$newVersion');

    final migration = DatabaseMigration();
    await migration.upgrade(db, oldVersion: oldVersion, newVersion: newVersion);

    AppLogger.database('Database upgrade completed');
  }

  /// Configure database settings.
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
    // Set WAL mode for better concurrency
    await db.rawQuery('PRAGMA journal_mode = WAL');
    AppLogger.database('Database configured with foreign keys and WAL mode');
  }

  /// Closes the database connection and cleans up resources.
  ///
  /// This method closes the database and clears any cached connections.
  /// It should be called when the application is shutting down or when
  /// testing to ensure clean state.
  Future<void> close() async {
    try {
      AppLogger.database('Closing database connection');

      // Close main database
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }

      // Complete any pending requests with error
      for (final completer in _pendingRequests) {
        if (!completer.isCompleted) {
          completer.completeError(
            app_exceptions.DatabaseException(
              'Database closed',
              operation: 'close',
            ),
          );
        }
      }
      _pendingRequests.clear();

      _isInitialized = false;

      AppLogger.database('Database connection closed successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error closing database connection',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - we want to clean up as much as possible
    }
  }

  /// Resets the database connection for testing purposes.
  ///
  /// This method is primarily used in tests to ensure a clean state
  /// between test runs.
  Future<void> reset() async {
    await close();
    AppLogger.database('Database connection reset');
  }

  /// Checks if the database is initialized and open.
  bool get isOpen => _database != null && _database!.isOpen;

  /// Simple password hashing (for demo purposes - use proper hashing in production).
  String _hashPassword(String password) {
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
  }
}
