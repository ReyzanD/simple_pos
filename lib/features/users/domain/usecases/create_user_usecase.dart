import '../entities/user.dart';
import '../entities/user_role.dart';
import '../repositories/user_repository.dart';

/// Use case for creating a new user
class CreateUserUseCase {
  final UserRepository _repository;

  CreateUserUseCase(this._repository);

  /// Execute the use case to create a new user
  ///
  /// Returns the ID of the created user, or -1 if creation failed
  Future<int> execute({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    // Check if username already exists
    final exists = await _repository.usernameExists(username);
    if (exists) {
      return -1;
    }

    // Hash the password
    final passwordHash = _hashPassword(password);

    // Create user entity
    final user = User(
      username: username,
      fullName: fullName,
      role: _parseRole(role),
      isActive: true,
    );

    return await _repository.createUser(user, passwordHash);
  }

  String _hashPassword(String password) {
    // Simple hash - matches the one used in LoginUseCase and database migration
    // NOTE: In production, use proper bcrypt/argon2 with proper salt
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(
        0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
  }

  UserRole _parseRole(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.cashier,
    );
  }
}
