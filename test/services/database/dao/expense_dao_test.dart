import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/dao/expense_dao.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ExpenseDAO Tests', () {
    late ExpenseDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = ExpenseDao.instance;
      connection = DatabaseConnection.instance;

      // Reset and initialize with in-memory database for isolation
      await connection.reset();
      await connection.initialize(':memory:');

      // Create expenses table for testing
      final db = await connection.database;
      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          date INTEGER NOT NULL,
          created_by INTEGER
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
      test('should insert an expense and return it with ID', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final expense = {
          'category': 'Supplies',
          'amount': 500.0,
          'date': now,
          'created_by': 1,
        };

        // Act
        final result = await dao.insert(expense);

        // Assert
        expect(result['id'], isNotNull);
        expect(result['id'], greaterThan(0));
        expect(result['category'], 'Supplies');
        expect(result['amount'], 500.0);
        expect(result['date'], now);
        expect(result['created_by'], 1);
      });

      test('should get all expenses ordered by date DESC', () async {
        // Arrange
        final now = DateTime.now();
        final timestamp1 = now.millisecondsSinceEpoch ~/ 1000;
        final timestamp2 = now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        final timestamp3 = now.add(Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000;

        await dao.insert({
          'category': 'Expense A',
          'amount': 100.0,
          'date': timestamp1,
        });
        await dao.insert({
          'category': 'Expense B',
          'amount': 200.0,
          'date': timestamp2,
        });
        await dao.insert({
          'category': 'Expense C',
          'amount': 300.0,
          'date': timestamp3,
        });

        // Act
        final expenses = await dao.getAll();

        // Assert
        expect(expenses.length, 3);
        expect(expenses[0]['date'], timestamp3); // Most recent first
        expect(expenses[1]['date'], timestamp2);
        expect(expenses[2]['date'], timestamp1);
      });

      test('should return empty list when no expenses', () async {
        // Act
        final expenses = await dao.getAll();

        // Assert
        expect(expenses, isEmpty);
      });

      test('should get expense by ID', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'category': 'Supplies',
          'amount': 500.0,
          'date': now,
          'created_by': 1,
        });
        final id = inserted['id'] as int;

        // Act
        final expense = await dao.getById(id);

        // Assert
        expect(expense, isNotNull);
        expect(expense?['id'], id);
        expect(expense?['category'], 'Supplies');
        expect(expense?['amount'], 500.0);
      });

      test('should return null when expense does not exist', () async {
        // Act
        final expense = await dao.getById(999);

        // Assert
        expect(expense, isNull);
      });

      test('should update expense', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'category': 'Supplies',
          'amount': 500.0,
          'date': now,
          'created_by': 1,
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.update(id, {
          'category': 'Updated Supplies',
          'amount': 750.0,
        });

        // Assert
        expect(affected, 1);

        final expense = await dao.getById(id);
        expect(expense, isNotNull);
        expect(expense?['category'], 'Updated Supplies');
        expect(expense?['amount'], 750.0);
      });

      test('should throw NotFoundException when updating non-existent expense',
          () async {
        // Act & Assert
        expect(
          () => dao.update(999, {'category': 'Updated'}),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });

      test('should delete expense', () async {
        // Arrange
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final inserted = await dao.insert({
          'category': 'Supplies',
          'amount': 500.0,
          'date': now,
          'created_by': 1,
        });
        final id = inserted['id'] as int;

        // Act
        final affected = await dao.delete(id);

        // Assert
        expect(affected, 1);

        final expense = await dao.getById(id);
        expect(expense, isNull);
      });

      test('should throw NotFoundException when deleting non-existent expense',
          () async {
        // Act & Assert
        expect(
          () => dao.delete(999),
          throwsA(isA<app_exceptions.NotFoundException>()),
        );
      });
    });

    group('Query Operations', () {
      test('should get expenses by date range', () async {
        // Arrange
        final now = DateTime.now();
        final day1 = now.millisecondsSinceEpoch ~/ 1000;
        final day2 = now.add(Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
        final day3 = now.add(Duration(days: 2)).millisecondsSinceEpoch ~/ 1000;

        await dao.insert({
          'category': 'Expense A',
          'amount': 100.0,
          'date': day1,
        });
        await dao.insert({
          'category': 'Expense B',
          'amount': 200.0,
          'date': day2,
        });
        await dao.insert({
          'category': 'Expense C',
          'amount': 300.0,
          'date': day3,
        });

        // Act - Get expenses for day1 and day2 only
        final expenses = await dao.getByDateRange(day1, day2);

        // Assert
        expect(expenses.length, 2);
      });

      test('should get expenses by category', () async {
        // Arrange
        final now = DateTime.now();
        await dao.insert({
          'category': 'Supplies',
          'amount': 500.0,
          'date': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'category': 'Rent',
          'amount': 1000.0,
          'date': now.millisecondsSinceEpoch ~/ 1000,
        });
        await dao.insert({
          'category': 'Supplies',
          'amount': 300.0,
          'date': now.millisecondsSinceEpoch ~/ 1000,
        });

        // Act
        final expenses = await dao.getByCategory('Supplies');

        // Assert
        expect(expenses.length, 2);
        expect(expenses.every((e) => e['category'] == 'Supplies'), isTrue);
      });

      test('should calculate total expenses in range', () async {
        // Arrange
        final now = DateTime.now();
        final start = now.millisecondsSinceEpoch ~/ 1000;
        final end = now.add(Duration(days: 2)).millisecondsSinceEpoch ~/ 1000;

        await dao.insert({
          'category': 'Expense A',
          'amount': 100.0,
          'date': start,
        });
        await dao.insert({
          'category': 'Expense B',
          'amount': 200.0,
          'date': start + 86400,
        });
        await dao.insert({
          'category': 'Expense C',
          'amount': 300.0,
          'date': end + 86400, // Outside range
        });

        // Act
        final total = await dao.getTotalInRange(start, end);

        // Assert
        expect(total, 300.0); // 100 + 200
      });

      test('should get total expenses by category in range', () async {
        // Arrange
        final now = DateTime.now();
        final start = now.millisecondsSinceEpoch ~/ 1000;
        final end = now.add(Duration(days: 2)).millisecondsSinceEpoch ~/ 1000;

        await dao.insert({
          'category': 'Supplies',
          'amount': 100.0,
          'date': start,
        });
        await dao.insert({
          'category': 'Supplies',
          'amount': 200.0,
          'date': start + 86400,
        });
        await dao.insert({
          'category': 'Rent',
          'amount': 500.0,
          'date': start,
        });

        // Act
        final totals = await dao.getTotalByCategory(start, end);

        // Assert
        expect(totals.length, 2);
        final suppliesTotal = totals.firstWhere((t) => t['category'] == 'Supplies');
        expect(suppliesTotal['total'], 300.0);
        expect(suppliesTotal['count'], 2);
      });
    });

    group('Utility Operations', () {
      test('should count all expenses', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 5; i++) {
          await dao.insert({
            'category': 'Expense $i',
            'amount': 100.0,
            'date': now.millisecondsSinceEpoch ~/ 1000 + (i * 86400),
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
        // Missing required fields should cause an error
        final expense = {
          'category': 'Supplies',
        };

        // Act & Assert - missing amount and date should cause an error
        expect(
          () => dao.insert(expense),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });
  });
}
