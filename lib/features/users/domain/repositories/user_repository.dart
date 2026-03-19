import '../entities/user.dart';

/// Repository interface for User data operations
abstract class UserRepository {
  /// Get all users
  Future<List<User>> getUsers();

  /// Get user by ID
  Future<User?> getUserById(int id);

  /// Get user by username
  Future<User?> getUserByUsername(String username);

  /// Create a new user with password hash
  Future<int> createUser(User user, String passwordHash);

  /// Update existing user
  Future<void> updateUser(User user);

  /// Delete user (soft delete by setting isActive to false)
  Future<void> deleteUser(int id);

  /// Get password hash for authentication
  Future<String?> getPasswordHash(int userId);

  /// Update last login timestamp
  Future<void> updateLastLogin(int userId);

  /// Check if username exists
  Future<bool> usernameExists(String username);

  /// Change user password
  Future<void> changePassword(int userId, String newPasswordHash);
}
