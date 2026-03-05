# Simple POS - Architecture Documentation

This document explains the architecture and design patterns used in the Simple POS application.

## Table of Contents

1. [Overview](#overview)
2. [Clean Architecture](#clean-architecture)
3. [Directory Structure](#directory-structure)
4. [Design Patterns](#design-patterns)
5. [Database Architecture](#database-architecture)
6. [State Management](#state-management)
7. [Data Flow](#data-flow)
8. [Dependency Injection](#dependency-injection)
9. [Error Handling Strategy](#error-handling-strategy)
10. [Testing Strategy](#testing-strategy)

---

## Overview

Simple POS follows **Clean Architecture** principles, ensuring the application is:
- **Testable** - Business logic can be tested without UI, database, or external dependencies
- **Independent of Frameworks** - Core business logic doesn't depend on Flutter, databases, or APIs
- **Independent of UI** - UI can change without affecting business logic
- **Independent of Database** - Database can change without affecting business logic
- **Maintainable** - Clear separation of concerns makes code easier to understand and modify

---

## Clean Architecture

The application is organized into three concentric layers:

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  (Controllers, Screens, Widgets)                        │
│  - Manages UI state                                     │
│  - Handles user interactions                            │
│  - Displays data                                        │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │ depends on
                           │
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                         │
│  (Entities, Use Cases, Repository Interfaces)           │
│  - Core business logic                                  │
│  - Application-specific business rules                  │
│  - No dependencies on outer layers                      │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │ depends on
                           │
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                          │
│  (Repository Implementations, Data Sources, Models)     │
│  - Data access                                          │
│  - External service integrations                        │
│  - Data transfer objects                                │
└─────────────────────────────────────────────────────────┘
```

### Rule of Dependencies

**Inner layers must NOT depend on outer layers.**

- **Domain Layer** - No dependencies on other layers
- **Data Layer** - Depends only on Domain Layer
- **Presentation Layer** - Depends on Domain Layer

### Layer Communication

```
Presentation → Domain (Use Cases) → Domain (Repositories) → Data (Repository Implementations) → Data Sources
```

---

## Directory Structure

```
lib/
│
├── core/                              # Shared core functionality
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   └── currency_constants.dart    # Currency formatting constants
│   │
│   ├── config/
│   │   └── app_config.dart            # Application configuration
│   │
│   ├── exceptions/
│   │   ├── app_exceptions.dart        # Custom exception types
│   │   └── app_exceptions_extension.dart  # Exception helpers
│   │
│   └── utils/
│       ├── currency_formatter.dart    # Currency formatting utilities
│       ├── error_handlers.dart        # Error handling utilities
│       ├── validators.dart            # Input validation
│       └── logger.dart                # Logging utilities
│
├── features/                          # Feature-based organization
│   │
│   ├── inventory/                     # Inventory Management Feature
│   │   │
│   │   ├── data/                      # DATA LAYER
│   │   │   ├── datasources/
│   │   │   │   └── product_local_datasource_impl.dart
│   │   │   ├── models/                # (Not used - entities directly mapped)
│   │   │   └── repositories/
│   │   │       └── product_repository_impl.dart
│   │   │
│   │   ├── domain/                    # DOMAIN LAYER
│   │   │   ├── entities/
│   │   │   │   ├── product.dart       # Core business entity
│   │   │   │   ├── category.dart
│   │   │   │   └── supplier.dart
│   │   │   │
│   │   │   ├── repositories/
│   │   │   │   ├── product_repository.dart  # Repository interface
│   │   │   │   ├── category_repository.dart
│   │   │   │   └── supplier_repository.dart
│   │   │   │
│   │   │   └── usecases/
│   │   │       ├── add_product_usecase.dart
│   │   │       ├── delete_product_usecase.dart
│   │   │       ├── get_products_usecase.dart
│   │   │       ├── search_products_usecase.dart
│   │   │       └── update_product_usecase.dart
│   │   │
│   │   └── presentation/              # PRESENTATION LAYER
│   │       ├── controllers/
│   │       │   └── inventory_controller.dart  # State management
│   │       │
│   │       ├── screens/
│   │       │   └── inventory_screen.dart     # UI screen
│   │       │
│   │       └── widgets/
│   │           ├── add_product_dialog.dart
│   │           ├── edit_product_dialog.dart
│   │           └── product_card.dart
│   │
│   ├── pos/                           # Point of Sale Feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── cart_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── cart_item.dart
│   │   │   │   └── cart.dart
│   │   │   │
│   │   │   ├── repositories/
│   │   │   │   └── cart_repository.dart
│   │   │   │
│   │   │   └── usecases/
│   │   │       ├── add_to_cart_usecase.dart
│   │   │       ├── checkout_usecase.dart
│   │   │       ├── remove_from_cart_usecase.dart
│   │   │       └── update_cart_quantity_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── pos_controller.dart
│   │       │
│   │       ├── screens/
│   │       │   └── pos_screen.dart
│   │       │
│   │       └── widgets/
│   │           ├── cart_item_card.dart
│   │           ├── checkout_dialog.dart
│   │           └── payment_method_selector.dart
│   │
│   ├── sales/                         # Sales & Transactions Feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── transaction_local_datasource_impl.dart
│   │   │   └── repositories/
│   │   │       ├── transaction_repository_impl.dart
│   │   │       ├── category_repository_impl.dart
│   │   │       └── supplier_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── transaction.dart
│   │   │   │   ├── transaction_item.dart
│   │   │   │   ├── payment.dart
│   │   │   │   ├── payment_method.dart
│   │   │   │   ├── payment_status.dart
│   │   │   │   ├── receipt.dart
│   │   │   │   ├── sales_report.dart
│   │   │   │   └── store_info.dart
│   │   │   │
│   │   │   ├── repositories/
│   │   │   │   ├── transaction_repository.dart
│   │   │   │   ├── category_repository.dart
│   │   │   │   └── supplier_repository.dart
│   │   │   │
│   │   │   └── usecases/
│   │   │       ├── create_transaction_usecase.dart
│   │   │       ├── get_transactions_usecase.dart
│   │   │       ├── refund_transaction_usecase.dart
│   │   │       ├── validate_payment_usecase.dart
│   │   │       ├── generate_receipt_usecase.dart
│   │   │       ├── generate_sales_report_usecase.dart
│   │   │       └── export_sales_to_csv_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── sales_history_screen.dart
│   │       │   └── sales_report_screen.dart
│   │       │
│   │       └── widgets/
│   │           ├── receipt_options_dialog.dart
│   │           └── low_stock_alert_badge.dart
│   │
│   └── shared/                        # Shared Components
│       └── presentation/
│           ├── widgets/
│           │   ├── price_text.dart
│           │   └── quantity_input.dart
│           │
│           └── screens/
│               └── main_navigation.dart
│
├── services/                          # Global Services
│   └── database/
│       └── database_helper.dart       # SQLite setup
│
└── l10n/                              # Localization
    ├── app_en.arb                     # English translations
    └── app_id.arb                     # Indonesian translations
```

---

## Design Patterns

### 1. Repository Pattern

**Purpose:** Abstracts data access logic, providing a collection-like interface for accessing domain objects.

**Implementation:**

```dart
// Domain Layer - Interface
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<List<Product>> searchProducts(String query);
}

// Data Layer - Implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getProducts() async {
    final productMaps = await localDataSource.getAllProducts();
    return productMaps.map((map) => Product.fromMap(map)).toList();
  }

  // ... other methods
}
```

**Benefits:**
- Domain layer doesn't know about data sources (SQLite, API, etc.)
- Easy to swap data sources without changing business logic
- Testable - can mock repositories in tests

### 2. Use Case Pattern

**Purpose:** Encapsulates a single piece of business logic (Application Specific Business Rule).

**Implementation:**

```dart
class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase({required this.repository});

  Future<Product> execute(Product product) async {
    // Validate
    product.validate();

    // Check for duplicates
    final existing = await repository.searchProducts(product.name);
    if (existing.any((p) => p.name == product.name)) {
      throw ValidationException('Produk dengan nama ini sudah ada');
    }

    // Add product
    return await repository.addProduct(product);
  }
}
```

**Benefits:**
- Business logic is reusable across the application
- Easy to test - single responsibility
- Clear intent - use case name describes what it does

### 3. Dependency Inversion Principle (DIP)

**Purpose:** High-level modules (domain) should not depend on low-level modules (data). Both should depend on abstractions.

**Implementation:**

```dart
// Domain layer defines interface
abstract class ProductRepository {
  Future<List<Product>> getProducts();
}

// Data layer implements interface
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getProducts() async {
    // Implementation
  }
}

// Presentation layer uses interface
class InventoryController extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;

  InventoryController({required this.getProductsUseCase});

  // Controller doesn't know about ProductRepositoryImpl
}
```

**Benefits:**
- Can swap implementations without changing business logic
- Easy to mock for testing
- Flexible architecture

### 4. Provider Pattern (State Management)

**Purpose:** Manages UI state using Flutter's Provider package.

**Implementation:**

```dart
// Controller extends ChangeNotifier
class InventoryController extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  InventoryController({required this.getProductsUseCase});

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await getProductsUseCase.execute();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Widget uses Provider
Consumer<InventoryController>(
  builder: (context, controller, child) {
    if (controller.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: controller.products[index]);
      },
    );
  },
)
```

**Benefits:**
- Clean separation of business logic from UI
- Automatic UI updates when state changes
- Testable - can inject mock use cases

### 5. Entity Pattern

**Purpose:** Represents core business objects with validation logic.

**Implementation:**

```dart
class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final int? categoryId;
  final int? supplierId;
  final String? barcode;
  final double costPrice;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.categoryId,
    this.supplierId,
    this.barcode,
    this.costPrice = 0,
  });

  // Business logic
  bool get isOutOfStock => stock == 0;
  bool get isLowStock => stock > 0 && stock <= 10;
  double get profitMargin => (price - costPrice) / price * 100;

  // Validation
  void validate() {
    Validators.validateProductName(name);
    Validators.validatePrice(price);
    Validators.validateStock(stock);
  }

  // Convert to/from Map for database storage
  Map<String, dynamic> toMap() { ... }
  static Product fromMap(Map<String, dynamic> map) { ... }
}
```

**Benefits:**
- Business logic lives with the entity
- Self-validating objects
- Clear, immutable data structures

---

## Database Architecture

### Schema Design

```sql
-- Products Table
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  price REAL NOT NULL,
  stock INTEGER NOT NULL,
  category_id INTEGER,
  supplier_id INTEGER,
  barcode TEXT UNIQUE,
  cost_price REAL DEFAULT 0,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Categories Table
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TEXT NOT NULL
);

-- Suppliers Table
CREATE TABLE suppliers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  contact_person TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  created_at TEXT NOT NULL
);

-- Transactions Table
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_date TEXT NOT NULL,
  subtotal REAL NOT NULL,
  tax REAL NOT NULL DEFAULT 0,
  discount REAL NOT NULL DEFAULT 0,
  total_amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  payment_status TEXT NOT NULL DEFAULT 'completed',
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Transaction Items Table
CREATE TABLE transaction_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  subtotal REAL NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Payments Table
CREATE TABLE payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_id INTEGER NOT NULL,
  payment_method TEXT NOT NULL,
  amount REAL NOT NULL,
  cash_received REAL,
  card_last_4_digits TEXT,
  payment_date TEXT NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
);
```

### Indexes

For performance optimization:

```sql
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id);
```

### Migration System

```dart
class DatabaseHelper {
  static const int _databaseVersion = 2;

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
  }

  Future _migrateToV2(Database db) async {
    // Add new tables
    await db.execute('CREATE TABLE categories ...');
    await db.execute('CREATE TABLE suppliers ...');

    // Add new columns
    await db.execute('ALTER TABLE products ADD COLUMN category_id INTEGER');
    await db.execute('ALTER TABLE products ADD COLUMN supplier_id INTEGER');
    await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT');
    await db.execute('ALTER TABLE products ADD COLUMN cost_price REAL DEFAULT 0');

    // Create indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)');
  }
}
```

---

## State Management

### Provider Setup

```dart
// main.dart
class POSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Database
        Provider<DatabaseHelper>(
          lazy: false,
          create: (_) => DatabaseHelper.instance,
        ),

        // Inventory - Data Layer
        ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(
          update: (_, db, __) => ProductLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(
          update: (_, dataSource, __) => ProductRepositoryImpl(localDataSource: dataSource),
        ),

        // Inventory - Domain Layer (Use Cases)
        ProxyProvider<ProductRepositoryImpl, GetProductsUseCase>(
          update: (_, repo, __) => GetProductsUseCase(repository: repo),
        ),

        // Inventory - Presentation Layer (Controller)
        ChangeNotifierProxyProvider<GetProductsUseCase, InventoryController>(
          create: (context) => InventoryController(
            getProductsUseCase: context.read(),
          ),
          update: (_, getProductsUseCase, controller) =>
              controller ?? InventoryController(
                getProductsUseCase: getProductsUseCase,
              ),
        ),
      ],
      child: MaterialApp(...),
    );
  }
}
```

### Controller Pattern

Controllers extend `ChangeNotifier` and manage state for a feature:

```dart
class InventoryController extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  InventoryController({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.searchProductsUseCase,
  });

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await getProductsUseCase.execute();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await addProductUseCase.execute(product);
      await loadProducts(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
```

---

## Data Flow

### Example: Adding a Product

```
1. User clicks "Add Product" button
   ↓
2. UI calls controller.addProduct(product)
   ↓
3. Controller calls AddProductUseCase.execute(product)
   ↓
4. Use Case validates product
   ↓
5. Use Case calls repository.addProduct(product)
   ↓
6. Repository Implementation calls dataSource.insertProduct(product.toMap())
   ↓
7. Data Source executes SQL INSERT
   ↓
8. Data Source returns new product with ID
   ↓
9. Repository maps to Product entity and returns
   ↓
10. Use Case returns Product
   ↓
11. Controller calls loadProducts() to refresh list
   ↓
12. Controller notifies listeners
   ↓
13. UI rebuilds with new product list
```

### Error Flow

```
1. Validation fails in use case
   ↓
2. Use Case throws ValidationException
   ↓
3. Controller catches exception
   ↓
4. Controller sets errorMessage
   ↓
5. Controller calls notifyListeners()
   ↓
6. UI shows error message
```

---

## Dependency Injection

### Provider Chain

Dependencies are injected from outer layers to inner layers:

```
Presentation (Controller)
    ↓ depends on
Domain (Use Cases)
    ↓ depends on
Domain (Repository Interfaces)
    ↓ implemented by
Data (Repository Implementations)
    ↓ depends on
Data (Data Sources)
    ↓ depends on
Core (Database Helper)
```

### Example: Inventory Feature

```dart
// main.dart - Dependency graph setup
MultiProvider(
  providers: [
    // Level 1: Database
    Provider<DatabaseHelper>(...),

    // Level 2: Data Sources
    ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(...),

    // Level 3: Repository Implementation
    ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(...),

    // Level 4: Use Cases (depend on Repository interface)
    ProxyProvider<ProductRepositoryImpl, GetProductsUseCase>(...),
    ProxyProvider<ProductRepositoryImpl, AddProductUseCase>(...),
    ProxyProvider<ProductRepositoryImpl, UpdateProductUseCase>(...),
    ProxyProvider<ProductRepositoryImpl, DeleteProductUseCase>(...),
    ProxyProvider<ProductRepositoryImpl, SearchProductsUseCase>(...),

    // Level 5: Controller (depends on Use Cases)
    ChangeNotifierProxyProvider5<
      GetProductsUseCase,
      AddProductUseCase,
      UpdateProductUseCase,
      DeleteProductUseCase,
      SearchProductsUseCase,
      InventoryController
    >(...),
  ],
)
```

---

## Error Handling Strategy

### Exception Hierarchy

```dart
// Base exception
class AppException implements Exception {
  final String message;
  AppException(this.message);
}

// Specific exceptions
class ValidationException extends AppException { ... }
class NotFoundException extends AppException { ... }
class DatabaseException extends AppException { ... }
class InsufficientStockException extends AppException { ... }
class EmptyCartException extends AppException { ... }
```

### Error Handling Flow

```dart
// In Use Case
Future<Product> execute(Product product) async {
  // Validate
  if (product.name.isEmpty) {
    throw ValidationException('Nama produk harus diisi');
  }

  // Try operation
  try {
    return await repository.addProduct(product);
  } on DatabaseException catch (e) {
    throw AppException('Gagal menambahkan produk: ${e.message}');
  }
}

// In Controller
Future<void> addProduct(Product product) async {
  try {
    await addProductUseCase.execute(product);
    await loadProducts();
  } catch (e) {
    errorMessage = e.toString();
    notifyListeners();
    rethrow; // Let UI handle display
  }
}

// In UI
onPressed: () async {
  try {
    await controller.addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  } catch (e) {
    ErrorHandlers.handleException(
      context: context,
      exception: e,
    );
  }
}
```

### Error Dialogs

```dart
// Centralized error handling
class ErrorHandlers {
  static void handleException({
    required BuildContext context,
    required Object exception,
  }) {
    String title = 'Error';
    String message = 'Terjadi kesalahan yang tidak terduga';

    if (exception is ValidationException) {
      title = 'Validasi Error';
      message = exception.message;
    } else if (exception is DatabaseException) {
      title = 'Database Error';
      message = exception.message;
    }

    showErrorDialog(
      context: context,
      title: title,
      message: message,
    );
  }
}
```

---

## Testing Strategy

### Test Pyramid

```
        E2E Tests (Integration)
       /                      \
      /                        \
     /                          \
    /                            \
   /    Widget Tests (UI)         \
  /                                  \
 /    Unit Tests (Business Logic)     \
----------------------------------------
|                                        |
|         Domain Layer                   |
|         (Entities, Use Cases)          |
|                                        |
-----------------------------------------
```

### Unit Tests

Test business logic in isolation:

```dart
test('should calculate profit margin correctly', () {
  // Arrange
  final product = Product(
    name: 'Test',
    price: 100,
    stock: 10,
    costPrice: 60,
  );

  // Act
  final margin = product.profitMargin;

  // Assert
  expect(margin, 40.0);
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('should display product list', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<InventoryController>(
        create: (_) => mockController,
        child: InventoryScreen(),
      ),
    ),
  );

  expect(find.text('Product 1'), findsOneWidget);
});
```

### Integration Tests

Test complete workflows:

```dart
testWidgets('should complete checkout flow', (tester) async {
  // Launch app
  app.main();
  await tester.pumpAndSettle();

  // Add products to cart
  await tester.tap(find.byKey(Key('product_1')));
  await tester.pumpAndSettle();

  // Go to checkout
  await tester.tap(find.text('Checkout'));
  await tester.pumpAndSettle();

  // Verify checkout dialog
  expect(find.text('Konfirmasi Checkout'), findsOneWidget);
});
```

### Mocking

Use Mockito to mock dependencies:

```dart
@GenerateMocks([ProductRepository])
import 'add_product_usecase_test.mocks.dart';

test('should add product via repository', () async {
  final mockRepo = MockProductRepository();
  final useCase = AddProductUseCase(repository: mockRepo);

  when(mockRepo.addProduct(any))
      .thenAnswer((_) async => testProduct);

  final result = await useCase.execute(testProduct);

  verify(mockRepo.addProduct(testProduct)).called(1);
  expect(result.name, 'Test Product');
});
```

---

## Architecture Benefits

### 1. Testability
- Business logic can be tested without UI
- Easy to mock dependencies
- Fast unit tests

### 2. Maintainability
- Clear separation of concerns
- Easy to locate code
- Changes are isolated to specific layers

### 3. Scalability
- Easy to add new features
- Can swap implementations (e.g., change from SQLite to API)
- Clear patterns to follow

### 4. Flexibility
- UI can change without affecting business logic
- Database can change without affecting business logic
- Easy to add new data sources

### 5. Reusability
- Use cases can be reused across different UIs
- Entities can be reused across different features
- Utilities can be shared across the app

---

## Best Practices

1. **Follow Dependency Rule** - Inner layers must NOT depend on outer layers
2. **Use Interfaces** - Depend on abstractions, not concretions
3. **Keep Entities Simple** - No dependencies on frameworks or other layers
4. **One Use Case = One Action** - Each use case should do one thing
5. **Validate in Use Cases** - Business validation goes in domain layer
6. **Handle Errors Gracefully** - Use custom exceptions and error handlers
7. **Test Everything** - Unit tests for business logic, widget tests for UI
8. **Use DI** - Let Provider manage object creation and lifecycles
9. **Keep Controllers Thin** - Controllers should coordinate, not contain business logic
10. **Document Your Code** - Use dartdoc for public APIs

---

## Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Provider Package](https://pub.dev/packages/provider)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)

---

**Last Updated:** February 2025

**Maintained by:** Simple POS Development Team
