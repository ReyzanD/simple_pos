import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for updating an existing user
class UpdateUserUseCase {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  /// Execute the use case to update a user
  ///
  /// Returns true if successful, false otherwise
  Future<bool> execute(User user) async {
    try {
      await _repository.updateUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Change user password
  Future<bool> changePassword(int userId, String newPassword) async {
    try {
      final passwordHash = _hashPassword(newPassword);
      await _repository.changePassword(userId, passwordHash);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle user active status
  Future<bool> toggleActiveStatus(User user) async {
    try {
      final updated = user.copyWith(isActive: !user.isActive);
      await _repository.updateUser(updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _hashPassword(String password) {
    // Simple hash - matches the one used in LoginUseCase and database migration
    // NOTE: In production, use proper bcrypt/argon2 with proper salt
    final bytes = password.codeUnits;
    final hash = bytes.fold<int>(
        0, (prev, element) => prev + element);
    return 'simple_hash_$hash';
  }
}
