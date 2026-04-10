import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_config.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_data.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_metadata.dart';
import 'package:simple_pos/features/backup/domain/repositories/backup_repository.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';
import '../datasources/backup_local_datasource.dart';
import '../datasources/backup_drive_datasource.dart';

/// Implementation of backup repository
/// Combines local and Drive datasources with local-first fallback
class BackupRepositoryImpl implements BackupRepository {
  final BackupLocalDataSource localDataSource;
  final BackupDriveDataSource driveDataSource;

  BackupRepositoryImpl({
    required this.localDataSource,
    required this.driveDataSource,
  });

  @override
  Future<BackupMetadata> createBackup(BackupConfig config, BackupData data) async {
    try {
      AppLogger.useCase('CreateBackup', details: 'Type: ${config.type}');

      // Create metadata
      final metadata = BackupMetadata(
        id: _generateBackupId(),
        type: config.type,
        createdAt: DateTime.now(),
        size: await data.getTotalSize(),
        location: config.location,
        isValid: true,
        baseBackupId: data.baseBackupId,
        databaseVersion: 2, // TODO: Get from constants
        appVersion: '1.0.0', // TODO: Get from package_info
      );

      // Save locally first
      await localDataSource.saveBackup(data, metadata);

      // Upload to Drive if requested
      if (config.location == StorageLocation.drive ||
          config.location == StorageLocation.both) {
        try {
          final driveFileId = await driveDataSource.uploadBackup(data, metadata);
          // Update metadata with Drive file ID
          final updatedMetadata = BackupMetadata(
            id: metadata.id,
            type: metadata.type,
            createdAt: metadata.createdAt,
            size: metadata.size,
            location: StorageLocation.both,
            isValid: metadata.isValid,
            baseBackupId: metadata.baseBackupId,
            driveFileId: driveFileId,
            databaseVersion: metadata.databaseVersion,
            appVersion: metadata.appVersion,
          );
          AppLogger.info(
            'Backup uploaded to Drive: $driveFileId',
            tag: 'BackupRepository',
          );
          return updatedMetadata;
        } catch (e, stackTrace) {
          AppLogger.error(
            'Failed to upload to Drive, backup saved locally only',
            error: e,
            stackTrace: stackTrace,
            tag: 'BackupRepository',
          );
          // Return local-only metadata on Drive failure
          return BackupMetadata(
            id: metadata.id,
            type: metadata.type,
            createdAt: metadata.createdAt,
            size: metadata.size,
            location: StorageLocation.local,
            isValid: metadata.isValid,
            baseBackupId: metadata.baseBackupId,
            databaseVersion: metadata.databaseVersion,
            appVersion: metadata.appVersion,
          );
        }
      }

      AppLogger.info('Backup created successfully', tag: 'BackupRepository');
      return metadata;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createBackup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupRepository',
      );
      throw DatabaseException(
        'Gagal membuat backup',
        operation: 'createBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<BackupData> loadBackup(String backupId) async {
    try {
      AppLogger.useCase('LoadBackup', details: 'ID: $backupId');

      // Try to load from local first
      try {
        final data = await localDataSource.loadBackup(backupId);
        AppLogger.info('Backup loaded from local storage', tag: 'BackupRepository');
        return data;
      } on NotFoundException {
        AppLogger.info(
          'Backup not found locally, checking Drive',
          tag: 'BackupRepository',
        );
      }

      // If not found locally, try Drive
      final metadata = await localDataSource.getMetadata(backupId);
      if (metadata?.driveFileId != null) {
        try {
          final data = await driveDataSource.downloadBackup(metadata!.driveFileId!);
          AppLogger.info('Backup loaded from Drive', tag: 'BackupRepository');
          return data;
        } catch (e, stackTrace) {
          AppLogger.error(
            'Failed to download from Drive',
            error: e,
            stackTrace: stackTrace,
            tag: 'BackupRepository',
          );
        }
      }

      throw NotFoundException(
        'Backup tidak ditemukan',
        resourceType: 'Backup',
        resourceId: backupId,
      );
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in loadBackup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupRepository',
      );
      throw DatabaseException(
        'Gagal memuat backup',
        operation: 'loadBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<BackupMetadata>> listBackups() async {
    try {
      AppLogger.useCase('ListBackups');

      // Get local backups
      final localBackups = await localDataSource.listBackups();

      // Try to get Drive backups (if available)
      List<BackupMetadata> driveBackups = [];
      try {
        final isDriveAvailable = await driveDataSource.isAvailable();
        if (isDriveAvailable) {
          driveBackups = await driveDataSource.listBackups();
        }
      } catch (e) {
        AppLogger.warning(
          'Failed to list Drive backups, using local only',
          tag: 'BackupRepository',
        );
      }

      // Combine and deduplicate backups
      final combinedBackups = <BackupMetadata>[];
      final seenIds = <String>{};

      for (final backup in [...localBackups, ...driveBackups]) {
        if (!seenIds.contains(backup.id)) {
          seenIds.add(backup.id);
          combinedBackups.add(backup);
        }
      }

      // Sort by creation date (newest first)
      combinedBackups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      AppLogger.info(
        'Found ${combinedBackups.length} total backups',
        tag: 'BackupRepository',
      );
      return combinedBackups;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in listBackups',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupRepository',
      );
      throw DatabaseException(
        'Gagal mendapatkan daftar backup',
        operation: 'listBackups',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteBackup(BackupMetadata backup) async {
    try {
      AppLogger.useCase('DeleteBackup', details: 'ID: ${backup.id}');

      // Delete from local if present
      if (backup.isLocal) {
        await localDataSource.deleteBackup(backup.id);
        AppLogger.info('Backup deleted from local storage', tag: 'BackupRepository');
      }

      // Delete from Drive if present
      if (backup.isOnDrive && backup.driveFileId != null) {
        try {
          await driveDataSource.deleteBackup(backup.driveFileId!);
          AppLogger.info('Backup deleted from Drive', tag: 'BackupRepository');
        } catch (e, stackTrace) {
          AppLogger.error(
            'Failed to delete from Drive',
            error: e,
            stackTrace: stackTrace,
            tag: 'BackupRepository',
          );
          // Continue even if Drive deletion fails
        }
      }

      AppLogger.info('Backup deletion completed', tag: 'BackupRepository');
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteBackup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupRepository',
      );
      throw DatabaseException(
        'Gagal menghapus backup',
        operation: 'deleteBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> uploadToDrive(BackupMetadata backup, BackupData data) async {
    try {
      AppLogger.useCase('UploadToDrive', details: 'ID: ${backup.id}');

      final driveFileId = await driveDataSource.uploadBackup(data, backup);

      AppLogger.info('Backup uploaded to Drive', tag: 'BackupRepository');
      return driveFileId;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in uploadToDrive',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupRepository',
      );
      throw DatabaseException(
        'Gagal mengupload ke Drive',
        operation: 'uploadToDrive',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<BackupData> downloadFromDrive(String driveFileId) async {
    try {
      AppLogger.useCase('DownloadFromDrive', details: 'Drive ID: $driveFileId');

      final data = await driveDataSource.downloadBackup(driveFileId);

      AppLogger.info('Backup downloaded from Drive', tag: 'BackupRepository');
      return data;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in downloadFromDrive',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupRepository',
      );
      throw DatabaseException(
        'Gagal mendownload dari Drive',
        operation: 'downloadFromDrive',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getAvailableStorageSpace() async {
    try {
      AppLogger.useCase('GetAvailableStorageSpace');

      final space = await localDataSource.getAvailableStorageSpace();

      AppLogger.info(
        'Available storage: ${space ~/ (1024 * 1024)} MB',
        tag: 'BackupRepository',
      );
      return space;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getAvailableStorageSpace',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupRepository',
      );
      throw DatabaseException(
        'Gagal mengecek ruang penyimpanan',
        operation: 'getAvailableStorageSpace',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Generate unique backup ID
  String _generateBackupId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'backup_$timestamp.$random';
  }
}
