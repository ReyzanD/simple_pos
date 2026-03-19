import '../repositories/user_session_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  final UserSessionRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout by recording session end time
  Future<void> execute(int sessionId, {double? closingCash}) async {
    await _repository.endSession(sessionId, closingCash: closingCash);
  }

  /// Execute logout for the current active session
  Future<void> logoutCurrentSession(int userId, {double? closingCash}) async {
    final activeSession = await _repository.getActiveSession(userId);
    if (activeSession != null) {
      await execute(activeSession.id!, closingCash: closingCash);
    }
  }
}
