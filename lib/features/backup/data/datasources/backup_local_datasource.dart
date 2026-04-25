import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
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
    final backupDir = Directory(
      '${appDir.path}/${BackupConstants.backupDirName}',
    );

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
      AppLogger.info(
        'Created backup root directory',
        tag: 'BackupLocalDataSource',
      );
    }

    return backupDir;
  }

  /// Get the full backup directory
  Future<Directory> get _fullBackupDir async {
    final root = await _backupRootDir;
    final fullDir = Directory(
      '${root.path}/${BackupConstants.fullBackupDirName}',
    );

    if (!await fullDir.exists()) {
      await fullDir.create(recursive: true);
      AppLogger.info(
        'Created full backup directory',
        tag: 'BackupLocalDataSource',
      );
    }

    return fullDir;
  }

  /// Get the incremental backup directory
  Future<Directory> get _incrementalBackupDir async {
    final root = await _backupRootDir;
    final incDir = Directory(
      '${root.path}/${BackupConstants.incrementalBackupDirName}',
    );

    if (!await incDir.exists()) {
      await incDir.create(recursive: true);
      AppLogger.info(
        'Created incremental backup directory',
        tag: 'BackupLocalDataSource',
      );
    }

    return incDir;
  }

  /// Get the temp backup directory
  /// Used for temporary files during backup creation/extraction
  Future<Directory> get tempBackupDir async {
    final root = await _backupRootDir;
    final tempDir = Directory(
      '${root.path}/${BackupConstants.tempBackupDirName}',
    );

    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
      AppLogger.info(
        'Created temp backup directory',
        tag: 'BackupLocalDataSource',
      );
    }

    return tempDir;
  }

  /// Get backup directory based on type
  Future<Directory> _getBackupDir(BackupType type) async {
    return type == BackupType.full
        ? await _fullBackupDir
        : await _incrementalBackupDir;
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

      AppLogger.info(
        'Backup saved successfully at $filePath',
        tag: 'BackupLocalDataSource',
      );
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
      AppLogger.info(
        'Backup loaded successfully',
        tag: 'BackupLocalDataSource',
      );
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
      backups.addAll(
        await _listBackupsInDirectory(incDir, BackupType.incremental),
      );

      AppLogger.info(
        'Found ${backups.length} local backups',
        tag: 'BackupLocalDataSource',
      );
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
      AppLogger.info(
        'Deleting backup: $backupId',
        tag: 'BackupLocalDataSource',
      );

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
        AppLogger.info(
          'Backup deleted successfully',
          tag: 'BackupLocalDataSource',
        );
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
      final metadata = await _searchMetadataInDirectory(
        fullDir,
        backupId,
        BackupType.full,
      );
      if (metadata != null) return metadata;

      // Search in incremental backups
      final incDir = await _incrementalBackupDir;
      return await _searchMetadataInDirectory(
        incDir,
        backupId,
        BackupType.incremental,
      );
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
  Future<BackupMetadata?> getMetadataFromFile(
    String filePath,
    BackupType type,
  ) async {
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
      final metadataMap =
          <String, dynamic>{}; // Placeholder until proper JSON parsing

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
      AppLogger.info(
        'Getting available storage space',
        tag: 'BackupLocalDataSource',
      );
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
      final fullBackups =
          backups.where((b) => b.type == BackupType.full).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final incrementalBackups =
          backups.where((b) => b.type == BackupType.incremental).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Delete excess full backups
      if (fullBackups.length > BackupConstants.maxLocalFullBackups) {
        final toDelete = fullBackups.skip(BackupConstants.maxLocalFullBackups);
        for (final backup in toDelete) {
          await deleteBackup(backup.id);
        }
      }

      // Delete excess incremental backups
      if (incrementalBackups.length >
          BackupConstants.maxLocalIncrementalBackups) {
        final toDelete = incrementalBackups.skip(
          BackupConstants.maxLocalIncrementalBackups,
        );
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
  /// Compresses database, images, metadata, and manifest into a ZIP archive
  Future<String> createZipBackup(BackupData data, String outputPath) async {
    try {
      AppLogger.info('Creating ZIP backup', tag: 'BackupLocalDataSource');

      // Create archive
      final archive = Archive();

      // Add database file if present
      if (data.databaseFile != null && await data.databaseFile!.exists()) {
        final dbBytes = await data.databaseFile!.readAsBytes();
        final dbFile = ArchiveFile(
          'database/simple_pos.db',
          dbBytes.length,
          dbBytes,
        );
        archive.addFile(dbFile);

        // Calculate checksum for database
        final dbDigest = sha256.convert(dbBytes);
        AppLogger.database(
          'Database checksum: ${dbDigest.toString()}',
          details: 'BackupLocalDataSource',
        );
      }

      // Add image files
      for (final imageFile in data.imageFiles) {
        if (await imageFile.exists()) {
          final imageBytes = await imageFile.readAsBytes();
          final fileName = imageFile.path.split('/').last;
          final imageFileInArchive = ArchiveFile(
            'images/$fileName',
            imageBytes.length,
            imageBytes,
          );
          archive.addFile(imageFileInArchive);
        }
      }

      // Create and add metadata.json
      final metadata = {
        'createdAt': DateTime.now().toIso8601String(),
        'databaseVersion': 2,
        'appVersion': '1.0.0',
        'compressionLevel': BackupConstants.compressionLevel,
        'hasDatabase': data.databaseFile != null,
        'imageCount': data.imageFiles.length,
        'isIncremental': data.isIncremental,
        'baseBackupId': data.baseBackupId,
      };
      final metadataJson = metadata.toString();
      final metadataBytes = metadataJson.codeUnits;
      final metadataFile = ArchiveFile(
        'metadata.json',
        metadataBytes.length,
        metadataBytes,
      );
      archive.addFile(metadataFile);

      // Create and add manifest.json with file checksums
      final manifest = <String, dynamic>{
        'version': '1.0',
        'files': <String, String>{},
      };

      // Add database checksum
      if (data.databaseFile != null && await data.databaseFile!.exists()) {
        final dbBytes = await data.databaseFile!.readAsBytes();
        final dbDigest = sha256.convert(dbBytes);
        manifest['files']['database/simple_pos.db'] = dbDigest.toString();
      }

      // Add image checksums
      for (final imageFile in data.imageFiles) {
        if (await imageFile.exists()) {
          final imageBytes = await imageFile.readAsBytes();
          final imageDigest = sha256.convert(imageBytes);
          final fileName = 'images/${imageFile.path.split('/').last}';
          manifest['files'][fileName] = imageDigest.toString();
        }
      }

      final manifestJson = manifest.toString();
      final manifestBytes = manifestJson.codeUnits;
      final manifestFile = ArchiveFile(
        'manifest.json',
        manifestBytes.length,
        manifestBytes,
      );
      archive.addFile(manifestFile);

      // Encode and compress the archive
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);
      if (zipBytes == null) {
        throw DatabaseException(
          'Gagal membuat kompresi ZIP',
          operation: 'createZipBackup',
        );
      }

      // Write ZIP file
      final zipFile = File(outputPath);
      await zipFile.writeAsBytes(zipBytes);

      // Verify file was created
      if (!await zipFile.exists()) {
        throw DatabaseException(
          'File ZIP tidak berhasil dibuat',
          operation: 'createZipBackup',
        );
      }

      final fileSize = await zipFile.length();
      AppLogger.info(
        'ZIP backup created successfully: ${outputPath.split('/').last} (${fileSize} bytes)',
        tag: 'BackupLocalDataSource',
      );

      return outputPath;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create ZIP backup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      throw DatabaseException(
        'Gagal membuat file ZIP backup',
        operation: 'createZipBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Extract a ZIP backup file
  /// Extracts ZIP and returns BackupData with database and images
  Future<BackupData> extractZipBackup(String zipPath) async {
    try {
      AppLogger.info(
        'Extracting ZIP backup: $zipPath',
        tag: 'BackupLocalDataSource',
      );

      // Read ZIP file
      final zipFile = File(zipPath);
      if (!await zipFile.exists()) {
        throw NotFoundException(
          'File backup tidak ditemukan',
          resourceType: 'Backup',
          resourceId: zipPath,
        );
      }

      final zipBytes = await zipFile.readAsBytes();

      // Decode ZIP archive
      final archive = ZipDecoder().decodeBytes(zipBytes);

      // Verify manifest if present
      Map<String, dynamic>? manifest;
      ArchiveFile? manifestFile;
      for (final file in archive) {
        if (file.name == 'manifest.json') {
          manifestFile = file;
          break;
        }
      }

      if (manifestFile != null) {
        final manifestBytes = manifestFile.content as List<int>;
        final manifestJson = String.fromCharCodes(manifestBytes);
        manifest = _parseJsonSafely(manifestJson);

        if (manifest != null) {
          AppLogger.database(
            'Manifest found, will verify file integrity',
            details: 'BackupLocalDataSource',
          );
        }
      }

      // Get temp directory for extraction
      final tempDir = await tempBackupDir;

      // Extract files
      File? databaseFile;
      final List<File> imageFiles = [];
      final Map<String, String> actualChecksums = {};

      for (final file in archive) {
        final filePath = '${tempDir.path}/${file.name}';

        if (file.isFile) {
          // Create directory structure
          final outputFile = File(filePath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);

          // Calculate checksum for verification
          final fileBytes = file.content as List<int>;
          final digest = sha256.convert(fileBytes);
          actualChecksums[file.name] = digest.toString();

          // Track database file
          if (file.name == 'database/simple_pos.db') {
            databaseFile = outputFile;
          }

          // Track image files
          if (file.name.startsWith('images/')) {
            imageFiles.add(outputFile);
          }
        }
      }

      // Verify checksums if manifest is present
      if (manifest != null && manifest['files'] != null) {
        final expectedChecksums = manifest['files'] as Map<String, dynamic>;
        bool verificationFailed = false;

        for (final entry in expectedChecksums.entries) {
          final fileName = entry.key;
          final expectedChecksum = entry.value as String;
          final actualChecksum = actualChecksums[fileName];

          if (actualChecksum == null) {
            AppLogger.warning('File missing from archive: $fileName');
            verificationFailed = true;
          } else if (actualChecksum != expectedChecksum) {
            AppLogger.error(
              'Checksum mismatch for $fileName',
              error: Exception(
                'Expected: $expectedChecksum, Got: $actualChecksum',
              ),
            );
            verificationFailed = true;
          }
        }

        if (verificationFailed) {
          throw ValidationException(
            'File integrity verification failed. Backup may be corrupted.',
          );
        }

        AppLogger.info('All file checksums verified successfully');
      }

      // Read metadata if present
      Map<String, dynamic>? metadata;
      ArchiveFile? metadataFile;
      for (final file in archive) {
        if (file.name == 'metadata.json') {
          metadataFile = file;
          break;
        }
      }

      if (metadataFile != null) {
        final metadataBytes = metadataFile.content as List<int>;
        final metadataJson = String.fromCharCodes(metadataBytes);
        metadata = _parseJsonSafely(metadataJson);
      }

      AppLogger.info(
        'ZIP backup extracted successfully (database: ${databaseFile != null}, images: ${imageFiles.length})',
        tag: 'BackupLocalDataSource',
      );

      return BackupData(
        databaseFile: databaseFile,
        imageFiles: imageFiles,
        baseBackupId: metadata?['baseBackupId'] as String?,
      );
    } on NotFoundException catch (_) {
      rethrow;
    } on ValidationException catch (_) {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to extract ZIP backup',
        error: e,
        stackTrace: stackTrace,
        tag: 'BackupLocalDataSource',
      );
      throw DatabaseException(
        'Gagal mengekstrak file ZIP backup',
        operation: 'extractZipBackup',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Parse JSON safely, returning null on failure
  Map<String, dynamic>? _parseJsonSafely(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
      return parsed;
    } catch (e) {
      AppLogger.warning('Failed to parse JSON safely: $e');
      return null;
    }
  }
}
