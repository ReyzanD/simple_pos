import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_metadata.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';

/// Storage usage information
class StorageUsage {
  final int localBackupSize;
  final int driveBackupSize;
  final int totalLocalSize;
  final int availableSpace;
  final int localBackupCount;
  final int driveBackupCount;

  const StorageUsage({
    required this.localBackupSize,
    required this.driveBackupSize,
    required this.totalLocalSize,
    required this.availableSpace,
    required this.localBackupCount,
    required this.driveBackupCount,
  });

  /// Get local backup size in human-readable format
  String get localBackupSizeFormatted {
    if (localBackupSize < 1024) return '$localBackupSize B';
    if (localBackupSize < 1024 * 1024) return '${(localBackupSize / 1024).toStringAsFixed(1)} KB';
    if (localBackupSize < 1024 * 1024 * 1024) return '${(localBackupSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(localBackupSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get available space in human-readable format
  String get availableSpaceFormatted {
    if (availableSpace < 1024) return '$availableSpace B';
    if (availableSpace < 1024 * 1024) return '${(availableSpace / 1024).toStringAsFixed(1)} KB';
    if (availableSpace < 1024 * 1024 * 1024) return '${(availableSpace / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(availableSpace / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  String toString() =>
      'StorageUsage(local: $localBackupSizeFormatted, available: $availableSpaceFormatted, '
      'count: $localBackupCount)';
}

/// Cleanup result information
class CleanupResult {
  final int filesDeleted;
  final int spaceFreed;
  final List<String> deletedBackupIds;
  final List<String> warnings;

  const CleanupResult({
    required this.filesDeleted,
    required this.spaceFreed,
    required this.deletedBackupIds,
    this.warnings = const [],
  });

  /// Get space freed in human-readable format
  String get spaceFreedFormatted {
    if (spaceFreed < 1024) return '$spaceFreed B';
    if (spaceFreed < 1024 * 1024) return '${(spaceFreed / 1024).toStringAsFixed(1)} KB';
    if (spaceFreed < 1024 * 1024 * 1024) return '${(spaceFreed / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(spaceFreed / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  String toString() =>
      'CleanupResult(deleted: $filesDeleted files, freed: $spaceFreedFormatted, warnings: ${warnings.length})';
}

/// Service for managing backup storage and cleanup
class BackupStorageManager {
  final int maxLocalFullBackups;
  final int maxLocalIncrementalBackups;

  BackupStorageManager({
    this.maxLocalFullBackups = BackupConstants.maxLocalFullBackups,
    this.maxLocalIncrementalBackups = BackupConstants.maxLocalIncrementalBackups,
  });

  /// Clean up old backups based on retention policy
  /// Returns CleanupResult with details
  Future<CleanupResult> cleanupOldBackups(List<BackupMetadata> backups) async {
    try {
      AppLogger.info('Starting backup cleanup', tag: 'BackupStorageManager');

      final deletedIds = <String>[];
      final warnings = <String>[];
      int filesDeleted = 0;
      int spaceFreed = 0;

      // Separate full and incremental backups
      final fullBackups = backups
          .where((b) => b.type == BackupType.full && b.isLocal)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final incrementalBackups = backups
          .where((b) => b.type == BackupType.incremental && b.isLocal)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Clean up full backups (but keep at least one)
      if (fullBackups.length > maxLocalFullBackups) {
        final toDelete = fullBackups.take(fullBackups.length - maxLocalFullBackups).toList();

        // Ensure we keep the most recent full backup
        if (toDelete.contains(fullBackups.last)) {
          warnings.add('Skipping deletion of most recent full backup');
          toDelete.remove(fullBackups.last);
        }

        for (final backup in toDelete) {
          try {
            final deleted = await _deleteBackupFiles(backup);
            if (deleted) {
              deletedIds.add(backup.id);
              filesDeleted++;
              spaceFreed += backup.size;
            }
          } catch (e, stackTrace) {
            AppLogger.error(
              'Failed to delete backup ${backup.id}',
              error: e,
              stackTrace: stackTrace,
              tag: 'BackupStorageManager',
            );
            warnings.add('Gagal menghapus backup ${backup.id}: $e');
          }
        }
      }

      // Clean up incremental backups
      if (incrementalBackups.length > maxLocalIncrementalBackups) {
        final toDelete = incrementalBackups
            .take(incrementalBackups.length - maxLocalIncrementalBackups)
            .toList();

        for (final backup in toDelete) {
          try {
            final deleted = await _deleteBackupFiles(backup);
            if (deleted) {
              deletedIds.add(backup.id);
              filesDeleted++;
              spaceFreed += backup.size;
            }
          } catch (e, stackTrace) {
            AppLogger.error(
              'Failed to delete backup ${backup.id}',
              error: e,
              stackTrace: stackTrace,
              tag: 'BackupStorageManager',
            );
            warnings.add('Gagal menghapus backup ${backup.id}: $e');
          }
        }
      }

      // Clean up orphaned files
      final orphanedCleanup = await _cleanupOrphanedFiles(backups);
      filesDeleted += orphanedCleanup.filesDeleted;
      spaceFreed += orphanedCleanup.spaceFreed;
      warnings.addAll(orphanedCleanup.warnings);

      AppLogger.info(
        'Cleanup completed: $filesDeleted files deleted, ${spaceFreed ~/ (1024 * 1024)} MB freed',
        tag: 'BackupStorageManager',
      );

      return CleanupResult(
        filesDeleted: filesDeleted,
        spaceFreed: spaceFreed,
        deletedBackupIds: deletedIds,
        warnings: warnings,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cleanup old backups',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      throw DatabaseException(
        'Gagal membersihkan backup lama',
        operation: 'cleanup old backups',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete backup files from storage
  Future<bool> _deleteBackupFiles(BackupMetadata backup) async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupFile = File(path.join(backupDir.path, _getBackupFileName(backup)));

      if (await backupFile.exists()) {
        await backupFile.delete();
        AppLogger.info('Deleted backup file: ${backupFile.path}', tag: 'BackupStorageManager');
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete backup files for ${backup.id}',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      return false;
    }
  }

  /// Clean up orphaned files (files without metadata)
  Future<CleanupResult> _cleanupOrphanedFiles(List<BackupMetadata> knownBackups) async {
    try {
      final warnings = <String>[];
      int filesDeleted = 0;
      int spaceFreed = 0;

      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) {
        return CleanupResult(
          filesDeleted: 0,
          spaceFreed: 0,
          deletedBackupIds: [],
        );
      }

      // Get all backup files
      final files = backupDir.listSync().whereType<File>().toList();

      // Collect known backup file names
      final knownFileNames = knownBackups
          .where((b) => b.isLocal)
          .map((b) => _getBackupFileName(b))
          .toSet();

      // Delete orphaned files
      for (final file in files) {
        final fileName = path.basename(file.path);

        if (!knownFileNames.contains(fileName)) {
          try {
            final fileSize = await file.length();
            await file.delete();
            filesDeleted++;
            spaceFreed += fileSize;
            AppLogger.info('Deleted orphaned file: $fileName', tag: 'BackupStorageManager');
          } catch (e, stackTrace) {
            AppLogger.error(
              'Failed to delete orphaned file: $fileName',
              error: e,
              stackTrace: stackTrace,
              tag: 'BackupStorageManager',
            );
            warnings.add('Gagal menghapus file orphaned: $fileName');
          }
        }
      }

      return CleanupResult(
        filesDeleted: filesDeleted,
        spaceFreed: spaceFreed,
        deletedBackupIds: [],
        warnings: warnings,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cleanup orphaned files',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      return CleanupResult(
        filesDeleted: 0,
        spaceFreed: 0,
        deletedBackupIds: [],
        warnings: ['Gagal membersihkan file orphaned: $e'],
      );
    }
  }

  /// Calculate storage usage
  Future<StorageUsage> calculateStorageUsage(List<BackupMetadata> backups) async {
    try {
      AppLogger.info('Calculating storage usage', tag: 'BackupStorageManager');

      // Calculate local backup sizes
      final localBackups = backups.where((b) => b.isLocal);
      final localBackupSize = localBackups.fold<int>(0, (sum, b) => sum + b.size);
      final localBackupCount = localBackups.length;

      // Calculate Drive backup sizes
      final driveBackups = backups.where((b) => b.isOnDrive);
      final driveBackupSize = driveBackups.fold<int>(0, (sum, b) => sum + b.size);
      final driveBackupCount = driveBackups.length;

      // Get available storage space
      final availableSpace = await _getAvailableStorageSpace();

      // Get total local storage size (app directory)
      final totalLocalSize = await _getAppDirectorySize();

      return StorageUsage(
        localBackupSize: localBackupSize,
        driveBackupSize: driveBackupSize,
        totalLocalSize: totalLocalSize,
        availableSpace: availableSpace,
        localBackupCount: localBackupCount,
        driveBackupCount: driveBackupCount,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to calculate storage usage',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      throw DatabaseException(
        'Gagal menghitung penggunaan storage',
        operation: 'calculate storage usage',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get available storage space
  Future<int> _getAvailableStorageSpace() async {
    try {
      // On most platforms, we can't get exact available space
      // Return a reasonable estimate or throw if not available
      // For now, return 1GB as a safe default
      return 1024 * 1024 * 1024;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get available storage space',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      // Return safe default
      return 1024 * 1024 * 1024; // 1GB
    }
  }

  /// Get app directory size
  Future<int> _getAppDirectorySize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return await _calculateDirectorySize(appDir);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to calculate app directory size',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      return 0;
    }
  }

  /// Calculate directory size recursively
  Future<int> _calculateDirectorySize(Directory dir) async {
    int size = 0;

    try {
      final entities = dir.listSync();

      for (final entity in entities) {
        if (entity is File) {
          try {
            size += await entity.length();
          } catch (e) {
            // Skip files we can't read
          }
        } else if (entity is Directory) {
          size += await _calculateDirectorySize(entity);
        }
      }
    } catch (e) {
      // Skip directories we can't read
    }

    return size;
  }

  /// Get backup directory
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(appDir.path, BackupConstants.backupDirName));

    // Create directory if it doesn't exist
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  /// Get backup file name from metadata
  String _getBackupFileName(BackupMetadata backup) {
    return BackupConstants.generateBackupFileName(
      dateTime: backup.createdAt,
      type: backup.type,
    );
  }

  /// Check if storage space is sufficient for backup
  Future<bool> hasEnoughSpace(int requiredBytes) async {
    try {
      final availableSpace = await _getAvailableStorageSpace();
      return availableSpace >= requiredBytes;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check storage space',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      return false;
    }
  }

  /// Get storage health status
  Future<Map<String, dynamic>> getStorageHealth(List<BackupMetadata> backups) async {
    try {
      final usage = await calculateStorageUsage(backups);
      final warnings = <String>[];
      final errors = <String>[];

      // Check if running low on space
      const lowSpaceThreshold = 100 * 1024 * 1024; // 100MB
      if (usage.availableSpace < lowSpaceThreshold) {
        errors.add('Storage space sangat rendah: ${usage.availableSpaceFormatted}');
      }

      // Check if backups are taking too much space
      const maxBackupSpace = 1024 * 1024 * 1024; // 1GB
      if (usage.localBackupSize > maxBackupSpace) {
        warnings.add('Backup menggunakan banyak space: ${usage.localBackupSizeFormatted}');
      }

      // Check if too many backups
      if (usage.localBackupCount > maxLocalFullBackups + maxLocalIncrementalBackups) {
        warnings.add(
          'Jumlah backup melebihi batas: ${usage.localBackupCount} backups',
        );
      }

      return {
        'healthy': errors.isEmpty,
        'warnings': warnings,
        'errors': errors,
        'usage': usage,
      };
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get storage health',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupStorageManager',
      );
      return {
        'healthy': false,
        'warnings': <String>[],
        'errors': ['Gagal mengecek kesehatan storage: $e'],
        'usage': null,
      };
    }
  }
}
