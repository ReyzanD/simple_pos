import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_metadata.dart';

void main() {
  group('BackupMetadata', () {
    late BackupMetadata metadata;

    setUp(() {
      metadata = BackupMetadata(
        id: 'backup_123',
        type: BackupType.full,
        createdAt: DateTime(2026, 4, 11, 10, 30),
        size: 1024 * 1024 * 5, // 5 MB
        location: StorageLocation.local,
        isValid: true,
        databaseVersion: 2,
        appVersion: '1.0.0',
      );
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = metadata.toJson();

        expect(json['id'], 'backup_123');
        expect(json['type'], 'full');
        expect(json['createdAt'], '2026-04-11T10:30:00.000');
        expect(json['size'], 1024 * 1024 * 5);
        expect(json['location'], 'local');
        expect(json['isValid'], true);
        expect(json['databaseVersion'], 2);
        expect(json['appVersion'], '1.0.0');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'backup_456',
          'type': 'incremental',
          'createdAt': '2026-04-11T14:20:00.000',
          'size': 1024 * 512, // 512 KB
          'location': 'drive',
          'isValid': true,
          'baseBackupId': 'backup_123',
          'driveFileId': 'file_789',
          'databaseVersion': 2,
          'appVersion': '1.0.0',
        };

        final deserialized = BackupMetadata.fromJson(json);

        expect(deserialized.id, 'backup_456');
        expect(deserialized.type, BackupType.incremental);
        expect(deserialized.createdAt, DateTime(2026, 4, 11, 14, 20));
        expect(deserialized.size, 1024 * 512);
        expect(deserialized.location, StorageLocation.drive);
        expect(deserialized.isValid, true);
        expect(deserialized.baseBackupId, 'backup_123');
        expect(deserialized.driveFileId, 'file_789');
        expect(deserialized.databaseVersion, 2);
        expect(deserialized.appVersion, '1.0.0');
      });

      test('should handle serialization round-trip', () {
        final json = metadata.toJson();
        final roundTrip = BackupMetadata.fromJson(json);

        expect(roundTrip.id, metadata.id);
        expect(roundTrip.type, metadata.type);
        expect(roundTrip.createdAt, metadata.createdAt);
        expect(roundTrip.size, metadata.size);
        expect(roundTrip.location, metadata.location);
        expect(roundTrip.isValid, metadata.isValid);
        expect(roundTrip.databaseVersion, metadata.databaseVersion);
        expect(roundTrip.appVersion, metadata.appVersion);
      });
    });

    group('Getters', () {
      test('isLocal should return true for local location', () {
        final localBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 1000,
          location: StorageLocation.local,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(localBackup.isLocal, true);
        expect(localBackup.isOnDrive, false);
      });

      test('isLocal should return true for both location', () {
        final bothBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 1000,
          location: StorageLocation.both,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(bothBackup.isLocal, true);
        expect(bothBackup.isOnDrive, true);
      });

      test('isOnDrive should return true for drive location', () {
        final driveBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 1000,
          location: StorageLocation.drive,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(driveBackup.isLocal, false);
        expect(driveBackup.isOnDrive, true);
      });
    });

    group('Size Formatting', () {
      test('should format bytes correctly', () {
        final byteBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 512,
          location: StorageLocation.local,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(byteBackup.sizeFormatted, '512 B');
      });

      test('should format kilobytes correctly', () {
        final kbBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 1024 * 5, // 5 KB
          location: StorageLocation.local,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(kbBackup.sizeFormatted, '5.0 KB');
      });

      test('should format megabytes correctly', () {
        final mbBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 1024 * 1024 * 10, // 10 MB
          location: StorageLocation.local,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(mbBackup.sizeFormatted, '10.0 MB');
      });

      test('should format gigabytes correctly', () {
        final gbBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 1024 * 1024 * 1024 * 2, // 2 GB
          location: StorageLocation.local,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(gbBackup.sizeFormatted, '2.0 GB');
      });

      test('should handle fractional sizes', () {
        final fractionalBackup = BackupMetadata(
          id: '1',
          type: BackupType.full,
          createdAt: DateTime.now(),
          size: 1024 * 1024 * 1.5.toInt(), // 1.5 MB
          location: StorageLocation.local,
          isValid: true,
          databaseVersion: 2,
          appVersion: '1.0.0',
        );

        expect(fractionalBackup.sizeFormatted, contains('MB'));
      });
    });

    group('toString', () {
      test('should provide useful string representation', () {
        final string = metadata.toString();

        expect(string, contains('backup_123'));
        expect(string, contains('BackupType.full'));
        expect(string, contains('2026-04-11'));
        expect(string, contains('${1024 * 1024 * 5}'));
      });
    });
  });
}
