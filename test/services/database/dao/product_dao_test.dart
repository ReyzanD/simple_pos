import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart' as app_exceptions;
import 'package:simple_pos/services/database/dao/product_dao.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ProductDAO Singleton Pattern', () {
    test('should return same instance on multiple calls', () {
      final instance1 = ProductDao.instance;
      final instance2 = ProductDao.instance;

      expect(instance1, same(instance2));
      expect(instance1.hashCode, instance2.hashCode);
    });

    test('should maintain singleton across async operations', () async {
      final futures = List.generate(10, (index) async {
        await Future.delayed(Duration(milliseconds: 10));
        return ProductDao.instance;
      });

      final instances = await Future.wait(futures);

      // All instances should be the same
      final firstInstance = instances.first;
      for (final instance in instances) {
        expect(instance, same(firstInstance));
      }
    });
  });

  group('ProductDAO CRUD Operations', () {
    late ProductDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = ProductDao.instance;
      connection = DatabaseConnection.instance;

      // Use in-memory database for isolation
      await connection.reset();
      await connection.initialize(':memory:');

      // Create products table
      final db = await connection.database;
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          price REAL NOT NULL,
          stock INTEGER NOT NULL,
          category_id INTEGER,
          supplier_id INTEGER,
          barcode TEXT UNIQUE,
          cost_price REAL DEFAULT 0,
          image_path TEXT,
          discount_percentage REAL DEFAULT 0,
          has_variants INTEGER DEFAULT 0
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

    group('insert()', () {
      test('should insert a product and return with ID', () async {
        final product = {
          'name': 'Test Product',
          'price': 100.0,
          'stock': 50,
          'barcode': '123456789',
          'category_id': 1,
          'supplier_id': 1,
        };

        final result = await dao.insert(product);

        expect(result['id'], isNotNull);
        expect(result['id'], greaterThan(0));
        expect(result['name'], equals('Test Product'));
        expect(result['price'], equals(100.0));
        expect(result['stock'], equals(50));
      });

      test('should insert multiple products with unique IDs', () async {
        final products = List.generate(3, (index) => {
              'name': 'Product $index',
              'price': 100.0 * (index + 1),
              'stock': 50 - index,
            });

        final results = <Map<String, dynamic>>[];
        for (final product in products) {
          final result = await dao.insert(product);
          results.add(result);
        }

        expect(results.length, equals(3));
        expect(results[0]['id'], isNot(equals(results[1]['id'])));
        expect(results[1]['id'], isNot(equals(results[2]['id'])));
        expect(results[0]['name'], equals('Product 0'));
        expect(results[1]['name'], equals('Product 1'));
        expect(results[2]['name'], equals('Product 2'));
      });

      test('should insert product with all optional fields', () async {
        final product = {
          'name': 'Complete Product',
          'price': 150.0,
          'stock': 100,
          'barcode': '987654321',
          'category_id': 2,
          'supplier_id': 3,
          'cost_price': 100.0,
          'image_path': '/path/to/image.jpg',
          'discount_percentage': 10.0,
          'has_variants': 1,
        };

        final result = await dao.insert(product);

        expect(result['name'], equals('Complete Product'));
        expect(result['cost_price'], equals(100.0));
        expect(result['image_path'], equals('/path/to/image.jpg'));
        expect(result['discount_percentage'], equals(10.0));
        expect(result['has_variants'], equals(1));
      });
    });

    group('getAll()', () {
      setUp(() async {
        // Insert test data
        final products = [
          {'name': 'Product A', 'price': 50.0, 'stock': 100},
          {'name': 'Product B', 'price': 75.0, 'stock': 50},
          {'name': 'Product C', 'price': 100.0, 'stock': 25},
        ];
        for (final product in products) {
          await dao.insert(product);
        }
      });

      test('should return all products ordered by ID DESC', () async {
        final results = await dao.getAll();

        expect(results.length, greaterThanOrEqualTo(3));
        if (results.length >= 3) {
          // Verify descending order by ID
          expect(results[0]['id'], greaterThan(results[1]['id'] as int));
          expect(results[1]['id'], greaterThan(results[2]['id'] as int));
        }
      });

      test('should return empty list when no products exist', () async {
        // Reset database to ensure empty state
        await connection.reset();
        await connection.initialize(':memory:');

        final db = await connection.database;
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            price REAL NOT NULL,
            stock INTEGER NOT NULL
          )
        ''');

        final results = await dao.getAll();

        expect(results, isEmpty);
      });
    });

    group('getById()', () {
      late int productId;

      setUp(() async {
        final product = {
          'name': 'Target Product',
          'price': 200.0,
          'stock': 30,
          'barcode': '111222333',
        };
        final result = await dao.insert(product);
        productId = result['id'] as int;
      });

      test('should return product when ID exists', () async {
        final result = await dao.getById(productId);

        expect(result, isNotNull);
        expect(result!['id'], equals(productId));
        expect(result['name'], equals('Target Product'));
        expect(result['price'], equals(200.0));
        expect(result['stock'], equals(30));
      });

      test('should return null when ID does not exist', () async {
        final result = await dao.getById(99999);

        expect(result, isNull);
      });

      test('should return correct product for each ID', () async {
        // Insert multiple products
        final products = [
          {'name': 'Product 1', 'price': 10.0, 'stock': 10},
          {'name': 'Product 2', 'price': 20.0, 'stock': 20},
          {'name': 'Product 3', 'price': 30.0, 'stock': 30},
        ];

        final ids = <int>[];
        for (final product in products) {
          final result = await dao.insert(product);
          ids.add(result['id'] as int);
        }

        // Verify each product can be retrieved
        for (var i = 0; i < ids.length; i++) {
          final result = await dao.getById(ids[i]);
          expect(result, isNotNull);
          expect(result!['name'], equals('Product ${i + 1}'));
        }
      });
    });

    group('update()', () {
      late int productId;

      setUp(() async {
        final product = {
          'name': 'Original Product',
          'price': 100.0,
          'stock': 50,
        };
        final result = await dao.insert(product);
        productId = result['id'] as int;
      });

      test('should update product when ID is provided', () async {
        final updatedProduct = {
          'id': productId,
          'name': 'Updated Product',
          'price': 150.0,
          'stock': 75,
        };

        final count = await dao.update(updatedProduct);

        expect(count, equals(1));

        // Verify the update
        final result = await dao.getById(productId);
        expect(result, isNotNull);
        expect(result!['name'], equals('Updated Product'));
        expect(result['price'], equals(150.0));
        expect(result['stock'], equals(75));
      });

      test('should throw ValidationException when ID is null', () async {
        final productWithoutId = {
          'name': 'No ID Product',
          'price': 100.0,
          'stock': 50,
        };

        expect(
          () => dao.update(productWithoutId),
          throwsA(isA<app_exceptions.ValidationException>()),
        );
      });

      test('should return 0 when product does not exist', () async {
        final nonExistentProduct = {
          'id': 99999,
          'name': 'Ghost Product',
          'price': 100.0,
          'stock': 50,
        };

        final count = await dao.update(nonExistentProduct);

        expect(count, equals(0));
      });

      test('should update only specified fields', () async {
        // Insert another product
        final otherProduct = {
          'name': 'Other Product',
          'price': 200.0,
          'stock': 100,
        };
        final otherId = (await dao.insert(otherProduct))['id'] as int;

        // Update only one field of the first product
        final partialUpdate = {
          'id': productId,
          'stock': 999,
        };

        await dao.update(partialUpdate);

        // Verify only target product was updated
        final updated = await dao.getById(productId);
        final other = await dao.getById(otherId);

        expect(updated!['stock'], equals(999));
        expect(updated['name'], equals('Original Product')); // Unchanged
        expect(other!['stock'], equals(100)); // Unchanged
      });
    });

    group('delete()', () {
      late int productId;

      setUp(() async {
        final product = {
          'name': 'Deletable Product',
          'price': 100.0,
          'stock': 50,
        };
        final result = await dao.insert(product);
        productId = result['id'] as int;
      });

      test('should delete product when ID exists', () async {
        final count = await dao.delete(productId);

        expect(count, equals(1));

        // Verify deletion
        final result = await dao.getById(productId);
        expect(result, isNull);
      });

      test('should return 0 when product does not exist', () async {
        final count = await dao.delete(99999);

        expect(count, equals(0));
      });

      test('should not affect other products', () async {
        // Insert multiple products
        final products = List.generate(5, (index) => {
              'name': 'Product $index',
              'price': 100.0,
              'stock': 50,
            });

        final ids = <int>[];
        for (final product in products) {
          final result = await dao.insert(product);
          ids.add(result['id'] as int);
        }

        // Delete middle product
        final deleteCount = await dao.delete(ids[2]);

        expect(deleteCount, equals(1));

        // Verify other products still exist
        final remaining = await dao.getAll();
        expect(remaining.length, equals(ids.length - 1));

        for (var i = 0; i < ids.length; i++) {
          final exists = await dao.exists(ids[i]);
          if (i == 2) {
            expect(exists, isFalse);
          } else {
            expect(exists, isTrue);
          }
        }
      });
    });

    group('exists()', () {
      test('should return true when product exists', () async {
        final product = {
          'name': 'Existing Product',
          'price': 100.0,
          'stock': 50,
        };
        final result = await dao.insert(product);
        final id = result['id'] as int;

        final exists = await dao.exists(id);

        expect(exists, isTrue);
      });

      test('should return false when product does not exist', () async {
        final exists = await dao.exists(99999);

        expect(exists, isFalse);
      });

      test('should handle zero correctly', () async {
        final exists = await dao.exists(0);

        expect(exists, isFalse);
      });

      test('should handle negative IDs correctly', () async {
        final exists = await dao.exists(-1);

        expect(exists, isFalse);
      });
    });
  });

  group('ProductDAO Query Operations', () {
    late ProductDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = ProductDao.instance;
      connection = DatabaseConnection.instance;

      await connection.reset();
      await connection.initialize(':memory:');

      final db = await connection.database;
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          price REAL NOT NULL,
          stock INTEGER NOT NULL,
          category_id INTEGER,
          supplier_id INTEGER,
          barcode TEXT UNIQUE,
          cost_price REAL DEFAULT 0,
          has_variants INTEGER DEFAULT 0
        )
      ''');

      // Insert test data
      final products = [
        {
          'name': 'Apple iPhone 15',
          'price': 999.0,
          'stock': 100,
          'category_id': 1,
          'supplier_id': 1,
          'barcode': 'APPLE001',
          'has_variants': 1,
        },
        {
          'name': 'Samsung Galaxy S24',
          'price': 899.0,
          'stock': 50,
          'category_id': 1,
          'supplier_id': 2,
          'barcode': 'SAMSUNG001',
          'has_variants': 1,
        },
        {
          'name': 'MacBook Pro',
          'price': 1999.0,
          'stock': 20,
          'category_id': 2,
          'supplier_id': 1,
          'barcode': 'MAC001',
          'has_variants': 0,
        },
        {
          'name': 'Low Stock Item',
          'price': 50.0,
          'stock': 5,
          'category_id': 3,
          'supplier_id': 3,
          'barcode': 'LOW001',
          'has_variants': 0,
        },
        {
          'name': 'Out of Stock Item',
          'price': 75.0,
          'stock': 0,
          'category_id': 3,
          'supplier_id': 3,
          'barcode': 'OUT001',
          'has_variants': 0,
        },
      ];
      for (final product in products) {
        await dao.insert(product);
      }
    });

    tearDown(() async {
      try {
        await connection.reset();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    group('search()', () {
      test('should find products by partial name match', () async {
        final results = await dao.search('iPhone');

        expect(results.isNotEmpty, isTrue);
        expect(results.first['name'], contains('iPhone'));
      });

      test('should find products case-insensitively', () async {
        final results = await dao.search('macbook');

        expect(results.isNotEmpty, isTrue);
        expect(results.first['name'], contains('MacBook'));
      });

      test('should return empty list for non-matching query', () async {
        final results = await dao.search('NonExistentProduct');

        expect(results, isEmpty);
      });

      test('should find multiple matching products', () async {
        final results = await dao.search('Product');

        expect(results.length, greaterThan(0));
      });

      test('should return results ordered by ID DESC', () async {
        final results = await dao.search('Item');

        if (results.length >= 2) {
          expect(results[0]['id'], greaterThan(results[1]['id'] as int));
        }
      });

      test('should handle empty query string', () async {
        final results = await dao.search('');

        expect(results, isNotEmpty); // Should match all products with empty string
      });
    });

    group('getByBarcode()', () {
      test('should find product by exact barcode', () async {
        final result = await dao.getByBarcode('APPLE001');

        expect(result, isNotNull);
        expect(result!['name'], equals('Apple iPhone 15'));
        expect(result['barcode'], equals('APPLE001'));
      });

      test('should return null for non-existent barcode', () async {
        final result = await dao.getByBarcode('NONEXISTENT');

        expect(result, isNull);
      });

      test('should handle null barcode values', () async {
        final result = await dao.getByBarcode('');

        expect(result, isNull);
      });
    });

    group('getLowStockProducts()', () {
      test('should return products with stock <= threshold', () async {
        final results = await dao.getLowStockProducts(threshold: 10);

        expect(results.length, equals(2));
        expect(
          results.any((p) => p['name'] == 'Low Stock Item'),
          isTrue,
        );
        expect(
          results.any((p) => p['name'] == 'Out of Stock Item'),
          isTrue,
        );
      });

      test('should use default threshold of 10', () async {
        final results = await dao.getLowStockProducts();

        expect(results.length, equals(2));
      });

      test('should return empty list when no products are low stock', () async {
        final results = await dao.getLowStockProducts(threshold: 0);

        expect(results, isEmpty);
      });

      test('should order results by stock ASC', () async {
        final results = await dao.getLowStockProducts(threshold: 100);

        expect(results.length, greaterThan(1));
        if (results.length >= 2) {
          expect(results[0]['stock'], lessThanOrEqualTo(results[1]['stock']! as int));
        }
      });
    });

    group('getOutOfStockProducts()', () {
      test('should return products with stock = 0', () async {
        final results = await dao.getOutOfStockProducts();

        expect(results.length, equals(1));
        expect(results.first['name'], equals('Out of Stock Item'));
        expect(results.first['stock'], equals(0));
      });

      test('should return empty list when no products are out of stock', () async {
        // Delete the out of stock product
        await dao.delete(5);

        final results = await dao.getOutOfStockProducts();

        expect(results, isEmpty);
      });

      test('should order results by name ASC', () async {
        // Insert another out of stock product
        await dao.insert({
          'name': 'Another Out of Stock',
          'price': 100.0,
          'stock': 0,
        });

        final results = await dao.getOutOfStockProducts();

        expect(results.length, greaterThan(1));
        if (results.length >= 2) {
          final names = results.map((p) => p['name'] as String).toList();
          expect(names[0], lessThan(names[1]));
        }
      });
    });

    group('getByCategoryId()', () {
      test('should return products in specified category', () async {
        final results = await dao.getByCategoryId(1);

        expect(results.length, equals(2));
        expect(
          results.any((p) => p['name'] == 'Apple iPhone 15'),
          isTrue,
        );
        expect(
          results.any((p) => p['name'] == 'Samsung Galaxy S24'),
          isTrue,
        );
      });

      test('should return empty list for non-existent category', () async {
        final results = await dao.getByCategoryId(999);

        expect(results, isEmpty);
      });

      test('should order results by name ASC', () async {
        final results = await dao.getByCategoryId(1);

        expect(results.length, equals(2));
        final names = results.map((p) => p['name'] as String).toList();
        expect(names[0], lessThan(names[1]));
      });
    });

    group('getBySupplierId()', () {
      test('should return products from specified supplier', () async {
        final results = await dao.getBySupplierId(1);

        expect(results.length, equals(2));
        expect(
          results.any((p) => p['name'] == 'Apple iPhone 15'),
          isTrue,
        );
        expect(
          results.any((p) => p['name'] == 'MacBook Pro'),
          isTrue,
        );
      });

      test('should return empty list for non-existent supplier', () async {
        final results = await dao.getBySupplierId(999);

        expect(results, isEmpty);
      });

      test('should order results by name ASC', () async {
        final results = await dao.getBySupplierId(1);

        expect(results.length, equals(2));
        final names = results.map((p) => p['name'] as String).toList();
        expect(names[0], lessThan(names[1]));
      });
    });

    group('getProductsWithVariants()', () {
      test('should return products with has_variants = 1', () async {
        final results = await dao.getProductsWithVariants();

        expect(results.length, equals(2));
        expect(
          results.any((p) => p['name'] == 'Apple iPhone 15'),
          isTrue,
        );
        expect(
          results.any((p) => p['name'] == 'Samsung Galaxy S24'),
          isTrue,
        );
      });

      test('should not return products without variants', () async {
        final results = await dao.getProductsWithVariants();

        expect(
          results.any((p) => p['name'] == 'MacBook Pro'),
          isFalse,
        );
        expect(
          results.any((p) => p['name'] == 'Low Stock Item'),
          isFalse,
        );
      });

      test('should order results by name ASC', () async {
        final results = await dao.getProductsWithVariants();

        expect(results.length, equals(2));
        final names = results.map((p) => p['name'] as String).toList();
        expect(names[0], lessThan(names[1]));
      });
    });

    group('count()', () {
      test('should return total number of products', () async {
        final count = await dao.count();

        expect(count, equals(5));
      });

      test('should return 0 for empty database', () async {
        // Reset database
        await connection.reset();
        await connection.initialize(':memory:');

        final db = await connection.database;
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            price REAL NOT NULL,
            stock INTEGER NOT NULL
          )
        ''');

        final count = await dao.count();

        expect(count, equals(0));
      });
    });

    group('getTotalStockValue()', () {
      test('should calculate total stock value correctly', () async {
        final totalValue = await dao.getTotalStockValue();

        // Expected: (999 * 100) + (899 * 50) + (1999 * 20) + (50 * 5) + (75 * 0)
        // = 99900 + 44950 + 39980 + 250 + 0 = 185080
        expect(totalValue, closeTo(185080, 0.01));
      });

      test('should return 0 for empty database', () async {
        // Reset database
        await connection.reset();
        await connection.initialize(':memory:');

        final db = await connection.database;
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            price REAL NOT NULL,
            stock INTEGER NOT NULL
          )
        ''');

        final totalValue = await dao.getTotalStockValue();

        expect(totalValue, equals(0.0));
      });
    });
  });

  group('ProductDAO Stock Management', () {
    late ProductDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = ProductDao.instance;
      connection = DatabaseConnection.instance;

      await connection.reset();
      await connection.initialize(':memory:');

      final db = await connection.database;
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          price REAL NOT NULL,
          stock INTEGER NOT NULL
        )
      ''');

      final product = {
        'name': 'Test Product',
        'price': 100.0,
        'stock': 50,
      };
      await dao.insert(product);
    });

    tearDown(() async {
      try {
        await connection.reset();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    group('updateStock()', () {
      test('should update stock to new value', () async {
        final count = await dao.updateStock(1, 75);

        expect(count, equals(1));

        final product = await dao.getById(1);
        expect(product!['stock'], equals(75));
      });

      test('should handle zero stock', () async {
        final count = await dao.updateStock(1, 0);

        expect(count, equals(1));

        final product = await dao.getById(1);
        expect(product!['stock'], equals(0));
      });

      test('should handle negative stock', () async {
        final count = await dao.updateStock(1, -10);

        expect(count, equals(1));

        final product = await dao.getById(1);
        expect(product!['stock'], equals(-10));
      });

      test('should return 0 for non-existent product', () async {
        final count = await dao.updateStock(999, 100);

        expect(count, equals(0));
      });
    });

    group('adjustStock()', () {
      test('should add to stock when delta is positive', () async {
        final count = await dao.adjustStock(1, 25);

        expect(count, equals(1));

        final product = await dao.getById(1);
        expect(product!['stock'], equals(75)); // 50 + 25
      });

      test('should subtract from stock when delta is negative', () async {
        final count = await dao.adjustStock(1, -30);

        expect(count, equals(1));

        final product = await dao.getById(1);
        expect(product!['stock'], equals(20)); // 50 - 30
      });

      test('should handle zero delta', () async {
        final count = await dao.adjustStock(1, 0);

        expect(count, equals(1));

        final product = await dao.getById(1);
        expect(product!['stock'], equals(50)); // Unchanged
      });

      test('should handle large delta', () async {
        final count = await dao.adjustStock(1, 1000);

        expect(count, equals(1));

        final product = await dao.getById(1);
        expect(product!['stock'], equals(1050)); // 50 + 1000
      });

      test('should return 0 for non-existent product', () async {
        final count = await dao.adjustStock(999, 100);

        expect(count, equals(0));
      });
    });
  });

  group('ProductDAO Error Handling', () {
    late ProductDao dao;
    late DatabaseConnection connection;

    setUp(() async {
      dao = ProductDao.instance;
      connection = DatabaseConnection.instance;
    });

    tearDown(() async {
      try {
        await connection.reset();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    test('should throw DatabaseException when table does not exist', () async {
      await connection.reset();
      await connection.initialize(':memory:');

      expect(
        () => dao.getAll(),
        throwsA(isA<app_exceptions.DatabaseException>()),
      );
    });

    test('should throw DatabaseException for invalid insert', () async {
      await connection.reset();
      await connection.initialize(':memory:');

      final db = await connection.database;
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          price REAL NOT NULL,
          stock INTEGER NOT NULL
        )
      ''');

      // Insert first product
      await dao.insert({'name': 'Product 1', 'price': 100.0, 'stock': 50});

      // Try to insert duplicate
      expect(
        () => dao.insert({'name': 'Product 1', 'price': 100.0, 'stock': 50}),
        throwsA(isA<app_exceptions.DatabaseException>()),
      );
    });

    test('should handle malformed data gracefully', () async {
      await connection.reset();
      await connection.initialize(':memory:');

      final db = await connection.database;
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          price REAL NOT NULL,
          stock INTEGER NOT NULL
        )
      ''');

      // Insert product with negative price (should still work in SQLite)
      final result = await dao.insert({'name': 'Bad Product', 'price': -100.0, 'stock': 50});

      expect(result['id'], isNotNull);
      expect(result['price'], equals(-100.0));
    });
  });
}
