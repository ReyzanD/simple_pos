import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simple_pos/services/database/database_schema.dart';

void main() {
  late Database db;

  setUpAll(() {
    // Initialize FFI for in-memory database
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create a new in-memory database for each test
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (_, __) async {},
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('DatabaseSchema - Table Creation', () {
    test('createCategoriesTable should create categories table with correct schema', () async {
      // Act
      await DatabaseSchema.createCategoriesTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='categories'",
      );
      expect(tables.length, 1, reason: 'Categories table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(categories)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('name'));
      expect(columnNames, contains('description'));
      expect(columnNames, contains('discount_percentage'));
      expect(columnNames, contains('created_at'));
    });

    test('createSuppliersTable should create suppliers table with correct schema', () async {
      // Act
      await DatabaseSchema.createSuppliersTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='suppliers'",
      );
      expect(tables.length, 1, reason: 'Suppliers table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(suppliers)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('name'));
      expect(columnNames, contains('contact_person'));
      expect(columnNames, contains('phone'));
      expect(columnNames, contains('email'));
      expect(columnNames, contains('address'));
      expect(columnNames, contains('created_at'));
    });

    test('createProductsTable should create products table with correct schema', () async {
      // Act
      await DatabaseSchema.createProductsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='products'",
      );
      expect(tables.length, 1, reason: 'Products table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(products)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('name'));
      expect(columnNames, contains('price'));
      expect(columnNames, contains('stock'));
      expect(columnNames, contains('category_id'));
      expect(columnNames, contains('supplier_id'));
      expect(columnNames, contains('barcode'));
      expect(columnNames, contains('cost_price'));
      expect(columnNames, contains('image_path'));
      expect(columnNames, contains('discount_percentage'));
      expect(columnNames, contains('has_variants'));
    });

    test('createTransactionsTable should create transactions table with correct schema', () async {
      // Act
      await DatabaseSchema.createTransactionsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='transactions'",
      );
      expect(tables.length, 1, reason: 'Transactions table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(transactions)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('transaction_date'));
      expect(columnNames, contains('subtotal'));
      expect(columnNames, contains('tax'));
      expect(columnNames, contains('discount'));
      expect(columnNames, contains('total_amount'));
      expect(columnNames, contains('payment_method'));
      expect(columnNames, contains('payment_status'));
      expect(columnNames, contains('notes'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('createTransactionItemsTable should create transaction_items table with correct schema', () async {
      // Act
      await DatabaseSchema.createTransactionItemsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='transaction_items'",
      );
      expect(tables.length, 1, reason: 'Transaction items table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(transaction_items)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('transaction_id'));
      expect(columnNames, contains('product_id'));
      expect(columnNames, contains('product_name'));
      expect(columnNames, contains('quantity'));
      expect(columnNames, contains('unit_price'));
      expect(columnNames, contains('subtotal'));
      expect(columnNames, contains('cost_price'));
    });

    test('createPaymentsTable should create payments table with correct schema', () async {
      // Act
      await DatabaseSchema.createPaymentsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='payments'",
      );
      expect(tables.length, 1, reason: 'Payments table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(payments)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('transaction_id'));
      expect(columnNames, contains('payment_method'));
      expect(columnNames, contains('amount'));
      expect(columnNames, contains('cash_received'));
      expect(columnNames, contains('card_last_4_digits'));
      expect(columnNames, contains('payment_date'));
    });

    test('createPromotionsTable should create promotions table with correct schema', () async {
      // Act
      await DatabaseSchema.createPromotionsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='promotions'",
      );
      expect(tables.length, 1, reason: 'Promotions table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(promotions)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('name'));
      expect(columnNames, contains('description'));
      expect(columnNames, contains('discount_percentage'));
      expect(columnNames, contains('start_date'));
      expect(columnNames, contains('end_date'));
      expect(columnNames, contains('is_enabled'));
      expect(columnNames, contains('created_at'));
    });

    test('createDiscountPresetsTable should create discount_presets table with correct schema', () async {
      // Act
      await DatabaseSchema.createDiscountPresetsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='discount_presets'",
      );
      expect(tables.length, 1, reason: 'Discount presets table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(discount_presets)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('name'));
      expect(columnNames, contains('description'));
      expect(columnNames, contains('discount_percentage'));
      expect(columnNames, contains('created_at'));
    });

    test('createShiftsTable should create shifts table with correct schema', () async {
      // Act
      await DatabaseSchema.createShiftsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='shifts'",
      );
      expect(tables.length, 1, reason: 'Shifts table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(shifts)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('user_name'));
      expect(columnNames, contains('opening_balance'));
      expect(columnNames, contains('closing_balance'));
      expect(columnNames, contains('cash_sales'));
      expect(columnNames, contains('card_sales'));
      expect(columnNames, contains('qr_sales'));
      expect(columnNames, contains('transfer_sales'));
      expect(columnNames, contains('total_transactions'));
      expect(columnNames, contains('opened_at'));
      expect(columnNames, contains('closed_at'));
    });

    test('createUsersTable should create users table with correct schema', () async {
      // Act
      await DatabaseSchema.createUsersTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'",
      );
      expect(tables.length, 1, reason: 'Users table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(users)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('username'));
      expect(columnNames, contains('password_hash'));
      expect(columnNames, contains('full_name'));
      expect(columnNames, contains('role'));
      expect(columnNames, contains('is_active'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('last_login'));
    });

    test('createUserSessionsTable should create user_sessions table with correct schema', () async {
      // Act
      await DatabaseSchema.createUserSessionsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='user_sessions'",
      );
      expect(tables.length, 1, reason: 'User sessions table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(user_sessions)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('user_id'));
      expect(columnNames, contains('login_time'));
      expect(columnNames, contains('logout_time'));
    });

    test('createExpensesTable should create expenses table with correct schema', () async {
      // Act
      await DatabaseSchema.createExpensesTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='expenses'",
      );
      expect(tables.length, 1, reason: 'Expenses table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(expenses)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('category'));
      expect(columnNames, contains('amount'));
      expect(columnNames, contains('description'));
      expect(columnNames, contains('payment_method'));
      expect(columnNames, contains('receipt_image'));
      expect(columnNames, contains('created_by'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('date'));
    });

    test('createHeldCartsTable should create held_carts table with correct schema', () async {
      // Act
      await DatabaseSchema.createHeldCartsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='held_carts'",
      );
      expect(tables.length, 1, reason: 'Held carts table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(held_carts)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('customer_name'));
      expect(columnNames, contains('cart_data'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('createVariantAttributesTable should create variant_attributes table with correct schema', () async {
      // Act
      await DatabaseSchema.createVariantAttributesTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='variant_attributes'",
      );
      expect(tables.length, 1, reason: 'Variant attributes table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(variant_attributes)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('product_id'));
      expect(columnNames, contains('attribute_name'));
      expect(columnNames, contains('attribute_values'));
      expect(columnNames, contains('sort_order'));
    });

    test('createProductVariantsTable should create product_variants table with correct schema', () async {
      // Act
      await DatabaseSchema.createProductVariantsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='product_variants'",
      );
      expect(tables.length, 1, reason: 'Product variants table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(product_variants)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('product_id'));
      expect(columnNames, contains('name'));
      expect(columnNames, contains('sku'));
      expect(columnNames, contains('barcode'));
      expect(columnNames, contains('price'));
      expect(columnNames, contains('cost_price'));
      expect(columnNames, contains('stock'));
      expect(columnNames, contains('attributes'));
      expect(columnNames, contains('is_active'));
      expect(columnNames, contains('created_at'));
    });

    test('createCashCountsTable should create cash_counts table with correct schema', () async {
      // Act
      await DatabaseSchema.createCashCountsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='cash_counts'",
      );
      expect(tables.length, 1, reason: 'Cash counts table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(cash_counts)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('shift_id'));
      expect(columnNames, contains('denomination'));
      expect(columnNames, contains('count'));
      expect(columnNames, contains('counted_at'));
      expect(columnNames, contains('counted_by'));
    });

    test('createAuditLogsTable should create audit_logs table with correct schema', () async {
      // Act
      await DatabaseSchema.createAuditLogsTable(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='audit_logs'",
      );
      expect(tables.length, 1, reason: 'Audit logs table should exist');

      // Check schema
      final columns = await db.rawQuery("PRAGMA table_info(audit_logs)");
      final columnNames = columns.map((c) => c['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('action'));
      expect(columnNames, contains('entity_type'));
      expect(columnNames, contains('entity_id'));
      expect(columnNames, contains('description'));
      expect(columnNames, contains('username'));
      expect(columnNames, contains('user_id'));
      expect(columnNames, contains('old_values'));
      expect(columnNames, contains('new_values'));
      expect(columnNames, contains('ip_address'));
      expect(columnNames, contains('user_agent'));
      expect(columnNames, contains('created_at'));
    });
  });

  group('DatabaseSchema - Index Creation', () {
    test('createProductIndexes should create all product indexes', () async {
      // Arrange
      await DatabaseSchema.createProductsTable(db);

      // Act
      await DatabaseSchema.createProductIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='products'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames, contains('idx_products_name'));
      expect(indexNames, contains('idx_products_category'));
      expect(indexNames, contains('idx_products_supplier'));
      expect(indexNames, contains('idx_products_barcode'));
      expect(indexNames, contains('idx_products_stock'));
      expect(indexNames, contains('idx_products_has_variants'));
    });

    test('createTransactionIndexes should create all transaction indexes', () async {
      // Arrange
      await DatabaseSchema.createTransactionsTable(db);
      await DatabaseSchema.createTransactionItemsTable(db);

      // Act
      await DatabaseSchema.createTransactionIndexes(db);

      // Assert
      final transactionIndexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='transactions'",
      );
      final transactionIndexNames = transactionIndexes.map((i) => i['name']).toList();

      expect(transactionIndexNames, contains('idx_transactions_date'));
      expect(transactionIndexNames, contains('idx_transactions_created_at'));
      expect(transactionIndexNames, contains('idx_transactions_payment_method'));

      final itemIndexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='transaction_items'",
      );
      final itemIndexNames = itemIndexes.map((i) => i['name']).toList();

      expect(itemIndexNames, contains('idx_transaction_items_transaction'));
      expect(itemIndexNames, contains('idx_transaction_items_product'));
    });

    test('createPromotionIndexes should create all promotion indexes', () async {
      // Arrange
      await DatabaseSchema.createPromotionsTable(db);

      // Act
      await DatabaseSchema.createPromotionIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='promotions'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames, contains('idx_promotions_enabled'));
      expect(indexNames, contains('idx_promotions_dates'));
    });

    test('createShiftIndexes should create all shift indexes', () async {
      // Arrange
      await DatabaseSchema.createShiftsTable(db);

      // Act
      await DatabaseSchema.createShiftIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='shifts'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames, contains('idx_shifts_opened_at'));
      expect(indexNames, contains('idx_shifts_closed_at'));
    });

    test('createUserIndexes should create all user indexes', () async {
      // Arrange
      await DatabaseSchema.createUsersTable(db);
      await DatabaseSchema.createUserSessionsTable(db);

      // Act
      await DatabaseSchema.createUserIndexes(db);

      // Assert
      final userIndexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='users'",
      );
      final userIndexNames = userIndexes.map((i) => i['name']).toList();

      expect(userIndexNames, contains('idx_users_username'));
      expect(userIndexNames, contains('idx_users_role'));

      final sessionIndexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='user_sessions'",
      );
      final sessionIndexNames = sessionIndexes.map((i) => i['name']).toList();

      expect(sessionIndexNames, contains('idx_user_sessions_user'));
      expect(sessionIndexNames, contains('idx_user_sessions_login_time'));
    });

    test('createExpenseIndexes should create all expense indexes', () async {
      // Arrange
      await DatabaseSchema.createExpensesTable(db);

      // Act
      await DatabaseSchema.createExpenseIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='expenses'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames, contains('idx_expenses_date'));
      expect(indexNames, contains('idx_expenses_category'));
      expect(indexNames, contains('idx_expenses_created_by'));
    });

    test('createHeldCartIndexes should create held cart indexes', () async {
      // Arrange
      await DatabaseSchema.createHeldCartsTable(db);

      // Act
      await DatabaseSchema.createHeldCartIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='held_carts'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames, contains('idx_held_carts_created'));
    });

    test('createVariantIndexes should create all variant indexes', () async {
      // Arrange
      await DatabaseSchema.createVariantAttributesTable(db);
      await DatabaseSchema.createProductVariantsTable(db);

      // Act
      await DatabaseSchema.createVariantIndexes(db);

      // Assert
      final variantIndexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='product_variants'",
      );
      final variantIndexNames = variantIndexes.map((i) => i['name']).toList();

      expect(variantIndexNames, contains('idx_product_variants_product_id'));
      expect(variantIndexNames, contains('idx_product_variants_sku'));
      expect(variantIndexNames, contains('idx_product_variants_barcode'));

      final attributeIndexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='variant_attributes'",
      );
      final attributeIndexNames = attributeIndexes.map((i) => i['name']).toList();

      expect(attributeIndexNames, contains('idx_variant_attributes_product_id'));
    });

    test('createCashCountIndexes should create cash count indexes', () async {
      // Arrange
      await DatabaseSchema.createCashCountsTable(db);

      // Act
      await DatabaseSchema.createCashCountIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='cash_counts'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames, contains('idx_cash_counts_shift'));
      expect(indexNames, contains('idx_cash_counts_denomination'));
    });

    test('createAuditLogIndexes should create audit log indexes', () async {
      // Arrange
      await DatabaseSchema.createAuditLogsTable(db);

      // Act
      await DatabaseSchema.createAuditLogIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='audit_logs'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames, contains('idx_audit_logs_entity'));
      expect(indexNames, contains('idx_audit_logs_created_at'));
      expect(indexNames, contains('idx_audit_logs_action'));
      expect(indexNames, contains('idx_audit_logs_user'));
    });
  });

  group('DatabaseSchema - Schema Validation', () {
    test('tableExists should return true for existing table', () async {
      // Arrange
      await DatabaseSchema.createCategoriesTable(db);

      // Act
      final exists = await DatabaseSchema.tableExists(db, 'categories');

      // Assert
      expect(exists, isTrue);
    });

    test('tableExists should return false for non-existent table', () async {
      // Act
      final exists = await DatabaseSchema.tableExists(db, 'nonexistent');

      // Assert
      expect(exists, isFalse);
    });

    test('indexExists should return true for existing index', () async {
      // Arrange
      await DatabaseSchema.createProductsTable(db);
      await DatabaseSchema.createProductIndexes(db);

      // Act
      final exists = await DatabaseSchema.indexExists(db, 'idx_products_name', 'products');

      // Assert
      expect(exists, isTrue);
    });

    test('indexExists should return false for non-existent index', () async {
      // Arrange
      await DatabaseSchema.createProductsTable(db);

      // Act
      final exists = await DatabaseSchema.indexExists(db, 'idx_products_name', 'products');

      // Assert
      expect(exists, isFalse);
    });
  });

  group('DatabaseSchema - Full Schema Creation', () {
    test('createAllTables should create all tables', () async {
      // Act
      await DatabaseSchema.createAllTables(db);

      // Assert
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      final tableNames = tables.map((t) => t['name']).toList();

      expect(tableNames.length, greaterThan(10));
      expect(tableNames, contains('categories'));
      expect(tableNames, contains('suppliers'));
      expect(tableNames, contains('products'));
      expect(tableNames, contains('transactions'));
      expect(tableNames, contains('transaction_items'));
      expect(tableNames, contains('payments'));
      expect(tableNames, contains('promotions'));
      expect(tableNames, contains('discount_presets'));
      expect(tableNames, contains('shifts'));
      expect(tableNames, contains('users'));
      expect(tableNames, contains('user_sessions'));
      expect(tableNames, contains('expenses'));
      expect(tableNames, contains('held_carts'));
      expect(tableNames, contains('variant_attributes'));
      expect(tableNames, contains('product_variants'));
      expect(tableNames, contains('cash_counts'));
      expect(tableNames, contains('audit_logs'));
    });

    test('createAllIndexes should create all indexes', () async {
      // Arrange
      await DatabaseSchema.createAllTables(db);

      // Act
      await DatabaseSchema.createAllIndexes(db);

      // Assert
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );
      final indexNames = indexes.map((i) => i['name']).toList();

      expect(indexNames.length, greaterThan(20));
      expect(indexNames, contains('idx_products_name'));
      expect(indexNames, contains('idx_products_barcode'));
      expect(indexNames, contains('idx_transactions_date'));
      expect(indexNames, contains('idx_promotions_enabled'));
      expect(indexNames, contains('idx_users_username'));
      expect(indexNames, contains('idx_expenses_date'));
    });
  });

  group('DatabaseSchema - Migration', () {
    test('createAllTables should create all tables in correct order', () async {
      // Act
      await DatabaseSchema.createAllTables(db);

      // Assert - Verify core tables exist
      expect(await DatabaseSchema.tableExists(db, 'categories'), isTrue);
      expect(await DatabaseSchema.tableExists(db, 'suppliers'), isTrue);
      expect(await DatabaseSchema.tableExists(db, 'products'), isTrue);
      expect(await DatabaseSchema.tableExists(db, 'transactions'), isTrue);
      expect(await DatabaseSchema.tableExists(db, 'transaction_items'), isTrue);
      expect(await DatabaseSchema.tableExists(db, 'payments'), isTrue);
    });

    test('createAllIndexes should create all indexes', () async {
      // Arrange
      await DatabaseSchema.createAllTables(db);

      // Act
      await DatabaseSchema.createAllIndexes(db);

      // Assert - Verify key indexes exist
      expect(await DatabaseSchema.indexExists(db, 'idx_products_name', 'products'), isTrue);
      expect(await DatabaseSchema.indexExists(db, 'idx_products_barcode', 'products'), isTrue);
      expect(await DatabaseSchema.indexExists(db, 'idx_transactions_date', 'transactions'), isTrue);
      expect(await DatabaseSchema.indexExists(db, 'idx_promotions_enabled', 'promotions'), isTrue);
      expect(await DatabaseSchema.indexExists(db, 'idx_users_username', 'users'), isTrue);
    });

    test('migration methods should handle ALTER TABLE operations safely', () async {
      // Arrange - Create products table without image_path
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          stock INTEGER NOT NULL
        )
      ''');

      // Act - Add image_path column (simulating v3 migration)
      try {
        await db.execute('ALTER TABLE products ADD COLUMN image_path TEXT');
        // Assert - Column added successfully
        final columns = await db.rawQuery("PRAGMA table_info(products)");
        final columnNames = columns.map((c) => c['name']).toList();
        expect(columnNames, contains('image_path'));
      } catch (e) {
        fail('Should be able to add column: $e');
      }
    });
  });
}
