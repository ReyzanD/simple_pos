# POS Enhancement Implementation Plan

**Date:** 2026-03-17
**Status:** Ready for Implementation
**Design Document:** `docs/superpowers/specs/2026-03-17-pos-enhancement-design.md`

---

## Goal

Implement 5 phases of enhancements to the Simple POS system:
1. Staff/User Management (authentication, role-based permissions)
2. Expense Tracking (daily expenses with categorization)
3. Supplier Management UI enhancements (search, contact actions, metrics)
4. Data Export/Backup (CSV/Excel, full database backup)
5. UI Improvements (dark mode fixes, text visibility, navigation)

---

## Architecture

- **Clean Architecture** with strict layer separation (Domain → Data → Presentation)
- **Provider** for state management
- **SQLite** for local data persistence
- **Database migrations** v11 → v12 → v13

---

## Tech Stack

- Flutter SDK
- sqflite (database)
- provider (state management)
- url_launcher (deep links)
- excel (Excel export)
- crypto (password hashing)
- csv (CSV export)
- share_plus (sharing files)

---

## Phase 1: Dependencies & Setup

### Step 1.1: Update pubspec.yaml with new dependencies
**File:** `pubspec.yaml`

Add to dependencies section:
```yaml
  url_launcher: ^6.3.0
  excel: ^4.0.0
  crypto: ^3.0.3
```

Run: `flutter pub get`

**Verification:** Packages download successfully

---

## Phase 2: UI Improvements (Quick Wins First)

### Step 2.1: Fix dark mode in promotions_tab_widget.dart
**File:** `lib/features/sales/presentation/widgets/promotions_tab_widget.dart`

1. Replace `Colors.grey` with `AppTheme.textSecondary`
2. Replace `Colors.white` with `AppTheme.cardColor`
3. Replace hardcoded shadows with `AppTheme.shadow` (if exists) or use standard shadow

### Step 2.2: Fix dark mode in pos_screen.dart
**File:** `lib/features/pos/presentation/screens/pos_screen.dart`

1. Search for hardcoded `Colors.white`, `Colors.black`, `Colors.grey.*`
2. Replace with `AppTheme.*` equivalents
3. Ensure text contrast is readable

### Step 2.3: Create Grep pattern to find all hardcoded colors
**Run:** `grep -r "Colors\." lib/ --include="*.dart" | grep -v "AppTheme"`

Fix all occurrences found

---

## Phase 3: Supplier Screen Enhancements

### Step 3.1: Add product count to Supplier entity
**File:** `lib/features/inventory/domain/entities/supplier.dart`

Add property:
```dart
  final int productCount;
```

Update constructor and `copyWith`

### Step 3.2: Add product count to SupplierModel
**File:** `lib/features/inventory/data/models/supplier_model.dart`

Add property and update toEntity/fromEntity

### Step 3.3: Update supplier queries to include product count
**File:** `lib/features/inventory/data/datasources/supplier_local_datasource_impl.dart`

Modify query to include COUNT of products per supplier

### Step 3.4: Add search bar to SupplierScreen
**File:** `lib/features/inventory/presentation/screens/supplier_screen.dart`

Add at top of body:
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Cari supplier...',
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) {
    // Filter logic
  },
)
```

### Step 3.5: Add call button to supplier list items
**File:** `lib/features/inventory/presentation/screens/supplier_screen.dart`

Add trailing action:
```dart
IconButton(
  icon: Icon(Icons.phone),
  onPressed: () => _callSupplier(supplier.phone),
)
```

### Step 3.6: Add email button to supplier list items
Similar to call button, using `Icons.email`

### Step 3.7: Implement contact action handlers
**File:** `lib/features/inventory/presentation/screens/supplier_screen.dart`

Add methods:
```dart
Future<void> _callSupplier(String? phone) async {
  if (phone == null) return;
  final Uri launchUri = Uri(scheme: 'tel', path: phone);
  if (!await launchUrl(launchUri)) {
    // Show error
  }
}

Future<void> _emailSupplier(String? email) async {
  if (email == null) return;
  final Uri launchUri = Uri(scheme: 'mailto', path: email);
  if (!await launchUrl(launchUri)) {
    // Show error
  }
}
```

Add import: `import 'package:url_launcher/url_launcher.dart';`

---

## Phase 4: User/Staff Management

### Step 4.1: Create UserRole enum
**File:** `lib/features/users/domain/entities/user_role.dart`

```dart
enum UserRole {
  admin,
  cashier;
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin: return 'Admin';
      case UserRole.cashier: return 'Kasir';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.cashier,
    );
  }
}
```

### Step 4.2: Create Permission enum
**File:** `lib/features/users/domain/entities/permission.dart`

```dart
enum Permission {
  // POS
  posProcessSales,
  posApplyDiscounts,
  posProcessReturns,

  // Inventory
  inventoryView,
  inventoryAdd,
  inventoryEdit,
  inventoryDelete,

  // Sales
  salesViewReports,
  salesManagePromotions,

  // Settings
  settingsView,
  settingsManageUsers,
  settingsManagePrinters,
}
```

### Step 4.3: Create User entity
**File:** `lib/features/users/domain/entities/user.dart`

```dart
class User {
  final int? id;
  final String username;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.isActive = true,
    this.lastLogin,
  });

  User copyWith({
    int? id,
    String? username,
    String? fullName,
    UserRole? role,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
```

### Step 4.4: Create UserSession entity
**File:** `lib/features/users/domain/entities/user_session.dart`

```dart
class UserSession {
  final int? id;
  final int userId;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final double openingCash;
  final double? closingCash;

  UserSession({
    this.id,
    required this.userId,
    required this.loginTime,
    this.logoutTime,
    this.openingCash = 0,
    this.closingCash,
  });
}
```

### Step 4.5: Create UserRepository interface
**File:** `lib/features/users/domain/repositories/user_repository.dart`

```dart
import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User?> getUserById(int id);
  Future<User?> getUserByUsername(String username);
  Future<int> createUser(User user, String passwordHash);
  Future<void> updateUser(User user);
  Future<void> deleteUser(int id);
  Future<String?> getPasswordHash(int userId);
  Future<void> updateLastLogin(int userId);
}
```

### Step 4.6: Create LoginUseCase
**File:** `lib/features/users/domain/usecases/login_usecase.dart`

```dart
import 'package:crypt/crypt.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoginUseCase {
  final UserRepository _repository;

  LoginUseCase(this._repository);

  Future<User?> execute(String username, String password) async {
    final user = await _repository.getUserByUsername(username);
    if (user == null) return null;
    if (!user.isActive) return null;

    final storedHash = await _repository.getPasswordHash(user.id!);
    if (storedHash == null) return null;

    if (Crypt(password).match(storedHash)) {
      await _repository.updateLastLogin(user.id!);
      return user;
    }
    return null;
  }
}
```

### Step 4.7: Create remaining use cases
**Files:**
- `lib/features/users/domain/usecases/get_current_user_usecase.dart`
- `lib/features/users/domain/usecases/get_users_usecase.dart`
- `lib/features/users/domain/usecases/create_user_usecase.dart`
- `lib/features/users/domain/usecases/update_user_usecase.dart`
- `lib/features/users/domain/usecases/delete_user_usecase.dart`

### Step 4.8: Create UserModel
**File:** `lib/features/users/data/models/user_model.dart`

```dart
import '../../domain/entities/user.dart';
import '../entities/user_role.dart';

class UserModel {
  final int? id;
  final String username;
  final String fullName;
  final String role;
  final int isActive;
  final int? lastLogin;

  UserModel({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      isActive: map['is_active'] as int? ?? 1,
      lastLogin: map['last_login'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'last_login': lastLogin,
    };
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      fullName: fullName,
      role: UserRoleExtension.fromString(role),
      isActive: isActive == 1,
      lastLogin: lastLogin != null
          ? DateTime.fromMillisecondsSinceEpoch(lastLogin! * 1000)
          : null,
    );
  }

  static UserModel fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      role: user.role.name,
      isActive: user.isActive ? 1 : 0,
      lastLogin: user.lastLogin?.millisecondsSinceEpoch ~/ 1000,
    );
  }
}
```

### Step 4.9: Create UserLocalDataSourceImpl
**File:** `lib/features/users/data/datasources/user_local_datasource_impl.dart`

```dart
import 'package:simple_pos/services/database/database_helper.dart';
import '../models/user_model.dart';

class UserLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  UserLocalDataSourceImpl({required this.databaseHelper});

  Future<List<UserModel>> getUsers() async {
    final db = await databaseHelper.database;
    final maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<int> createUser(UserModel user, String passwordHash) async {
    final db = await databaseHelper.database;
    final map = user.toMap();
    map['password_hash'] = passwordHash;
    map['created_at'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return await db.insert('users', map);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await databaseHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getPasswordHash(int userId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'users',
      columns: ['password_hash'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return maps.first['password_hash'] as String?;
  }

  Future<void> updateLastLogin(int userId) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      {'last_login': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
```

### Step 4.10: Create UserRepositoryImpl
**File:** `lib/features/users/data/repositories/user_repository_impl.dart`

```dart
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource_impl.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSourceImpl localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<List<User>> getUsers() async {
    final models = await localDataSource.getUsers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<User?> getUserById(int id) async {
    final db = await localDataSource.databaseHelper.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    final model = await localDataSource.getUserByUsername(username);
    return model?.toEntity();
  }

  @override
  Future<int> createUser(User user, String passwordHash) async {
    final model = UserModel.fromEntity(user);
    return await localDataSource.createUser(model, passwordHash);
  }

  @override
  Future<void> updateUser(User user) async {
    final model = UserModel.fromEntity(user);
    await localDataSource.updateUser(model);
  }

  @override
  Future<void> deleteUser(int id) async {
    await localDataSource.deleteUser(id);
  }

  @override
  Future<String?> getPasswordHash(int userId) async {
    return await localDataSource.getPasswordHash(userId);
  }

  @override
  Future<void> updateLastLogin(int userId) async {
    await localDataSource.updateLastLogin(userId);
  }
}
```

### Step 4.11: Create AuthController
**File:** `lib/features/users/presentation/controllers/auth_controller.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final GetUsersUseCase _getUsersUseCase;
  final CreateUserUseCase _createUserUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController({
    required LoginUseCase loginUseCase,
    required GetUsersUseCase getUsersUseCase,
    required CreateUserUseCase createUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _getUsersUseCase = getUsersUseCase,
        _createUserUseCase = createUserUseCase;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _loginUseCase.execute(username, password);
      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Username atau password salah');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
```

### Step 4.12: Create LoginScreen
**File:** `lib/features/users/presentation/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../shared/presentation/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthController>().login(
            _usernameController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storefront, size: 80, color: AppTheme.primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Simple POS',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Masuk untuk melanjutkan',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username wajib diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Consumer<AuthController>(
                    builder: (context, auth, child) {
                      if (auth.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return ModernButton(
                        text: 'Masuk',
                        onPressed: _handleLogin,
                        isFullWidth: true,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Step 4.13: Create UserManagementScreen
**File:** `lib/features/users/presentation/screens/user_management_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../domain/entities/user_role.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Staff'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ModernCard(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('Admin'),
              subtitle: Text('admin'),
              trailing: Chip(
                label: Text('Admin'),
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4.14: Add database migration to v12 (users table)
**File:** `lib/services/database/database_helper.dart`

Add method:
```dart
Future<void> _migrateToV12(Database db) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      full_name TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'cashier',
      is_active INTEGER DEFAULT 1,
      created_at INTEGER NOT NULL,
      last_login INTEGER
    )
  ''');

  await db.execute('''
    CREATE TABLE user_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      login_time INTEGER NOT NULL,
      logout_time INTEGER,
      opening_cash REAL DEFAULT 0,
      closing_cash REAL,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''');

  await db.execute('CREATE INDEX idx_users_username ON users(username)');
  await db.execute('CREATE INDEX idx_users_role ON users(role)');
  await db.execute('CREATE INDEX idx_user_sessions_user ON user_sessions(user_id)');

  // Create default admin user
  final adminPasswordHash = Crypt('admin123').hash();
  await db.insert('users', {
    'username': 'admin',
    'password_hash': adminPasswordHash,
    'full_name': 'Administrator',
    'role': 'admin',
    'is_active': 1,
    'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
  });
}
```

Add to _onUpgrade:
```dart
if (oldVersion < 12) {
  await _migrateToV12(db);
}
```

### Step 4.15: Update database version constant
**File:** `lib/core/constants/app_constants.dart`

Change: `static const int databaseVersion = 11;`
To: `static const int databaseVersion = 12;`

### Step 4.16: Wire up AuthController in main.dart
**File:** `lib/main.dart`

Add ProxyProviders for users feature:
```dart
// User Data Sources
ProxyProvider<DatabaseHelper, UserLocalDataSourceImpl>(
  update: (_, db, __) => UserLocalDataSourceImpl(databaseHelper: db),
)

// User Repositories
ProxyProvider<UserLocalDataSourceImpl, UserRepositoryImpl>(
  update: (_, dataSource, __) =>
      UserRepositoryImpl(localDataSource: dataSource),
)

// User Use Cases
ProxyProvider<UserRepositoryImpl, LoginUseCase>(
  update: (_, repo, __) => LoginUseCase(repo),
)

ProxyProvider<UserRepositoryImpl, GetUsersUseCase>(
  update: (_, repo, __) => GetUsersUseCase(repo),
)

// Auth Controller
ChangeNotifierProxyProvider2<LoginUseCase, GetUsersUseCase, AuthController>(
  update: (_, loginUseCase, getUsersUseCase, __) => AuthController(
    loginUseCase: loginUseCase,
    getUsersUseCase: getUsersUseCase,
    createUserUseCase: CreateUserUseCase(/* ... */),
  ),
)
```

### Step 4.17: Create PermissionService
**File:** `lib/core/services/permission_service.dart`

```dart
import '../../features/users/domain/entities/user.dart';
import '../../features/users/domain/entities/user_role.dart';
import '../../features/users/domain/entities/permission.dart';

class PermissionService {
  static const Map<UserRole, Set<Permission>> _rolePermissions = {
    UserRole.admin: {
      // POS - Full access
      Permission.posProcessSales,
      Permission.posApplyDiscounts,
      Permission.posProcessReturns,

      // Inventory - Full access
      Permission.inventoryView,
      Permission.inventoryAdd,
      Permission.inventoryEdit,
      Permission.inventoryDelete,

      // Sales - Full access
      Permission.salesViewReports,
      Permission.salesManagePromotions,

      // Settings - Full access
      Permission.settingsView,
      Permission.settingsManageUsers,
      Permission.settingsManagePrinters,
    },
    UserRole.cashier: {
      // POS - Limited
      Permission.posProcessSales,

      // Inventory - View only
      Permission.inventoryView,
    },
  };

  bool hasPermission(User user, Permission permission) {
    final permissions = _rolePermissions[user.role];
    return permissions?.contains(permission) ?? false;
  }

  bool canAccessFeature(User user, String feature) {
    // Map feature strings to permissions
    final featurePermission = _featureToPermission(feature);
    return featurePermission == null ||
        hasPermission(user, featurePermission);
  }

  Permission? _featureToPermission(String feature) {
    switch (feature) {
      case 'settings':
        return Permission.settingsView;
      case 'sales_reports':
        return Permission.salesViewReports;
      case 'inventory_edit':
        return Permission.inventoryEdit;
      default:
        return null;
    }
  }
}
```

---

## Phase 5: Expense Tracking

### Step 5.1: Create Expense entity
**File:** `lib/features/expenses/domain/entities/expense.dart`

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

  Expense({
    this.id,
    required this.category,
    required this.amount,
    this.description,
    this.paymentMethod,
    this.receiptImagePath,
    this.createdBy,
    DateTime? createdAt,
    DateTime? date,
  })  : createdAt = createdAt ?? DateTime.now(),
        date = date ?? DateTime.now();

  Expense copyWith({
    int? id,
    String? category,
    double? amount,
    String? description,
    String? paymentMethod,
    String? receiptImagePath,
    int? createdBy,
    DateTime? createdAt,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
    );
  }
}
```

### Step 5.2: Create predefined expense categories constant
**File:** `lib/features/expenses/domain/constants/expense_categories.dart`

```dart
class ExpenseCategories {
  static const List<String> predefined = [
    'Sewa',
    'Listrik & Air',
    'Perlengkapan',
    'Pemeliharaan',
    'Gaji Karyawan',
    'Lain-lain',
  ];

  static List<String> withCustom(List<String> customCategories) {
    return [...predefined, ...customCategories];
  }
}
```

### Step 5.3: Create ExpenseRepository interface
**File:** `lib/features/expenses/domain/repositories/expense_repository.dart`

```dart
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  });
  Future<Expense?> getExpenseById(int id);
  Future<int> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(int id);
  Future<Map<String, double>> getExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
}
```

### Step 5.4: Create expense use cases
**Files:**
- `lib/features/expenses/domain/usecases/add_expense_usecase.dart`
- `lib/features/expenses/domain/usecases/get_expenses_usecase.dart`
- `lib/features/expenses/domain/usecases/update_expense_usecase.dart`
- `lib/features/expenses/domain/usecases/delete_expense_usecase.dart`
- `lib/features/expenses/domain/usecases/get_expense_summary_usecase.dart`

### Step 5.5: Create ExpenseModel
**File:** `lib/features/expenses/data/models/expense_model.dart`

```dart
import '../../domain/entities/expense.dart';

class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final String? description;
  final String? paymentMethod;
  final String? receiptImagePath;
  final int? createdBy;
  final int createdAt;
  final int date;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    this.description,
    this.paymentMethod,
    this.receiptImagePath,
    this.createdBy,
    required this.createdAt,
    required this.date,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] as String?,
      receiptImagePath: map['receipt_image'] as String?,
      createdBy: map['created_by'] as int?,
      createdAt: map['created_at'] as int,
      date: map['date'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'payment_method': paymentMethod,
      'receipt_image': receiptImagePath,
      'created_by': createdBy,
      'created_at': createdAt,
      'date': date,
    };
  }

  Expense toEntity() {
    return Expense(
      id: id,
      category: category,
      amount: amount,
      description: description,
      paymentMethod: paymentMethod,
      receiptImagePath: receiptImagePath,
      createdBy: createdBy,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt * 1000),
      date: DateTime.fromMillisecondsSinceEpoch(date * 1000),
    );
  }

  static ExpenseModel fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      category: expense.category,
      amount: expense.amount,
      description: expense.description,
      paymentMethod: expense.paymentMethod,
      receiptImagePath: expense.receiptImagePath,
      createdBy: expense.createdBy,
      createdAt: expense.createdAt.millisecondsSinceEpoch ~/ 1000,
      date: expense.date.millisecondsSinceEpoch ~/ 1000,
    );
  }
}
```

### Step 5.6: Create ExpenseLocalDataSourceImpl
**File:** `lib/features/expenses/data/datasources/expense_local_datasource_impl.dart`

```dart
import 'package:simple_pos/services/database/database_helper.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  ExpenseLocalDataSourceImpl({required this.databaseHelper});

  Future<List<ExpenseModel>> getExpenses({
    int? startDate,
    int? endDate,
    String? category,
  }) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (startDate != null) {
      conditions.add('date >= ?');
      whereArgs.add(startDate);
    }
    if (endDate != null) {
      conditions.add('date <= ?');
      whereArgs.add(endDate);
    }
    if (category != null) {
      conditions.add('category = ?');
      whereArgs.add(category);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final maps = await db.query(
      'expenses',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );

    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  Future<int> addExpense(ExpenseModel expense) async {
    final db = await databaseHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await databaseHelper.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await databaseHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
```

### Step 5.7: Add database migration to v13 (expenses table)
**File:** `lib/services/database/database_helper.dart`

Add method:
```dart
Future<void> _migrateToV13(Database db) async {
  await db.execute('''
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
    )
  ''');

  await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
  await db.execute('CREATE INDEX idx_expenses_category ON expenses(category)');
  await db.execute('CREATE INDEX idx_expenses_created_by ON expenses(created_by)');
}
```

Add to _onUpgrade:
```dart
if (oldVersion < 13) {
  await _migrateToV13(db);
}
```

### Step 5.8: Update database version to 13
**File:** `lib/core/constants/app_constants.dart`

Change: `static const int databaseVersion = 12;`
To: `static const int databaseVersion = 13;`

---

## Phase 6: Data Export/Backup

### Step 6.1: Create ExportService
**File:** `lib/core/services/export_service.dart`

```dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_pos/services/database/database_helper.dart';

class ExportService {
  final DatabaseHelper databaseHelper;

  ExportService({required this.databaseHelper});

  Future<String> exportTransactionsToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    if (startDate != null || endDate != null) {
      final conditions = <String>[];
      if (startDate != null) {
        conditions.add('created_at >= ?');
        whereArgs.add(startDate.millisecondsSinceEpoch ~/ 1000);
      }
      if (endDate != null) {
        conditions.add('created_at <= ?');
        whereArgs.add(endDate.millisecondsSinceEpoch ~/ 1000);
      }
      where = conditions.join(' AND ');
    }

    final transactions = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    final rows = <List<String>>[];
    rows.add(['ID', 'Total', 'Payment Method', 'Created At']);

    for (var tx in transactions) {
      rows.add([
        tx['id'].toString(),
        tx['total_amount'].toString(),
        tx['payment_method'].toString(),
        DateTime.fromMillisecondsSinceEpoch(tx['created_at'] * 1000)
            .toLocal()
            .toString(),
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);

    return file.path;
  }

  Future<String> exportProductsToCsv() async {
    final db = await databaseHelper.database;
    final products = await db.query('products');

    final rows = <List<String>>[];
    rows.add(['ID', 'Name', 'Price', 'Cost', 'Stock', 'Barcode']);

    for (var p in products) {
      rows.add([
        p['id'].toString(),
        p['name'].toString(),
        p['price'].toString(),
        p['cost_price'].toString(),
        p['stock'].toString(),
        p['barcode']?.toString() ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/products_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);

    return file.path;
  }

  Future<String> exportTransactionsToExcel({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await databaseHelper.database;
    final transactions = await db.query('transactions');

    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    sheet.appendRow(['ID', 'Total', 'Payment Method', 'Created At']);

    for (var tx in transactions) {
      sheet.appendRow([
        tx['id'],
        tx['total_amount'],
        tx['payment_method'],
        DateTime.fromMillisecondsSinceEpoch(tx['created_at'] * 1000)
            .toLocal()
            .toString(),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }

  Future<void> shareExport(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
}
```

### Step 6.2: Create BackupService
**File:** `lib/core/services/backup_service.dart`

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:simple_pos/services/database/database_helper.dart';

class BackupService {
  final DatabaseHelper databaseHelper;

  BackupService({required this.databaseHelper});

  Future<String> createBackup() async {
    final db = await databaseHelper.database;
    final dbPath = db.path;

    final directory = await getExternalStorageDirectory();
    final backupDir = Directory('${directory!.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupPath = '${backupDir.path}/backup_$timestamp.db';

    await File(dbPath).copy(backupPath);

    return backupPath;
  }

  Future<List<File>> getAvailableBackups() async {
    final directory = await getExternalStorageDirectory();
    final backupDir = Directory('${directory!.path}/backups');

    if (!await backupDir.exists()) {
      return [];
    }

    final files = await backupDir.list().where((f) => f.path.endsWith('.db')).toList();
    return files.cast<File>();
  }
}
```

### Step 6.3: Create DataManagementScreen
**File:** `lib/features/settings/presentation/screens/data_management_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_button.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isExporting = false;
  bool _isBackingUp = false;

  Future<void> _exportTransactions() async {
    setState(() => _isExporting = true);
    try {
      final exportService = ExportService(
        databaseHelper: context.read<DatabaseHelper>(),
      );
      final path = await exportService.exportTransactionsToCsv();
      await exportService.shareExport(path);
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final backupService = BackupService(
        databaseHelper: context.read<DatabaseHelper>(),
      );
      final path = await backupService.createBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup created: $path')),
        );
      }
    } finally {
      setState(() => _isBackingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Data'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Ekspor Data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ModernCard(
            child: ListTile(
              leading: Icon(Icons.table_chart, color: AppTheme.primaryColor),
              title: Text('Ekspor Transaksi (CSV)'),
              subtitle: Text('Unduh semua transaksi dalam format CSV'),
              trailing: _isExporting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.chevron_right),
              onTap: _isExporting ? null : _exportTransactions,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Backup & Restore',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ModernCard(
            child: ListTile(
              leading: Icon(Icons.backup, color: AppTheme.secondaryColor),
              title: Text('Buat Backup'),
              subtitle: Text('Simpan backup database'),
              trailing: _isBackingUp
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _isBackingUp ? null : _createBackup,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Phase 7: Navigation & Auth Integration

### Step 7.1: Add auth guard to MainNavigation
**File:** `lib/features/shared/presentation/main_navigation.dart`

Wrap with Consumer<AuthController>:
```dart
Widget build(BuildContext context) {
  final auth = context.watch<AuthController>();

  if (!auth.isAuthenticated) {
    return LoginScreen();
  }

  return Scaffold(
    // ... existing navigation code
  );
}
```

### Step 7.2: Add logout to navigation drawer
**File:** `lib/features/shared/presentation/main_navigation.dart`

Add to drawer:
```dart
ListTile(
  leading: Icon(Icons.logout),
  title: Text('Keluar'),
  onTap: () {
    context.read<AuthController>().logout();
  },
),
```

### Step 7.3: Add user info to drawer header
**File:** `lib/features/shared/presentation/main_navigation.dart`

```dart
UserAccountsDrawerHeader(
  accountName: Text(auth.currentUser?.fullName ?? 'User'),
  accountEmail: Text(auth.currentUser?.role.displayName ?? ''),
  currentAccountPicture: CircleAvatar(
    child: Icon(Icons.person),
  ),
),
```

---

## Testing Strategy

### Unit Tests to Write:
1. `LoginUseCase` tests - valid/invalid credentials
2. `PermissionService` tests - role-based access
3. `Expense` entity tests - calculations

### Integration Tests to Write:
1. Login flow
2. Expense CRUD operations
3. Export functionality

---

## Commits Plan

Commit after each major milestone:
1. ✅ `feat: add url_launcher, excel, crypto dependencies`
2. ✅ `fix: replace hardcoded colors with AppTheme`
3. ✅ `feat: enhance supplier screen with search and contacts`
4. ✗ `feat: implement user management domain layer`
5. ✗ `feat: implement user management data layer`
6. ✗ `feat: create login screen and auth controller`
7. ✗ `feat: add database migration v12 (users table)`
8. ✗ `feat: implement expense tracking domain and data layers`
9. ✗ `feat: add database migration v13 (expenses table)`
10. ✗ `feat: create expense screen and widgets`
11. ✗ `feat: implement export service`
12. ✗ `feat: implement backup service`
13. ✗ `feat: add data management screen`
14. ✗ `feat: integrate auth into navigation`
15. ✗ `test: add unit tests for auth and expenses`

---

## Rollback Plan

If issues occur:
1. Database migration errors: Add rollback in `_onDowngrade`
2. Build errors: Check package versions in pubspec.yaml
3. Runtime errors: Review logs for specific error location

---

## Notes

- Always run `flutter analyze` after each feature
- Test on physical device for contact actions (tel/mailto)
- Use default admin: `admin` / `admin123` after first install
