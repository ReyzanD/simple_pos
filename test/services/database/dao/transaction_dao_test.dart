import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/dao/transaction_dao.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TransactionDAO Tests', () {
    late TransactionDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = TransactionDao.instance;
      connection = DatabaseConnection.instance;

      // Reset and initialize with in-memory database for isolation
      await connection.reset();
      await connection.initialize(':memory:');

      // Create tables for testing
      final db = await connection.database;

      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          stock INTEGER NOT NULL,
          cost_price REAL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaction_date TEXT NOT NULL,
          subtotal REAL NOT NULL,
          tax REAL DEFAULT 0,
          discount REAL DEFAULT 0,
          total_amount REAL NOT NULL,
          payment_method TEXT NOT NULL,
          payment_status TEXT DEFAULT 'completed',
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE transaction_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaction_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          subtotal REAL NOT NULL,
          cost_price REAL DEFAULT 0,
          FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaction_id INTEGER NOT NULL,
          payment_method TEXT NOT NULL,
          amount REAL NOT NULL,
          cash_received REAL,
          card_last_4_digits TEXT,
          payment_date TEXT NOT NULL,
          FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
        )
      ''');

      // Insert test product
      await db.insert('products', {
        'name': 'Test Product',
        'price': 50.0,
        'stock': 100,
        'cost_price': 30.0,
      });
    });

    tearDown(() async {
      try {
        await connection.reset();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    group('createFullTransaction', () {
      test('should create transaction with items and payment', () async {
        // Arrange
        final now = DateTime.now();
        final txnMap = {
          'transaction_date': now.toIso8601String(),
          'subtotal': 100.0,
          'tax': 10.0,
          'discount': 5.0,
          'total_amount': 105.0,
          'payment_method': 'cash',
          'payment_status': 'completed',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final itemMaps = [
          {
            'product_id': 1,
            'product_name': 'Test Product',
            'quantity': 2,
            'unit_price': 50.0,
            'subtotal': 100.0,
            'cost_price': 30.0,
          },
        ];

        final paymentMap = {
          'payment_method': 'cash',
          'amount': 105.0,
          'cash_received': 110.0,
          'payment_date': now.toIso8601String(),
        };

        // Act
        final txId = await dao.createFullTransaction(
          txnMap: txnMap,
          itemMaps: itemMaps,
          paymentMap: paymentMap,
        );

        // Assert
        expect(txId, isNotNull);
        expect(txId, greaterThan(0));

        // Verify transaction was created
        final transactions = await (await connection.database).query('transactions');
        expect(transactions.length, 1);
        expect(transactions.first['id'], txId);
        expect(transactions.first['total_amount'], 105.0);

        // Verify items were created
        final items = await (await connection.database).query('transaction_items');
        expect(items.length, 1);
        expect(items.first['transaction_id'], txId);
        expect(items.first['quantity'], 2);

        // Verify payment was created
        final payments = await (await connection.database).query('payments');
        expect(payments.length, 1);
        expect(payments.first['transaction_id'], txId);
        expect(payments.first['amount'], 105.0);

        // Verify stock was updated
        final products = await (await connection.database).query('products');
        expect(products.first['stock'], 98); // 100 - 2
      });

      test('should create transaction without payment', () async {
        // Arrange
        final now = DateTime.now();
        final txnMap = {
          'transaction_date': now.toIso8601String(),
          'subtotal': 50.0,
          'tax': 5.0,
          'discount': 0.0,
          'total_amount': 55.0,
          'payment_method': 'card',
          'payment_status': 'completed',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final itemMaps = [
          {
            'product_id': 1,
            'product_name': 'Test Product',
            'quantity': 1,
            'unit_price': 50.0,
            'subtotal': 50.0,
            'cost_price': 30.0,
          },
        ];

        // Act
        await dao.createFullTransaction(
          txnMap: txnMap,
          itemMaps: itemMaps,
          paymentMap: null,
        );

        // Assert
        final payments = await (await connection.database).query('payments');
        expect(payments.length, 0);
      });

      test('should create transaction with multiple items', () async {
        // Arrange
        final now = DateTime.now();
        final txnMap = {
          'transaction_date': now.toIso8601String(),
          'subtotal': 150.0,
          'tax': 15.0,
          'discount': 0.0,
          'total_amount': 165.0,
          'payment_method': 'cash',
          'payment_status': 'completed',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final itemMaps = [
          {
            'product_id': 1,
            'product_name': 'Test Product',
            'quantity': 1,
            'unit_price': 50.0,
            'subtotal': 50.0,
            'cost_price': 30.0,
          },
          {
            'product_id': 1,
            'product_name': 'Test Product',
            'quantity': 2,
            'unit_price': 50.0,
            'subtotal': 100.0,
            'cost_price': 30.0,
          },
        ];

        // Act
        final txId = await dao.createFullTransaction(
          txnMap: txnMap,
          itemMaps: itemMaps,
          paymentMap: null,
        );

        // Assert
        final items = await (await connection.database).query('transaction_items');
        expect(items.length, 2);
        expect(items.where((i) => i['transaction_id'] == txId).length, 2);

        // Verify stock was updated correctly (100 - 1 - 2 = 97)
        final products = await (await connection.database).query('products');
        expect(products.first['stock'], 97);
      });
    });

    group('getAll', () {
      test('should return all transactions ordered by date DESC', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 3; i++) {
          final txnMap = {
            'transaction_date':
                now.add(Duration(days: i)).toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          };
          await dao.createFullTransaction(
            txnMap: txnMap,
            itemMaps: [
              {
                'product_id': 1,
                'product_name': 'Test Product',
                'quantity': 1,
                'unit_price': 50.0,
                'subtotal': 50.0,
                'cost_price': 30.0,
              },
            ],
            paymentMap: null,
          );
        }

        // Act
        final transactions = await dao.getAll();

        // Assert
        expect(transactions.length, 3);
        expect(transactions.first['transaction_date'],
            contains(now.add(Duration(days: 2)).toIso8601String().substring(0, 10)));
        expect(transactions.last['transaction_date'],
            contains(now.toIso8601String().substring(0, 10)));
      });

      test('should return empty list when no transactions', () async {
        // Act
        final transactions = await dao.getAll();

        // Assert
        expect(transactions, isEmpty);
      });
    });

    group('getById', () {
      test('should return transaction when it exists', () async {
        // Arrange
        final now = DateTime.now();
        final txnMap = {
          'transaction_date': now.toIso8601String(),
          'subtotal': 50.0,
          'tax': 5.0,
          'discount': 0.0,
          'total_amount': 55.0,
          'payment_method': 'cash',
          'payment_status': 'completed',
          'notes': 'Test note',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final txId = await dao.createFullTransaction(
          txnMap: txnMap,
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final transaction = await dao.getById(txId);

        // Assert
        expect(transaction, isNotNull);
        expect(transaction?['id'], txId);
        expect(transaction?['total_amount'], 55.0);
        expect(transaction?['notes'], 'Test note');
      });

      test('should return null when transaction does not exist', () async {
        // Act
        final transaction = await dao.getById(999);

        // Assert
        expect(transaction, isNull);
      });
    });

    group('update', () {
      test('should update transaction', () async {
        // Arrange
        final now = DateTime.now();
        final txnMap = {
          'transaction_date': now.toIso8601String(),
          'subtotal': 50.0,
          'tax': 5.0,
          'discount': 0.0,
          'total_amount': 55.0,
          'payment_method': 'cash',
          'payment_status': 'completed',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final txId = await dao.createFullTransaction(
          txnMap: txnMap,
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        final updatedMap = {
          'id': txId,
          'payment_status': 'refunded',
          'notes': 'Refunded transaction',
          'updated_at': now.add(Duration(hours: 1)).toIso8601String(),
        };

        // Act
        final affected = await dao.update(updatedMap);

        // Assert
        expect(affected, 1);

        final transaction = await dao.getById(txId);
        expect(transaction, isNotNull);
        expect(transaction?['payment_status'], 'refunded');
        expect(transaction?['notes'], 'Refunded transaction');
      });

      test('should throw ValidationException when id is null', () async {
        // Arrange
        final transactionMap = {
          'payment_status': 'refunded',
        };

        // Act & Assert
        expect(
          () => dao.update(transactionMap),
          throwsA(isA<app_exceptions.ValidationException>()),
        );
      });
    });

    group('updateStatus', () {
      test('should update transaction status', () async {
        // Arrange
        final now = DateTime.now();
        final txnMap = {
          'transaction_date': now.toIso8601String(),
          'subtotal': 50.0,
          'tax': 5.0,
          'discount': 0.0,
          'total_amount': 55.0,
          'payment_method': 'cash',
          'payment_status': 'completed',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final txId = await dao.createFullTransaction(
          txnMap: txnMap,
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        await dao.updateStatus(txId, 'refunded');

        // Assert
        final transaction = await dao.getById(txId);
        expect(transaction, isNotNull);
        expect(transaction?['payment_status'], 'refunded');
      });
    });

    group('delete', () {
      test('should soft delete transaction', () async {
        // Arrange
        final now = DateTime.now();
        final txnMap = {
          'transaction_date': now.toIso8601String(),
          'subtotal': 50.0,
          'tax': 5.0,
          'discount': 0.0,
          'total_amount': 55.0,
          'payment_method': 'cash',
          'payment_status': 'completed',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final txId = await dao.createFullTransaction(
          txnMap: txnMap,
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final affected = await dao.delete(txId);

        // Assert
        expect(affected, 1);

        final transaction = await dao.getById(txId);
        expect(transaction, isNotNull);
        expect(transaction?['payment_status'], 'refunded'); // Transaction still exists, just status changed
      });
    });

    group('getByDateRange', () {
      test('should return transactions in date range', () async {
        // Arrange
        final now = DateTime.now();
        final date1 = now;
        final date2 = now.add(Duration(days: 1));
        final date3 = now.add(Duration(days: 2));

        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': date1.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': date1.toIso8601String(),
            'updated_at': date1.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': date2.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': date2.toIso8601String(),
            'updated_at': date2.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': date3.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': date3.toIso8601String(),
            'updated_at': date3.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act - Get transactions for date1 and date2 only
        final transactions = await dao.getByDateRange(
          date1.toIso8601String(),
          date2.toIso8601String(),
        );

        // Assert
        expect(transactions.length, 2);
      });
    });

    group('getByStatus', () {
      test('should return transactions with specific status', () async {
        // Arrange
        final now = DateTime.now();
        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        await dao.createFullTransaction(
          txnMap: {
            'transaction_date':
                now.add(Duration(days: 1)).toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'refunded',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final transactions = await dao.getByStatus('completed');

        // Assert
        expect(transactions.length, 1);
        expect(transactions.first['payment_status'], 'completed');
      });
    });

    group('getRecent', () {
      test('should return recent transactions with limit', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 10; i++) {
          await dao.createFullTransaction(
            txnMap: {
              'transaction_date':
                  now.add(Duration(days: i)).toIso8601String(),
              'subtotal': 50.0,
              'tax': 5.0,
              'discount': 0.0,
              'total_amount': 55.0,
              'payment_method': 'cash',
              'payment_status': 'completed',
              'created_at': now.toIso8601String(),
              'updated_at': now.toIso8601String(),
            },
            itemMaps: [
              {
                'product_id': 1,
                'product_name': 'Test Product',
                'quantity': 1,
                'unit_price': 50.0,
                'subtotal': 50.0,
                'cost_price': 30.0,
              },
            ],
            paymentMap: null,
          );
        }

        // Act
        final transactions = await dao.getRecent(limit: 5);

        // Assert
        expect(transactions.length, 5);
      });
    });

    group('getItems', () {
      test('should return items for transaction', () async {
        // Arrange
        final now = DateTime.now();
        final txId = await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 150.0,
            'tax': 15.0,
            'discount': 0.0,
            'total_amount': 165.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Product 1',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
            {
              'product_id': 1,
              'product_name': 'Product 2',
              'quantity': 2,
              'unit_price': 50.0,
              'subtotal': 100.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final items = await dao.getItems(txId);

        // Assert
        expect(items.length, 2);
        expect(items.first['product_name'], 'Product 1');
        expect(items.last['product_name'], 'Product 2');
      });
    });

    group('getPayment', () {
      test('should return payment for transaction', () async {
        // Arrange
        final now = DateTime.now();
        final txId = await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: {
            'payment_method': 'cash',
            'amount': 55.0,
            'cash_received': 60.0,
            'payment_date': now.toIso8601String(),
          },
        );

        // Act
        final payment = await dao.getPayment(txId);

        // Assert
        expect(payment, isNotNull);
        expect(payment?['amount'], 55.0);
        expect(payment?['cash_received'], 60.0);
      });

      test('should return null when payment does not exist', () async {
        // Act
        final payment = await dao.getPayment(999);

        // Assert
        expect(payment, isNull);
      });
    });

    group('getPaymentsByTransactionId', () {
      test('should return all payments for transaction', () async {
        // Arrange
        final now = DateTime.now();
        final txId = await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: {
            'payment_method': 'cash',
            'amount': 55.0,
            'payment_date': now.toIso8601String(),
          },
        );

        // Act
        final payments = await dao.getPaymentsByTransactionId(txId);

        // Assert
        expect(payments.length, 1);
        expect(payments.first['amount'], 55.0);
      });
    });

    group('Analytics Operations', () {
      test('should calculate total sales in range', () async {
        // Arrange
        final now = DateTime.now();
        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final total =
            await dao.getTotalSalesInRange(now.toIso8601String(), now.toIso8601String());

        // Assert
        expect(total, 55.0);
      });

      test('should calculate total profit in range', () async {
        // Arrange
        final now = DateTime.now();
        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 100.0,
            'tax': 10.0,
            'discount': 0.0,
            'total_amount': 110.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 2,
              'unit_price': 50.0,
              'subtotal': 100.0,
              'cost_price': 30.0, // Profit: (50-30) * 2 = 40
            },
          ],
          paymentMap: null,
        );

        // Act
        final profit =
            await dao.getTotalProfitInRange(now.toIso8601String(), now.toIso8601String());

        // Assert
        expect(profit, 40.0);
      });

      test('should get sales by payment method', () async {
        // Arrange
        final now = DateTime.now();
        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final sales = await dao.getSalesByPaymentMethod(
            now.toIso8601String(), now.toIso8601String());

        // Assert
        expect(sales.length, 1);
        expect(sales.first['payment_method'], 'cash');
        expect(sales.first['total_amount'], 55.0);
      });

      test('should get top selling products', () async {
        // Arrange
        final now = DateTime.now();
        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 100.0,
            'tax': 10.0,
            'discount': 0.0,
            'total_amount': 110.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 2,
              'unit_price': 50.0,
              'subtotal': 100.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final topProducts = await dao.getTopSellingProducts(
            now.toIso8601String(), now.toIso8601String());

        // Assert
        expect(topProducts.length, 1);
        expect(topProducts.first['product_id'], 1);
        expect(topProducts.first['total_quantity'], 2);
      });
    });

    group('Utility Operations', () {
      test('should count transactions', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 5; i++) {
          await dao.createFullTransaction(
            txnMap: {
              'transaction_date': now.toIso8601String(),
              'subtotal': 50.0,
              'tax': 5.0,
              'discount': 0.0,
              'total_amount': 55.0,
              'payment_method': 'cash',
              'payment_status': 'completed',
              'created_at': now.toIso8601String(),
              'updated_at': now.toIso8601String(),
            },
            itemMaps: [
              {
                'product_id': 1,
                'product_name': 'Test Product',
                'quantity': 1,
                'unit_price': 50.0,
                'subtotal': 50.0,
                'cost_price': 30.0,
              },
            ],
            paymentMap: null,
          );
        }

        // Act
        final count = await dao.count();

        // Assert
        expect(count, 5);
      });

      test('should count transactions by status', () async {
        // Arrange
        final now = DateTime.now();
        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        await dao.createFullTransaction(
          txnMap: {
            'transaction_date': now.toIso8601String(),
            'subtotal': 50.0,
            'tax': 5.0,
            'discount': 0.0,
            'total_amount': 55.0,
            'payment_method': 'cash',
            'payment_status': 'refunded',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          itemMaps: [
            {
              'product_id': 1,
              'product_name': 'Test Product',
              'quantity': 1,
              'unit_price': 50.0,
              'subtotal': 50.0,
              'cost_price': 30.0,
            },
          ],
          paymentMap: null,
        );

        // Act
        final count = await dao.countByStatus('completed');

        // Assert
        expect(count, 1);
      });
    });
  });
}
