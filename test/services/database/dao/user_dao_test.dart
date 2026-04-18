import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/dao/user_dao.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('UserDAO Tests', () {
    late UserDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = UserDao.instance;
      connection = DatabaseConnection.instance;

      // Reset and initialize with in-memory database for isolation
      await connection.reset();
      await connection.initialize(':memory:');

      // Create users table for testing
      final db = await connection.database;
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          full_name TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'cashier',
          is_active INTEGER DEFAULT 1,
          created_at INTEGER NOT NULL,
          last_login INTEGER
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
      test('should insert a user and return it with ID', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final user = {
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        };

        // Act
        final result = await dao.insert(user);

        // Assert
        expect(result['id'], isNotNull);
        expect(result['id'], greaterThan(0));
        expect(result['username'], 'johndoe');
        expect(result['full_name'], 'John Doe');
        expect(result['role'], 'cashier');
        expect(result['is_active'], 1);
        expect(result['password_hash'], isNull); // Password hash excluded from result
      });

      test('should get all users ordered by full_name ASC', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'username': 'userb',
          'password_hash': 'hash1',
          'full_name': 'User B',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'usera',
          'password_hash': 'hash2',
          'full_name': 'User A',
          'role': 'admin',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'userc',
          'password_hash': 'hash3',
          'full_name': 'User C',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });

        // Act
        final users = await dao.getAll();

        // Assert
        expect(users.length, 3);
        expect(users[0]['full_name'], 'User A');
        expect(users[1]['full_name'], 'User B');
        expect(users[2]['full_name'], 'User C');
        expect(users.every((u) => u['password_hash'] == null), isTrue); // No password hashes
      });

      test('should return empty list when no users', () async {
        // Act
        final users = await dao.getAll();

        // Assert
        expect(users, isEmpty);
      });

      test('should get user by ID', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });
        final id = inserted['id'] as int;

        // Act
        final user = await dao.getById(id);

        // Assert
        expect(user, isNotNull);
        expect(user?['id'], id);
        expect(user?['username'], 'johndoe');
        expect(user?['full_name'], 'John Doe');
        expect(user?['password_hash'], isNull); // Password hash excluded
      });

      test('should return null when user does not exist', () async {
        // Act
        final user = await dao.getById(999);

        // Assert
        expect(user, isNull);
      });

      test('should update user', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.update(id, {
          'full_name': 'John Updated',
          'role': 'admin',
          'is_active': 0,
        });

        // Assert
        expect(affected, 1);

        final user = await dao.getById(id);
        expect(user, isNotNull);
        expect(user?['full_name'], 'John Updated');
        expect(user?['role'], 'admin');
        expect(user?['is_active'], 0);
      });

      test('should throw NotFoundException when updating non-existent user',
          () async {
        // Act & Assert
        expect(
          () => dao.update(999, {'full_name': 'Updated'}),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });

      test('should delete user', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.delete(id);

        // Assert
        expect(affected, 1);

        final user = await dao.getById(id);
        expect(user, isNull);
      });

      test('should throw NotFoundException when deleting non-existent user',
          () async {
        // Act & Assert
        expect(
          () => dao.delete(999),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });
    });

    group('Query Operations', () {
      test('should get user by username', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });

        // Act
        final user = await dao.getByUsername('johndoe');

        // Assert
        expect(user, isNotNull);
        expect(user?['username'], 'johndoe');
        expect(user?['full_name'], 'John Doe');
        expect(user?['password_hash'], isNull); // Password hash excluded
      });

      test('should return null when username does not exist', () async {
        // Act
        final user = await dao.getByUsername('nonexistent');

        // Assert
        expect(user, isNull);
      });

      test('should get users by role', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'username': 'user1',
          'password_hash': 'hash1',
          'full_name': 'User One',
          'role': 'admin',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'user2',
          'password_hash': 'hash2',
          'full_name': 'User Two',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'user3',
          'password_hash': 'hash3',
          'full_name': 'User Three',
          'role': 'admin',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });

        // Act
        final admins = await dao.getByRole('admin');

        // Assert
        expect(admins.length, 2);
        expect(admins.every((u) => u['role'] == 'admin'), isTrue);
      });

      test('should get active users only', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'username': 'user1',
          'password_hash': 'hash1',
          'full_name': 'User One',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'user2',
          'password_hash': 'hash2',
          'full_name': 'User Two',
          'role': 'cashier',
          'is_active': 0,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'user3',
          'password_hash': 'hash3',
          'full_name': 'User Three',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });

        // Act
        final activeUsers = await dao.getActiveUsers();

        // Assert
        expect(activeUsers.length, 2);
        expect(activeUsers.every((u) => u['is_active'] == 1), isTrue);
      });

      test('should check if username exists', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });

        // Act
        final exists = await dao.usernameExists('johndoe');

        // Assert
        expect(exists, isTrue);
      });

      test('should return false when username does not exist', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });

        // Act
        final exists = await dao.usernameExists('janedoe');

        // Assert
        expect(exists, isFalse);
      });

      test('should exclude user when checking username existence with excludeId',
          () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });
        final id = inserted['id'] as int;

        // Act
        final exists = await dao.usernameExists('johndoe', excludeId: id);

        // Assert
        expect(exists, isFalse); // Should not find itself
      });

      test('should authenticate user with correct credentials', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final passwordHash = 'hash123';
        await dao.insert({
          'username': 'johndoe',
          'password_hash': passwordHash,
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });

        // Act
        final user = await dao.authenticate('johndoe', passwordHash);

        // Assert
        expect(user, isNotNull);
        expect(user?['username'], 'johndoe');
        expect(user?['full_name'], 'John Doe');
        expect(user?['password_hash'], isNull); // Password hash excluded from result
        expect(user?['last_login'], isNotNull); // Should be updated
      });

      test('should return null when authentication fails', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });

        // Act - wrong password
        final user = await dao.authenticate('johndoe', 'wronghash');

        // Assert
        expect(user, isNull);
      });

      test('should update last login timestamp', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });
        final id = inserted['id'] as int;

        // Act
        await Future.delayed(Duration(milliseconds: 1500)); // Wait for timestamp to advance (1.5s to ensure seconds change)
        final affected = await dao.updateLastLogin(id);

        // Assert
        expect(affected, 1);

        final user = await dao.getById(id);
        expect(user, isNotNull);
        expect(user?['last_login'], isNotNull);
        expect(user?['last_login'], greaterThan(now));
      });
    });

    group('Utility Operations', () {
      test('should count all users', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 5; i++) {
          await dao.insert({
            'username': 'user$i',
            'password_hash': 'hash$i',
            'full_name': 'User $i',
            'role': 'cashier',
            'is_active': 1,
            'created_at': now.millisecondsSinceEpoch ~/ 1000,
          });
        }

        // Act
        final count = await dao.count();

        // Assert
        expect(count, 5);
      });

      test('should count active users', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'username': 'user1',
          'password_hash': 'hash1',
          'full_name': 'User One',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'user2',
          'password_hash': 'hash2',
          'full_name': 'User Two',
          'role': 'cashier',
          'is_active': 0,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'username': 'user3',
          'password_hash': 'hash3',
          'full_name': 'User Three',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
        });

        // Act
        final count = await dao.countActive();

        // Assert
        expect(count, 2);
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
        // Duplicate username should fail
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await dao.insert({
          'username': 'johndoe',
          'password_hash': 'hash123',
          'full_name': 'John Doe',
          'role': 'cashier',
          'is_active': 1,
          'created_at': now,
        });

        // Act & Assert
        expect(
          () => dao.insert({
            'username': 'johndoe',
            'password_hash': 'hash456',
            'full_name': 'Jane Doe',
            'role': 'cashier',
            'is_active': 1,
            'created_at': now,
          }),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });
  });
}
