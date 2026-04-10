import 'package:simple_pos/core/constants/backup_constants.dart';

/// Represents metadata for a backup file
class BackupMetadata {
  final String id;
  final BackupType type;
  final DateTime createdAt;
  final int size;
  final StorageLocation location;
  final bool isValid;
  final String? baseBackupId;
  final String? driveFileId;
  final int databaseVersion;
  final String appVersion;

  const BackupMetadata({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.size,
    required this.location,
    required this.isValid,
    this.baseBackupId,
    this.driveFileId,
    required this.databaseVersion,
    required this.appVersion,
  });

  /// Calculate if backup is stored locally
  bool get isLocal =>
    location == StorageLocation.local || location == StorageLocation.both;

  /// Calculate if backup is stored on Drive
  bool get isOnDrive =>
    location == StorageLocation.drive || location == StorageLocation.both;

  /// Get file size in human-readable format
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'size': size,
      'location': location.name,
      'isValid': isValid,
      'baseBackupId': baseBackupId,
      'driveFileId': driveFileId,
      'databaseVersion': databaseVersion,
      'appVersion': appVersion,
    };
  }

  /// Create from JSON
  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      id: json['id'] as String,
      type: BackupType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      size: json['size'] as int,
      location: StorageLocation.values.firstWhere((e) => e.name == json['location']),
      isValid: json['isValid'] as bool,
      baseBackupId: json['baseBackupId'] as String?,
      driveFileId: json['driveFileId'] as String?,
      databaseVersion: json['databaseVersion'] as int,
      appVersion: json['appVersion'] as String,
    );
  }

  @override
  String toString() =>
      'BackupMetadata(id: $id, type: $type, created: $createdAt, size: $size)';
}