import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUserUseCase {
  final UserRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Execute the use case to get current user by ID
  Future<User?> execute(int userId) async {
    return await _repository.getUserById(userId);
  }

  /// Check if current user has specific permission
  bool hasPermission(User user, String permission) {
    // TODO: Implement permission checking logic
    // For now, admin has all permissions
    return user.isAdmin;
  }
}
