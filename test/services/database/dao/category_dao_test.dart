import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/dao/category_dao.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CategoryDAO Tests', () {
    late CategoryDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = CategoryDao.instance;
      connection = DatabaseConnection.instance;

      // Reset and initialize with in-memory database for isolation
      await connection.reset();
      await connection.initialize(':memory:');

      // Create categories table for testing
      final db = await connection.database;
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          description TEXT,
          discount_percentage REAL DEFAULT 0,
          created_at TEXT NOT NULL
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
      test('should insert a category and return it with ID', () async {
        // Arrange
        final now = DateTime.now();
        final category = {
          'name': 'Electronics',
          'description': 'Electronic devices',
          'discount_percentage': 10.0,
          'created_at': now.toIso8601String(),
        };

        // Act
        final result = await dao.insert(category);

        // Assert
        expect(result['id'], isNotNull);
        expect(result['id'], greaterThan(0));
        expect(result['name'], 'Electronics');
        expect(result['description'], 'Electronic devices');
        expect(result['discount_percentage'], 10.0);
      });

      test('should get all categories ordered by name ASC', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Category B',
          'description': 'Second category',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Category A',
          'description': 'First category',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Category C',
          'description': 'Third category',
          'created_at': now.toIso8601String(),
        });

        // Act
        final categories = await dao.getAll();

        // Assert
        expect(categories.length, 3);
        expect(categories[0]['name'], 'Category A');
        expect(categories[1]['name'], 'Category B');
        expect(categories[2]['name'], 'Category C');
      });

      test('should return empty list when no categories', () async {
        // Act
        final categories = await dao.getAll();

        // Assert
        expect(categories, isEmpty);
      });

      test('should get category by ID', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'discount_percentage': 5.0,
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final category = await dao.getById(id);

        // Assert
        expect(category, isNotNull);
        expect(category?['id'], id);
        expect(category?['name'], 'Electronics');
        expect(category?['description'], 'Electronic devices');
        expect(category?['discount_percentage'], 5.0);
      });

      test('should return null when category does not exist', () async {
        // Act
        final category = await dao.getById(999);

        // Assert
        expect(category, isNull);
      });

      test('should update category', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'discount_percentage': 5.0,
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.update(id, {
          'name': 'Electronics Updated',
          'description': 'Updated description',
          'discount_percentage': 15.0,
        });

        // Assert
        expect(affected, 1);

        final category = await dao.getById(id);
        expect(category, isNotNull);
        expect(category?['name'], 'Electronics Updated');
        expect(category?['description'], 'Updated description');
        expect(category?['discount_percentage'], 15.0);
      });

      test('should throw NotFoundException when updating non-existent category',
          () async {
        // Act & Assert
        expect(
          () => dao.update(999, {'name': 'Updated'}),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });

      test('should delete category', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.delete(id);

        // Assert
        expect(affected, 1);

        final category = await dao.getById(id);
        expect(category, isNull);
      });

      test('should throw NotFoundException when deleting non-existent category',
          () async {
        // Act & Assert
        expect(
          () => dao.delete(999),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });
    });

    group('Query Operations', () {
      test('should search categories by name', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Food',
          'description': 'Food items',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Electronics Accessories',
          'description': 'Accessories',
          'created_at': now.toIso8601String(),
        });

        // Act
        final results = await dao.search('Electron');

        // Assert
        expect(results.length, 2);
        expect(
          results.any((c) => c['name'] == 'Electronics'),
          isTrue,
        );
        expect(
          results.any((c) => c['name'] == 'Electronics Accessories'),
          isTrue,
        );
      });

      test('should search categories by description', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Cat A',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Cat B',
          'description': 'Food items',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Cat C',
          'description': 'Electronic accessories',
          'created_at': now.toIso8601String(),
        });

        // Act
        final results = await dao.search('electronic');

        // Assert
        expect(results.length, 2);
        expect(
          results.any((c) => c['description'] == 'Electronic devices'),
          isTrue,
        );
        expect(
          results.any((c) => c['description'] == 'Electronic accessories'),
          isTrue,
        );
      });

      test('should return empty list for search with no matches', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });

        // Act
        final results = await dao.search('NonExistent');

        // Assert
        expect(results, isEmpty);
      });

      test('should check if category name exists', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });

        // Act
        final exists = await dao.nameExists('Electronics');

        // Assert
        expect(exists, isTrue);
      });

      test('should return false when category name does not exist', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });

        // Act
        final exists = await dao.nameExists('Food');

        // Assert
        expect(exists, isFalse);
      });

      test('should exclude category when checking name existence with excludeId',
          () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final exists = await dao.nameExists('Electronics', excludeId: id);

        // Assert
        expect(exists, isFalse); // Should not find itself
      });
    });

    group('Utility Operations', () {
      test('should count all categories', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 5; i++) {
          await dao.insert({
            'name': 'Category $i',
            'description': 'Description $i',
            'created_at': now.toIso8601String(),
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
        // Arrange - duplicate name should fail
        final now = DateTime.now();
        await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });

        // Act & Assert
        expect(
          () => dao.insert({
            'name': 'Electronics',
            'description': 'Duplicate name',
            'created_at': now.toIso8601String(),
          }),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });

      test('should throw DatabaseException on update error', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Electronics',
          'description': 'Electronic devices',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Food',
          'description': 'Food items',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act & Assert - try to update to duplicate name
        expect(
          () => dao.update(id, {'name': 'Food'}),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });
  });
}
