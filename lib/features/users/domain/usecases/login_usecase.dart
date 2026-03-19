import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for user login authentication
class LoginUseCase {
  final UserRepository _repository;

  LoginUseCase(this._repository);

  /// Authenticate user with username and password
  /// Returns User if successful, null otherwise
  Future<User?> execute(String username, String password) async {
    // Get user by username
    final user = await _repository.getUserByUsername(username);

    if (user == null) {
      return null;
    }

    // Check if user is active
    if (!user.isActive) {
      return null;
    }

    // Get stored password hash
    final storedHash = await _repository.getPasswordHash(user.id!);
    if (storedHash == null) {
      return null;
    }

    // Verify password using simple hash (matches database migration)
    final inputHash = _hashPassword(password);
    if (inputHash == storedHash) {
      // Update last login
      await _repository.updateLastLogin(user.id!);
      return user;
    }

    return null;
  }

  /// Hash a password for storage
  /// NOTE: This is a simple hash for demo purposes
  /// In production, use proper bcrypt/argon2 with proper salt
  String _hashPassword(String password) {
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(
        0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
  }
}
