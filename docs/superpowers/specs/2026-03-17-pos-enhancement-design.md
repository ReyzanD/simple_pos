# Minimarket POS Enhancement Design

**Date:** 2026-03-17
**Status:** Approved
**Phases:** 5 (Incremental Implementation)

---

## Overview

Enhance the existing Simple POS system with:
1. Staff/User Management (authentication, role-based permissions)
2. Expense Tracking (daily expenses with categorization)
3. Supplier Management UI enhancements (search, contact actions, metrics)
4. Data Export/Backup (CSV/Excel, full database backup)
5. UI Improvements (dark mode fixes, text visibility, navigation enhancements)

---

## Architecture Principles

- **Follow existing Clean Architecture** patterns (Domain → Data → Presentation)
- **Use Provider for state management** (consistent with current codebase)
- **Maintain existing theme system** (AppTheme colors already well-defined)
- **Database migrations** from v11 → v12 (users) → v13 (expenses)

---

## Current System State

- **Database version:** 11 (shifts table added)
- **Architecture:** Clean Architecture with Provider
- **Features:** POS, Inventory, Sales, Settings, Shifts
- **Existing packages:** sqflite, provider, mobile_scanner, fl_chart, csv, share_plus, path_provider

---

## Phase 1: Staff/User Management

### Database Schema (v11 → v12)

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'cashier',
  is_active INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  last_login INTEGER
);

CREATE TABLE user_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  login_time INTEGER NOT NULL,
  logout_time INTEGER,
  opening_cash REAL DEFAULT 0,
  closing_cash REAL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
```

### Roles and Permissions

**Two roles only:**
```dart
enum UserRole { admin, cashier }
```

**Permission enum:**
```dart
enum Permission {
  // POS permissions
  posProcessSales,
  posApplyDiscounts,
  posProcessReturns,

  // Inventory permissions
  inventoryView,
  inventoryAdd,
  inventoryEdit,
  inventoryDelete,

  // Sales permissions
  salesViewReports,
  salesManagePromotions,

  // Settings permissions
  settingsView,
  settingsManageUsers,
  settingsManagePrinters,
}
```

**Permission matrix:**

| Permission | Admin | Cashier |
|------------|-------|---------|
| POS Sales | ✓ | ✓ |
| Apply Discounts | ✓ | ✗ |
| Process Returns | ✓ | ✗ |
| Inventory View | ✓ | ✓ |
| Inventory Add/Edit/Delete | ✓ | ✗ |
| Sales Reports | ✓ | ✗ |
| Manage Promotions | ✓ | ✗ |
| Settings View | ✓ | ✗ |
| Manage Users | ✓ | ✗ |
| Manage Printers | ✓ | ✗ |

### Domain Layer

**Entities:**
- `User` (id, username, fullName, role, isActive, lastLogin)
- `UserSession` (id, userId, loginTime, logoutTime, openingCash, closingCash)

**Repository interface:**
- `UserRepository` (getUsers, getUserById, getUserByUsername, createUser, updateUser, deleteUser)

**Use cases:**
- `LoginUseCase` - Authenticate user with username/password
- `LogoutUseCase` - Record logout time and session details
- `GetUsersUseCase` - List all users (admin only)
- `CreateUserUseCase` - Add new user (admin only)
- `UpdateUserUseCase` - Modify user details (admin only)
- `DeleteUserUseCase` - Soft delete user (admin only)
- `GetCurrentUserUseCase` - Get currently logged-in user

### Data Layer

**Data source:**
- `UserLocalDataSourceImpl` - SQLite operations via DatabaseHelper

**Model:**
- `UserModel` - with toEntity() and fromEntity() methods

**Repository:**
- `UserRepositoryImpl` - Implements UserRepository interface

### Presentation Layer

**Controller:**
- `AuthController` - Manages authentication state, current user

**Screens:**
- `LoginScreen` - Username/password login form
- `UserManagementScreen` - List/add/edit/delete users (admin only)

**Widgets:**
- `UserRoleSelector` - Dropdown for role selection

### Core Service

**PermissionService:**
```dart
class PermissionService {
  bool hasPermission(User user, Permission permission);
  bool canAccessFeature(User user, String feature);
  List<Permission> getRolePermissions(UserRole role);
}
```

---

## Phase 2: Expense Tracking

### Database Schema (v12 → v13)

```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,
  amount REAL NOT NULL,
  description TEXT,
  payment_method TEXT,
  receipt_image TEXT,
  created_by INTEGER,
  created_at INTEGER NOT NULL,
  date INTEGER NOT NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_created_by ON expenses(created_by);
```

### Expense Categories

**Predefined categories (Indonesian):**
- Sewa (Rent)
- Listrik & Air (Utilities)
- Perlengkapan (Supplies)
- Pemeliharaan (Maintenance)
- Gaji Karyawan (Salary)
- Lain-lain (Other)

**Custom categories:** Users can add their own categories beyond the predefined list.

### Domain Layer

**Entity:**
```dart
class Expense {
  final int? id;
  final String category;
  final double amount;
  final String? description;
  final String? paymentMethod;
  final String? receiptImagePath;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime date;
}
```

**Repository interface:**
- `ExpenseRepository` (getExpenses, getExpenseById, addExpense, updateExpense, deleteExpense, getExpenseSummary)

**Use cases:**
- `AddExpenseUseCase` - Add new expense
- `GetExpensesUseCase` - List expenses with filters
- `UpdateExpenseUseCase` - Modify expense
- `DeleteExpenseUseCase` - Remove expense
- `GetExpenseSummaryUseCase` - Get totals by category and date range

### Presentation Layer

**Controller:**
- `ExpenseController` - Manage expense state and operations

**Screen:**
- `ExpenseScreen` - List expenses with filters, add/edit/delete

**Widgets:**
- `ExpenseCategoryChip` - Category selector with custom option
- `ExpenseFormDialog` - Add/edit expense form with receipt image option

---

## Phase 3: Supplier Management UI

### Current State

Supplier screen exists at `lib/features/inventory/presentation/screens/supplier_screen.dart`
- ✅ Basic CRUD operations
- ❌ Missing: Search, contact actions, metrics

### Enhancements Needed

1. **Search functionality** - Filter suppliers by name/contact
2. **Contact actions** - Call and email buttons using `url_launcher`
3. **Product count** - Show number of products per supplier
4. **Performance metrics** - Total purchases, last order date

### New Dependencies

```yaml
url_launcher: ^6.3.0
```

### Changes to Existing Files

**SupplierScreen enhancements:**
- Add search bar at top
- Replace trailing actions with call/email buttons
- Add product count badge
- Show purchase metrics in card subtitle

**Supplier entity additions:**
```dart
// Add to Supplier entity or use separate query
int get productCount; // derived from products table
double? totalPurchases;
DateTime? lastOrderDate;
```

---

## Phase 4: Data Export/Backup

### Export Service

**Formats supported:**
- CSV (using existing `csv` package)
- Excel (using new `excel` package)

**Exportable data:**
- Transactions
- Products
- Expenses

**ExportService interface:**
```dart
class ExportService {
  Future<String> exportTransactionsToCsv(DateTimeRange range);
  Future<String> exportProductsToCsv();
  Future<String> exportExpensesToCsv(DateTimeRange range);
  Future<String> exportTransactionsToExcel(DateTimeRange range);
  Future<String> exportProductsToExcel();
  Future<String> exportExpensesToExcel(DateTimeRange range);
  Future<void> shareExport(String filePath);
}
```

### Backup/Restore Service

**BackupService:**
```dart
class BackupService {
  Future<String> createBackup(); // Returns backup file path
  Future<void> scheduleAutoBackup(BackupFrequency frequency);
  Future<List<BackupMetadata>> getAvailableBackups();
}
```

**RestoreService:**
```dart
class RestoreService {
  Future<BackupPreview> previewBackup(String backupPath);
  Future<void> restoreFromBackup(String backupPath, RestoreMode mode);
  Future<bool> validateBackup(String backupPath);
}
```

**Restore modes:**
- `Replace` - Clear all data, restore from backup
- `Merge` - Merge backup data with existing data

### Presentation Layer

**Screen:**
- `DataManagementScreen` - Export options, backup/restore controls

---

## Phase 5: UI Improvements

### Dark Mode Fixes

The `app_theme.dart` already has well-defined colors. Main issues to fix:
1. Replace hardcoded colors with `AppTheme` helper methods
2. Ensure all cards use `AppTheme.getCardColor(context)`
3. Fix text contrast issues

### Files to Review for Hardcoded Colors

- `lib/features/sales/presentation/widgets/promotions_tab_widget.dart`
- `lib/features/pos/presentation/screens/pos_screen.dart`
- Any widget using `Colors.grey`, `Colors.white`, `Colors.black` directly

### Navigation Enhancements

**MainNavigation changes:**
1. Add auth check at startup - show LoginScreen if no authenticated user
2. Show current shift info in header/drawer
3. Add quick action to close shift
4. Display current user's name and role

---

## Implementation Order (Incremental)

### Week 1: UI Improvements + Supplier Enhancements
- Fix hardcoded colors for dark mode
- Enhance supplier screen with search and contact actions
- Add shift info to navigation

### Week 2: Staff/User Management
- Database migration v11 → v12
- Implement auth domain layer
- Create login screen and permission service
- Add auth check to app startup

### Week 3: Expense Tracking
- Database migration v12 → v13
- Implement expense domain and data layers
- Create expense screen and widgets

### Week 4: Data Export/Backup
- Implement export service
- Create data management screen
- Add backup/restore functionality

---

## Dependencies to Add

```yaml
dependencies:
  url_launcher: ^6.3.0   # Phase 3 - Supplier contact actions
  excel: ^4.0.0          # Phase 4 - Excel export
  crypto: ^3.0.3         # Phase 1 - Password hashing
```

---

## Files to Create

### Users Feature (15 files)
```
lib/features/users/
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── user_session.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   └── usecases/
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       ├── get_users_usecase.dart
│       ├── create_user_usecase.dart
│       ├── update_user_usecase.dart
│       ├── delete_user_usecase.dart
│       └── get_current_user_usecase.dart
├── data/
│   ├── datasources/
│   │   └── user_local_datasource_impl.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── user_repository_impl.dart
└── presentation/
    ├── controllers/
    │   └── auth_controller.dart
    ├── screens/
    │   ├── login_screen.dart
    │   └── user_management_screen.dart
    └── widgets/
        └── user_role_selector.dart
```

### Expenses Feature (14 files)
```
lib/features/expenses/
├── domain/
│   ├── entities/
│   │   └── expense.dart
│   ├── repositories/
│   │   └── expense_repository.dart
│   └── usecases/
│       ├── add_expense_usecase.dart
│       ├── get_expenses_usecase.dart
│       ├── update_expense_usecase.dart
│       ├── delete_expense_usecase.dart
│       └── get_expense_summary_usecase.dart
├── data/
│   ├── datasources/
│   │   └── expense_local_datasource_impl.dart
│   ├── models/
│   │   └── expense_model.dart
│   └── repositories/
│       └── expense_repository_impl.dart
└── presentation/
    ├── controllers/
    │   └── expense_controller.dart
    ├── screens/
    │   └── expense_screen.dart
    └── widgets/
        ├── expense_category_chip.dart
        └── expense_form_dialog.dart
```

### Core Services (4 files)
```
lib/core/services/
├── permission_service.dart
├── export_service.dart
├── backup_service.dart
└── restore_service.dart
```

### Settings Screen (1 file)
```
lib/features/settings/presentation/screens/
└── data_management_screen.dart
```

---

## Files to Modify

| File | Changes |
|------|---------|
| `lib/services/database/database_helper.dart` | Add migrations to v12, v13 |
| `lib/core/constants/app_constants.dart` | Update databaseVersion to 13 |
| `lib/main.dart` | Add auth providers, startup auth check |
| `lib/features/shared/presentation/main_navigation.dart` | Auth guard, shift info |
| `lib/features/inventory/presentation/screens/supplier_screen.dart` | Search, contact actions |
| `lib/features/inventory/domain/entities/supplier.dart` | Add metrics properties |
| `pubspec.yaml` | Add new dependencies |

---

## Verification Checklist

### Staff/User Management
- [ ] Users can log in with username/password
- [ ] Role-based permissions work correctly
- [ ] Cashiers cannot access settings
- [ ] Admins have full access
- [ ] Session tracking works

### Expense Tracking
- [ ] Can add daily expenses
- [ ] Expenses are categorized
- [ ] Custom categories can be added
- [ ] Can see expense reports
- [ ] Expenses affect profit calculations

### Supplier Management
- [ ] Supplier list has search
- [ ] Can call supplier from app
- [ ] Can email supplier from app
- [ ] Product count displays correctly

### Data Export/Backup
- [ ] Can export transactions to CSV
- [ ] Can export transactions to Excel
- [ ] Can export products
- [ ] Can export expenses
- [ ] Backup creates file
- [ ] Restore works from backup
- [ ] Share functionality works

### UI Improvements
- [ ] Dark mode is readable
- [ ] All text is visible in both themes
- [ ] Cards have proper contrast
- [ ] Shift info displays in navigation
- [ ] Login screen shows on app start (if not authenticated)
