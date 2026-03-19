import 'user_role.dart';

/// User entity representing a system user
class User {
  final int? id;
  final String username;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final DateTime? lastLogin;

  const User({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.isActive = true,
    this.lastLogin,
  });

  /// Create a copy of this User with some fields replaced
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

  /// Check if user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is a cashier
  bool get isCashier => role == UserRole.cashier;

  /// Check if user is active
  bool get canLogin => isActive;

  @override
  String toString() {
    return 'User(id: $id, username: $username, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.username == username &&
        other.fullName == fullName &&
        other.role == role &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        fullName.hashCode ^
        role.hashCode ^
        isActive.hashCode;
  }
}
