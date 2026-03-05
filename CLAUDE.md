# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Design System (CRITICAL - ALWAYS FOLLOW)

### Color Palette
**Primary Colors:**
- **Primary**: `#4F46E5` (Indigo) - Main actions, active elements, navigation
- **Primary Light**: `#818CF8` - Hover states, lighter accents
- **Primary Dark**: `#3730A3` - Pressed states, darker accents

**Secondary Colors:**
- **Secondary**: `#14B8A6` (Teal) - Accents, secondary actions, cost prices
- **Secondary Light**: `#2DD4BF` - Teal hover states
- **Secondary Dark**: `#0F766E` - Teal pressed states

**Semantic Colors (Use for Status):**
- **Success**: `#10B981` (Green) - Available stock, success messages, profit
- **Warning**: `#F59E0B` (Amber) - Low stock alerts, warnings
- **Error**: `#EF4444` (Red) - Out of stock, errors, delete actions
- **Info**: `#3B82F6` (Blue) - Information, links, edit actions

**Neutral Colors:**
- **Background**: `#F9FAFB` - Main background
- **Surface/Card**: `#FFFFFF` - Card backgrounds
- **Text Primary**: `#111827` - Headings, important text
- **Text Secondary**: `#6B7280` - Body text, descriptions
- **Text Tertiary**: `#9CA3AF` - Placeholder text, disabled text
- **Border**: `#E5E7EB` - Dividers, borders
- **Divider**: `#F3F4F6` - Section dividers

**Access via `AppTheme` class:**
```dart
import 'package:simple_pos/core/theme/app_theme.dart';

AppTheme.primaryColor      // #4F46E5 Indigo
AppTheme.secondaryColor    // #14B8A6 Teal
AppTheme.successColor      // #10B981 Green
AppTheme.warningColor      // #F59E0B Amber
AppTheme.errorColor        // #EF4444 Red
AppTheme.infoColor         // #3B82F6 Blue
AppTheme.textPrimary       // #111827
AppTheme.textSecondary     // #6B7280
AppTheme.textTertiary      // #9CA3AF
AppTheme.borderColor       // #E5E7EB
```

### Material 3 Spacing System
**Standard spacing increments (multiples of 4):**
- `4px` - Tight spacing (inside small components)
- `8px` - Small spacing (between related items)
- `12px` - Medium spacing (between sections in cards)
- `16px` - Standard padding (default for most containers)
- `20px` - Large padding (screen edges, important sections)
- `24px` - Extra large (major section breaks)
- `32px` - Hero spacing (top-level sections)

**Standard usage:**
- Card padding: `16px` horizontal/vertical
- Screen padding: `20px` horizontal/vertical
- Button padding: `24px` horizontal, `14px` vertical
- Input field padding: `16px` horizontal, `14px` vertical
- Gap between siblings: `8px` (small), `12px` (medium), `16px` (large)

### Border Radius (Material 3 Style)
- `8px` - Small elements (chips, badges, input fields)
- `10px` - Icon buttons, small buttons
- `12px` - Standard buttons, cards, dialogs
- `14px` - Medium containers
- `16px` - Large cards, important containers
- `20px` - Dialogs, bottom sheets
- `24px` - Hero containers

**Standard usage:**
- Cards: `16px` border radius
- Buttons: `12px` border radius
- Input fields: `12px` border radius
- Dialogs: `20px` border radius
- Chips/Badges: `8px` border radius

### Elevation & Shadows
Subtle shadows with low opacity:
```dart
// Small elevation (cards, buttons)
BoxShadow(
  color: Colors.black.withValues(alpha: 0.04),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// Medium elevation (floating elements)
BoxShadow(
  color: Colors.black.withValues(alpha: 0.08),
  blurRadius: 16,
  offset: Offset(0, 4),
)

// Large elevation (dialogs, drawers)
BoxShadow(
  color: Colors.black.withValues(alpha: 0.12),
  blurRadius: 20,
  offset: Offset(0, 8),
)
```

### Typography Scale
```dart
// Display (hero text)
displayLarge:  32px, bold
displayMedium: 28px, bold
displaySmall:  24px, bold

// Headlines
headlineLarge:  22px, bold
headlineMedium: 20px, semi-bold (w600)
headlineSmall:  18px, semi-bold (w600)

// Titles
titleLarge:  18px, semi-bold (w600)
titleMedium: 16px, medium (w500)
titleSmall:  14px, medium (w500)

// Body
bodyLarge:  16px, normal
bodyMedium: 14px, normal
bodySmall:  12px, normal, textSecondary color

// Labels
labelLarge:  14px, semi-bold (w600)
labelMedium: 12px, medium (w500)
labelSmall:  11px, medium (w500), textTertiary color
```

### Component-Specific Rules

**Buttons:**
- Primary buttons: `AppTheme.primaryColor` background, white text
- Icon buttons: `40x40px` or `48x48px` container with 10% primary tint
- FAB: `16px` border radius, 4px elevation
- Disabled: `Colors.grey.shade300` background

**Cards:**
- Background: `AppTheme.cardColor` (white) or `AppTheme.backgroundColor` for subtle
- Border radius: `16px`
- Elevation: Subtle shadow (0.04-0.08 alpha)
- Margin: `12px` vertical between stacked cards
- Padding: `16px` standard

**Status Indicators (Color Mapping):**
- Stock OK: `AppTheme.successColor` with check_circle icon
- Low stock: `AppTheme.warningColor` with warning_amber icon
- Out of stock: `AppTheme.errorColor` with block icon
- Info/tip: `AppTheme.infoColor` with info icon
- Primary action: `AppTheme.primaryColor`
- Secondary/cost: `AppTheme.secondaryColor`

**Payment Method Colors (Sales Reports):**
- Cash: `AppTheme.successColor`
- Card: `AppTheme.infoColor`
- QR: `AppTheme.primaryColor`
- Transfer: `AppTheme.warningColor`

### Reusable Components (Always Use These)
Located in `lib/core/widgets/`:

**ModernButton**
```dart
ModernButton(
  text: 'Save',
  icon: Icons.save,
  onPressed: () => handleSave(),
  isLoading: false,
  isFullWidth: false,
  backgroundColor: AppTheme.primaryColor, // Optional override
)
```

**ModernSecondaryButton**
```dart
ModernSecondaryButton(
  text: 'Cancel',
  icon: Icons.close,
  onPressed: () => handleCancel(),
)
```

**ModernCard**
```dart
ModernCard(
  child: content,
  onTap: () => handleTap(),
  backgroundColor: AppTheme.cardColor,
  elevation: 2,
  padding: EdgeInsets.all(16),
)
```

**ModernStatCard**
```dart
ModernStatCard(
  title: 'Total Sales',
  value: '\$1,234',
  icon: Icons.trending_up,
  iconColor: AppTheme.successColor,
  subtitle: '+12% from last week',
)
```

**ModernActionButton (FAB-style)**
```dart
ModernActionButton(
  label: 'Add Product',
  icon: Icons.add,
  onPressed: () => handleAdd(),
)
```

---

## Build, Test, and Development Commands

### Running the Application
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Build release APK
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle --release
```

### Dependency Management
```bash
# Install dependencies
flutter pub get

# Generate mock objects for testing
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test types
flutter test test/unit              # Unit tests only
flutter test test/widget            # Widget tests only
flutter test integration_test       # Integration tests only

# Run single test file
flutter test test/unit/features/pos/domain/usecases/add_to_cart_usecase_test.dart
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Check only lib folder (faster)
flutter analyze lib/

# Format code
dart format .

# Check formatting without applying
dart format --output=none --set-exit-if-changed .
```

### Database
- Current version: **2** (defined in `AppConstants.databaseVersion`)
- Migration system in `DatabaseHelper._onUpgrade()` - must be updated when schema changes
- Tables: categories, suppliers, products, transactions, transaction_items, payments

## Architecture Overview

### Clean Architecture Structure

This Flutter app follows **Clean Architecture** with strict layer separation. Each feature (POS, Inventory, Sales, Settings) has three layers:

#### 1. Domain Layer (`feature/domain/`)
**Pure business logic - no dependencies on Flutter or frameworks**

- **entities/** - Core business objects (e.g., `Product`, `CartItem`, `Transaction`)
  - Immutable data classes with business logic
  - Example: `Product` has `isLowStock`, `isOutOfStock` computed properties

- **repositories/** - Abstract interfaces (contracts)
  - Define data operations without implementation
  - Example: `ProductRepository` with `getProducts()`, `addProduct()`, etc.

- **usecases/** - Application business rules (also called "Interactors")
  - Single responsibility classes that orchestrate business logic
  - Each use case takes repository interfaces via constructor
  - Example: `AddToCartUseCase.execute(product, quantity)` validates, checks stock, updates cart

#### 2. Data Layer (`feature/data/`)
**Data management - implements domain interfaces**

- **datasources/** - Data sources (SQLite, APIs, SharedPreferences)
  - Local data sources: `*LocalDataSourceImpl` using SQLite via `DatabaseHelper`
  - Settings use: `SettingsLocalDataSource` with SharedPreferences

- **models/** - Data transfer objects (DTOs)
  - Convert between database format and domain entities
  - `toEntity()` and `fromEntity()` methods

- **repositories/** - Repository implementations
  - Implement domain repository interfaces
  - Use data sources to fetch/transform data
  - Handle data errors and convert to domain exceptions

#### 3. Presentation Layer (`feature/presentation/`)
**UI and state management - depends on domain layer (not data)**

- **controllers/** - State management with Provider `ChangeNotifier`
  - Expose state: `isLoading`, `hasError`, `products`, etc.
  - Business logic methods: `loadProducts()`, `addToCart()`, etc.
  - Controllers depend on use cases, not repositories directly
  - Example: `POSController` uses `AddToCartUseCase`, not `CartRepository`

- **screens/** - Full-screen widgets
  - Use `Consumer<Controller>` or `context.watch<Controller>()` for state
  - Call controller methods on user actions

- **widgets/** - Reusable UI components
  - Feature-specific widgets (e.g., `ProductGridItem`, `ProductListItem`)

### Dependency Injection Pattern

**IMPORTANT**: The app uses `ProxyProvider` chains extensively in `main.dart` to wire dependencies:

```dart
// 1. Database is provided at root
Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance)

// 2. Data sources depend on database
ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(
  update: (_, db, __) => ProductLocalDataSourceImpl(databaseHelper: db),
)

// 3. Repositories depend on data sources
ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(
  update: (_, dataSource, __) => ProductRepositoryImpl(localDataSource: dataSource),
)

// 4. Use cases depend on repositories
ProxyProvider<ProductRepositoryImpl, GetProductsUseCase>(
  update: (_, repo, __) => GetProductsUseCase(repository: repo),
)

// 5. Controllers depend on multiple use cases
ChangeNotifierProxyProvider5<GetProductsUseCase, AddProductUseCase, ...>(
  update: (_, getProducts, addProduct, ...) =>
    InventoryController(getProductsUseCase: getProducts, addProductUseCase: addProduct, ...),
)
```

**Key implications**:
- Controllers receive dependencies via constructor injection, not instantiation
- When adding new use cases to a controller, must change the ProxyProvider number (e.g., `ProxyProvider5` to `ProxyProvider6`)
- Always provide concrete implementation types (e.g., `ProductRepositoryImpl`) not interfaces

### State Management Pattern

Controllers extend `ChangeNotifier` and follow this pattern:

```dart
class FeatureController extends ChangeNotifier {
  // Private state
  List<Item> _items = [];
  bool _isLoading = false;
  AppException? _error;

  // Public getters
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  // Business logic methods
  Future<void> performAction() async {
    try {
      _setLoading(true);
      _clearError();
      // ... use case call
      _items = await useCase.execute();
    } on AppException catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Private state setters
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  // ...
}
```

### Error Handling System

Custom exception hierarchy in `core/exceptions/app_exceptions.dart`:

- `AppException` - Base class with `userMessage` property
  - `DatabaseException` - Database operation failures
  - `ValidationException` - Input validation failures
  - `NotFoundException` - Resource not found
  - `ConflictException` - Constraint violations

**Pattern**: Always catch `AppException` in controllers and expose via `error` getter. UI shows `error.userMessage` to users.

## Feature-Specific Notes

### POS (Point of Sale)
- **Cart state**: Managed in-memory by `POSController`, lost on app restart
- **Stock validation**: `AddToCartUseCase` prevents adding beyond available stock
- **Checkout**: Creates transaction, clears cart, deducts product stock atomically
- **Barcode scanner**: Uses `mobile_scanner` package, looks up product by barcode field or ID

### Inventory
- **Low stock threshold**: Configurable in Settings (default 10)
- **Product fields**: name, price, costPrice, stock, categoryId, supplierId, barcode
- **Search**: Case-insensitive partial match on name field
- **Categories & Suppliers**: Separate management, referenced by foreign key

### Sales & Transactions
- **Transaction flow**: Cart → CheckoutUseCase → CreateTransactionUseCase → Database
- **Payment methods**: Enum `PaymentMethod` (cash, card, qr, transfer)
- **Reports**: `SalesReport` entity with daily breakdown, top products, payment breakdown
- **Profit calculation**: `sum(price - costPrice) * quantity` across all transaction items

### Settings
- Persisted via SharedPreferences in `SettingsLocalDataSource`
- Includes business info, tax rate, currency, low stock threshold
- No Settings entity in domain - uses `Settings` class directly

## Database Schema

Key tables and relationships:

```
categories (id, name, description)
  ↓
suppliers (id, name, contact_person, phone, email, address)
  ↓
products (id, name, price, cost_price, stock, category_id, supplier_id, barcode)

transactions (id, total_amount, payment_method, created_at, profit)
  ↓
transaction_items (id, transaction_id, product_id, quantity, unit_price, cost_price, subtotal)

payments (id, transaction_id, payment_method, amount)
```

**Foreign key constraints** are enforced at application level, not database level (SQLite limitation with Flutter).

## Important Implementation Details

### SQLite Operations
- Use `DatabaseHelper.instance.database` to get database instance
- Always use parameterized queries: `db.query('table', where: 'id = ?', whereArgs: [id])`
- Wrap in try-catch and convert to `DatabaseException` with operation name
- Use transactions for multi-table operations: `db.transaction((txn) async { ... })`

### Testing Mock Generation
When adding new use cases or repositories:
1. Create test file with `@GenerateMocks([ClassName])` annotation
2. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Mock classes will be generated as `*.mocks.dart`

### Localization
- ARB files in `lib/l10n/`: `app_en.arb` (English), `app_id.arb` (Indonesian)
- Default locale: Indonesian
- Access via: `AppLocalizations.of(context).messageKey`
- After editing ARB files, run `flutter gen-l10n`

## Common Patterns

### Adding a New Feature

1. **Domain layer first**:
   - Create entity in `feature/domain/entities/`
   - Create repository interface in `feature/domain/repositories/`
   - Create use case in `feature/domain/usecases/`

2. **Data layer**:
   - Create data source implementation in `feature/data/datasources/`
   - Create model in `feature/data/models/`
   - Create repository implementation in `feature/data/repositories/`

3. **Presentation layer**:
   - Create controller in `feature/presentation/controllers/`
   - Create screen in `feature/presentation/screens/`
   - Add widgets in `feature/presentation/widgets/`

4. **Wire up in main.dart**:
   - Add ProxyProvider chain for data sources → repositories → use cases → controller
   - Add to navigation (usually via `MainNavigation` widget)

### Repository Pattern Example

```dart
// Domain interface
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<void> addProduct(Product product);
}

// Data implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getProducts() async {
    final models = await localDataSource.getProducts();
    return models.map((model) => model.toEntity()).toList();
  }
}
```

### Use Case Pattern Example

```dart
class AddToCartUseCase {
  final ProductRepository productRepository;
  final CartRepository cartRepository;

  AddToCartUseCase({
    required this.productRepository,
    required this.cartRepository,
  });

  Future<void> execute(Product product, int quantity) async {
    // Validation
    if (quantity <= 0) {
      throw ValidationException('Quantity must be positive');
    }

    // Business logic
    final available = await productRepository.getStock(product.id);
    final inCart = await cartRepository.getQuantity(product.id);

    if (inCart + quantity > available) {
      throw ValidationException('Insufficient stock');
    }

    // Execute
    await cartRepository.addItem(product, quantity);
  }
}
```

## Debugging

Enable detailed logging via `AppLogger` class in `core/utils/logger.dart`:

```dart
AppLogger.info('Message');
AppLogger.ui('UI action', details: 'Additional info');
AppLogger.error('Error occurred', error: e, stackTrace: stackTrace);
AppLogger.database('Database operation', details: 'Query details');
```

Logs are tagged automatically by class and can be filtered in Android Studio/VS Code debug console.
