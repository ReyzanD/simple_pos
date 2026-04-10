import 'package:simple_pos/features/backup/domain/entities/backup_metadata.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_config.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_data.dart';

/// Repository interface for backup operations
abstract class BackupRepository {
  /// Create a backup with given configuration
  /// Returns BackupMetadata with file path and size
  Future<BackupMetadata> createBackup(BackupConfig config, BackupData data);

  /// Load backup data from storage
  Future<BackupData> loadBackup(String backupId);

  /// List all available backups
  Future<List<BackupMetadata>> listBackups();

  /// Delete a backup
  Future<void> deleteBackup(BackupMetadata backup);

  /// Upload backup to Google Drive
  Future<String> uploadToDrive(BackupMetadata backup, BackupData data);

  /// Download backup from Google Drive
  Future<BackupData> downloadFromDrive(String driveFileId);

  /// Get available storage space (in bytes)
  Future<int> getAvailableStorageSpace();
}