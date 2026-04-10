import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/permission.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../../../core/services/audit_logger.dart';

/// AuthController manages authentication state and user operations
class AuthController extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final GetUsersUseCase _getUsersUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _users = [];

  AuthController({
    required LoginUseCase loginUseCase,
    required GetUsersUseCase getUsersUseCase,
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required DeleteUserUseCase deleteUserUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _getUsersUseCase = getUsersUseCase,
       _createUserUseCase = createUserUseCase,
       _updateUserUseCase = updateUserUseCase,
       _deleteUserUseCase = deleteUserUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  List<User> get users => _users;

  /// Login with username and password
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _loginUseCase.execute(username, password);
      if (user != null) {
        _currentUser = user;

        // Log successful login
        await AuditLogger.instance.logLogin(
          username: user.username,
          userId: user.id.toString(),
        );

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

  /// Logout current user
  void logout() {
    final user = _currentUser;
    _currentUser = null;
    notifyListeners();

    // Log logout
    if (user != null) {
      AuditLogger.instance.logLogout(
        username: user.username,
        userId: user.id.toString(),
      );
    }
  }

  /// Set current user (for session restore)
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Load all users (admin only)
  Future<void> loadUsers() async {
    _setLoading(true);
    _clearError();

    try {
      _users = await _getUsersUseCase.execute(activeOnly: false);
    } catch (e) {
      _setError('Gagal memuat pengguna: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new user (admin only)
  Future<bool> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final id = await _createUserUseCase.execute(
        username: username,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (id > 0) {
        // Refresh users list
        await loadUsers();
        _setLoading(false);
        return true;
      } else {
        _setError('Username sudah ada atau gagal membuat pengguna');
        return false;
      }
    } catch (e) {
      _setError('Gagal membuat pengguna: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user (admin only)
  Future<bool> updateUser(User user) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _updateUserUseCase.execute(user);
      if (success) {
        // Refresh users list
        await loadUsers();
        // Update current user if updating self
        if (_currentUser?.id == user.id) {
          _currentUser = user;
        }
        _setLoading(false);
        return true;
      } else {
        _setError('Gagal memperbarui pengguna');
        return false;
      }
    } catch (e) {
      _setError('Gagal memperbarui pengguna: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user (admin only)
  Future<bool> deleteUser(int userId) async {
    _setLoading(true);
    _clearError();

    try {
      final canDelete = await _deleteUserUseCase.canDeleteUser(
        userId,
        _currentUser?.id,
      );

      if (!canDelete) {
        _setError('Tidak dapat menghapus pengguna ini');
        _setLoading(false);
        return false;
      }

      final success = await _deleteUserUseCase.execute(userId);
      if (success) {
        // Refresh users list
        await loadUsers();
        _setLoading(false);
        return true;
      } else {
        _setError('Gagal menghapus pengguna');
        return false;
      }
    } catch (e) {
      _setError('Gagal menghapus pengguna: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change user password
  Future<bool> changePassword(int userId, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _updateUserUseCase.changePassword(
        userId,
        newPassword,
      );
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Gagal mengubah password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if current user has specific permission
  bool hasPermission(Permission permission) {
    if (_currentUser == null) return false;
    return _hasPermission(_currentUser!, permission);
  }

  /// Check if a user has specific permission
  bool _hasPermission(User user, Permission permission) {
    // Admin has all permissions
    if (user.isAdmin) return true;

    // Cashier permissions
    if (user.isCashier) {
      const cashierPermissions = {
        Permission.posProcessSales,
        Permission.inventoryView,
      };
      return cashierPermissions.contains(permission);
    }

    return false;
  }

  /// Check if current user can access feature
  bool canAccessFeature(String feature) {
    if (_currentUser == null) return false;

    // Map feature strings to permissions
    final permission = _featureToPermission(feature);
    if (permission == null) return true; // No specific permission required

    return hasPermission(permission);
  }

  Permission? _featureToPermission(String feature) {
    switch (feature) {
      case 'settings':
        return Permission.settingsView;
      case 'sales_reports':
        return Permission.salesViewReports;
      case 'inventory_edit':
        return Permission.inventoryEdit;
      case 'inventory_add':
        return Permission.inventoryAdd;
      case 'inventory_delete':
        return Permission.inventoryDelete;
      case 'promotions':
        return Permission.salesManagePromotions;
      case 'manage_users':
        return Permission.settingsManageUsers;
      case 'apply_discount':
        return Permission.posApplyDiscounts;
      case 'process_returns':
        return Permission.posProcessReturns;
      default:
        return null;
    }
  }

  // Private state setters
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
