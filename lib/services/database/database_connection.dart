import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/constants/app_constants.dart';

import 'migrations/database_migration.dart';

/// Manages database connections with singleton pattern, connection pooling,
/// and retry logic with exponential backoff.
///
/// This class extracts the database connection logic from DatabaseHelper,
/// providing a clean separation of concerns and making testing easier.
///
/// Responsibilities:
/// - Manage database connection lifecycle
/// - Implement retry logic with exponential backoff
/// - Queue pending requests during initialization
/// - Configure database settings (foreign keys, WAL mode)
/// - Delegate schema creation and migrations to DatabaseMigration
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
        version: DatabaseMigration.currentVersion,
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

  /// Creates database schema for new installations.
  ///
  /// Delegates to DatabaseMigration.createSchema() for consistency
  /// with the migration system.
  Future<void> _onCreate(Database db, int version) async {
    try {
      AppLogger.database('Creating new database schema (version $version)');
      await DatabaseMigration.createSchema(db);
      AppLogger.database('Database schema created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Schema creation failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Upgrades existing database to new version.
  ///
  /// Delegates to DatabaseMigration.runMigrations() to handle
  /// all schema changes incrementally.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      AppLogger.database(
        'Upgrading database from v$oldVersion to v$newVersion',
      );
      await DatabaseMigration.runMigrations(db, oldVersion, newVersion);
      AppLogger.database('Database upgrade completed');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Database upgrade failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Configures database settings.
  ///
  /// Enables:
  /// - Foreign key constraints
  /// - WAL (Write-Ahead Logging) mode for better concurrency
  Future<void> _onConfigure(Database db) async {
    try {
      // Enable foreign keys
      await db.execute('PRAGMA foreign_keys = ON');

      // Set WAL mode for better concurrency
      await db.rawQuery('PRAGMA journal_mode = WAL');

      AppLogger.database('Database configured with foreign keys and WAL mode');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Database configuration failed - ignoring non-critical error',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - configuration is not critical
    }
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
}
