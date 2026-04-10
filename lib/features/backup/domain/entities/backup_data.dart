import 'dart:io';

/// Represents collected backup data
class BackupData {
  final File? databaseFile;
  final List<File> imageFiles;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? settings;

  /// For incremental backups
  final Map<String, List<Map<String, dynamic>>>? databaseChanges;
  final String? baseBackupId;

  const BackupData({
    this.databaseFile,
    this.imageFiles = const [],
    this.preferences,
    this.settings,
    this.databaseChanges,
    this.baseBackupId,
  });

  /// Get total size of all files
  Future<int> getTotalSize() async {
    int total = 0;

    if (databaseFile != null && await databaseFile!.exists()) {
      total += await databaseFile!.length();
    }

    for (final image in imageFiles) {
      if (await image.exists()) {
        total += await image.length();
      }
    }

    return total;
  }

  /// Check if this is an incremental backup
  bool get isIncremental => baseBackupId != null;

  @override
  String toString() =>
      'BackupData(database: ${databaseFile?.path ?? "N/A"}, '
      'images: ${imageFiles.length}, isIncremental: $isIncremental)';
}