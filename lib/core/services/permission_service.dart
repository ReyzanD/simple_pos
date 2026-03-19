import '../../features/users/domain/entities/user.dart';
import '../../features/users/domain/entities/user_role.dart';
import '../../features/users/domain/entities/permission.dart';

/// PermissionService for role-based access control (RBAC)
/// Maps user roles to their granted permissions
class PermissionService {
  /// Permission matrix: maps roles to their granted permissions
  static const Map<UserRole, Set<Permission>> _rolePermissions = {
    // Admin - Full access to all features
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
      Permission.settingsManageData,
    },

    // Cashier - Limited access
    UserRole.cashier: {
      // POS - Limited to basic sales
      Permission.posProcessSales,

      // Inventory - Read-only
      Permission.inventoryView,

      // Settings - Can access settings view but limited
      Permission.settingsView,
    },
  };

  /// Feature path to permission mapping
  /// Used for navigation-based permission checks
  static const Map<String, Permission> _featurePermissions = {
    'pos': Permission.posProcessSales,
    'pos_discount': Permission.posApplyDiscounts,
    'pos_returns': Permission.posProcessReturns,
    'inventory': Permission.inventoryView,
    'inventory_add': Permission.inventoryAdd,
    'inventory_edit': Permission.inventoryEdit,
    'inventory_delete': Permission.inventoryDelete,
    'sales': Permission.salesViewReports,
    'sales_reports': Permission.salesViewReports,
    'promotions': Permission.salesManagePromotions,
    'settings': Permission.settingsView,
    'settings_users': Permission.settingsManageUsers,
    'settings_printers': Permission.settingsManagePrinters,
    'settings_data': Permission.settingsManageData,
  };

  /// Check if a user has a specific permission
  bool hasPermission(User user, Permission permission) {
    final permissions = _rolePermissions[user.role];
    return permissions?.contains(permission) ?? false;
  }

  /// Check if a user can access a specific feature
  bool canAccessFeature(User user, String feature) {
    final permission = _featurePermissions[feature];
    if (permission == null) return true; // No specific permission required
    return hasPermission(user, permission);
  }

  /// Get all permissions for a user role
  Set<Permission> getPermissionsForRole(UserRole role) {
    return _rolePermissions[role] ?? {};
  }

  /// Check if user is admin (convenience method)
  bool isAdmin(User user) {
    return user.role == UserRole.admin;
  }

  /// Check if user is cashier (convenience method)
  bool isCashier(User user) {
    return user.role == UserRole.cashier;
  }

  /// Get display name for permission
  String getPermissionDisplayName(Permission permission) {
    return permission.displayName;
  }

  /// Check if user can process discounts
  bool canApplyDiscounts(User user) {
    return hasPermission(user, Permission.posApplyDiscounts);
  }

  /// Check if user can process returns
  bool canProcessReturns(User user) {
    return hasPermission(user, Permission.posProcessReturns);
  }

  /// Check if user can add products
  bool canAddProducts(User user) {
    return hasPermission(user, Permission.inventoryAdd);
  }

  /// Check if user can edit products
  bool canEditProducts(User user) {
    return hasPermission(user, Permission.inventoryEdit);
  }

  /// Check if user can delete products
  bool canDeleteProducts(User user) {
    return hasPermission(user, Permission.inventoryDelete);
  }

  /// Check if user can view reports
  bool canViewReports(User user) {
    return hasPermission(user, Permission.salesViewReports);
  }

  /// Check if user can manage promotions
  bool canManagePromotions(User user) {
    return hasPermission(user, Permission.salesManagePromotions);
  }

  /// Check if user can manage users (admin only)
  bool canManageUsers(User user) {
    return hasPermission(user, Permission.settingsManageUsers);
  }

  /// Check if user can manage printers (admin only)
  bool canManagePrinters(User user) {
    return hasPermission(user, Permission.settingsManagePrinters);
  }

  /// Check if user can manage data (admin only)
  bool canManageData(User user) {
    return hasPermission(user, Permission.settingsManageData);
  }
}
