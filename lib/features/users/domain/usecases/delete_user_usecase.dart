import '../repositories/user_repository.dart';

/// Use case for deleting a user
class DeleteUserUseCase {
  final UserRepository _repository;

  DeleteUserUseCase(this._repository);

  /// Execute the use case to delete a user
  ///
  /// Returns true if successful, false otherwise
  Future<bool> execute(int userId) async {
    try {
      await _repository.deleteUser(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user can be safely deleted
  ///
  /// Users cannot delete themselves and must not be the last admin
  Future<bool> canDeleteUser(int userIdToDelete, int? currentUserId) async {
    // Cannot delete yourself
    if (userIdToDelete == currentUserId) {
      return false;
    }

    // Get the user to delete
    final userToDelete = await _repository.getUserById(userIdToDelete);
    if (userToDelete == null) {
      return false;
    }

    // Check if this is the last admin
    if (userToDelete.isAdmin) {
      final allUsers = await _repository.getUsers();
      final adminCount = allUsers.where((u) => u.isAdmin && u.isActive).length;
      if (adminCount <= 1) {
        return false;
      }
    }

    return true;
  }
}
