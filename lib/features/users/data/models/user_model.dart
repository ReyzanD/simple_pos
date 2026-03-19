import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

/// UserModel for data transfer between database and domain layer
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

  /// Create UserModel from database map
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

  /// Convert to database map
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

  /// Convert to domain entity
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

  /// Create UserModel from domain entity
  static UserModel fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      role: user.role.name,
      isActive: user.isActive ? 1 : 0,
      lastLogin: user.lastLogin != null
          ? user.lastLogin!.millisecondsSinceEpoch ~/ 1000
          : null,
    );
  }
}
