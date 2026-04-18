import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/dao/supplier_dao.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SupplierDAO Tests', () {
    late SupplierDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = SupplierDao.instance;
      connection = DatabaseConnection.instance;

      // Reset and initialize with in-memory database for isolation
      await connection.reset();
      await connection.initialize(':memory:');

      // Create suppliers table for testing
      final db = await connection.database;
      await db.execute('''
        CREATE TABLE suppliers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          contact_person TEXT,
          phone TEXT,
          email TEXT,
          address TEXT,
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
      test('should insert a supplier and return it with ID', () async {
        // Arrange
        final now = DateTime.now();
        final supplier = {
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'phone': '123-456-7890',
          'email': 'john@acme.com',
          'address': '123 Main St',
          'created_at': now.toIso8601String(),
        };

        // Act
        final result = await dao.insert(supplier);

        // Assert
        expect(result['id'], isNotNull);
        expect(result['id'], greaterThan(0));
        expect(result['name'], 'Acme Corp');
        expect(result['contact_person'], 'John Doe');
        expect(result['phone'], '123-456-7890');
        expect(result['email'], 'john@acme.com');
        expect(result['address'], '123 Main St');
      });

      test('should get all suppliers ordered by name ASC', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Supplier B',
          'contact_person': 'Person B',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Supplier A',
          'contact_person': 'Person A',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Supplier C',
          'contact_person': 'Person C',
          'created_at': now.toIso8601String(),
        });

        // Act
        final suppliers = await dao.getAll();

        // Assert
        expect(suppliers.length, 3);
        expect(suppliers[0]['name'], 'Supplier A');
        expect(suppliers[1]['name'], 'Supplier B');
        expect(suppliers[2]['name'], 'Supplier C');
      });

      test('should return empty list when no suppliers', () async {
        // Act
        final suppliers = await dao.getAll();

        // Assert
        expect(suppliers, isEmpty);
      });

      test('should get supplier by ID', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'phone': '123-456-7890',
          'email': 'john@acme.com',
          'address': '123 Main St',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final supplier = await dao.getById(id);

        // Assert
        expect(supplier, isNotNull);
        expect(supplier?['id'], id);
        expect(supplier?['name'], 'Acme Corp');
        expect(supplier?['contact_person'], 'John Doe');
        expect(supplier?['phone'], '123-456-7890');
      });

      test('should return null when supplier does not exist', () async {
        // Act
        final supplier = await dao.getById(999);

        // Assert
        expect(supplier, isNull);
      });

      test('should update supplier', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'phone': '123-456-7890',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.update(id, {
          'name': 'Acme Corp Updated',
          'contact_person': 'Jane Doe',
          'phone': '987-654-3210',
          'email': 'jane@acme.com',
        });

        // Assert
        expect(affected, 1);

        final supplier = await dao.getById(id);
        expect(supplier, isNotNull);
        expect(supplier?['name'], 'Acme Corp Updated');
        expect(supplier?['contact_person'], 'Jane Doe');
        expect(supplier?['phone'], '987-654-3210');
        expect(supplier?['email'], 'jane@acme.com');
      });

      test('should throw NotFoundException when updating non-existent supplier',
          () async {
        // Act & Assert
        expect(
          () => dao.update(999, {'name': 'Updated'}),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });

      test('should delete supplier', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.delete(id);

        // Assert
        expect(affected, 1);

        final supplier = await dao.getById(id);
        expect(supplier, isNull);
      });

      test('should throw NotFoundException when deleting non-existent supplier',
          () async {
        // Act & Assert
        expect(
          () => dao.delete(999),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });
    });

    group('Query Operations', () {
      test('should search suppliers by name', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Beta Corp',
          'contact_person': 'Jane Doe',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Acme Industries',
          'contact_person': 'Bob Smith',
          'created_at': now.toIso8601String(),
        });

        // Act
        final results = await dao.search('Acme');

        // Assert
        expect(results.length, 2);
        expect(
          results.any((s) => s['name'] == 'Acme Corp'),
          isTrue,
        );
        expect(
          results.any((s) => s['name'] == 'Acme Industries'),
          isTrue,
        );
      });

      test('should search suppliers by contact person', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Supplier A',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Supplier B',
          'contact_person': 'Jane Smith',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Supplier C',
          'contact_person': 'John Smith',
          'created_at': now.toIso8601String(),
        });

        // Act
        final results = await dao.search('John');

        // Assert
        expect(results.length, 2);
        expect(
          results.any((s) => s['contact_person'] == 'John Doe'),
          isTrue,
        );
        expect(
          results.any((s) => s['contact_person'] == 'John Smith'),
          isTrue,
        );
      });

      test('should return empty list for search with no matches', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });

        // Act
        final results = await dao.search('NonExistent');

        // Assert
        expect(results, isEmpty);
      });

      test('should check if supplier name exists', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });

        // Act
        final exists = await dao.nameExists('Acme Corp');

        // Assert
        expect(exists, isTrue);
      });

      test('should return false when supplier name does not exist', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });

        // Act
        final exists = await dao.nameExists('Beta Corp');

        // Assert
        expect(exists, isFalse);
      });

      test('should exclude supplier when checking name existence with excludeId',
          () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act
        final exists = await dao.nameExists('Acme Corp', excludeId: id);

        // Assert
        expect(exists, isFalse); // Should not find itself
      });
    });

    group('Utility Operations', () {
      test('should count all suppliers', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 5; i++) {
          await dao.insert({
            'name': 'Supplier $i',
            'contact_person': 'Person $i',
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
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });

        // Act & Assert
        expect(
          () => dao.insert({
            'name': 'Acme Corp',
            'contact_person': 'Jane Doe',
            'created_at': now.toIso8601String(),
          }),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });

      test('should throw DatabaseException on update error', () async {
        // Arrange
        final now = DateTime.now();
        final inserted = await dao.insert({
          'name': 'Acme Corp',
          'contact_person': 'John Doe',
          'created_at': now.toIso8601String(),
        });
        await dao.insert({
          'name': 'Beta Corp',
          'contact_person': 'Jane Doe',
          'created_at': now.toIso8601String(),
        });
        final id = inserted['id'] as int;

        // Act & Assert - try to update to duplicate name
        expect(
          () => dao.update(id, {'name': 'Beta Corp'}),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });
  });
}
