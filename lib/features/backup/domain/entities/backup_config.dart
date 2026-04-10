import 'package:simple_pos/core/constants/backup_constants.dart';

/// Configuration for creating a backup
class BackupConfig {
  final BackupType type;
  final List<BackupDataType> dataTypes;
  final bool compress;
  final StorageLocation location;

  const BackupConfig({
    required this.type,
    required this.dataTypes,
    this.compress = true,
    required this.location,
  });

  /// Check if this config includes database backup
  bool get includesDatabase =>
      dataTypes.contains(BackupDataType.database) ||
      dataTypes.contains(BackupDataType.all);

  /// Check if this config includes images backup
  bool get includesImages =>
      dataTypes.contains(BackupDataType.images) ||
      dataTypes.contains(BackupDataType.all);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'dataTypes': dataTypes.map((e) => e.name).toList(),
      'compress': compress,
      'location': location.name,
    };
  }

  /// Create from JSON
  factory BackupConfig.fromJson(Map<String, dynamic> json) {
    return BackupConfig(
      type: BackupType.values.firstWhere((e) => e.name == json['type']),
      dataTypes: (json['dataTypes'] as List)
          .map((e) => BackupDataType.values.firstWhere((d) => d.name == e))
          .toList(),
      compress: json['compress'] as bool,
      location: StorageLocation.values.firstWhere((e) => e.name == json['location']),
    );
  }

  @override
  String toString() =>
      'BackupConfig(type: $type, dataTypes: ${dataTypes.map((e) => e.name).join(', ')}, '
      'compress: $compress, location: $location)';
}