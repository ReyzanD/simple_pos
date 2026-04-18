# Riverpod Migration & Codebase Chunking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the entire codebase from Provider to Riverpod v2 state management while simultaneously chunking large files into smaller, maintainable units across 5 phases over 4-6 weeks.

**Architecture:** Feature-by-feature migration with widget extraction. Each phase follows the pattern: extract widgets → create Riverpod providers → migrate controllers to Notifiers → test → verify → commit. Maintain Clean Architecture principles with proper layering (presentation → domain → data).

**Tech Stack:** Flutter, Riverpod v2 (flutter_riverpod ^2.4.0, riverpod_annotation ^2.3.0), build_runner ^2.4.0, riverpod_generator ^2.3.0

---

## File Structure Mapping

### Phase 1: Inventory Feature
- Create: `lib/riverpod_config.dart` (global Riverpod configuration)
- Create: `lib/features/inventory/presentation/providers/inventory_providers.dart` (Riverpod version)
- Modify: `lib/main.dart` (simplify to Riverpod ProviderScope)
- Modify: `lib/features/inventory/presentation/screens/inventory_screen.dart` (update to use Riverpod)
- Create: `lib/features/inventory/presentation/widgets/product_list_item.dart` (extracted widget)
- Create: `lib/features/inventory/presentation/widgets/product_grid_item.dart` (extracted widget)
- Delete: `lib/features/inventory/domain/providers/inventory_providers.dart` (old Provider version)
- Modify: `lib/features/inventory/presentation/controllers/inventory_controller.dart` (migrate to Riverpod, will be replaced)

### Phase 2: POS Feature
- Create: `lib/features/pos/presentation/providers/pos_providers.dart` (Riverpod version)
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart` (update to use Riverpod)
- Create: `lib/features/pos/presentation/widgets/product_card.dart` (extracted widget)
- Create: `lib/features/pos/presentation/widgets/cart_summary.dart` (extracted widget)
- Create: `lib/features/pos/presentation/widgets/checkout_dialog.dart` (extracted widget)
- Create: `lib/features/pos/presentation/widgets/quantity_selector.dart` (extracted widget)
- Create: `lib/features/pos/presentation/widgets/favorite_toggle.dart` (extracted widget)
- Delete: `lib/features/pos/domain/providers/pos_providers.dart` (old Provider version)
- Modify: `lib/features/pos/presentation/controllers/pos_controller.dart` (migrate to Riverpod, will be replaced)
- Modify: `lib/features/pos/presentation/controllers/cart_controller.dart` (migrate to Riverpod, will be replaced)

### Phase 3: Sales/Analytics Feature
- Create: `lib/features/sales/presentation/providers/sales_providers.dart` (Riverpod version)
- Modify: `lib/features/sales/presentation/screens/sales_report_screen.dart` (update to use Riverpod)
- Create: `lib/features/sales/presentation/widgets/report_summary_cards.dart` (extracted widget)
- Create: `lib/features/sales/presentation/widgets/report_chart_section.dart` (extracted widget)
- Create: `lib/features/sales/presentation/widgets/report_transaction_list.dart` (extracted widget)
- Create: `lib/features/sales/presentation/widgets/report_filter_dialog.dart` (extracted widget)
- Delete: `lib/features/sales/domain/providers/sales_providers.dart` (old Provider version)
- Modify: `lib/features/sales/presentation/controllers/sales_report_controller.dart` (migrate to Riverpod, will be replaced)
- Modify: `lib/features/sales/presentation/controllers/analytics_controller.dart` (migrate to Riverpod, will be replaced)

### Phase 4: Backup Feature
- Create: `lib/features/backup/presentation/providers/backup_providers.dart` (Riverpod version)
- Modify: `lib/features/backup/presentation/screens/backup_screen.dart` (update to use Riverpod)
- Create: `lib/features/backup/presentation/widgets/backup_storage_status.dart` (extracted widget)
- Create: `lib/features/backup/presentation/widgets/backup_progress_bar.dart` (extracted widget)
- Create: `lib/features/backup/presentation/widgets/backup_list_item.dart` (extracted widget)
- Delete: `lib/features/backup/domain/providers/backup_providers.dart` (old Provider version)
- Modify: `lib/features/backup/presentation/controllers/backup_controller.dart` (migrate to Riverpod, will be replaced)

### Phase 5: Settings & Other Features
- Modify: `lib/features/settings/presentation/controllers/settings_controller.dart` (migrate to Riverpod)
- Modify: `lib/features/users/presentation/controllers/auth_controller.dart` (migrate to Riverpod)
- Modify: `lib/features/expenses/presentation/controllers/expense_controller.dart` (migrate to Riverpod)
- Modify: `lib/features/shifts/presentation/controllers/shift_controller.dart` (migrate to Riverpod)
- Modify: `lib/features/sales/presentation/controllers/refund_controller.dart` (migrate to Riverpod)
- Modify: `lib/features/sales/presentation/controllers/discount_controller.dart` (migrate to Riverpod)
- Delete: `lib/core/providers/` (entire directory)

---

## Phase 1: Inventory Feature (Week 1)

### Task 1: Add Riverpod Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add Riverpod dependencies to pubspec.yaml**

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Keep existing dependencies...
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  # Keep existing dev dependencies...
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
```

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: Dependencies installed successfully

- [ ] **Step 3: Commit dependency changes**

Run: `git add pubspec.yaml pubspec.lock`
Run: `git commit -m "feat: add Riverpod v2 dependencies"`

---

### Task 2: Create Riverpod Configuration File

**Files:**
- Create: `lib/riverpod_config.dart`

- [ ] **Step 1: Create riverpod_config.dart with global providers**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';
import 'core/controllers/theme_controller.dart';

part 'riverpod_config.g.dart';

/// Database provider for dependency injection
@riverpod
DatabaseHelper database() {
  return DatabaseHelper.instance;
}

/// Theme mode provider for app-wide theme management
@riverpod
ThemeMode themeMode() {
  return ThemeMode.system;
}

/// Theme controller provider (transition from old Provider)
@riverpod
ThemeController themeController() {
  return ThemeController()..init();
}
```

- [ ] **Step 2: Generate Riverpod code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: Riverpod generated files created successfully

- [ ] **Step 3: Add riverpod_config.dart to main.dart imports**

Modify: `lib/main.dart` - Add import line:
```dart
import 'riverpod_config.dart';
```

- [ ] **Step 4: Commit configuration file**

Run: `git add lib/riverpod_config.dart lib/main.dart .dart_tool/`
Run: `git commit -m "feat: add Riverpod configuration file"`

---

### Task 3: Simplify main.dart to Use Riverpod

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace MultiProvider with ProviderScope**

Replace entire `POSApp.build()` method:
```dart
class POSApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      locale: const Locale('id'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigation(),
    );
  }
}
```

- [ ] **Step 2: Replace void main() to use ProviderScope**

```dart
void main() {
  runApp(
    const ProviderScope(
      child: POSApp(),
    ),
  );
}
```

- [ ] **Step 3: Remove all Provider provider imports**

Remove these imports from main.dart:
```dart
import 'package:provider/provider.dart';
import 'package:simple_pos/core/providers/core_providers.dart';
import 'package:simple_pos/features/expenses/domain/providers/expenses_providers.dart';
import 'package:simple_pos/features/inventory/domain/providers/inventory_providers.dart';
import 'package:simple_pos/features/sales/domain/providers/sales_providers.dart';
import 'package:simple_pos/features/settings/domain/providers/settings_providers.dart';
import 'package:simple_pos/features/shifts/domain/providers/shifts_providers.dart';
import 'package:simple_pos/features/users/domain/providers/users_providers.dart';
import 'package:simple_pos/features/pos/domain/providers/pos_providers.dart';
```

- [ ] **Step 4: Test app launch**

Run: `flutter run`
Expected: App launches without errors, MainNavigation screen displays

- [ ] **Step 5: Commit main.dart changes**

Run: `git add lib/main.dart`
Run: `git commit -m "refactor: migrate main.dart to Riverpod ProviderScope"`

---

### Task 4: Create Inventory Riverpod Providers

**Files:**
- Create: `lib/features/inventory/presentation/providers/inventory_providers.dart`

- [ ] **Step 1: Create inventory_providers.dart with Riverpod structure**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/import_products_from_csv_usecase.dart';
import '../../domain/entities/product.dart';

part 'inventory_providers.g.dart';

/// Get products use case provider
@riverpod
GetProductsUseCase getProductsUseCase(GetProductsUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository: repo);
}

/// Add product use case provider
@riverpod
AddProductUseCase addProductUseCase(AddProductUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return AddProductUseCase(repository: repo);
}

/// Update product use case provider
@riverpod
UpdateProductUseCase updateProductUseCase(UpdateProductUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return UpdateProductUseCase(repository: repo);
}

/// Delete product use case provider
@riverpod
DeleteProductUseCase deleteProductUseCase(DeleteProductUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return DeleteProductUseCase(repository: repo);
}

/// Search products use case provider
@riverpod
SearchProductsUseCase searchProductsUseCase(SearchProductsUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return SearchProductsUseCase(repository: repo);
}

/// Import from CSV use case provider
@riverpod
ImportProductsFromCsvUseCase importProductsFromCsvUseCase(ImportProductsFromCsvUseCaseRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ImportProductsFromCsvUseCase(repository: repo);
}

/// Product repository provider
@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  final dataSource = ProductLocalDataSourceImpl(databaseHelper: db);
  return ProductRepositoryImpl(localDataSource: dataSource);
}

/// Product local data source provider
@riverpod
ProductLocalDataSourceImpl productLocalDataSource(ProductLocalDataSourceImplRef ref) {
  final db = ref.watch(databaseProvider);
  return ProductLocalDataSourceImpl(databaseHelper: db);
}

/// Inventory notifier - manages inventory state and operations
@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  List<Product> build() {
    return [];
  }
  
  Future<void> loadProducts() async {
    final useCase = ref.read(getProductsUseCaseProvider);
    state = await useCase.execute();
  }
  
  Future<void> addProduct({
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    String? imagePath,
    bool hasVariants = false,
  }) async {
    final useCase = ref.read(addProductUseCaseProvider);
    final product = Product(
      name: name,
      price: price,
      costPrice: costPrice,
      stock: stock,
      categoryId: categoryId,
      supplierId: supplierId,
      barcode: barcode,
      imagePath: imagePath,
      hasVariants: hasVariants,
    );
    
    await useCase.execute(product);
    await loadProducts();
  }
  
  Future<void> updateProductFields({
    required int productId,
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
  }) async {
    final useCase = ref.read(updateProductUseCaseProvider);
    final product = Product(
      id: productId,
      name: name,
      price: price,
      costPrice: costPrice,
      stock: stock,
      categoryId: categoryId,
      supplierId: supplierId,
      barcode: barcode,
    );
    
    await useCase.execute(product);
    await loadProducts();
  }
  
  Future<void> deleteProduct(int productId) async {
    final useCase = ref.read(deleteProductUseCaseProvider);
    await useCase.execute(productId);
    await loadProducts();
  }
  
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts();
      return;
    }
    
    final useCase = ref.read(searchProductsUseCaseProvider);
    state = await useCase.execute(query);
  }
  
  Future<void> importProductsFromCsv(
    List<Product> products,
    String username,
  ) async {
    final useCase = ref.read(importProductsFromCsvUseCaseProvider);
    await useCase.execute(products, username);
    await loadProducts();
  }
}

final inventoryProvider = notifierProvider<InventoryNotifier, List<Product>>(InventoryNotifier.new);
```

- [ ] **Step 2: Generate Riverpod code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: inventory_providers.g.dart generated successfully

- [ ] **Step 3: Commit Riverpod providers**

Run: `git add lib/features/inventory/presentation/providers/inventory_providers.dart lib/features/inventory/presentation/providers/inventory_providers.g.dart`
Run: `git commit -m "feat: create Riverpod inventory providers"`

---

### Task 5: Extract ProductListItem Widget

**Files:**
- Create: `lib/features/inventory/presentation/widgets/product_list_item.dart`
- Modify: `lib/features/inventory/presentation/screens/inventory_screen.dart`

- [ ] **Step 1: Create product_list_item.dart widget file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/product.dart';
import '../providers/inventory_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neo_brutal_theme.dart';

/// ProductListItem
///
/// **Purpose:** Display product in list view with quick actions
///
/// **Used by:** InventoryScreen
///
/// **State:** ConsumerWidget (data from Riverpod)
class ProductListItem extends ConsumerWidget {
  final Product product;
  final int index;
  final List<Category> categories;
  final List<Supplier> suppliers;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddStock;

  const ProductListItem({
    required this.product,
    required this.index,
    required this.categories,
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
    required this.onAddStock,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryName = categories
        .firstWhere((cat) => cat.id == product.categoryId,
            orElse: () => Category(id: 0, name: 'Uncategorized'))
        .name;
    
    final supplierName = suppliers
        .firstWhere((sup) => sup.id == product.supplierId,
            orElse: () => Supplier(id: 0, name: 'Unknown'))
        .name;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: product.imagePath != null
                    ? const Icon(Icons.inventory_2_outlined,
                        size: 32, color: AppTheme.textSecondary)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(product.imagePath!,
                            fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit product',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                    onPressed: onAddStock,
                    tooltip: 'Add stock',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete product',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  Color _getStockColor() {
    if (product.stock <= 0) return AppTheme.errorColor;
    if (product.stock <= 10) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  IconData _getStockIcon() {
    if (product.stock <= 0) return Icons.block;
    if (product.stock <= 10) return Icons.warning_amber;
    return Icons.check_circle;
  }
}
```

- [ ] **Step 2: Update inventory_screen.dart to use ProductListItem**

Replace the existing `_ProductListItem` class with import and usage:
```dart
import 'widgets/product_list_item.dart';

ProductListItem(
  product: product,
  index: index,
  categories: categoryController.categories,
  suppliers: supplierController.suppliers,
  onEdit: () => _showEditDialog(context, product),
  onDelete: () => _showDeleteDialog(context, product),
  onAddStock: () => _showAddStockDialog(context, product),
)
```

- [ ] **Step 3: Test product list item rendering**

Run: `flutter run`
Expected: Product list displays correctly, animations work

- [ ] **Step 4: Commit widget extraction**

Run: `git add lib/features/inventory/presentation/widgets/product_list_item.dart lib/features/inventory/presentation/screens/inventory_screen.dart`
Run: `git commit -m "refactor: extract ProductListItem widget"`

---

### Task 6: Extract ProductGridItem Widget

**Files:**
- Create: `lib/features/inventory/presentation/widgets/product_grid_item.dart`
- Modify: `lib/features/inventory/presentation/screens/inventory_screen.dart`

- [ ] **Step 1: Create product_grid_item.dart widget file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/product.dart';
import '../providers/inventory_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neo_brutal_theme.dart';

/// ProductGridItem
///
/// **Purpose:** Display product in grid view with quick actions
///
/// **Used by:** InventoryScreen
///
/// **State:** ConsumerWidget
class ProductGridItem extends ConsumerWidget {
  final Product product;
  final int index;
  final List<Category> categories;
  final List<Supplier> suppliers;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddStock;

  const ProductGridItem({
    required this.product,
    required this.index,
    required this.categories,
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
    required this.onAddStock,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryName = categories
        .firstWhere((cat) => cat.id == product.categoryId,
            orElse: () => Category(id: 0, name: 'Uncategorized'))
        .name;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: product.imagePath != null
                    ? const Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppTheme.textSecondary)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(product.imagePath!,
                            fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit product',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                    onPressed: onAddStock,
                    tooltip: 'Add stock',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete product',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms);
  }
}
```

- [ ] **Step 2: Update inventory_screen.dart to use ProductGridItem**

Replace the existing `_ProductGridItem` class with import and usage:
```dart
import 'widgets/product_grid_item.dart';

ProductGridItem(
  product: product,
  index: index,
  categories: categoryController.categories,
  suppliers: supplierController.suppliers,
  onEdit: () => _showEditDialog(context, product),
  onDelete: () => _showDeleteDialog(context, product),
  onAddStock: () => _showAddStockDialog(context, product),
)
```

- [ ] **Step 3: Test product grid item rendering**

Run: `flutter run`
Expected: Product grid displays correctly, animations work

- [ ] **Step 4: Commit widget extraction**

Run: `git add lib/features/inventory/presentation/widgets/product_grid_item.dart lib/features/inventory/presentation/screens/inventory_screen.dart`
Run: `git commit -m "refactor: extract ProductGridItem widget"`

---

### Task 7: Update Inventory Screen to Use Riverpod

**Files:**
- Modify: `lib/features/inventory/presentation/screens/inventory_screen.dart`

- [ ] **Step 1: Replace Consumer3 with Consumer**

Replace the `body` Consumer3 with:
```dart
body: Consumer(
  builder: (context, ref, _) {
    final inventoryState = ref.watch(inventoryProvider);
    final categoryState = ref.watch(categoryProvider);
    final supplierState = ref.watch(supplierProvider);
```

- [ ] **Step 2: Replace controller references with Riverpod providers**

Replace all `context.read<InventoryController>()` with `ref.read(inventoryProvider.notifier)`
Replace all `context.read<CategoryController>()` with `ref.read(categoryProvider.notifier)`
Replace all `context.read<SupplierController>()` with `ref.read(supplierProvider.notifier)`

- [ ] **Step 3: Update state references**

Replace `inventoryController.products` with `inventoryState`
Replace `inventoryController.isLoading` with appropriate loading state
Replace `inventoryController.error` with error handling

- [ ] **Step 4: Test inventory screen with Riverpod**

Run: `flutter run`
Expected: Inventory screen works, products load, search/filter works

- [ ] **Step 5: Commit screen updates**

Run: `git add lib/features/inventory/presentation/screens/inventory_screen.dart`
Run: `git commit -m "refactor: update inventory screen to use Riverpod"`

---

### Task 8: Create Inventory Unit Tests

**Files:**
- Create: `test/features/inventory/presentation/providers/inventory_notifier_test.dart`

- [ ] **Step 1: Create test file structure**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:simple_pos/features/inventory/domain/usecases/get_products_usecase.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';

void main() {
  group('InventoryNotifier', () {
    late ProviderContainer container;
    late MockGetProductsUseCase mockGetProductsUseCase;
    late MockAddProductUseCase mockAddProductUseCase;
    
    setUp(() {
      mockGetProductsUseCase = MockGetProductsUseCase();
      mockAddProductUseCase = MockAddProductUseCase();
      
      container = ProviderContainer(
        overrides: [
          getProductsUseCaseProvider.overrideWithValue(mockGetProductsUseCase),
          addProductUseCaseProvider.overrideWithValue(mockAddProductUseCase),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('loadProducts should update state with products', () async {
      final testProducts = [
        Product(id: 1, name: 'Test Product', price: 10.0, costPrice: 8.0, stock: 5),
      ];
      
      when(mockGetProductsUseCase.execute())
          .thenAnswer((_) async => testProducts);
      
      await container.read(inventoryProvider.notifier).loadProducts();
      
      expect(container.read(inventoryProvider), equals(testProducts));
    });
    
    test('addProduct should add product and refresh list', () async {
      final newProduct = Product(id: 2, name: 'New Product', price: 15.0, costPrice: 12.0, stock: 10);
      
      when(mockAddProductUseCase.execute(any))
          .thenAnswer((_) async => {});
      when(mockGetProductsUseCase.execute())
          .thenAnswer((_) async => [newProduct]);
      
      await container.read(inventoryProvider.notifier).addProduct(
        name: 'New Product',
        price: 15.0,
        costPrice: 12.0,
        stock: 10,
      );
      
      verify(mockAddProductUseCase.execute(newProduct)).called(1);
      verify(mockGetProductsUseCase.execute()).called(1);
    });
  });
}
```

- [ ] **Step 2: Run inventory tests**

Run: `flutter test test/features/inventory/presentation/providers/inventory_notifier_test.dart`
Expected: All tests pass

- [ ] **Step 3: Commit tests**

Run: `git add test/features/inventory/presentation/providers/inventory_notifier_test.dart`
Run: `git commit -m "test: add inventory notifier unit tests"`

---

### Task 9: Delete Old Inventory Provider File

**Files:**
- Delete: `lib/features/inventory/domain/providers/inventory_providers.dart`

- [ ] **Step 1: Delete old Provider version**

Run: `rm "lib/features/inventory/domain/providers/inventory_providers.dart"`

- [ ] **Step 2: Test app still works**

Run: `flutter run`
Expected: App launches and works correctly

- [ ] **Step 3: Commit cleanup**

Run: `git add lib/features/inventory/domain/providers/inventory_providers.dart`
Run: `git commit -m "refactor: remove old inventory Provider file"`

---

### Task 10: Phase 1 Verification & Commit

- [ ] **Step 1: Run full integration test for inventory**

Run: `flutter run`
Test checklist:
- [ ] Products load correctly
- [ ] Add product works
- [ ] Edit product works
- [ ] Delete product works
- [ ] Search works
- [ ] Filters work
- [ ] Stock management works
- [ ] No console errors

- [ ] **Step 2: Create phase completion commit**

Run: `git add .`
Run: `git commit -m "feat: complete Phase 1 - Inventory feature migrated to Riverpod"`

---

## Phase 2: POS Feature (Week 2)

### Task 11: Create POS Riverpod Providers

**Files:**
- Create: `lib/features/pos/presentation/providers/pos_providers.dart`

- [ ] **Step 1: Create pos_providers.dart with Riverpod structure**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

part 'pos_providers.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() => [];
  
  Future<void> addToCart(Product product, int quantity) async {
    final useCase = ref.read(addToCartUseCaseProvider);
    await useCase.execute(product, quantity);
    state = await ref.read(cartListProvider);
  }
  
  Future<void> removeFromCart(int productId) async {
    final useCase = ref.read(removeFromCartUseCaseProvider);
    await useCase.execute(productId);
    state = await ref.read(cartListProvider);
  }
  
  Future<void> clearCart() async {
    state = [];
  }
}

final cartProvider = notifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
```

- [ ] **Step 2: Generate Riverpod code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: pos_providers.g.dart generated successfully

- [ ] **Step 3: Commit POS providers**

Run: `git add lib/features/pos/presentation/providers/pos_providers.dart lib/features/pos/presentation/providers/pos_providers.g.dart`
Run: `git commit -m "feat: create Riverpod POS providers"`

---

### Task 12: Extract ProductCard Widget

**Files:**
- Create: `lib/features/pos/presentation/widgets/product_card.dart`
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart`

- [ ] **Step 1: Create product_card.dart widget file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/product.dart';
import '../providers/pos_providers.dart';
import '../../../core/theme/app_theme.dart';

/// ProductCard
///
/// **Purpose:** Display product card in POS with add to cart action
///
/// **Used by:** POSScreen
///
/// **State:** ConsumerWidget
class ProductCard extends ConsumerWidget {
  final Product product;
  final int index;
  final VoidCallback onTap;

  const ProductCard({
    required this.product,
    required this.index,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final inCart = cartState.any((item) => item.productId == product.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imagePath != null
                    ? const Icon(Icons.inventory_2_outlined, size: 40)
                    : Image.asset(product.imagePath!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Rp ${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (inCart)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                      SizedBox(width: 4),
                      Text('In cart', style: TextStyle(fontSize: 12, color: AppTheme.successColor)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 300.ms);
  }
}
```

- [ ] **Step 2: Update pos_screen.dart to use ProductCard**

Replace existing product card widget with import and usage.

- [ ] **Step 3: Test product card rendering**

Run: `flutter run`
Expected: Product cards display correctly

- [ ] **Step 4: Commit widget extraction**

Run: `git add lib/features/pos/presentation/widgets/product_card.dart lib/features/pos/presentation/screens/pos_screen.dart`
Run: `git commit -m "refactor: extract ProductCard widget"`

---

### Task 13: Extract CartSummary Widget

**Files:**
- Create: `lib/features/pos/presentation/widgets/cart_summary.dart`
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart`

- [ ] **Step 1: Create cart_summary.dart widget file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/pos_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/modern_button.dart';

/// CartSummary
///
/// **Purpose:** Display cart total and checkout button
///
/// **Used by:** POSScreen
///
/// **State:** ConsumerWidget
class CartSummary extends ConsumerWidget {
  final VoidCallback onCheckout;

  const CartSummary({
    required this.onCheckout,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final total = cartState.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cart Total',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            ModernButton(
              text: 'Checkout',
              icon: Icons.payment,
              onPressed: onCheckout,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update pos_screen.dart to use CartSummary**

Replace existing cart summary with import and usage.

- [ ] **Step 3: Test cart summary rendering**

Run: `flutter run`
Expected: Cart summary displays total correctly

- [ ] **Step 4: Commit widget extraction**

Run: `git add lib/features/pos/presentation/widgets/cart_summary.dart lib/features/pos/presentation/screens/pos_screen.dart`
Run: `git commit -m "refactor: extract CartSummary widget"`

---

### Task 14: Update POS Screen to Use Riverpod

**Files:**
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart`

- [ ] **Step 1: Replace Provider consumers with Riverpod**

Replace all `Consumer<POSController>` with `Consumer` and `ref.watch(cartProvider)`

- [ ] **Step 2: Update controller references**

Replace all `context.read<POSController>()` with `ref.read(cartProvider.notifier)`
Replace all `context.read<CartController>()` with `ref.read(cartProvider.notifier)`

- [ ] **Step 3: Test POS screen with Riverpod**

Run: `flutter run`
Expected: POS screen works, cart functions, checkout works

- [ ] **Step 4: Commit screen updates**

Run: `git add lib/features/pos/presentation/screens/pos_screen.dart`
Run: `git commit -m "refactor: update POS screen to use Riverpod"`

---

### Task 15: Create POS Unit Tests

**Files:**
- Create: `test/features/pos/presentation/providers/cart_notifier_test.dart`

- [ ] **Step 1: Create cart notifier test file**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart';
import 'package:simple_pos/features/pos/domain/entities/product.dart';

void main() {
  group('CartNotifier', () {
    late ProviderContainer container;
    late MockAddToCartUseCase mockAddToCartUseCase;
    
    setUp(() {
      mockAddToCartUseCase = MockAddToCartUseCase();
      container = ProviderContainer(
        overrides: [
          addToCartUseCaseProvider.overrideWithValue(mockAddToCartUseCase),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('addToCart should add item to cart', () async {
      final product = Product(id: 1, name: 'Test', price: 10.0, costPrice: 8.0, stock: 5);
      final cartItem = CartItem(productId: 1, quantity: 2, price: 10.0);
      
      when(mockAddToCartUseCase.execute(any, any))
          .thenAnswer((_) async => {});
      
      await container.read(cartProvider.notifier).addToCart(product, 2);
      
      verify(mockAddToCartUseCase.execute(product, 2)).called(1);
    });
  });
}
```

- [ ] **Step 2: Run POS tests**

Run: `flutter test test/features/pos/presentation/providers/cart_notifier_test.dart`
Expected: All tests pass

- [ ] **Step 3: Commit tests**

Run: `git add test/features/pos/presentation/providers/cart_notifier_test.dart`
Run: `git commit -m "test: add POS notifier unit tests"`

---

### Task 16: Delete Old POS Provider Files

**Files:**
- Delete: `lib/features/pos/domain/providers/pos_providers.dart`

- [ ] **Step 1: Delete old Provider version**

Run: `rm "lib/features/pos/domain/providers/pos_providers.dart"`

- [ ] **Step 2: Test app still works**

Run: `flutter run`
Expected: App launches and POS works correctly

- [ ] **Step 3: Commit cleanup**

Run: `git add lib/features/pos/domain/providers/pos_providers.dart`
Run: `git commit -m "refactor: remove old POS Provider file"`

---

### Task 17: Phase 2 Verification & Commit

- [ ] **Step 1: Run full integration test for POS**

Run: `flutter run`
Test checklist:
- [ ] Cart loads correctly
- [ ] Add to cart works
- [ ] Remove from cart works
- [ ] Cart updates in real-time
- [ ] Checkout works
- [ ] Payment methods work
- [ ] No console errors

- [ ] **Step 2: Create phase completion commit**

Run: `git add .`
Run: `git commit -m "feat: complete Phase 2 - POS feature migrated to Riverpod"`

---

## Phase 3: Sales/Analytics Feature (Week 3)

### Task 18: Create Sales Riverpod Providers

**Files:**
- Create: `lib/features/sales/presentation/providers/sales_providers.dart`

- [ ] **Step 1: Create sales_providers.dart with Riverpod structure**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/get_sales_report_usecase.dart';
import '../../domain/usecases/get_transaction_history_usecase.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/transaction.dart';

part 'sales_providers.g.dart';

@riverpod
class SalesReportNotifier extends _$SalesReportNotifier {
  @override
  SalesReport? build() => null;
  
  Future<void> loadReport() async {
    final useCase = ref.read(getSalesReportUseCaseProvider);
    state = await useCase.execute();
  }
}

final salesReportProvider = notifierProvider<SalesReportNotifier, SalesReport?>(SalesReportNotifier.new);

@riverpod
class TransactionHistoryNotifier extends _$TransactionHistoryNotifier {
  @override
  List<Transaction> build() => [];
  
  Future<void> loadTransactions() async {
    final useCase = ref.read(getTransactionHistoryUseCaseProvider);
    state = await useCase.execute();
  }
}

final transactionHistoryProvider = notifierProvider<TransactionHistoryNotifier, List<Transaction>>(TransactionHistoryNotifier.new);
```

- [ ] **Step 2: Generate Riverpod code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: sales_providers.g.dart generated successfully

- [ ] **Step 3: Commit sales providers**

Run: `git add lib/features/sales/presentation/providers/sales_providers.dart lib/features/sales/presentation/providers/sales_providers.g.dart`
Run: `git commit -m "feat: create Riverpod sales providers"`

---

### Task 19: Extract ReportSummaryCards Widget

**Files:**
- Create: `lib/features/sales/presentation/widgets/report_summary_cards.dart`
- Modify: `lib/features/sales/presentation/screens/sales_report_screen.dart`

- [ ] **Step 1: Create report_summary_cards.dart widget file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sales_report.dart';
import '../providers/sales_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/modern_stat_card.dart';

/// ReportSummaryCards
///
/// **Purpose:** Display KPI summary cards for sales report
///
/// **Used by:** SalesReportScreen
///
/// **State:** ConsumerWidget
class ReportSummaryCards extends ConsumerWidget {
  const ReportSummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(salesReportProvider);
    
    if (reportState == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ModernStatCard(
          title: 'Total Sales',
          value: 'Rp ${reportState!.totalSales.toStringAsFixed(0)}',
          icon: Icons.trending_up,
          iconColor: AppTheme.successColor,
        ),
        const SizedBox(height: 12),
        ModernStatCard(
          title: 'Total Transactions',
          value: '${reportState!.transactionCount}',
          icon: Icons.receipt_long,
          iconColor: AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        ModernStatCard(
          title: 'Total Profit',
          value: 'Rp ${reportState!.totalProfit.toStringAsFixed(0)}',
          icon: Icons.attach_money,
          iconColor: AppTheme.successColor,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Update sales_report_screen.dart to use ReportSummaryCards**

Replace existing summary cards with import and usage.

- [ ] **Step 3: Test report summary cards**

Run: `flutter run`
Expected: Summary cards display correctly

- [ ] **Step 4: Commit widget extraction**

Run: `git add lib/features/sales/presentation/widgets/report_summary_cards.dart lib/features/sales/presentation/screens/sales_report_screen.dart`
Run: `git commit -m "refactor: extract ReportSummaryCards widget"`

---

### Task 20: Update Sales Report Screen to Use Riverpod

**Files:**
- Modify: `lib/features/sales/presentation/screens/sales_report_screen.dart`

- [ ] **Step 1: Replace Provider consumers with Riverpod**

Replace all `Consumer<SalesReportController>` with `Consumer` and `ref.watch(salesReportProvider)`

- [ ] **Step 2: Update controller references**

Replace all `context.read<SalesReportController>()` with `ref.read(salesReportProvider.notifier)`

- [ ] **Step 3: Test sales report screen with Riverpod**

Run: `flutter run`
Expected: Sales report screen works, data loads correctly

- [ ] **Step 4: Commit screen updates**

Run: `git add lib/features/sales/presentation/screens/sales_report_screen.dart`
Run: `git commit -m "refactor: update sales report screen to use Riverpod"`

---

### Task 21: Phase 3 Verification & Commit

- [ ] **Step 1: Run full integration test for sales**

Run: `flutter run`
Test checklist:
- [ ] Reports load correctly
- [ ] Charts display
- [ ] Transaction history shows
- [ ] Filter options work
- [ ] No console errors

- [ ] **Step 2: Create phase completion commit**

Run: `git add .`
Run: `git commit -m "feat: complete Phase 3 - Sales/Analytics feature migrated to Riverpod"`

---

## Phase 4: Backup Feature (Week 4)

### Task 22: Create Backup Riverpod Providers

**Files:**
- Create: `lib/features/backup/presentation/providers/backup_providers.dart`

- [ ] **Step 1: Create backup_providers.dart with Riverpod structure**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/create_backup_usecase.dart';
import '../../domain/usecases/restore_backup_usecase.dart';
import '../../domain/entities/backup.dart';

part 'backup_providers.g.dart';

@riverpod
class BackupNotifier extends _$BackupNotifier {
  @override
  List<Backup> build() => [];
  
  Future<void> loadBackups() async {
    final useCase = ref.read(getBackupsUseCaseProvider);
    state = await useCase.execute();
  }
  
  Future<void> createBackup(String name) async {
    final useCase = ref.read(createBackupUseCaseProvider);
    await useCase.execute(name);
    await loadBackups();
  }
  
  Future<void> restoreBackup(Backup backup) async {
    final useCase = ref.read(restoreBackupUseCaseProvider);
    await useCase.execute(backup);
  }
}

final backupProvider = notifierProvider<BackupNotifier, List<Backup>>(BackupNotifier.new);
```

- [ ] **Step 2: Generate Riverpod code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: backup_providers.g.dart generated successfully

- [ ] **Step 3: Commit backup providers**

Run: `git add lib/features/backup/presentation/providers/backup_providers.dart lib/features/backup/presentation/providers/backup_providers.g.dart`
Run: `git commit -m "feat: create Riverpod backup providers"`

---

### Task 23: Extract Backup Storage Status Widget

**Files:**
- Create: `lib/features/backup/presentation/widgets/backup_storage_status.dart`
- Modify: `lib/features/backup/presentation/screens/backup_screen.dart`

- [ ] **Step 1: Create backup_storage_status.dart widget file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/backup_providers.dart';
import '../../../core/theme/app_theme.dart';

/// BackupStorageStatus
///
/// **Purpose:** Display storage usage statistics
///
/// **Used by:** BackupScreen
///
/// **State:** ConsumerWidget
class BackupStorageStatus extends ConsumerWidget {
  const BackupStorageStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Storage Usage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppTheme.backgroundColor,
              valueColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              '50% used',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update backup_screen.dart to use BackupStorageStatus**

Replace existing storage status widget with import and usage.

- [ ] **Step 3: Test backup storage status widget**

Run: `flutter run`
Expected: Storage status displays correctly

- [ ] **Step 4: Commit widget extraction**

Run: `git add lib/features/backup/presentation/widgets/backup_storage_status.dart lib/features/backup/presentation/screens/backup_screen.dart`
Run: `git commit -m "refactor: extract BackupStorageStatus widget"`

---

### Task 24: Update Backup Screen to Use Riverpod

**Files:**
- Modify: `lib/features/backup/presentation/screens/backup_screen.dart`

- [ ] **Step 1: Replace Provider consumers with Riverpod**

Replace all `Consumer<BackupController>` with `Consumer` and `ref.watch(backupProvider)`

- [ ] **Step 2: Update controller references**

Replace all `context.read<BackupController>()` with `ref.read(backupProvider.notifier)`

- [ ] **Step 3: Test backup screen with Riverpod**

Run: `flutter run`
Expected: Backup screen works, operations function correctly

- [ ] **Step 4: Commit screen updates**

Run: `git add lib/features/backup/presentation/screens/backup_screen.dart`
Run: `git commit -m "refactor: update backup screen to use Riverpod"`

---

### Task 25: Phase 4 Verification & Commit

- [ ] **Step 1: Run full integration test for backup**

Run: `flutter run`
Test checklist:
- [ ] Backups load correctly
- [ ] Create backup works
- [ ] Restore backup works
- [ ] Delete backup works
- [ ] No console errors

- [ ] **Step 2: Create phase completion commit**

Run: `git add .`
Run: `git commit -m "feat: complete Phase 4 - Backup feature migrated to Riverpod"`

---

## Phase 5: Settings & Other Features (Weeks 5-6)

### Task 26: Migrate Remaining Controllers to Riverpod

**Files:**
- Modify: Multiple controller files

- [ ] **Step 1: Migrate SettingsController**

Update `lib/features/settings/presentation/controllers/settings_controller.dart` to use Riverpod patterns instead of ChangeNotifier.

- [ ] **Step 2: Migrate AuthController**

Update `lib/features/users/presentation/controllers/auth_controller.dart` to use Riverpod patterns.

- [ ] **Step 3: Migrate ExpenseController**

Update `lib/features/expenses/presentation/controllers/expense_controller.dart` to use Riverpod patterns.

- [ ] **Step 4: Migrate remaining controllers**

Update remaining controllers: ShiftController, RefundController, DiscountController

- [ ] **Step 5: Test all migrated controllers**

Run: `flutter run`
Expected: All features work correctly with Riverpod

- [ ] **Step 6: Commit controller migrations**

Run: `git add lib/features/settings/presentation/controllers/settings_controller.dart lib/features/users/presentation/controllers/auth_controller.dart lib/features/expenses/presentation/controllers/expense_controller.dart lib/features/shifts/presentation/controllers/shift_controller.dart lib/features/sales/presentation/controllers/refund_controller.dart lib/features/sales/presentation/controllers/discount_controller.dart`
Run: `git commit -m "refactor: migrate remaining controllers to Riverpod"`

---

### Task 27: Remove Core Providers Directory

**Files:**
- Delete: `lib/core/providers/`

- [ ] **Step 1: Remove entire providers directory**

Run: `rm -rf "lib/core/providers/"`

- [ ] **Step 2: Test app still works**

Run: `flutter run`
Expected: App launches and all features work correctly

- [ ] **Step 3: Commit cleanup**

Run: `git add lib/core/providers/`
Run: `git commit -m "refactor: remove core providers directory"`

---

### Task 28: Final Testing & Verification

- [ ] **Step 1: Run comprehensive test suite**

Run: `flutter test --coverage`
Expected: All tests pass, coverage meets targets

- [ ] **Step 2: Run integration tests**

Run: `flutter test integration_test/`
Expected: All integration tests pass

- [ ] **Step 3: Analyze code quality**

Run: `flutter analyze`
Expected: No issues

- [ ] **Step 4: Format code**

Run: `dart format .`
Expected: All files formatted

- [ ] **Step 5: Build release APK**

Run: `flutter build apk --release`
Expected: Build succeeds

---

### Task 29: Update Documentation

**Files:**
- Modify: `README.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update README with Riverpod information**

Add migration guide section explaining the transition from Provider to Riverpod.

- [ ] **Step 2: Update CLAUDE.md with new architecture**

Update architecture documentation to reflect Riverpod patterns.

- [ ] **Step 3: Commit documentation updates**

Run: `git add README.md CLAUDE.md`
Run: `git commit -m "docs: update documentation for Riverpod migration"`

---

### Task 30: Final Commit & Tag Release

- [ ] **Step 1: Create final commit**

Run: `git add .`
Run: `git commit -m "feat: complete Riverpod migration and codebase chunking"`

- [ ] **Step 2: Create release tag**

Run: `git tag -a v2.0.0 -m "Riverpod migration complete - feature-by-feature approach with widget chunking"`

- [ ] **Step 3: Push to remote**

Run: `git push origin master`
Run: `git push origin v2.0.0`

---

## Testing Strategy

### Run Tests After Each Phase

```bash
flutter test test/features/[current-feature]/
flutter run
flutter analyze
dart format .
```

### Coverage Goals

Unit tests: 70%+ coverage
Widget tests: 50%+ coverage
Integration tests: Critical paths covered

### Performance Benchmarks

App cold start < 3 seconds
Hot reload < 2 seconds
Smooth scrolling with 1000+ products
No memory leaks

---

## Success Criteria

### Code Quality
No Provider remains in main.dart
All controllers migrated to Notifiers
All large files reduced to < 500 lines
40-50 new widget files created

### Functional
All features work: POS, Inventory, Sales, Backup, Settings
No regression bugs
Performance maintained or improved

### Testing
Unit tests pass with 70%+ coverage
Widget tests pass with 50%+ coverage
Integration tests pass for critical flows

### Architecture
Clean Riverpod architecture
Proper layering maintained
Type-safe dependency injection
Well-organized file structure

---

**End of Implementation Plan**