import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_data.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' hide DatabaseException;

/// Result of backup validation
class ValidationResult {
  final bool isValid;
  final String? error;
  final List<String> warnings;
  final Map<String, String>? checksums;
  final int? databaseVersion;
  final String? appVersion;

  ValidationResult({
    required this.isValid,
    this.error,
    this.warnings = const [],
    this.checksums,
    this.databaseVersion,
    this.appVersion,
  });

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, error: $error, warnings: ${warnings.length})';
}

/// Service for validating backup integrity and compatibility
class BackupValidator {
  final int _currentDatabaseVersion;
  final String _currentAppVersion;

  BackupValidator({
    required int currentDatabaseVersion,
    required String currentAppVersion,
  })  : _currentDatabaseVersion = currentDatabaseVersion,
        _currentAppVersion = currentAppVersion;

  /// Validate backup file integrity and compatibility
  /// Returns ValidationResult with detailed information
  Future<ValidationResult> validateBackup({
    required File backupFile,
    Map<String, dynamic>? metadata,
    Map<String, String>? expectedChecksums,
  }) async {
    try {
      AppLogger.info('Starting backup validation', tag: 'BackupValidator');

      final warnings = <String>[];
      final checksums = <String, String>{};

      // 1. Check if backup file exists
      if (!await backupFile.exists()) {
        return ValidationResult(
          isValid: false,
          error: 'File backup tidak ditemukan',
          warnings: warnings,
        );
      }

      // 2. Check file size
      final fileSize = await backupFile.length();
      if (fileSize == 0) {
        return ValidationResult(
          isValid: false,
          error: 'File backup kosong',
          warnings: warnings,
        );
      }

      AppLogger.info(
        'Backup file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB',
        tag: 'BackupValidator',
      );

      // 3. Validate metadata if provided
      if (metadata != null) {
        final metadataValidation = _validateMetadata(metadata);
        if (!metadataValidation.isValid) {
          return metadataValidation;
        }
        warnings.addAll(metadataValidation.warnings);
      }

      // 4. Validate database schema compatibility
      if (metadata != null && metadata.containsKey('databaseVersion')) {
        final dbVersion = metadata['databaseVersion'] as int?;
        if (dbVersion != null) {
          final schemaValidation = await _validateDatabaseSchema(dbVersion);
          if (!schemaValidation.isValid) {
            return schemaValidation;
          }
          warnings.addAll(schemaValidation.warnings);
        }
      }

      // 5. Validate file checksums if provided
      if (expectedChecksums != null) {
        final checksumValidation = await _validateChecksums(
          backupFile,
          expectedChecksums,
        );
        if (!checksumValidation.isValid) {
          return checksumValidation;
        }
        checksums.addAll(checksumValidation.checksums!);
      }

      // 6. Check if backup is too large
      const maxBackupSizeBytes = 500 * 1024 * 1024; // 500MB
      if (fileSize > maxBackupSizeBytes) {
        warnings.add(
          'Ukuran backup sangat besar: ${(fileSize / (1024 * 1024)).toStringAsFixed(0)} MB',
        );
      }

      AppLogger.info('Backup validation completed successfully', tag: 'BackupValidator');

      return ValidationResult(
        isValid: true,
        error: null,
        warnings: warnings,
        checksums: checksums.isNotEmpty ? checksums : null,
        databaseVersion: metadata?['databaseVersion'] as int?,
        appVersion: metadata?['appVersion'] as String?,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to validate backup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupValidator',
      );
      throw DatabaseException(
        'Gagal memvalidasi backup',
        operation: 'validate backup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validate backup data structure
  Future<ValidationResult> validateBackupData(BackupData data) async {
    try {
      AppLogger.info('Validating backup data structure', tag: 'BackupValidator');

      final warnings = <String>[];
      final checksums = <String, String>{};

      // 1. Validate database file
      if (data.databaseFile != null) {
        final dbValidation = await _validateDatabaseFile(data.databaseFile!);
        if (!dbValidation.isValid) {
          return dbValidation;
        }
        warnings.addAll(dbValidation.warnings);

        // Calculate database checksum
        if (await data.databaseFile!.exists()) {
          final dbChecksum = await _calculateFileChecksum(data.databaseFile!);
          checksums['database'] = dbChecksum;
        }
      } else {
        warnings.add('Backup tidak mengandung database');
      }

      // 2. Validate image files
      if (data.imageFiles.isNotEmpty) {
        AppLogger.info(
          'Validating ${data.imageFiles.length} image files',
          tag: 'BackupValidator',
        );

        int validImages = 0;
        for (final image in data.imageFiles) {
          if (await image.exists()) {
            final imageSize = await image.length();
            if (imageSize > 0) {
              validImages++;
              // Calculate image checksum
              final imageChecksum = await _calculateFileChecksum(image);
              checksums[path.basename(image.path)] = imageChecksum;
            }
          }
        }

        if (validImages < data.imageFiles.length) {
          warnings.add(
            'Beberapa gambar tidak valid atau hilang: ${data.imageFiles.length - validImages} dari ${data.imageFiles.length}',
          );
        }
      } else {
        warnings.add('Backup tidak mengandung gambar');
      }

      // 3. Validate preferences
      if (data.preferences != null && data.preferences!.isEmpty) {
        warnings.add('Backup preferences kosong');
      }

      // 4. Validate settings
      if (data.settings != null && data.settings!.isEmpty) {
        warnings.add('Backup settings kosong');
      }

      // 5. Validate incremental backup data
      if (data.isIncremental) {
        if (data.databaseChanges == null || data.databaseChanges!.isEmpty) {
          return ValidationResult(
            isValid: false,
            error: 'Backup incremental tidak mengandung perubahan data',
            warnings: warnings,
          );
        }
      }

      AppLogger.info('Backup data validation completed', tag: 'BackupValidator');

      return ValidationResult(
        isValid: true,
        error: null,
        warnings: warnings,
        checksums: checksums.isNotEmpty ? checksums : null,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to validate backup data',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupValidator',
      );
      throw DatabaseException(
        'Gagal memvalidasi data backup',
        operation: 'validate backup data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validate metadata structure and version compatibility
  ValidationResult _validateMetadata(Map<String, dynamic> metadata) {
    final warnings = <String>[];

    // Check required fields
    if (!metadata.containsKey('id')) {
      return ValidationResult(
        isValid: false,
        error: 'Metadata tidak mengandung ID',
        warnings: warnings,
      );
    }

    if (!metadata.containsKey('type')) {
      return ValidationResult(
        isValid: false,
        error: 'Metadata tidak mengandung tipe backup',
        warnings: warnings,
      );
    }

    if (!metadata.containsKey('createdAt')) {
      return ValidationResult(
        isValid: false,
        error: 'Metadata tidak mengandung tanggal pembuatan',
        warnings: warnings,
      );
    }

    // Check version compatibility
    if (metadata.containsKey('appVersion')) {
      final backupAppVersion = metadata['appVersion'] as String?;
      if (backupAppVersion != null) {
        final versionComparison = _compareVersions(
          _currentAppVersion,
          backupAppVersion,
        );
        if (versionComparison < 0) {
          warnings.add(
            'Backup dibuat dengan versi aplikasi yang lebih baru: $backupAppVersion (saat ini: $_currentAppVersion)',
          );
        }
      }
    }

    if (metadata.containsKey('databaseVersion')) {
      final backupDbVersion = metadata['databaseVersion'] as int?;
      if (backupDbVersion != null && backupDbVersion > _currentDatabaseVersion) {
        return ValidationResult(
          isValid: false,
          error: 'Backup memerlukan versi database yang lebih baru: $backupDbVersion (saat ini: $_currentDatabaseVersion)',
          warnings: warnings,
        );
      }
    }

    return ValidationResult(
      isValid: true,
      error: null,
      warnings: warnings,
    );
  }

  /// Validate database schema compatibility
  Future<ValidationResult> _validateDatabaseSchema(int backupDbVersion) async {
    final warnings = <String>[];

    // Check if backup version is too old
    const minSupportedVersion = 1;
    if (backupDbVersion < minSupportedVersion) {
      return ValidationResult(
        isValid: false,
        error: 'Versi database backup terlalu tua: $backupDbVersion (minimum: $minSupportedVersion)',
        warnings: warnings,
      );
    }

    // Check if backup version is newer than current
    if (backupDbVersion > _currentDatabaseVersion) {
      return ValidationResult(
        isValid: false,
        error: 'Versi database backup terlalu baru: $backupDbVersion (saat ini: $_currentDatabaseVersion)',
        warnings: warnings,
      );
    }

    // Warn if backup is from older version (might need migration)
    if (backupDbVersion < _currentDatabaseVersion) {
      warnings.add(
        'Backup dari versi database yang lebih lama: $backupDbVersion (saat ini: $_currentDatabaseVersion). '
        'Migrasi diperlukan saat restore.',
      );
    }

    return ValidationResult(
      isValid: true,
      error: null,
      warnings: warnings,
    );
  }

  /// Validate database file
  Future<ValidationResult> _validateDatabaseFile(File dbFile) async {
    final warnings = <String>[];

    if (!await dbFile.exists()) {
      return ValidationResult(
        isValid: false,
        error: 'File database tidak ditemukan',
        warnings: warnings,
      );
    }

    final fileSize = await dbFile.length();
    if (fileSize == 0) {
      return ValidationResult(
        isValid: false,
        error: 'File database kosong',
        warnings: warnings,
      );
    }

    // Try to open database to validate structure
    try {
      final db = await openDatabase(dbFile.path);

      // Check if tables exist
      final tables = [
        'categories',
        'suppliers',
        'products',
        'transactions',
        'transaction_items',
        'payments',
      ];

      for (final table in tables) {
        try {
          final result = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            [table],
          );
          if (result.isEmpty) {
            warnings.add('Tabel "$table" tidak ditemukan dalam database backup');
          }
        } catch (e) {
          AppLogger.error(
            'Failed to check table $table',
            error: e,
            tag: 'BackupValidator',
          );
        }
      }

      await db.close();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to open backup database',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupValidator',
      );
      return ValidationResult(
        isValid: false,
        error: 'File database tidak valid atau rusak',
        warnings: warnings,
      );
    }

    return ValidationResult(
      isValid: true,
      error: null,
      warnings: warnings,
    );
  }

  /// Validate file checksums
  Future<ValidationResult> _validateChecksums(
    File backupFile,
    Map<String, String> expectedChecksums,
  ) async {
    final warnings = <String>[];
    final checksums = <String, String>{};

    // Calculate actual checksum
    final actualChecksum = await _calculateFileChecksum(backupFile);
    checksums['backup'] = actualChecksum;

    // Compare with expected checksum
    if (expectedChecksums.containsKey('backup')) {
      final expectedChecksum = expectedChecksums['backup']!;
      if (actualChecksum != expectedChecksum) {
        return ValidationResult(
          isValid: false,
          error: 'Checksum backup tidak cocok. File mungkin rusak.',
          warnings: warnings,
          checksums: checksums,
        );
      }
    }

    return ValidationResult(
      isValid: true,
      error: null,
      warnings: warnings,
      checksums: checksums,
    );
  }

  /// Calculate SHA256 checksum of a file
  Future<String> _calculateFileChecksum(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compare version strings (e.g., "1.0.0" vs "1.2.3")
  /// Returns: -1 if version1 < version2, 0 if equal, 1 if version1 > version2
  int _compareVersions(String version1, String version2) {
    final parts1 = version1.split('.').map(int.parse).toList();
    final parts2 = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }

  /// Check if backup can be restored on current app version
  bool canRestoreBackup({
    required String backupAppVersion,
    required int backupDatabaseVersion,
  }) {
    // Check database version
    if (backupDatabaseVersion > _currentDatabaseVersion) {
      return false;
    }

    // Check app version (allow restore from same or older versions)
    final versionComparison = _compareVersions(
      _currentAppVersion,
      backupAppVersion,
    );

    // Allow restore if backup is from same or older version
    return versionComparison >= 0;
  }

  /// Get migration path from backup version to current version
  List<int> getMigrationPath(int fromVersion) {
    final migrations = <int>[];

    for (int v = fromVersion; v < _currentDatabaseVersion; v++) {
      migrations.add(v + 1);
    }

    return migrations;
  }
}
