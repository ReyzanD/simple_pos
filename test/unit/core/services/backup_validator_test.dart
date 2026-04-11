import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/services/backup_validator.dart';
import 'dart:io';

void main() {
  group('BackupValidator', () {
    late BackupValidator validator;

    setUp(() {
      validator = BackupValidator(
        currentDatabaseVersion: 2,
        currentAppVersion: '1.0.0',
      );
    });

    group('validateBackup', () {
      test('should return valid result for good backup file', () async {
        // Create a temporary test file
        final tempFile = File('/tmp/test_backup.zip');
        await tempFile.writeAsString('test backup data');

        final result = await validator.validateBackup(
          backupFile: tempFile,
        );

        // Clean up
        await tempFile.delete();

        expect(result.isValid, true);
        expect(result.error, isNull);
      });

      test('should return invalid result for non-existent file', () async {
        final nonExistentFile = File('/tmp/non_existent_backup.zip');

        final result = await validator.validateBackup(
          backupFile: nonExistentFile,
        );

        expect(result.isValid, false);
        expect(result.error, isNotNull);
        expect(result.error, contains('tidak ditemukan'));
      });

      test('should return invalid result for empty file', () async {
        final emptyFile = File('/tmp/empty_backup.zip');
        await emptyFile.create();

        final result = await validator.validateBackup(
          backupFile: emptyFile,
        );

        // Clean up
        await emptyFile.delete();

        expect(result.isValid, false);
        expect(result.error, contains('kosong'));
      });

      test('should accept metadata parameter when provided', () async {
        final tempFile = File('/tmp/test_backup_with_metadata.zip');
        await tempFile.writeAsString('test backup data');

        final metadata = {
          'databaseVersion': 2,
          'appVersion': '1.0.0',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final result = await validator.validateBackup(
          backupFile: tempFile,
          metadata: metadata,
        );

        // Clean up
        await tempFile.delete();

        expect(result, isNotNull);
      });

      test('should handle metadata with database version', () async {
        final tempFile = File('/tmp/test_backup_metadata_version.zip');
        await tempFile.writeAsString('test backup data');

        final metadata = {
          'databaseVersion': 1, // Different from current (2)
          'appVersion': '1.0.0',
        };

        final result = await validator.validateBackup(
          backupFile: tempFile,
          metadata: metadata,
        );

        // Clean up
        await tempFile.delete();

        expect(result, isNotNull);
        expect(result.warnings, isNotEmpty);
      });

      test('should validate checksums when provided', () async {
        final tempFile = File('/tmp/test_backup_checksums.zip');
        await tempFile.writeAsString('test backup data');

        final expectedChecksums = {
          'database': 'abc123',
          'images': 'def456',
        };

        final result = await validator.validateBackup(
          backupFile: tempFile,
          expectedChecksums: expectedChecksums,
        );

        // Clean up
        await tempFile.delete();

        expect(result.isValid, true);
        expect(result.checksums, isNotNull);
      });
    });

    group('ValidationResult', () {
      test('should provide useful string representation', () {
        final result = ValidationResult(
          isValid: true,
          warnings: ['warning1', 'warning2'],
        );

        final string = result.toString();

        expect(string, contains('true'));
        expect(string, contains('2'));
      });

      test('should include error in string when invalid', () {
        final result = ValidationResult(
          isValid: false,
          error: 'Test error',
        );

        final string = result.toString();

        expect(string, contains('false'));
        expect(string, contains('Test error'));
      });
    });

    group('Edge Cases', () {
      test('should handle very large backup files', () async {
        // This would be tested with actual large files in integration tests
        final tempFile = File('/tmp/large_backup.zip');
        await tempFile.writeAsString('x' * 1000); // Simulated large file

        final result = await validator.validateBackup(
          backupFile: tempFile,
        );

        // Clean up
        await tempFile.delete();

        expect(result.isValid, true);
      });

      test('should handle missing optional metadata', () async {
        final tempFile = File('/tmp/test_backup_no_metadata.zip');
        await tempFile.writeAsString('test backup data');

        final result = await validator.validateBackup(
          backupFile: tempFile,
        );

        // Clean up
        await tempFile.delete();

        expect(result.isValid, true);
        expect(result.databaseVersion, isNull);
        expect(result.appVersion, isNull);
      });
    });
  });
}
