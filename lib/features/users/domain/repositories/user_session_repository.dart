import '../entities/user_session.dart';

/// Repository interface for UserSession data operations
abstract class UserSessionRepository {
  /// Create a new user session
  Future<int> createSession(UserSession session);

  /// Get all sessions for a user
  Future<List<UserSession>> getUserSessions(int userId);

  /// Get active session for a user
  Future<UserSession?> getActiveSession(int userId);

  /// Get session by ID
  Future<UserSession?> getSessionById(int id);

  /// End a session by setting logout time
  Future<void> endSession(int sessionId, {double? closingCash});

  /// Get recent sessions (last N days)
  Future<List<UserSession>> getRecentSessions(int days);

  /// Delete old sessions (cleanup)
  Future<void> deleteOldSessions(DateTime beforeDate);
}
