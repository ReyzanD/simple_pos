import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource_impl.dart';
import '../models/user_model.dart';

/// Repository implementation for User data operations
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSourceImpl localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<List<User>> getUsers() async {
    final models = await localDataSource.getUsers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<User?> getUserById(int id) async {
    final model = await localDataSource.getUserById(id);
    return model?.toEntity();
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    final model = await localDataSource.getUserByUsername(username);
    return model?.toEntity();
  }

  @override
  Future<int> createUser(User user, String passwordHash) async {
    final model = UserModel.fromEntity(user);
    return await localDataSource.createUser(model, passwordHash);
  }

  @override
  Future<void> updateUser(User user) async {
    final model = UserModel.fromEntity(user);
    await localDataSource.updateUser(model);
  }

  @override
  Future<void> deleteUser(int id) async {
    await localDataSource.deleteUser(id);
  }

  @override
  Future<String?> getPasswordHash(int userId) async {
    return await localDataSource.getPasswordHash(userId);
  }

  @override
  Future<void> updateLastLogin(int userId) async {
    await localDataSource.updateLastLogin(userId);
  }

  @override
  Future<bool> usernameExists(String username) async {
    return await localDataSource.usernameExists(username);
  }

  @override
  Future<void> changePassword(int userId, String newPasswordHash) async {
    await localDataSource.changePassword(userId, newPasswordHash);
  }
}
