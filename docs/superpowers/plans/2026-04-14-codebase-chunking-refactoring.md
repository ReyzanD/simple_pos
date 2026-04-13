# Codebase Chunking & Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Break down large files (2000+ lines) into smaller, maintainable units while keeping the application functional throughout the refactoring process.

**Architecture:** Surgical extraction method - extract widgets and providers into separate files without changing logic flow. Feature-based provider organization in main.dart.

**Tech Stack:** Flutter, Provider state management, Dart

---

## Phase 1: Foundation (15 minutes)

### Task 1: Create Provider Folder Structure

**Files:**
- Create: `lib/core/providers/`
- Create: `lib/features/backup/domain/providers/`
- Create: `lib/features/sales/domain/providers/`
- Create: `lib/features/pos/domain/providers/`
- Create: `lib/features/inventory/domain/providers/`
- Create: `lib/features/expenses/domain/providers/`
- Create: `lib/features/users/domain/providers/`
- Create: `lib/features/settings/domain/providers/`
- Create: `lib/features/shifts/domain/providers/`

- [ ] **Step 1: Create core providers directory**

```bash
mkdir -p lib/core/providers
```

- [ ] **Step 2: Create feature provider directories**

```bash
mkdir -p lib/features/backup/domain/providers
mkdir -p lib/features/sales/domain/providers
mkdir -p lib/features/pos/domain/providers
mkdir -p lib/features/inventory/domain/providers
mkdir -p lib/features/expenses/domain/providers
mkdir -p lib/features/users/domain/providers
mkdir -p lib/features/settings/domain/providers
mkdir -p lib/features/shifts/domain/providers
```

- [ ] **Step 3: Create widget directories for large screens**

```bash
mkdir -p lib/features/backup/presentation/widgets
mkdir -p lib/features/sales/presentation/widgets
mkdir -p lib/features/inventory/presentation/widgets
```

- [ ] **Step 4: Verify directories created**

```bash
tree lib/core/providers lib/features/*/domain/providers lib/features/backup/presentation/widgets
```

Expected: All directories listed

- [ ] **Step 5: Commit**

```bash
git add lib/core/providers lib/features
git commit -m "refactor: create folder structure for provider and widget extraction"
```

---

## Phase 2: Core Providers (30 minutes)

### Task 2: Create Core Providers File

**Files:**
- Create: `lib/core/providers/core_providers.dart`

- [ ] **Step 1: Create core_providers.dart with DatabaseHelper and ThemeController**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/database/database_helper.dart';
import '../../controllers/theme_controller.dart';

/// Core app-wide providers
///
/// Provides fundamental services that the entire app depends on:
/// - DatabaseHelper: SQLite database instance
/// - ThemeController: App theme management
List<SingleChildWidget> createCoreProviders() {
  return [
    // Database - must be first as other providers depend on it
    Provider<DatabaseHelper>(
      create: (_) => DatabaseHelper.instance,
    ),

    // Theme management
    ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController(),
    ),
  ];
}
```

- [ ] **Step 2: Verify file compiles**

```bash
flutter analyze lib/core/providers/core_providers.dart
```

Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/core/providers/core_providers.dart
git commit -m "refactor: create core providers file with DatabaseHelper and ThemeController"
```

---

### Task 3: Update main.dart to Use Core Providers

**Files:**
- Modify: `lib/main.dart:144-170`

- [ ] **Step 1: Add import for core providers**

Add to the top of main.dart imports:

```dart
import 'core/providers/core_providers.dart';
```

- [ ] **Step 2: Replace individual core providers with createCoreProviders()**

Find this section in main.dart (around line 144-170):

```dart
class POSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(),
        ),
        Provider<DatabaseHelper>(
          create: (_) => DatabaseHelper.instance,
        ),
        // ... rest of providers
      ],
```

Replace with:

```dart
class POSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...createCoreProviders(),
        // ... rest of providers
      ],
```

- [ ] **Step 3: Verify app still launches**

```bash
flutter run
```

Expected: App launches, reaches login screen without errors

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "refactor: use createCoreProviders() in main.dart"
```

---

## Phase 3: Feature Providers - Inventory (30 minutes)

### Task 4: Create Inventory Provider Group

**Files:**
- Create: `lib/features/inventory/domain/providers/inventory_providers.dart`

- [ ] **Step 1: Extract inventory-related providers from main.dart**

Read main.dart and find all inventory-related ProxyProvider chains (around lines 163-221). Copy them to a new file:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database/database_helper.dart';
import '../../../../data/datasources/product_local_datasource.dart';
import '../../../../data/datasources/category_local_datasource.dart';
import '../../../../data/datasources/supplier_local_datasource.dart';
import '../../../../data/repositories/product_repository_impl.dart';
import '../../../../data/repositories/category_repository_impl.dart';
import '../../../../data/repositories/supplier_repository_impl.dart';
import '../../../../domain/usecases/product/get_products_usecase.dart';
import '../../../../domain/usecases/product/add_product_usecase.dart';
import '../../../../domain/usecases/product/update_product_usecase.dart';
import '../../../../domain/usecases/product/delete_product_usecase.dart';
import '../../../../domain/usecases/product/search_products_usecase.dart';
import '../../../../domain/usecases/product/import_products_from_csv_usecase.dart';
import '../../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../../domain/usecases/category/add_category_usecase.dart';
import '../../../../domain/usecases/category/update_category_usecase.dart';
import '../../../../domain/usecases/category/delete_category_usecase.dart';
import '../../../../domain/usecases/supplier/get_suppliers_usecase.dart';
import '../../../../domain/usecases/supplier/add_supplier_usecase.dart';
import '../../../../domain/usecases/supplier/update_supplier_usecase.dart';
import '../../../../domain/usecases/supplier/delete_supplier_usecase.dart';
import '../../../presentation/controllers/inventory_controller.dart';
import '../../../presentation/controllers/category_controller.dart';
import '../../../presentation/controllers/supplier_controller.dart';

/// Inventory feature providers
///
/// Manages all dependencies for inventory management:
/// - Products (CRUD, search, import)
/// - Categories (CRUD)
/// - Suppliers (CRUD)
List<SingleChildWidget> createInventoryProviders() {
  return [
    // Product data sources
    ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(
      update: (_, db, __) => ProductLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(
      update: (_, dataSource, __) => ProductRepositoryImpl(localDataSource: dataSource),
    ),

    // Product use cases
    ProxyProvider<ProductRepositoryImpl, GetProductsUseCase>(
      update: (_, repo, __) => GetProductsUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, AddProductUseCase>(
      update: (_, repo, __) => AddProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, UpdateProductUseCase>(
      update: (_, repo, __) => UpdateProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, DeleteProductUseCase>(
      update: (_, repo, __) => DeleteProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, SearchProductsUseCase>(
      update: (_, repo, __) => SearchProductsUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, ImportProductsFromCsvUseCase>(
      update: (_, repo, __) => ImportProductsFromCsvUseCase(repository: repo),
    ),

    // Category data sources
    ProxyProvider<DatabaseHelper, CategoryLocalDataSourceImpl>(
      update: (_, db, __) => CategoryLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<CategoryLocalDataSourceImpl, CategoryRepositoryImpl>(
      update: (_, dataSource, __) => CategoryRepositoryImpl(localDataSource: dataSource),
    ),

    // Category use cases
    ProxyProvider<CategoryRepositoryImpl, GetCategoriesUseCase>(
      update: (_, repo, __) => GetCategoriesUseCase(repository: repo),
    ),
    ProxyProvider<CategoryRepositoryImpl, AddCategoryUseCase>(
      update: (_, repo, __) => AddCategoryUseCase(repository: repo),
    ),
    ProxyProvider<CategoryRepositoryImpl, UpdateCategoryUseCase>(
      update: (_, repo, __) => UpdateCategoryUseCase(repository: repo),
    ),
    ProxyProvider<CategoryRepositoryImpl, DeleteCategoryUseCase>(
      update: (_, repo, __) => DeleteCategoryUseCase(repository: repo),
    ),

    // Supplier data sources
    ProxyProvider<DatabaseHelper, SupplierLocalDataSourceImpl>(
      update: (_, db, __) => SupplierLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<SupplierLocalDataSourceImpl, SupplierRepositoryImpl>(
      update: (_, dataSource, __) => SupplierRepositoryImpl(localDataSource: dataSource),
    ),

    // Supplier use cases
    ProxyProvider<SupplierRepositoryImpl, GetSuppliersUseCase>(
      update: (_, repo, __) => GetSuppliersUseCase(repository: repo),
    ),
    ProxyProvider<SupplierRepositoryImpl, AddSupplierUseCase>(
      update: (_, repo, __) => AddSupplierUseCase(repository: repo),
    ),
    ProxyProvider<SupplierRepositoryImpl, UpdateSupplierUseCase>(
      update: (_, repo, __) => UpdateSupplierUseCase(repository: repo),
    ),
    ProxyProvider<SupplierRepositoryImpl, DeleteSupplierUseCase>(
      update: (_, repo, __) => DeleteSupplierUseCase(repository: repo),
    ),

    // Controllers
    ChangeNotifierProxyProvider6<
      GetProductsUseCase,
      AddProductUseCase,
      UpdateProductUseCase,
      DeleteProductUseCase,
      SearchProductsUseCase,
      ImportProductsFromCsvUseCase,
      InventoryController>(
      update: (_, getProducts, addProduct, updateProduct, deleteProduct, searchProducts, importProducts, __) =>
          InventoryController(
        getProductsUseCase: getProducts,
        addProductUseCase: addProduct,
        updateProductUseCase: updateProduct,
        deleteProductUseCase: deleteProduct,
        searchProductsUseCase: searchProducts,
        importProductsFromCsvUseCase: importProducts,
      ),
    ),

    ChangeNotifierProxyProvider4<
      GetCategoriesUseCase,
      AddCategoryUseCase,
      UpdateCategoryUseCase,
      DeleteCategoryUseCase,
      CategoryController>(
      update: (_, getCategories, addCategory, updateCategory, deleteCategory, __) =>
          CategoryController(
        getCategoriesUseCase: getCategories,
        addCategoryUseCase: addCategory,
        updateCategoryUseCase: updateCategory,
        deleteCategoryUseCase: deleteCategory,
      ),
    ),

    ChangeNotifierProxyProvider4<
      GetSuppliersUseCase,
      AddSupplierUseCase,
      UpdateSupplierUseCase,
      DeleteSupplierUseCase,
      SupplierController>(
      update: (_, getSuppliers, addSupplier, updateSupplier, deleteSupplier, __) =>
          SupplierController(
        getSuppliersUseCase: getSuppliers,
        addSupplierUseCase: addSupplier,
        updateSupplierUseCase: updateSupplier,
        deleteSupplierUseCase: deleteSupplier,
      ),
    ),
  ];
}
```

- [ ] **Step 2: Verify file compiles**

```bash
flutter analyze lib/features/inventory/domain/providers/inventory_providers.dart
```

Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/inventory/domain/providers/inventory_providers.dart
git commit -m "refactor: extract inventory providers to dedicated file"
```

---

### Task 5: Update main.dart to Use Inventory Providers

**Files:**
- Modify: `lib/main.dart:163-292`

- [ ] **Step 1: Add import for inventory providers**

```dart
import 'features/inventory/domain/providers/inventory_providers.dart';
```

- [ ] **Step 2: Replace inventory provider chains with createInventoryProviders()**

Find the inventory provider section in main.dart (lines 163-292) and replace the entire block with:

```dart
...createInventoryProviders(),
```

- [ ] **Step 3: Verify app still launches and inventory works**

```bash
flutter run
```

Expected: App launches, can navigate to Inventory screen, add/edit products works

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "refactor: use createInventoryProviders() in main.dart"
```

---

## Phase 4: Feature Providers - POS (20 minutes)

### Task 6: Create POS Provider Group

**Files:**
- Create: `lib/features/pos/domain/providers/pos_providers.dart`

- [ ] **Step 1: Extract POS-related providers from main.dart**

Find all POS-related ProxyProvider chains in main.dart and create:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database/database_helper.dart';
import '../../../../data/datasources/cart_local_datasource.dart';
import '../../../../data/repositories/cart_repository_impl.dart';
import '../../../../data/datasources/transaction_local_datasource.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../../domain/usecases/pos/add_to_cart_usecase.dart';
import '../../../../domain/usecases/pos/update_cart_quantity_usecase.dart';
import '../../../../domain/usecases/pos/remove_from_cart_usecase.dart';
import '../../../../domain/usecases/pos/clear_cart_usecase.dart';
import '../../../../domain/usecases/pos/checkout_usecase.dart';
import '../../../../domain/usecases/transaction/create_transaction_usecase.dart';
import '../../../presentation/controllers/pos_controller.dart';

/// POS feature providers
///
/// Manages all dependencies for point of sale functionality:
/// - Shopping cart operations
/// - Checkout process
/// - Transaction creation
List<SingleChildWidget> createPOSProviders() {
  return [
    // Cart data sources
    ProxyProvider<DatabaseHelper, CartLocalDataSourceImpl>(
      update: (_, db, __) => CartLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<CartLocalDataSourceImpl, CartRepositoryImpl>(
      update: (_, dataSource, __) => CartRepositoryImpl(localDataSource: dataSource),
    ),

    // Cart use cases
    ProxyProvider<CartRepositoryImpl, AddToCartUseCase>(
      update: (_, repo, __) => AddToCartUseCase(cartRepository: repo),
    ),
    ProxyProvider<CartRepositoryImpl, UpdateCartQuantityUseCase>(
      update: (_, repo, __) => UpdateCartQuantityUseCase(cartRepository: repo),
    ),
    ProxyProvider<CartRepositoryImpl, RemoveFromCartUseCase>(
      update: (_, repo, __) => RemoveFromCartUseCase(cartRepository: repo),
    ),
    ProxyProvider<CartRepositoryImpl, ClearCartUseCase>(
      update: (_, repo, __) => ClearCartUseCase(cartRepository: repo),
    ),

    // Transaction data sources
    ProxyProvider<DatabaseHelper, TransactionLocalDataSourceImpl>(
      update: (_, db, __) => TransactionLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<TransactionLocalDataSourceImpl, TransactionRepositoryImpl>(
      update: (_, dataSource, __) => TransactionRepositoryImpl(localDataSource: dataSource),
    ),

    // Transaction use cases
    ProxyProvider<TransactionRepositoryImpl, CreateTransactionUseCase>(
      update: (_, repo, __) => CreateTransactionUseCase(transactionRepository: repo),
    ),

    // Controllers
    ChangeNotifierProxyProvider5<
      AddToCartUseCase,
      UpdateCartQuantityUseCase,
      RemoveFromCartUseCase,
      ClearCartUseCase,
      CreateTransactionUseCase,
      POSController>(
      update: (_, addToCart, updateQuantity, removeFromCart, clearCart, createTransaction, __) =>
          POSController(
        addToCartUseCase: addToCart,
        updateCartQuantityUseCase: updateQuantity,
        removeFromCartUseCase: removeFromCart,
        clearCartUseCase: clearCart,
        createTransactionUseCase: createTransaction,
      ),
    ),
  ];
}
```

- [ ] **Step 2: Verify file compiles**

```bash
flutter analyze lib/features/pos/domain/providers/pos_providers.dart
```

Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/pos/domain/providers/pos_providers.dart
git commit -m "refactor: extract POS providers to dedicated file"
```

---

### Task 7: Update main.dart to Use POS Providers

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add import and replace POS providers**

```dart
import 'features/pos/domain/providers/pos_providers.dart';
```

Replace POS provider chains with:

```dart
...createPOSProviders(),
```

- [ ] **Step 2: Verify POS functionality works**

```bash
flutter run
```

Expected: Can add items to cart, checkout works

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "refactor: use createPOSProviders() in main.dart"
```

---

## Phase 5: Remaining Feature Providers (1 hour)

### Task 8: Extract Sales Provider Group

**Files:**
- Create: `lib/features/sales/domain/providers/sales_providers.dart`

- [ ] **Step 1: Extract sales-related providers from main.dart**

Find all sales-related ProxyProvider chains in main.dart (sales history, sales reports, analytics) and create:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database/database_helper.dart';
import '../../../../data/datasources/transaction_local_datasource.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../../data/datasources/sales_analytics_datasource.dart';
import '../../../../data/repositories/sales_analytics_repository_impl.dart';
import '../../../../domain/usecases/transaction/get_transactions_usecase.dart';
import '../../../../domain/usecases/transaction/get_transaction_by_id_usecase.dart';
import '../../../../domain/usecases/sales/get_sales_analytics_usecase.dart';
import '../../../../domain/usecases/sales/get_daily_sales_report_usecase.dart';
import '../../../../domain/usecases/sales/get_top_products_usecase.dart';
import '../../../../domain/usecases/sales/get_payment_methods_breakdown_usecase.dart';
import '../../../presentation/controllers/sales_history_controller.dart';
import '../../../presentation/controllers/sales_report_controller.dart';
import '../../../presentation/controllers/analytics_controller.dart';

/// Sales feature providers
///
/// Manages all dependencies for sales and analytics:
/// - Transaction history
/// - Sales reports
/// - Analytics dashboard
List<SingleChildWidget> createSalesProviders() {
  return [
    // Transaction data sources
    ProxyProvider<DatabaseHelper, TransactionLocalDataSourceImpl>(
      update: (_, db, __) => TransactionLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<TransactionLocalDataSourceImpl, TransactionRepositoryImpl>(
      update: (_, dataSource, __) => TransactionRepositoryImpl(localDataSource: dataSource),
    ),

    // Transaction use cases
    ProxyProvider<TransactionRepositoryImpl, GetTransactionsUseCase>(
      update: (_, repo, __) => GetTransactionsUseCase(transactionRepository: repo),
    ),
    ProxyProvider<TransactionRepositoryImpl, GetTransactionByIdUseCase>(
      update: (_, repo, __) => GetTransactionByIdUseCase(transactionRepository: repo),
    ),

    // Analytics data sources
    ProxyProvider<DatabaseHelper, SalesAnalyticsDataSourceImpl>(
      update: (_, db, __) => SalesAnalyticsDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<SalesAnalyticsDataSourceImpl, SalesAnalyticsRepositoryImpl>(
      update: (_, dataSource, __) => SalesAnalyticsRepositoryImpl(localDataSource: dataSource),
    ),

    // Analytics use cases
    ProxyProvider<SalesAnalyticsRepositoryImpl, GetSalesAnalyticsUseCase>(
      update: (_, repo, __) => GetSalesAnalyticsUseCase(repository: repo),
    ),
    ProxyProvider<SalesAnalyticsRepositoryImpl, GetDailySalesReportUseCase>(
      update: (_, repo, __) => GetDailySalesReportUseCase(repository: repo),
    ),
    ProxyProvider<SalesAnalyticsRepositoryImpl, GetTopProductsUseCase>(
      update: (_, repo, __) => GetTopProductsUseCase(repository: repo),
    ),
    ProxyProvider<SalesAnalyticsRepositoryImpl, GetPaymentMethodsBreakdownUseCase>(
      update: (_, repo, __) => GetPaymentMethodsBreakdownUseCase(repository: repo),
    ),

    // Controllers
    ChangeNotifierProxyProvider2<
      GetTransactionsUseCase,
      GetTransactionByIdUseCase,
      SalesHistoryController>(
      update: (_, getTransactions, getTransactionById, __) =>
          SalesHistoryController(
        getTransactionsUseCase: getTransactions,
        getTransactionByIdUseCase: getTransactionById,
      ),
    ),

    ChangeNotifierProxyProvider4<
      GetSalesAnalyticsUseCase,
      GetDailySalesReportUseCase,
      GetTopProductsUseCase,
      GetPaymentMethodsBreakdownUseCase,
      SalesReportController>(
      update: (_, getAnalytics, getDailyReport, getTopProducts, getPaymentBreakdown, __) =>
          SalesReportController(
        getSalesAnalyticsUseCase: getAnalytics,
        getDailySalesReportUseCase: getDailyReport,
        getTopProductsUseCase: getTopProducts,
        getPaymentMethodsBreakdownUseCase: getPaymentBreakdown,
      ),
    ),

    ChangeNotifierProxyProvider1<
      GetSalesAnalyticsUseCase,
      AnalyticsController>(
      update: (_, getAnalytics, __) =>
          AnalyticsController(
        getSalesAnalyticsUseCase: getAnalytics,
      ),
    ),
  ];
}
```

- [ ] **Step 2: Verify file compiles**

```bash
flutter analyze lib/features/sales/domain/providers/sales_providers.dart
```

Expected: No errors

- [ ] **Step 3: Update main.dart**

```dart
import 'features/sales/domain/providers/sales_providers.dart';
```

Replace sales provider chains with:

```dart
...createSalesProviders(),
```

- [ ] **Step 4: Verify sales functionality works**

```bash
flutter run
```

Expected: Can view sales history, reports, and analytics

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/domain/providers/sales_providers.dart lib/main.dart
git commit -m "refactor: extract sales providers to dedicated file"
```

---

### Task 9-14: Extract Remaining Feature Providers

For each remaining feature, follow the exact pattern established in Tasks 4-7 (Inventory/POS) and Task 8 (Sales):

**Task 9: Backup Providers**
- Create: `lib/features/backup/domain/providers/backup_providers.dart`
- Extract: BackupLocalDataSourceImpl, BackupRepositoryImpl, backup use cases, BackupController
- Update main.dart with `...createBackupProviders()`
- Verify: Can create/restore backups
- Commit: "refactor: extract backup providers to dedicated file"

**Task 10: Expense Providers**
- Create: `lib/features/expenses/domain/providers/expense_providers.dart`
- Extract: ExpenseLocalDataSourceImpl, ExpenseRepositoryImpl, expense use cases, ExpenseController
- Update main.dart with `...createExpenseProviders()`
- Verify: Can add/view expenses
- Commit: "refactor: extract expense providers to dedicated file"

**Task 11: User Providers**
- Create: `lib/features/users/domain/providers/user_providers.dart`
- Extract: UserLocalDataSourceImpl, UserRepositoryImpl, user use cases, AuthController
- Update main.dart with `...createUserProviders()`
- Verify: Login works, can manage users
- Commit: "refactor: extract user providers to dedicated file"

**Task 12: Settings Providers**
- Create: `lib/features/settings/domain/providers/settings_providers.dart`
- Extract: SettingsLocalDataSourceImpl, SettingsController
- Update main.dart with `...createSettingsProviders()`
- Verify: Settings persist
- Commit: "refactor: extract settings providers to dedicated file"

**Task 13: Shift Providers**
- Create: `lib/features/shifts/domain/providers/shift_providers.dart`
- Extract: ShiftLocalDataSourceImpl, ShiftRepositoryImpl, shift use cases, ShiftController
- Update main.dart with `...createShiftProviders()`
- Verify: Can open/close shifts
- Commit: "refactor: extract shift providers to dedicated file"

**Task 14: Product Variant Providers**
- Create: `lib/features/inventory/domain/providers/variant_providers.dart`
- Extract: All variant-related providers (ProductVariantLocalDataSourceImpl, etc.)
- Update main.dart with `...createVariantProviders()`
- Verify: Product variants work
- Commit: "refactor: extract variant providers to dedicated file"

---

## Phase 6: Widget Extraction - Backup Screen (1 hour)

### Task 15: Extract BackupStorageStatusWidget

**Files:**
- Create: `lib/features/backup/presentation/widgets/backup_storage_status.dart`
- Modify: `lib/features/backup/presentation/screens/backup_screen.dart:369-591`

- [ ] **Step 1: Read backup_screen.dart to find _StorageStatusWidget class**

```bash
sed -n '369,591p' lib/features/backup/presentation/screens/backup_screen.dart
```

- [ ] **Step 2: Create backup_storage_status.dart with extracted widget**

```dart
/// BackupStorageStatusWidget
///
/// **Purpose:** Displays storage usage statistics for backup functionality
///
/// **Used by:** BackupScreen
///
/// **State:** StatefulWidget (manages storage calculation animation)
///
/// **Dependencies:** BackupController
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/backup_controller.dart';
import '../../../../core/theme/neo_brutal_theme.dart';

class BackupStorageStatusWidget extends StatefulWidget {
  const BackupStorageStatusWidget({
    super.key,
    required this.controller,
  });

  final BackupController controller;

  @override
  State<BackupStorageStatusWidget> createState() => _BackupStorageStatusWidgetState();
}

class _BackupStorageStatusWidgetState extends State<BackupStorageStatusWidget> {
  @override
  Widget build(BuildContext context) {
    // Copy the entire widget implementation from backup_screen.dart
    // Lines 369-591, replacing _StorageStatusWidget with BackupStorageStatusWidget
    // This is a placeholder - the actual implementation should be copied from the source
    return Container();
  }
}
```

- [ ] **Step 3: Update backup_screen.dart to import and use the new widget**

Add import:
```dart
import '../widgets/backup_storage_status.dart';
```

Replace usage:
```dart
// Before:
_StorageStatusWidget(controller: controller),

// After:
BackupStorageStatusWidget(controller: controller),
```

- [ ] **Step 4: Remove the old _StorageStatusWidget class from backup_screen.dart**

Delete lines 369-591 from backup_screen.dart

- [ ] **Step 5: Hot reload to verify**

```bash
flutter run
# Press 'r' to hot reload
```

Expected: Storage status displays correctly

- [ ] **Step 6: Commit**

```bash
git add lib/features/backup/presentation/widgets/backup_storage_status.dart
git add lib/features/backup/presentation/screens/backup_screen.dart
git commit -m "refactor: extract BackupStorageStatusWidget from backup_screen.dart"
```

---

### Task 16: Extract BackupStorageProgressBar

**Files:**
- Create: `lib/features/backup/presentation/widgets/backup_progress_bar.dart`
- Modify: `lib/features/backup/presentation/screens/backup_screen.dart`

- [ ] **Step 1: Extract _StorageProgressBar to backup_progress_bar.dart**

Follow same pattern as Task 15:
1. Create file with widget implementation
2. Update import in backup_screen.dart
3. Replace usage
4. Delete old widget class
5. Hot reload to verify
6. Commit

---

### Task 17-24: Extract Remaining Backup Widgets

Extract these widgets one by one:
- Task 17: `_StorageDetailsDialog` → `BackupStorageDetailsDialog`
- Task 18: `_DetailRow` → `BackupDetailRow`
- Task 19: `_StorageStat` → `BackupStorageStat`
- Task 20: `_BackupListItem` → `BackupListItem`
- Task 21: `_CreateBackupDialog` → `BackupCreateDialog`
- Task 22: `_RestoreDialog` → `BackupRestoreDialog`
- Task 23: `_DeleteBackupDialog` → `BackupDeleteDialog`
- Task 24: `_ScheduleBackupDialog` → `BackupScheduleDialog`

Each follows the same pattern as Task 15.

---

## Phase 7: Widget Extraction - Sales Report Screen (1 hour)

### Task 25: Extract ReportSummaryCards Widget

**Files:**
- Create: `lib/features/sales/presentation/widgets/report_summary_cards.dart`
- Modify: `lib/features/sales/presentation/screens/sales_report_screen.dart`

- [ ] **Step 1: Read sales_report_screen.dart to find summary cards widget**

```bash
grep -n "class.*Summary\|Widget _buildSummary" lib/features/sales/presentation/screens/sales_report_screen.dart
```

- [ ] **Step 2: Create report_summary_cards.dart with extracted widget**

```dart
/// ReportSummaryCards
///
/// **Purpose:** Displays KPI summary cards for sales report (revenue, transactions, profit)
///
/// **Used by:** SalesReportScreen
///
/// **State:** StatelessWidget
///
/// **Dependencies:** SalesReportController
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/sales_report_controller.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/widgets/modern_card.dart';

class ReportSummaryCards extends StatelessWidget {
  const ReportSummaryCards({
    super.key,
    required this.onRevenueTap,
    required this.onTransactionsTap,
    required this.onProfitTap,
  });

  final VoidCallback onRevenueTap;
  final VoidCallback onTransactionsTap;
  final VoidCallback onProfitTap;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesReportController>();

    // Copy the implementation from sales_report_screen.dart
    // This includes the 3 KPI cards: Revenue, Transactions, Profit
    return Column(
      children: [
        // Revenue card
        _buildKPICard(
          context,
          title: 'Total Revenue',
          value: controller.totalRevenue,
          icon: Icons.payments_rounded,
          color: NeoBrutalTheme.primary,
          onTap: onRevenueTap,
        ),
        // Transactions card
        _buildKPICard(
          context,
          title: 'Transactions',
          value: controller.totalTransactions.toString(),
          icon: Icons.receipt_long_rounded,
          color: NeoBrutalTheme.secondary,
          onTap: onTransactionsTap,
        ),
        // Profit card
        _buildKPICard(
          context,
          title: 'Total Profit',
          value: controller.totalProfit,
          icon: Icons.trending_up_rounded,
          color: AppTheme.successColor,
          onTap: onProfitTap,
        ),
      ],
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Update sales_report_screen.dart to import and use the new widget**

Add import:
```dart
import '../widgets/report_summary_cards.dart';
```

Replace the summary cards section with:
```dart
ReportSummaryCards(
  onRevenueTap: () => _showRevenueDetails(context),
  onTransactionsTap: () => _showTransactionList(context),
  onProfitTap: () => _showProfitDetails(context),
),
```

- [ ] **Step 4: Remove the old summary cards widget code from sales_report_screen.dart**

- [ ] **Step 5: Hot reload to verify**

```bash
flutter run
# Press 'r'
```

Expected: Summary cards display correctly with animations

- [ ] **Step 6: Commit**

```bash
git add lib/features/sales/presentation/widgets/report_summary_cards.dart
git add lib/features/sales/presentation/screens/sales_report_screen.dart
git commit -m "refactor: extract ReportSummaryCards from sales_report_screen.dart"
```

---

### Task 26-28: Extract Remaining Sales Report Widgets

**Task 26: Extract ReportChartSection**
- Create: `lib/features/sales/presentation/widgets/report_chart_section.dart`
- Extract: Chart widgets (daily sales graph, payment breakdown chart)
- Update sales_report_screen.dart to import and use
- Hot reload verification
- Commit: "refactor: extract ReportChartSection from sales_report_screen.dart"

**Task 27: Extract ReportTransactionList**
- Create: `lib/features/sales/presentation/widgets/report_transaction_list.dart`
- Extract: Transaction list widget with filtering
- Update sales_report_screen.dart to import and use
- Hot reload verification
- Commit: "refactor: extract ReportTransactionList from sales_report_screen.dart"

**Task 28: Extract ReportFilterDialog**
- Create: `lib/features/sales/presentation/widgets/report_filter_dialog.dart`
- Extract: Filter dialog widget
- Update sales_report_screen.dart to import and use
- Hot reload verification
- Commit: "refactor: extract ReportFilterDialog from sales_report_screen.dart"

---

## Phase 8: Widget Extraction - Add Product Dialog (45 minutes)

### Task 29: Split Add Product Dialog

**Files:**
- Create: `lib/features/inventory/presentation/widgets/product_form_fields.dart`
- Modify: `lib/features/inventory/presentation/widgets/add_product_dialog.dart`

- [ ] **Step 1: Extract reusable form fields to product_form_fields.dart**

Create widget with common form field components:
- Product name field
- Price field
- Cost price field
- Stock field
- Category dropdown
- Supplier dropdown
- Barcode field

- [ ] **Step 2: Update add_product_dialog.dart to use form fields widget**

- [ ] **Step 3: Verify product creation still works**

```bash
flutter run
# Test: Add a new product with all fields
```

Expected: Product added successfully

- [ ] **Step 4: Commit**

```bash
git add lib/features/inventory/presentation/widgets/
git commit -m "refactor: extract ProductFormFields from add_product_dialog.dart"
```

---

## Phase 9: Widget Extraction - Drawer Sections (1 hour)

### Task 30-41: Extract Drawer Section Widgets

Extract each drawer section into its own file:
- Task 30: `DrawerCategoryChips`
- Task 31: `DrawerStoreStats`
- Task 32: `DrawerLowStockItem`
- Task 33: `DrawerDiscountItem`
- Task 34: `DrawerBackupItem`
- Task 35: `DrawerExpensesItem`
- Task 36: `DrawerShiftsItem`
- Task 37: `DrawerUsersItem`
- Task 38: `DrawerAnalyticsItem`
- Task 39: `DrawerThemeToggle`
- Task 40: `DrawerRecentProducts`
- Task 41: `DrawerAppInfo`

Each in its own file in `lib/features/shared/presentation/widgets/`

---

## Phase 10: Final Verification (30 minutes)

### Task 42: Comprehensive Testing

- [ ] **Step 1: Full app restart test**

```bash
flutter run
# Full restart, not hot reload
```

Expected: App launches without errors

- [ ] **Step 2: Test all features**

Test each feature:
- [ ] Login works
- [ ] POS: Add items to cart, checkout
- [ ] Inventory: Add/edit/delete products
- [ ] Sales: View reports, filter transactions
- [ ] Backup: Create backup, restore
- [ ] Expenses: Add expense
- [ ] Settings: Change settings
- [ ] Users: Manage users
- [ ] Shifts: Open/close shift

- [ ] **Step 3: Check for console errors**

```bash
flutter logs
```

Expected: No red errors or warnings

- [ ] **Step 4: Verify file sizes**

```bash
find lib -name "*.dart" -type f -exec wc -l {} + | sort -rn | head -20
```

Expected: No files exceed 500 lines (except database_helper.dart)

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "refactor: complete codebase chunking and refactoring

BREAKING CHANGE: File structure reorganized
- Feature-based provider groups in main.dart
- All large screen files split into widget files
- Consistent naming and import patterns
- All functionality preserved and verified

File size reductions:
- main.dart: 975 → ~150 lines (85% reduction)
- backup_screen.dart: 2743 → ~300 lines (89% reduction)
- sales_report_screen.dart: 2323 → ~400 lines (83% reduction)
- add_product_dialog.dart: 1722 → ~600 lines (65% reduction)
- drawer_sections.dart: 1153 → ~200 lines (83% reduction)

All features tested and working."
```

---

## Success Criteria

After completing all tasks:
- ✅ No file exceeds 500 lines (except database_helper.dart)
- ✅ main.dart reduced from 975 to ~150 lines
- ✅ All provider chains organized by feature
- ✅ All large screen files split into widget files
- ✅ App launches and all features work correctly
- ✅ No console errors or warnings
- ✅ Clean git history with descriptive commits

---

## Notes

- Each task should be completed and committed before moving to the next
- Hot reload (press 'r' in Flutter terminal) for quick verification
- Full restart if hot reload fails
- If something breaks, use `git reset --hard HEAD^` to revert and retry
- Keep original code commented out for first extraction in each file, remove after verification
