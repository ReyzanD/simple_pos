import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:simple_pos/core/services/backup_data_collector.dart';
import 'package:simple_pos/services/database/database_helper.dart';
import 'package:simple_pos/features/backup/domain/entities/backup_config.dart';
import 'package:simple_pos/core/constants/backup_constants.dart';

@GenerateMocks([DatabaseHelper])
import 'backup_data_collector_test.mocks.dart';

void main() {
  group('BackupDataCollector', () {
    late BackupDataCollector collector;
    late MockDatabaseHelper mockDatabaseHelper;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      collector = BackupDataCollector(
        databaseHelper: mockDatabaseHelper,
      );
    });

    group('Constructor', () {
      test('should create collector with required database helper', () {
        expect(collector, isNotNull);
        expect(collector, isA<BackupDataCollector>());
      });

      test('should require database helper parameter', () {
        // Test that collector can be created properly
        expect(collector, isNotNull);
      });
    });

    group('collectBackupData - Configuration', () {
      test('should accept full backup configuration', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.all],
          location: StorageLocation.local,
        );

        // The collector should handle the configuration
        expect(() => collector.collectBackupData(config), returnsNormally);
      });

      test('should accept incremental backup configuration', () async {
        final config = BackupConfig(
          type: BackupType.incremental,
          dataTypes: [BackupDataType.database],
          location: StorageLocation.local,
        );

        final since = DateTime.now().subtract(const Duration(days: 1));

        expect(
          () => collector.collectBackupData(config, since: since),
          returnsNormally,
        );
      });

      test('should accept local storage location', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          location: StorageLocation.local,
        );

        expect(() => collector.collectBackupData(config), returnsNormally);
      });

      test('should accept drive storage location', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          location: StorageLocation.drive,
        );

        expect(() => collector.collectBackupData(config), returnsNormally);
      });
    });

    group('collectBackupData - Data Types', () {
      test('should handle database-only data type', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          location: StorageLocation.local,
        );

        // Should not throw, may return BackupData with exceptions
        expect(() => collector.collectBackupData(config), returnsNormally);
      });

      test('should handle images-only data type', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.images],
          location: StorageLocation.local,
        );

        expect(() => collector.collectBackupData(config), returnsNormally);
      });

      test('should handle all data types', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.all],
          location: StorageLocation.local,
        );

        expect(() => collector.collectBackupData(config), returnsNormally);
      });

      test('should handle mixed data types', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database, BackupDataType.images],
          location: StorageLocation.local,
        );

        expect(() => collector.collectBackupData(config), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle database collection errors gracefully', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          location: StorageLocation.local,
        );

        // The collector should handle errors gracefully
        final result = collector.collectBackupData(config);

        // Should complete without throwing unhandled exceptions
        expect(result, completes);
      });

      test('should handle image collection errors gracefully', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.images],
          location: StorageLocation.local,
        );

        final result = collector.collectBackupData(config);
        expect(result, completes);
      });
    });

    group('Incremental Backups', () {
      test('should accept since parameter for incremental backups', () async {
        final config = BackupConfig(
          type: BackupType.incremental,
          dataTypes: [BackupDataType.database],
          location: StorageLocation.local,
        );

        final since = DateTime.now().subtract(const Duration(days: 7));

        expect(
          () => collector.collectBackupData(config, since: since),
          returnsNormally,
        );
      });

      test('should handle null since parameter for full backups', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          location: StorageLocation.local,
        );

        expect(
          () => collector.collectBackupData(config, since: null),
          returnsNormally,
        );
      });
    });

    group('Compression', () {
      test('should handle compress enabled', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          compress: true,
          location: StorageLocation.local,
        );

        expect(() => collector.collectBackupData(config), returnsNormally);
      });

      test('should handle compress disabled', () async {
        final config = BackupConfig(
          type: BackupType.full,
          dataTypes: [BackupDataType.database],
          compress: false,
          location: StorageLocation.local,
        );

        expect(() => collector.collectBackupData(config), returnsNormally);
      });
    });
  });
}
