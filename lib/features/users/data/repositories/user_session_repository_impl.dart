import '../../domain/entities/user_session.dart';
import '../../domain/repositories/user_session_repository.dart';
import '../datasources/user_session_local_datasource_impl.dart';
import '../models/user_session_model.dart';

/// Repository implementation for UserSession data operations
class UserSessionRepositoryImpl implements UserSessionRepository {
  final UserSessionLocalDataSourceImpl localDataSource;

  UserSessionRepositoryImpl({required this.localDataSource});

  @override
  Future<int> createSession(UserSession session) async {
    final model = UserSessionModel.fromEntity(session);
    return await localDataSource.createSession(model);
  }

  @override
  Future<List<UserSession>> getUserSessions(int userId) async {
    final models = await localDataSource.getUserSessions(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<UserSession?> getActiveSession(int userId) async {
    final model = await localDataSource.getActiveSession(userId);
    return model?.toEntity();
  }

  @override
  Future<UserSession?> getSessionById(int id) async {
    final model = await localDataSource.getSessionById(id);
    return model?.toEntity();
  }

  @override
  Future<void> endSession(int sessionId, {double? closingCash}) async {
    await localDataSource.endSession(sessionId, closingCash: closingCash);
  }

  @override
  Future<List<UserSession>> getRecentSessions(int days) async {
    final models = await localDataSource.getRecentSessions(days);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteOldSessions(DateTime beforeDate) async {
    await localDataSource.deleteOldSessions(beforeDate);
  }
}
