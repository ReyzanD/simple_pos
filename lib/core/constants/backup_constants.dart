/// Backup system constants
class BackupConstants {
  // Storage
  static const String backupDirName = 'backups';
  static const String fullBackupDirName = 'full';
  static const String incrementalBackupDirName = 'incremental';
  static const String tempBackupDirName = 'temp';
  static const String metadataFileName = 'metadata.json';

  // Storage limits
  static const int maxLocalFullBackups = 10;
  static const int maxLocalIncrementalBackups = 30;

  // Compression
  static const int compressionLevel = 6;
  static const bool defaultCompress = true;

  // File naming
  static String generateBackupFileName({
    required DateTime dateTime,
    required BackupType type,
  }) {
    final timestamp = '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}'
                      '${dateTime.day.toString().padLeft(2, '0')}'
                      '${dateTime.hour.toString().padLeft(2, '0')}'
                      '${dateTime.minute.toString().padLeft(2, '0')}'
                      '${dateTime.second.toString().padLeft(2, '0')}';
    final typeSuffix = type == BackupType.full ? 'full' : 'inc';
    return 'backup_$timestamp.$typeSuffix.zip';
  }

  // Google Drive
  static const String driveFolderName = 'Simple POS Backups';
  static const String driveFullFolderName = 'Full';
  static const String driveIncrementalFolderName = 'Incremental';

  // Backup file properties
  static const String propertyIsBackup = 'isBackup';
  static const String propertyBackupType = 'backupType';
  static const String propertyBackupDate = 'backupDate';
  static const String propertyBackupSize = 'backupSize';
  static const String propertyAppVersion = 'appVersion';
  static const String propertyDatabaseVersion = 'databaseVersion';

  // Performance
  static const Duration backupTimeout = Duration(minutes: 5);
  static const Duration restoreTimeout = Duration(minutes: 10);
  static const int maxBackupSizeBytes = 500 * 1024 * 1024; // 500MB
}

enum BackupType { full, incremental }

enum BackupDataType { database, images, all }

enum StorageLocation { local, drive, both }

enum BackupFrequency { daily, weekly, monthly }

enum RestoreMode { replaceAll, merge }