import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_config.dart';

void main() {
  group('BackupConfig', () {
    late BackupConfig config;

    setUp(() {
      config = BackupConfig(
        type: BackupType.full,
        dataTypes: [BackupDataType.all],
        compress: true,
        location: StorageLocation.local,
      );
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = config.toJson();

        expect(json['type'], 'full');
        expect(json['dataTypes'], ['all']);
        expect(json['compress'], true);
        expect(json['location'], 'local');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'type': 'incremental',
          'dataTypes': ['database', 'images'],
          'compress': false,
          'location': 'drive',
        };

        final deserialized = BackupConfig.fromJson(json);

        expect(deserialized.type, BackupType.incremental);
        expect(deserialized.dataTypes, [BackupDataType.database, BackupDataType.images]);
        expect(deserialized.compress, false);
        expect(deserialized.location, StorageLocation.drive);
      });

      test('should handle serialization round-trip', () {
        final json = config.toJson();
        final roundTrip = BackupConfig.fromJson(json);

        expect(roundTrip.type, config.type);
        expect(roundTrip.dataTypes, config.dataTypes);
        expect(roundTrip.compress, config.compress);
        expect(roundTrip.location, config.location);
      });
    });

    group('includesDatabase getter', () {
      test('should return true when dataTypes contains all', () {
        final allConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.all],
          compress: true,
          location: StorageLocation.local,
        );

        expect(allConfig.includesDatabase, true);
      });

      test('should return true when dataTypes contains database', () {
        final dbConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          compress: true,
          location: StorageLocation.local,
        );

        expect(dbConfig.includesDatabase, true);
      });

      test('should return true when dataTypes contains database and images', () {
        final mixedConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database, BackupDataType.images],
          compress: true,
          location: StorageLocation.local,
        );

        expect(mixedConfig.includesDatabase, true);
      });

      test('should return false when dataTypes only contains images', () {
        final imagesConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.images],
          compress: true,
          location: StorageLocation.local,
        );

        expect(imagesConfig.includesDatabase, false);
      });
    });

    group('includesImages getter', () {
      test('should return true when dataTypes contains all', () {
        final allConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.all],
          compress: true,
          location: StorageLocation.local,
        );

        expect(allConfig.includesImages, true);
      });

      test('should return true when dataTypes contains images', () {
        final imagesConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.images],
          compress: true,
          location: StorageLocation.local,
        );

        expect(imagesConfig.includesImages, true);
      });

      test('should return true when dataTypes contains database and images', () {
        final mixedConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database, BackupDataType.images],
          compress: true,
          location: StorageLocation.local,
        );

        expect(mixedConfig.includesImages, true);
      });

      test('should return false when dataTypes only contains database', () {
        final dbConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          compress: true,
          location: StorageLocation.local,
        );

        expect(dbConfig.includesImages, false);
      });
    });

    group('toString', () {
      test('should provide useful string representation', () {
        final string = config.toString();

        expect(string, contains('BackupType.full'));
        expect(string, contains('all'));
        expect(string, contains('true')); // compress
        expect(string, contains('StorageLocation.local'));
      });

      test('should include all data types in string', () {
        final multiConfig = BackupConfig(
          type: BackupType.incremental,
          dataTypes: [BackupDataType.database, BackupDataType.images],
          compress: false,
          location: StorageLocation.drive,
        );

        final string = multiConfig.toString();

        expect(string, contains('BackupType.incremental'));
        expect(string, contains('database'));
        expect(string, contains('images'));
        expect(string, contains('false')); // compress
        expect(string, contains('StorageLocation.drive'));
      });
    });

    group('Default Values', () {
      test('should use default compress value of true', () {
        final configWithoutCompress = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.all],
          location: StorageLocation.local,
        );

        expect(configWithoutCompress.compress, true);
      });

      test('should handle empty data types list', () {
        final emptyConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [],
          compress: true,
          location: StorageLocation.local,
        );

        expect(emptyConfig.includesDatabase, false);
        expect(emptyConfig.includesImages, false);
      });
    });

    group('Configuration Combinations', () {
      test('should handle full backup with all data types to local', () {
        final fullLocalConfig = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.all],
          compress: true,
          location: StorageLocation.local,
        );

        expect(fullLocalConfig.type, BackupType.full);
        expect(fullLocalConfig.includesDatabase, true);
        expect(fullLocalConfig.includesImages, true);
        expect(fullLocalConfig.compress, true);
        expect(fullLocalConfig.location, StorageLocation.local);
      });

      test('should handle incremental backup with database only to drive', () {
        final incrementalDriveConfig = BackupConfig(
          type: BackupType.incremental,
          dataTypes: [BackupDataType.database],
          compress: false,
          location: StorageLocation.drive,
        );

        expect(incrementalDriveConfig.type, BackupType.incremental);
        expect(incrementalDriveConfig.includesDatabase, true);
        expect(incrementalDriveConfig.includesImages, false);
        expect(incrementalDriveConfig.compress, false);
        expect(incrementalDriveConfig.location, StorageLocation.drive);
      });
    });
  });
}
