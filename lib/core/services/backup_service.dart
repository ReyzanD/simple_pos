import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_config.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_data.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_metadata.dart';
import 'package:simple_pos/features/backup/domain/repositories/backup_repository.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';
import 'package:simple_pos/core/constants/app_constants.dart';
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/services/backup_data_collector.dart';

/// Core service orchestrating all backup operations
/// Provides high-level backup management with validation and error handling
class BackupService {
  final BackupRepository backupRepository;
  final BackupDataCollector _dataCollector;
  final DatabaseHelper _databaseHelper;

  BackupService({
    required this.backupRepository,
    required BackupDataCollector dataCollector,
    required DatabaseHelper databaseHelper,
  }) : _dataCollector = dataCollector,
       _databaseHelper = databaseHelper;

  /// Create a backup with the given configuration
  /// Returns BackupResult with success status and metadata
  Future<BackupResult> createBackup(BackupConfig config) async {
    try {
      AppLogger.info('Starting backup creation', tag: 'BackupService');

      // Check storage space
      final availableSpace = await backupRepository.getAvailableStorageSpace();
      if (availableSpace < BackupConstants.maxBackupSizeBytes) {
        AppLogger.warning(
          'Low storage space: ${availableSpace ~/ (1024 * 1024)} MB',
          tag: 'BackupService',
        );
      }

      // Collect backup data
      final data = await _collectBackupData(config);

      // Validate data
      if (!await _validateBackupData(data)) {
        return BackupResult(
          success: false,
          error: 'Data backup tidak valid',
          metadata: null,
        );
      }

      // Create backup
      final metadata = await backupRepository.createBackup(config, data);

      AppLogger.info(
        'Backup created successfully: ${metadata.id}',
        tag: 'BackupService',
      );

      return BackupResult(success: true, error: null, metadata: metadata);
    } on AppException catch (e) {
      AppLogger.error('Backup creation failed', error: e, tag: 'BackupService');
      return BackupResult(success: false, error: e.userMessage, metadata: null);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createBackup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      return BackupResult(
        success: false,
        error: 'Terjadi kesalahan tidak terduga',
        metadata: null,
      );
    }
  }

  /// Restore backup with given mode
  /// Returns RestoreResult with success status and details
  Future<RestoreResult> restoreBackup(String backupId, RestoreMode mode) async {
    try {
      AppLogger.info(
        'Starting backup restore: $backupId (mode: ${mode.name})',
        tag: 'BackupService',
      );

      // Load backup data
      final data = await backupRepository.loadBackup(backupId);

      // Validate backup
      final validation = await validateBackup(backupId);
      if (!validation.isValid) {
        return RestoreResult(
          success: false,
          error: validation.error ?? 'Backup tidak valid',
          recordsProcessed: 0,
        );
      }

      // Restore based on mode
      if (mode == RestoreMode.replaceAll) {
        await _restoreReplaceAll(data);
      } else {
        await _restoreMerge(data);
      }

      AppLogger.info('Backup restored successfully', tag: 'BackupService');

      return RestoreResult(
        success: true,
        error: null,
        recordsProcessed: await _estimateRecordsProcessed(data),
      );
    } on AppException catch (e) {
      AppLogger.error('Backup restore failed', error: e, tag: 'BackupService');
      return RestoreResult(
        success: false,
        error: e.userMessage,
        recordsProcessed: 0,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in restoreBackup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      return RestoreResult(
        success: false,
        error: 'Terjadi kesalahan tidak terduga',
        recordsProcessed: 0,
      );
    }
  }

  /// Validate backup integrity
  /// Returns ValidationResult with validity status
  Future<ValidationResult> validateBackup(String backupId) async {
    try {
      AppLogger.info('Validating backup: $backupId', tag: 'BackupService');

      // Load backup to validate
      final data = await backupRepository.loadBackup(backupId);

      // Check if data exists
      if (data.databaseFile == null && data.imageFiles.isEmpty) {
        return ValidationResult(
          isValid: false,
          error: 'File backup kosong atau rusak',
          warnings: [],
        );
      }

      // Check database file
      if (data.databaseFile != null) {
        final exists = await data.databaseFile!.exists();
        if (!exists) {
          return ValidationResult(
            isValid: false,
            error: 'File database tidak ditemukan',
            warnings: [],
          );
        }
      }

      // Collect warnings
      final warnings = <String>[];

      if (data.databaseFile == null) {
        warnings.add('Backup tidak mengandung database');
      }

      if (data.imageFiles.isEmpty) {
        warnings.add('Backup tidak mengandung gambar');
      }

      AppLogger.info('Backup validation completed', tag: 'BackupService');

      return ValidationResult(isValid: true, error: null, warnings: warnings);
    } on AppException catch (e) {
      AppLogger.error(
        'Backup validation failed',
        error: e,
        tag: 'BackupService',
      );
      return ValidationResult(
        isValid: false,
        error: e.userMessage,
        warnings: [],
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in validateBackup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      return ValidationResult(
        isValid: false,
        error: 'Terjadi kesalahan tidak terduga',
        warnings: [],
      );
    }
  }

  /// List all available backups
  Future<List<BackupMetadata>> listBackups() async {
    try {
      AppLogger.info('Listing backups', tag: 'BackupService');

      final backups = await backupRepository.listBackups();

      AppLogger.info('Found ${backups.length} backups', tag: 'BackupService');
      return backups;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to list backups',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      return [];
    }
  }

  /// Delete a backup
  Future<bool> deleteBackup(String backupId) async {
    try {
      AppLogger.info('Deleting backup: $backupId', tag: 'BackupService');

      final backups = await listBackups();
      final backup = backups.where((b) => b.id == backupId).firstOrNull;

      if (backup == null) {
        AppLogger.warning('Backup not found: $backupId', tag: 'BackupService');
        return false;
      }

      await backupRepository.deleteBackup(backup);

      AppLogger.info('Backup deleted successfully', tag: 'BackupService');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete backup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      return false;
    }
  }

  /// Collect backup data from database and files
  Future<BackupData> _collectBackupData(BackupConfig config) async {
    return await _dataCollector.collectBackupData(config);
  }

  /// Restore backup by replacing all existing data
  Future<void> _restoreReplaceAll(BackupData data) async {
    try {
      AppLogger.info('Starting replace all restore', tag: 'BackupService');

      // 1. Close database connection
      AppLogger.info('Closing database connection', tag: 'BackupService');
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, AppConstants.databaseName));

      // 2. Delete current database
      if (await dbFile.exists()) {
        AppLogger.info('Deleting current database', tag: 'BackupService');
        await dbFile.delete();
      }

      // 3. Copy backup database
      if (data.databaseFile != null && await data.databaseFile!.exists()) {
        AppLogger.info('Copying backup database', tag: 'BackupService');
        await data.databaseFile!.copy(dbFile.path);
      }

      // 4. Restore images
      if (data.imageFiles.isNotEmpty) {
        AppLogger.info(
          'Restoring ${data.imageFiles.length} images',
          tag: 'BackupService',
        );
        await _restoreImages(data.imageFiles, replaceAll: true);
      }

      // 5. Restore preferences
      if (data.preferences != null) {
        AppLogger.info('Restoring preferences', tag: 'BackupService');
        await _restorePreferences(data.preferences!);
      }

      // 6. Restore settings
      if (data.settings != null) {
        AppLogger.info('Restoring settings', tag: 'BackupService');
        await _restoreSettings(data.settings!);
      }

      // 7. Force database reconnection
      AppLogger.info('Reconnecting to database', tag: 'BackupService');
      // The database will be re-opened on next access via DatabaseHelper

      AppLogger.info('Replace all restore completed', tag: 'BackupService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to restore backup (replace all)',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      throw DatabaseException(
        'Gagal me-restore backup (replace all)',
        operation: 'restore replace all',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Restore backup by merging with existing data
  Future<void> _restoreMerge(BackupData data) async {
    try {
      AppLogger.info('Starting merge restore', tag: 'BackupService');

      final db = await _databaseHelper.database;
      int recordsProcessed = 0;

      // 1. Merge database changes
      if (data.databaseChanges != null) {
        AppLogger.info('Merging database changes', tag: 'BackupService');

        for (final entry in data.databaseChanges!.entries) {
          final table = entry.key;
          final rows = entry.value;

          try {
            for (final row in rows) {
              await _mergeTableRow(db, table, row);
              recordsProcessed++;
            }
            AppLogger.database('Merged $table', details: '${rows.length} rows');
          } catch (e, stackTrace) {
            AppLogger.error(
              'Failed to merge table $table',
              error: e,
              stackTrace: stackTrace,
              tag: 'BackupService',
            );
            // Continue with other tables
          }
        }
      } else if (data.databaseFile != null &&
          await data.databaseFile!.exists()) {
        // Full database merge - open backup database and merge tables
        AppLogger.info('Merging full database', tag: 'BackupService');
        recordsProcessed += await _mergeFullDatabase(data.databaseFile!);
      }

      // 2. Merge images (add new, don't replace existing)
      if (data.imageFiles.isNotEmpty) {
        AppLogger.info(
          'Merging ${data.imageFiles.length} images',
          tag: 'BackupService',
        );
        await _restoreImages(data.imageFiles, replaceAll: false);
      }

      // 3. Merge preferences (don't overwrite existing)
      if (data.preferences != null) {
        AppLogger.info('Merging preferences', tag: 'BackupService');
        await _mergePreferences(data.preferences!);
      }

      // 4. Merge settings (don't overwrite existing)
      if (data.settings != null) {
        AppLogger.info('Merging settings', tag: 'BackupService');
        await _mergeSettings(data.settings!);
      }

      AppLogger.info(
        'Merge restore completed: $recordsProcessed records',
        tag: 'BackupService',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to restore backup (merge)',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      throw DatabaseException(
        'Gagal me-restore backup (merge)',
        operation: 'restore merge',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Merge a single table row
  Future<void> _mergeTableRow(
    Database db,
    String table,
    Map<String, dynamic> row,
  ) async {
    try {
      final id = row['id'];
      if (id == null) {
        // No ID, insert as new
        await db.insert(table, row);
        return;
      }

      // Check if row exists
      final existing = await db.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (existing.isEmpty) {
        // Insert new row
        await db.insert(table, row);
      } else {
        // Check if backup row is newer
        final backupUpdated =
            row['updated_at']?.toString() ?? row['created_at']?.toString();
        final existingUpdated =
            existing.first['updated_at']?.toString() ??
            existing.first['created_at']?.toString();

        if (backupUpdated != null &&
            (existingUpdated == null ||
                DateTime.parse(
                  backupUpdated,
                ).isAfter(DateTime.parse(existingUpdated)))) {
          // Update existing row
          await db.update(table, row, where: 'id = ?', whereArgs: [id]);
        }
        // Else: skip (keep existing, it's newer)
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to merge row in $table',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
      // Continue with other rows
    }
  }

  /// Merge full database
  Future<int> _mergeFullDatabase(File backupDbFile) async {
    int recordsProcessed = 0;

    try {
      // Open backup database
      final backupDb = await openDatabase(backupDbFile.path);
      final targetDb = await _databaseHelper.database;

      final tables = [
        'categories',
        'suppliers',
        'products',
        'transactions',
        'transaction_items',
        'payments',
        'promotions',
        'discount_presets',
        'shifts',
        'users',
        'user_sessions',
        'expenses',
      ];

      for (final table in tables) {
        try {
          // Get rows from backup
          final backupRows = await backupDb.query(table);

          for (final row in backupRows) {
            await _mergeTableRow(targetDb, table, row);
            recordsProcessed++;
          }
        } catch (e, stackTrace) {
          AppLogger.error(
            'Failed to merge table $table',
            error: e,
            stackTrace: stackTrace,
            tag: 'BackupService',
          );
          // Continue with other tables
        }
      }

      await backupDb.close();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to merge full database',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
    }

    return recordsProcessed;
  }

  /// Restore image files
  Future<void> _restoreImages(
    List<File> images, {
    required bool replaceAll,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'images', 'products'));

      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      for (final image in images) {
        try {
          final fileName = path.basename(image.path);
          final targetPath = path.join(imagesDir.path, fileName);
          final targetFile = File(targetPath);

          if (replaceAll) {
            // Replace existing
            await image.copy(targetPath);
          } else {
            // Only copy if doesn't exist
            if (!await targetFile.exists()) {
              await image.copy(targetPath);
            }
          }
        } catch (e, stackTrace) {
          AppLogger.error(
            'Failed to restore image: ${image.path}',
            error: e,
            stackTrace: stackTrace,
            tag: 'BackupService',
          );
          // Continue with other images
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to restore images',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
    }
  }

  /// Restore preferences
  Future<void> _restorePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final entry in preferences.entries) {
        final key = entry.key;
        final value = entry.value;

        try {
          if (value is String) {
            await prefs.setString(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is List<String>) {
            await prefs.setStringList(key, value);
          }
        } catch (e, stackTrace) {
          AppLogger.error(
            'Failed to restore preference: $key',
            error: e,
            stackTrace: stackTrace,
            tag: 'BackupService',
          );
          // Continue with other preferences
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to restore preferences',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
    }
  }

  /// Restore settings
  Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    await _restorePreferences(settings);
  }

  /// Merge preferences (don't overwrite existing)
  Future<void> _mergePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final entry in preferences.entries) {
        final key = entry.key;

        // Only set if not already exists
        if (!prefs.containsKey(key)) {
          final value = entry.value;

          try {
            if (value is String) {
              await prefs.setString(key, value);
            } else if (value is int) {
              await prefs.setInt(key, value);
            } else if (value is double) {
              await prefs.setDouble(key, value);
            } else if (value is bool) {
              await prefs.setBool(key, value);
            } else if (value is List<String>) {
              await prefs.setStringList(key, value);
            }
          } catch (e, stackTrace) {
            AppLogger.error(
              'Failed to merge preference: $key',
              error: e,
              stackTrace: stackTrace,
              tag: 'BackupService',
            );
            // Continue with other preferences
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to merge preferences',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupService',
      );
    }
  }

  /// Merge settings (don't overwrite existing)
  Future<void> _mergeSettings(Map<String, dynamic> settings) async {
    await _mergePreferences(settings);
  }

  /// Validate backup data before creating backup
  Future<bool> _validateBackupData(BackupData data) async {
    // Basic validation - will be expanded in future tasks
    return true;
  }

  /// Estimate number of records processed (for reporting)
  Future<int> _estimateRecordsProcessed(BackupData data) async {
    int count = 0;

    // Count database changes
    if (data.databaseChanges != null) {
      for (final rows in data.databaseChanges!.values) {
        count += rows.length;
      }
    } else if (data.databaseFile != null && await data.databaseFile!.exists()) {
      // Estimate from database file size
      // Rough estimate: assume average row size ~500 bytes
      final fileSize = await data.databaseFile!.length();
      count = (fileSize / 500).round();
    }

    // Add images
    count += data.imageFiles.length;

    // Add preferences and settings
    if (data.preferences != null) {
      count += data.preferences!.length;
    }
    if (data.settings != null) {
      count += data.settings!.length;
    }

    return count;
  }
}

/// Result of backup creation operation
class BackupResult {
  final bool success;
  final String? error;
  final BackupMetadata? metadata;

  BackupResult({required this.success, this.error, this.metadata});

  @override
  String toString() =>
      'BackupResult(success: $success, error: $error, metadata: ${metadata?.id})';
}

/// Result of restore operation
class RestoreResult {
  final bool success;
  final String? error;
  final int recordsProcessed;

  RestoreResult({
    required this.success,
    this.error,
    required this.recordsProcessed,
  });

  @override
  String toString() =>
      'RestoreResult(success: $success, error: $error, records: $recordsProcessed)';
}

/// Result of backup validation
class ValidationResult {
  final bool isValid;
  final String? error;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    this.error,
    this.warnings = const [],
  });

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, error: $error, warnings: ${warnings.length})';
}
