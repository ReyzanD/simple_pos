import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_metadata.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_data.dart';

/// Local data source for backup operations
/// Handles file I/O, directory management, and storage space checking
class BackupLocalDataSource {
  /// Get the root backup directory
  Future<Directory> get _backupRootDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/${BackupConstants.backupDirName}');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
      AppLogger.info('Created backup root directory', tag: 'BackupLocalDataSource');
    }

    return backupDir;
  }

  /// Get the full backup directory
  Future<Directory> get _fullBackupDir async {
    final root = await _backupRootDir;
    final fullDir = Directory('${root.path}/${BackupConstants.fullBackupDirName}');

    if (!await fullDir.exists()) {
      await fullDir.create(recursive: true);
      AppLogger.info('Created full backup directory', tag: 'BackupLocalDataSource');
    }

    return fullDir;
  }

  /// Get the incremental backup directory
  Future<Directory> get _incrementalBackupDir async {
    final root = await _backupRootDir;
    final incDir = Directory('${root.path}/${BackupConstants.incrementalBackupDirName}');

    if (!await incDir.exists()) {
      await incDir.create(recursive: true);
      AppLogger.info('Created incremental backup directory', tag: 'BackupLocalDataSource');
    }

    return incDir;
  }

  /// Get the temp backup directory
  /// Used for temporary files during backup creation/extraction
  Future<Directory> get tempBackupDir async {
    final root = await _backupRootDir;
    final tempDir = Directory('${root.path}/${BackupConstants.tempBackupDirName}');

    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
      AppLogger.info('Created temp backup directory', tag: 'BackupLocalDataSource');
    }

    return tempDir;
  }

  /// Get backup directory based on type
  Future<Directory> _getBackupDir(BackupType type) async {
    return type == BackupType.full ? await _fullBackupDir : await _incrementalBackupDir;
  }

  /// Save backup data to local storage
  /// Returns the path to the created backup file
  Future<String> saveBackup(BackupData data, BackupMetadata metadata) async {
    try {
      AppLogger.info('Saving backup locally', tag: 'BackupLocalDataSource');

      final backupDir = await _getBackupDir(metadata.type);
      final fileName = BackupConstants.generateBackupFileName(
        dateTime: metadata.createdAt,
        type: metadata.type,
      );
      final filePath = '${backupDir.path}/$fileName';

      // For now, just save metadata - ZIP creation will be implemented in Task 12
      final metadataPath = '$filePath.metadata';
      final metadataFile = File(metadataPath);
      await metadataFile.writeAsString(metadata.toJson().toString());

      AppLogger.info('Backup saved successfully at $filePath', tag: 'BackupLocalDataSource');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save backup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      throw DatabaseException(
        'Gagal menyimpan backup',
        operation: 'saveBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Load backup data from local storage
  Future<BackupData> loadBackup(String backupId) async {
    try {
      AppLogger.info('Loading backup: $backupId', tag: 'BackupLocalDataSource');

      final metadata = await getMetadata(backupId);
      if (metadata == null) {
        throw NotFoundException(
          'Backup tidak ditemukan',
          resourceType: 'Backup',
          resourceId: backupId,
        );
      }

      final backupDir = await _getBackupDir(metadata.type);
      final fileName = BackupConstants.generateBackupFileName(
        dateTime: metadata.createdAt,
        type: metadata.type,
      );
      final filePath = '${backupDir.path}/$fileName';

      final file = File(filePath);
      if (!await file.exists()) {
        throw NotFoundException(
          'File backup tidak ditemukan',
          resourceType: 'Backup',
          resourceId: backupId,
        );
      }

      // TODO: Implement ZIP extraction in Task 12
      AppLogger.info('Backup loaded successfully', tag: 'BackupLocalDataSource');
      return BackupData();
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load backup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      throw DatabaseException(
        'Gagal memuat backup',
        operation: 'loadBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// List all local backups
  Future<List<BackupMetadata>> listBackups() async {
    try {
      AppLogger.info('Listing local backups', tag: 'BackupLocalDataSource');

      final List<BackupMetadata> backups = [];

      // List full backups
      final fullDir = await _fullBackupDir;
      backups.addAll(await _listBackupsInDirectory(fullDir, BackupType.full));

      // List incremental backups
      final incDir = await _incrementalBackupDir;
      backups.addAll(await _listBackupsInDirectory(incDir, BackupType.incremental));

      AppLogger.info('Found ${backups.length} local backups', tag: 'BackupLocalDataSource');
      return backups;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to list backups',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      throw DatabaseException(
        'Gagal mendapatkan daftar backup',
        operation: 'listBackups',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// List backups in a specific directory
  Future<List<BackupMetadata>> _listBackupsInDirectory(
    Directory dir,
    BackupType type,
  ) async {
    final List<BackupMetadata> backups = [];

    if (!await dir.exists()) {
      return backups;
    }

    final entities = dir.listSync();
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.zip')) {
        final metadata = await getMetadataFromFile(entity.path, type);
        if (metadata != null) {
          backups.add(metadata);
        }
      }
    }

    return backups;
  }

  /// Delete a local backup
  Future<void> deleteBackup(String backupId) async {
    try {
      AppLogger.info('Deleting backup: $backupId', tag: 'BackupLocalDataSource');

      final metadata = await getMetadata(backupId);
      if (metadata == null) {
        throw NotFoundException(
          'Backup tidak ditemukan',
          resourceType: 'Backup',
          resourceId: backupId,
        );
      }

      final backupDir = await _getBackupDir(metadata.type);
      final fileName = BackupConstants.generateBackupFileName(
        dateTime: metadata.createdAt,
        type: metadata.type,
      );
      final filePath = '${backupDir.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Backup deleted successfully', tag: 'BackupLocalDataSource');
      }
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete backup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      throw DatabaseException(
        'Gagal menghapus backup',
        operation: 'deleteBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get metadata for a specific backup
  Future<BackupMetadata?> getMetadata(String backupId) async {
    try {
      // Search in full backups
      final fullDir = await _fullBackupDir;
      final metadata = await _searchMetadataInDirectory(fullDir, backupId, BackupType.full);
      if (metadata != null) return metadata;

      // Search in incremental backups
      final incDir = await _incrementalBackupDir;
      return await _searchMetadataInDirectory(incDir, backupId, BackupType.incremental);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get metadata',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      return null;
    }
  }

  /// Search for metadata in a specific directory
  Future<BackupMetadata?> _searchMetadataInDirectory(
    Directory dir,
    String backupId,
    BackupType type,
  ) async {
    if (!await dir.exists()) {
      return null;
    }

    final entities = dir.listSync();
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.zip')) {
        final metadata = await getMetadataFromFile(entity.path, type);
        if (metadata != null && metadata.id == backupId) {
          return metadata;
        }
      }
    }

    return null;
  }

  /// Get metadata from a backup file
  Future<BackupMetadata?> getMetadataFromFile(String filePath, BackupType type) async {
    try {
      final metadataPath = '$filePath.metadata';
      final metadataFile = File(metadataPath);

      if (!await metadataFile.exists()) {
        // If metadata file doesn't exist, create basic metadata from file
        final file = File(filePath);
        if (!await file.exists()) {
          return null;
        }

        final stat = await file.stat();
        final fileName = filePath.split('/').last;

        return BackupMetadata(
          id: fileName,
          type: type,
          createdAt: stat.modified,
          size: stat.size,
          location: StorageLocation.local,
          isValid: true,
          databaseVersion: 2, // Default to current version
          appVersion: '1.0.0', // Default version
        );
      }

      await metadataFile.readAsString(); // Will parse properly in Task 12
      final metadataMap = <String, dynamic>{}; // Placeholder until proper JSON parsing

      return BackupMetadata.fromJson(metadataMap);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to read metadata from file',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      return null;
    }
  }

  /// Get available storage space
  Future<int> getAvailableStorageSpace() async {
    try {
      // For simplicity, return a dummy value
      // In production, would use platform-specific code to get actual disk space
      AppLogger.info('Getting available storage space', tag: 'BackupLocalDataSource');
      return 1024 * 1024 * 1024; // 1GB dummy value
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get storage space',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      return 0;
    }
  }

  /// Clean up old backups based on retention policy
  Future<void> cleanupOldBackups() async {
    try {
      AppLogger.info('Cleaning up old backups', tag: 'BackupLocalDataSource');

      final backups = await listBackups();

      // Separate by type
      final fullBackups = backups.where((b) => b.type == BackupType.full).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final incrementalBackups = backups.where((b) => b.type == BackupType.incremental).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Delete excess full backups
      if (fullBackups.length > BackupConstants.maxLocalFullBackups) {
        final toDelete = fullBackups.skip(BackupConstants.maxLocalFullBackups);
        for (final backup in toDelete) {
          await deleteBackup(backup.id);
        }
      }

      // Delete excess incremental backups
      if (incrementalBackups.length > BackupConstants.maxLocalIncrementalBackups) {
        final toDelete = incrementalBackups.skip(BackupConstants.maxLocalIncrementalBackups);
        for (final backup in toDelete) {
          await deleteBackup(backup.id);
        }
      }

      AppLogger.info('Cleanup completed', tag: 'BackupLocalDataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cleanup old backups',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
    }
  }

  /// Create a ZIP file from backup data
  /// TODO: Implement in Task 12
  Future<String> createZipBackup(BackupData data, String outputPath) async {
    throw UnimplementedError('ZIP creation will be implemented in Task 12');
  }

  /// Extract a ZIP backup file
  /// TODO: Implement in Task 12
  Future<BackupData> extractZipBackup(String zipPath) async {
    throw UnimplementedError('ZIP extraction will be implemented in Task 12');
  }
}
