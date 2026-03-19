/// User role enum with display name extension
enum UserRole {
  admin,
  cashier;
}

/// Extension for UserRole to provide display names
extension UserRoleExtension on UserRole {
  /// Get the display name for the user role (Indonesian)
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.cashier:
        return 'Kasir';
    }
  }

  /// Get the description for the user role
  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Akses penuh ke semua fitur';
      case UserRole.cashier:
        return 'Hanya transaksi dan lihat stok';
    }
  }

  /// Convert string to UserRole
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.cashier,
    );
  }
}
