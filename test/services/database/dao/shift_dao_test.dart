import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/dao/shift_dao.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ShiftDAO Tests', () {
    late ShiftDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = ShiftDao.instance;
      connection = DatabaseConnection.instance;

      // Reset and initialize with in-memory database for isolation
      await connection.reset();
      await connection.initialize(':memory:');

      // Create shifts table for testing
      final db = await connection.database;
      await db.execute('''
        CREATE TABLE shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_name TEXT NOT NULL,
          opening_balance REAL DEFAULT 0,
          opened_at INTEGER NOT NULL,
          closed_at INTEGER
        )
      ''');
    });

    tearDown(() async {
      try {
        await connection.reset();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    group('CRUD Operations', () {
      test('should insert a shift and return it with ID', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final shift = {
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': now,
          'closed_at': null,
        };

        // Act
        final result = await dao.insert(shift);

        // Assert
        expect(result['id'], isNotNull);
        expect(result['id'], greaterThan(0));
        expect(result['user_name'], 'John Doe');
        expect(result['opening_balance'], 1000.0);
        expect(result['opened_at'], now);
        expect(result['closed_at'], isNull);
      });

      test('should get all shifts ordered by opened_at DESC', () async {
        // Arrange
        final now = DateTime.now();
        final timestamp1 = now.millisecondsSinceEpoch ~/ 1000;
        final timestamp2 = now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        final timestamp3 = now.add(Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000;

        await dao.insert({
          'user_name': 'User A',
          'opening_balance': 500.0,
          'opened_at': timestamp1,
          'closed_at': null,
        });
        await dao.insert({
          'user_name': 'User B',
          'opening_balance': 750.0,
          'opened_at': timestamp2,
          'closed_at': null,
        });
        await dao.insert({
          'user_name': 'User C',
          'opening_balance': 1000.0,
          'opened_at': timestamp3,
          'closed_at': null,
        });

        // Act
        final shifts = await dao.getAll();

        // Assert
        expect(shifts.length, 3);
        expect(shifts[0]['opened_at'], timestamp3); // Most recent first
        expect(shifts[1]['opened_at'], timestamp2);
        expect(shifts[2]['opened_at'], timestamp1);
      });

      test('should return empty list when no shifts', () async {
        // Act
        final shifts = await dao.getAll();

        // Assert
        expect(shifts, isEmpty);
      });

      test('should get shift by ID', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': now,
          'closed_at': null,
        });
        final id = inserted['id'] as int;

        // Act
        final shift = await dao.getById(id);

        // Assert
        expect(shift, isNotNull);
        expect(shift?['id'], id);
        expect(shift?['user_name'], 'John Doe');
        expect(shift?['opening_balance'], 1000.0);
      });

      test('should return null when shift does not exist', () async {
        // Act
        final shift = await dao.getById(999);

        // Assert
        expect(shift, isNull);
      });

      test('should update shift', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': now,
          'closed_at': null,
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.update(id, {
          'user_name': 'Jane Doe',
          'opening_balance': 1500.0,
        });

        // Assert
        expect(affected, 1);

        final shift = await dao.getById(id);
        expect(shift, isNotNull);
        expect(shift?['user_name'], 'Jane Doe');
        expect(shift?['opening_balance'], 1500.0);
      });

      test('should throw NotFoundException when updating non-existent shift',
          () async {
        // Act & Assert
        expect(
          () => dao.update(999, {'user_name': 'Updated'}),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });

      test('should delete shift', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': now,
          'closed_at': null,
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.delete(id);

        // Assert
        expect(affected, 1);

        final shift = await dao.getById(id);
        expect(shift, isNull);
      });

      test('should throw NotFoundException when deleting non-existent shift',
          () async {
        // Act & Assert
        expect(
          () => dao.delete(999),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });
    });

    group('Query Operations', () {
      test('should get shifts by user name', () async {
        // Arrange
        final now = DateTime.now();
        final timestamp1 = now.millisecondsSinceEpoch ~/ 1000;
        final timestamp2 = now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;

        await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': timestamp1,
          'closed_at': null,
        });
        await dao.insert({
          'user_name': 'Jane Smith',
          'opening_balance': 500.0,
          'opened_at': timestamp2,
          'closed_at': null,
        });
        await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1500.0,
          'opened_at': timestamp2 + 3600,
          'closed_at': null,
        });

        // Act
        final shifts = await dao.getByUserName('John Doe');

        // Assert
        expect(shifts.length, 2);
        expect(shifts.every((s) => s['user_name'] == 'John Doe'), isTrue);
      });

      test('should get open shift for user', () async {
        // Arrange
        final now = DateTime.now();
        final timestamp1 = now.millisecondsSinceEpoch ~/ 1000;
        final timestamp2 = now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;

        // Insert closed shift
        await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': timestamp1,
          'closed_at': timestamp1 + 7200,
        });

        // Insert open shift
        final inserted = await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1500.0,
          'opened_at': timestamp2,
          'closed_at': null,
        });
        final id = inserted['id'] as int;

        // Act
        final shift = await dao.getOpenShift('John Doe');

        // Assert
        expect(shift, isNotNull);
        expect(shift?['id'], id);
        expect(shift?['user_name'], 'John Doe');
        expect(shift?['closed_at'], isNull);
      });

      test('should return null when no open shift for user', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': now,
          'closed_at': now + 7200,
        });

        // Act
        final shift = await dao.getOpenShift('John Doe');

        // Assert
        expect(shift, isNull);
      });

      test('should close shift', () async {
        // Arrange
        final now = DateTime.now();
        final openedAt = now.millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
          'opened_at': openedAt,
          'closed_at': null,
        });
        final id = inserted['id'] as int;
        final closedAt = now.add(Duration(hours: 8)).millisecondsSinceEpoch ~/ 1000;

        // Act
        final affected = await dao.closeShift(id, closedAt);

        // Assert
        expect(affected, 1);

        final shift = await dao.getById(id);
        expect(shift, isNotNull);
        expect(shift?['closed_at'], closedAt);
      });
    });

    group('Utility Operations', () {
      test('should count all shifts', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 5; i++) {
          await dao.insert({
            'user_name': 'User $i',
            'opening_balance': 1000.0,
            'opened_at': now.millisecondsSinceEpoch ~/ 1000 + (i * 3600),
            'closed_at': null,
          });
        }

        // Act
        final count = await dao.count();

        // Assert
        expect(count, 5);
      });

      test('should return 0 when counting empty table', () async {
        // Act
        final count = await dao.count();

        // Assert
        expect(count, 0);
      });
    });

    group('Error Handling', () {
      test('should throw DatabaseException on insert error', () async {
        // This would fail if we had constraints, but shifts table has no NOT NULL constraints
        // other than user_name and opened_at, so we'll test with invalid data structure
        final shift = {
          'user_name': 'John Doe',
          'opening_balance': 1000.0,
        };

        // Act & Assert - missing opened_at should cause an error
        expect(
          () => dao.insert(shift),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });
  });
}
