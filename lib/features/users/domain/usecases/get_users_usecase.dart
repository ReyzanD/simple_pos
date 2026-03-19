import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for getting all users
class GetUsersUseCase {
  final UserRepository _repository;

  GetUsersUseCase(this._repository);

  /// Execute the use case to get all users
  Future<List<User>> execute({bool activeOnly = false}) async {
    final users = await _repository.getUsers();
    if (activeOnly) {
      return users.where((u) => u.isActive).toList();
    }
    return users;
  }

  /// Get user by ID
  Future<User?> getById(int id) async {
    return await _repository.getUserById(id);
  }

  /// Get user by username
  Future<User?> getByUsername(String username) async {
    return await _repository.getUserByUsername(username);
  }
}
