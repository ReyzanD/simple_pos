import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_config.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_data.dart';
import 'package:simple_pos/services/database/database_helper.dart';
import 'package:simple_pos/core/constants/app_constants.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';

/// Service for collecting backup data from various sources
/// Handles database export, file collection, and preferences export
class BackupDataCollector {
  final DatabaseHelper _databaseHelper;

  BackupDataCollector({
    required DatabaseHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  /// Collect all backup data based on configuration
  /// Returns BackupData with collected files and preferences
  Future<BackupData> collectBackupData(
    BackupConfig config, {
    DateTime? since,
  }) async {
    try {
      AppLogger.info(
        'Starting backup data collection',
        tag: 'BackupDataCollector',
      );

      File? databaseFile;
      final List<File> imageFiles = [];
      Map<String, dynamic>? preferences;
      Map<String, dynamic>? settings;
      Map<String, List<Map<String, dynamic>>>? databaseChanges;

      // Collect database
      if (config.includesDatabase) {
        if (config.type == BackupType.incremental && since != null) {
          // Collect incremental changes
          AppLogger.info(
            'Collecting incremental database changes since $since',
            tag: 'BackupDataCollector',
          );
          databaseChanges = await _collectDatabaseChanges(since);
        } else {
          // Collect full database
          AppLogger.info(
            'Collecting full database',
            tag: 'BackupDataCollector',
          );
          databaseFile = await _collectDatabase();
        }
      }

      // Collect images
      if (config.includesImages) {
        AppLogger.info(
          'Collecting product images',
          tag: 'BackupDataCollector',
        );
        imageFiles.addAll(await _collectImages(since));
      }

      // Collect preferences
      if (config.dataTypes.contains(BackupDataType.all) ||
          config.dataTypes.contains(BackupDataType.database)) {
        AppLogger.info(
          'Collecting app preferences',
          tag: 'BackupDataCollector',
        );
        preferences = await _collectPreferences();
      }

      // Collect settings
      if (config.dataTypes.contains(BackupDataType.all) ||
          config.dataTypes.contains(BackupDataType.database)) {
        AppLogger.info(
          'Collecting app settings',
          tag: 'BackupDataCollector',
        );
        settings = await _collectSettings();
      }

      final data = BackupData(
        databaseFile: databaseFile,
        imageFiles: imageFiles,
        preferences: preferences,
        settings: settings,
        databaseChanges: databaseChanges,
        baseBackupId: since != null ? _generateBaseBackupId(since) : null,
      );

      final totalSize = await data.getTotalSize();
      AppLogger.info(
        'Backup data collection completed: ${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB',
        tag: 'BackupDataCollector',
      );

      return data;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to collect backup data',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupDataCollector',
      );
      throw DatabaseException(
        'Gagal mengumpulkan data backup',
        operation: 'collect backup data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Collect database file
  Future<File> _collectDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, AppConstants.databaseName));

      if (!await dbFile.exists()) {
        throw DatabaseException(
          'File database tidak ditemukan',
          operation: 'collect database',
        );
      }

      AppLogger.database(
        'Database file collected',
        details: 'Size: ${await dbFile.length()} bytes',
      );

      return dbFile;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to collect database file',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupDataCollector',
      );
      throw DatabaseException(
        'Gagal mengambil file database',
        operation: 'collect database',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Collect incremental database changes
  Future<Map<String, List<Map<String, dynamic>>>> _collectDatabaseChanges(
    DateTime since,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final changes = <String, List<Map<String, dynamic>>>{};

      final tables = [
        'categories',
        'suppliers',
        'products',
        'transactions',
        'transaction_items',
        'payments',
      ];

      final sinceString = since.toIso8601String();

      for (final table in tables) {
        try {
          // Check if table has updated_at column
          final columns = await db.rawQuery('PRAGMA table_info($table)');
          final hasUpdatedAt = columns.any((col) => col['name'] == 'updated_at');

          List<Map<String, dynamic>> rows;

          if (hasUpdatedAt) {
            rows = await db.query(
              table,
              where: 'updated_at > ?',
              whereArgs: [sinceString],
            );
          } else {
            // Fallback to created_at if no updated_at
            final hasCreatedAt = columns.any((col) => col['name'] == 'created_at');
            if (hasCreatedAt) {
              rows = await db.query(
                table,
                where: 'created_at > ?',
                whereArgs: [sinceString],
              );
            } else {
              // No timestamp columns, get all rows
              rows = await db.query(table);
            }
          }

          if (rows.isNotEmpty) {
            changes[table] = rows;
            AppLogger.database(
              'Collected changes for $table',
              details: '${rows.length} rows modified',
            );
          }
        } catch (e, stackTrace) {
          AppLogger.error(
            'Failed to collect changes for table $table',
            error: e,
            stackTrace: stackTrace,
            tag: 'BackupDataCollector',
          );
          // Continue with other tables
        }
      }

      return changes;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to collect database changes',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupDataCollector',
      );
      throw DatabaseException(
        'Gagal mengumpulkan perubahan database',
        operation: 'collect database changes',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Collect product images from app directory
  Future<List<File>> _collectImages(DateTime? since) async {
    try {
      final List<File> images = [];

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'images', 'products'));

      if (!await imagesDir.exists()) {
        AppLogger.info(
          'Product images directory does not exist',
          tag: 'BackupDataCollector',
        );
        return images;
      }

      // List all image files
      final files = imagesDir.listSync(recursive: true);

      for (final file in files) {
        if (file is File) {
          final extension = path.extension(file.path).toLowerCase();
          if (extension == '.png' ||
              extension == '.jpg' ||
              extension == '.jpeg') {
            // Check modification time if filtering by date
            if (since != null) {
              final stat = await file.stat();
              if (stat.modified.isAfter(since)) {
                images.add(file);
              }
            } else {
              images.add(file);
            }
          }
        }
      }

      AppLogger.info(
        'Collected ${images.length} product images',
        tag: 'BackupDataCollector',
      );

      return images;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to collect some images',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupDataCollector',
      );
      // Return empty list instead of throwing
      return [];
    }
  }

  /// Collect SharedPreferences data
  Future<Map<String, dynamic>> _collectPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      final preferencesMap = <String, dynamic>{};

      for (final key in keys) {
        final value = prefs.get(key);
        preferencesMap[key] = value;
      }

      AppLogger.info(
        'Collected ${preferencesMap.length} preferences',
        tag: 'BackupDataCollector',
      );

      return preferencesMap;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to collect preferences',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupDataCollector',
      );
      // Return empty map instead of throwing
      return {};
    }
  }

  /// Collect app settings (business info, tax rate, etc)
  Future<Map<String, dynamic>> _collectSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Settings keys used in the app
      final settingsKeys = [
        'business_name',
        'business_address',
        'business_phone',
        'tax_rate',
        'currency',
        'low_stock_threshold',
        'receipt_footer',
        'printer_enabled',
        'barcode_scanner_enabled',
      ];

      final settingsMap = <String, dynamic>{};

      for (final key in settingsKeys) {
        final value = prefs.get(key);
        if (value != null) {
          settingsMap[key] = value;
        }
      }

      AppLogger.info(
        'Collected ${settingsMap.length} settings',
        tag: 'BackupDataCollector',
      );

      return settingsMap;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to collect settings',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupDataCollector',
      );
      // Return empty map instead of throwing
      return {};
    }
  }

  /// Generate base backup ID from timestamp
  String _generateBaseBackupId(DateTime timestamp) {
    return 'base_${timestamp.millisecondsSinceEpoch}';
  }

  /// Get database file path for external access
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return path.join(dbPath, AppConstants.databaseName);
  }

  /// Get images directory path
  Future<String> getImagesDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'images', 'products');
  }

  /// Validate that all required data is available
  Future<bool> validateBackupData(BackupData data) async {
    try {
      // Validate database file
      if (data.databaseFile != null) {
        if (!await data.databaseFile!.exists()) {
          AppLogger.error(
            'Database file does not exist',
            tag: 'BackupDataCollector',
          );
          return false;
        }

        final size = await data.databaseFile!.length();
        if (size == 0) {
          AppLogger.error(
            'Database file is empty',
            tag: 'BackupDataCollector',
          );
          return false;
        }
      }

      // Validate image files
      for (final image in data.imageFiles) {
        if (!await image.exists()) {
          AppLogger.error(
            'Image file does not exist: ${image.path}',
            tag: 'BackupDataCollector',
          );
        }
      }

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to validate backup data',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupDataCollector',
      );
      return false;
    }
  }
}
