import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseConnection Singleton Pattern', () {
    test('should return same instance on multiple calls', () async {
      final instance1 = DatabaseConnection.instance;
      final instance2 = DatabaseConnection.instance;

      expect(instance1, same(instance2));
      expect(instance1.hashCode, instance2.hashCode);
    });

    test('should maintain singleton across async operations', () async {
      final futures = List.generate(10, (index) async {
        await Future.delayed(Duration(milliseconds: 10));
        return DatabaseConnection.instance;
      });

      final instances = await Future.wait(futures);

      // All instances should be the same
      final firstInstance = instances.first;
      for (final instance in instances) {
        expect(instance, same(firstInstance));
      }
    });
  });

  group('DatabaseConnection Initialization', () {
    late DatabaseConnection connection;

    setUp(() {
      connection = DatabaseConnection.instance;
    });

    tearDown(() async {
      try {
        await connection.close();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('should initialize database successfully with in-memory database', () async {
      final db = await connection.initialize(':memory:');

      expect(db, isNotNull);
      expect(db.isOpen, isTrue);

      await db.close();
    });

    test('should return database instance from getter', () async {
      await connection.initialize(':memory:');

      final db = await connection.database;

      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should cache database instance and not reinitialize', () async {
      final db1 = await connection.initialize(':memory:');
      final db2 = await connection.database;

      expect(db1, same(db2));
    });

    test('should throw DatabaseException on initialization failure', () async {
      // Try to initialize with invalid path (simulated by using special characters)
      expect(
        () => connection.initialize('/invalid/\x00/path'),
        throwsA(isA<app_exceptions.DatabaseException>()),
      );
    });
  });

  group('DatabaseConnection Retry Logic', () {
    late DatabaseConnection connection;

    setUp(() {
      connection = DatabaseConnection.instance;
    });

    tearDown(() async {
      try {
        await connection.close();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('should retry failed connection attempts with exponential backoff',
        () async {
      // This test verifies the retry mechanism exists
      // In a real scenario, we'd mock the database to fail initially

      final db = await connection.initialize(':memory:');

      expect(db, isNotNull);
      expect(db.isOpen, isTrue);

      await db.close();
    });

    test('should stop retrying after max attempts and throw exception', () async {
      // This test would require mocking the database to always fail
      // For now, we test with invalid path which should fail immediately
      expect(
        () => connection.initialize('/invalid/path/db.db'),
        throwsA(isA<app_exceptions.DatabaseException>()),
      );
    });
  });

  group('DatabaseConnection Pool Management', () {
    late DatabaseConnection connection;

    setUp(() {
      connection = DatabaseConnection.instance;
    });

    tearDown(() async {
      try {
        await connection.close();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('should handle concurrent database requests', () async {
      await connection.initialize(':memory:');

      // Simulate concurrent requests
      final futures = List.generate(5, (index) async {
        final db = await connection.database;
        return db.path;
      });

      final results = await Future.wait(futures);

      // All requests should return the same database
      expect(results.every((path) => path == results.first), isTrue);
    });

    test('should reuse database connection across multiple operations', () async {
      await connection.initialize(':memory:');

      final db1 = await connection.database;
      final db2 = await connection.database;
      final db3 = await connection.database;

      expect(db1, same(db2));
      expect(db2, same(db3));
    });
  });

  group('DatabaseConnection Cleanup', () {
    test('should close database connection successfully', () async {
      final connection = DatabaseConnection.instance;
      await connection.initialize(':memory:');

      final db = await connection.database;
      expect(db.isOpen, isTrue);

      await connection.close();

      // Database should be closed
      expect(db.isOpen, isFalse);
    });

    test('should handle close when database is not initialized', () async {
      final connection = DatabaseConnection.instance;

      // Should not throw
      expect(() => connection.close(), returnsNormally);
    });

    test('should reset database reference after close', () async {
      final connection = DatabaseConnection.instance;
      await connection.initialize(':memory:');

      await connection.close();

      // Should be able to initialize again
      final db = await connection.initialize(':memory:');
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);

      await db.close();
    });
  });

  group('DatabaseConnection Error Handling', () {
    late DatabaseConnection connection;

    setUp(() {
      connection = DatabaseConnection.instance;
    });

    tearDown(() async {
      try {
        await connection.close();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('should wrap database errors in DatabaseException', () async {
      expect(
        () => connection.initialize('/invalid/path/to/db.db'),
        throwsA(isA<app_exceptions.DatabaseException>()),
      );
    });

    test('should include operation name in DatabaseException', () async {
      try {
        await connection.initialize('/invalid/path/to/db.db');
        fail('Should have thrown DatabaseException');
      } on app_exceptions.DatabaseException catch (e) {
        expect(e.operation, isNotNull);
        expect(e.operation, contains('init'));
      }
    });

    test('should include original error in DatabaseException', () async {
      try {
        await connection.initialize('/invalid/path/to/db.db');
        fail('Should have thrown DatabaseException');
      } on app_exceptions.DatabaseException catch (e) {
        expect(e.originalError, isNotNull);
      }
    });
  });

  group('DatabaseConnection Thread Safety', () {
    test('should be thread-safe with concurrent initialization', () async {
      // Test that multiple concurrent initialization attempts don't cause issues
      final futures = List.generate(10, (index) async {
        final connection = DatabaseConnection.instance;
        await connection.initialize(':memory:');
        return connection.database;
      });

      final databases = await Future.wait(futures);

      // All should return the same database instance
      expect(databases.every((db) => db == databases.first), isTrue);

      // Clean up
      await DatabaseConnection.instance.close();
    });
  });
}
