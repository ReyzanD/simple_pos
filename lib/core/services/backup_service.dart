import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:simple_pos/services/database/database_helper.dart';

/// BackupService for database backup and restore operations
class BackupService {
  final DatabaseHelper databaseHelper;

  BackupService({required this.databaseHelper});

  /// Create a backup of the database
  /// Returns the path to the backup file
  Future<String> createBackup() async {
    final db = await databaseHelper.database;
    final dbPath = db.path;

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');

    // Create backup directory if it doesn't exist
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    // Create backup file with timestamp
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupFileName = 'backup_$timestamp.db';
    final backupPath = path.join(backupDir.path, backupFileName);

    // Copy the database file
    await File(dbPath).copy(backupPath);

    return backupPath;
  }

  /// Get list of available backups
  Future<List<BackupInfo>> getAvailableBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');

    if (!await backupDir.exists()) {
      return [];
    }

    final files = await backupDir.list().where((f) => f.path.endsWith('.db')).toList();

    final backups = <BackupInfo>[];
    for (var file in files) {
      if (file is File) {
        final stat = await file.stat();
        final fileName = path.basename(file.path);

        // Extract timestamp from filename
        final timestampStr = fileName.replaceAll('backup_', '').replaceAll('.db', '');
        DateTime? timestamp;
        try {
          timestamp = DateTime.parse(timestampStr.replaceAll('-', ':'));
        } catch (e) {
          timestamp = stat.modified;
        }

        backups.add(BackupInfo(
          path: file.path,
          fileName: fileName,
          size: stat.size,
          createdAt: timestamp,
        ));
      }
    }

    // Sort by creation date, newest first
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return backups;
  }

  /// Restore database from backup
  /// WARNING: This will replace the current database
  Future<bool> restoreFromBackup(String backupPath) async {
    try {
      // Close current database connection
      // Note: DatabaseHelper will need to handle this

      final db = await databaseHelper.database;
      final currentDbPath = db.path;

      // Copy backup file to replace current database
      await File(backupPath).copy(currentDbPath);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a backup file
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get total size of all backups
  Future<int> getTotalBackupSize() async {
    final backups = await getAvailableBackups();
    return backups.fold<int>(0, (sum, backup) => sum + backup.size);
  }

  /// Delete old backups (older than specified days)
  Future<int> deleteOldBackups(int daysToKeep) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final backups = await getAvailableBackups();

    int deletedCount = 0;
    for (var backup in backups) {
      if (backup.createdAt.isBefore(cutoffDate)) {
        if (await deleteBackup(backup.path)) {
          deletedCount++;
        }
      }
    }

    return deletedCount;
  }
}

/// Information about a backup file
class BackupInfo {
  final String path;
  final String fileName;
  final int size;
  final DateTime createdAt;

  BackupInfo({
    required this.path,
    required this.fileName,
    required this.size,
    required this.createdAt,
  });

  /// Get human-readable size string
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get formatted date string
  String get dateFormatted {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} '
        '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
