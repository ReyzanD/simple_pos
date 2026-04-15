import 'package:simple_pos/core/database/database_helper.dart';
import '../models/user_session_model.dart';

/// Local data source implementation for UserSession using SQLite
class UserSessionLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  UserSessionLocalDataSourceImpl({required this.databaseHelper});

  /// Create new session
  Future<int> createSession(UserSessionModel session) async {
    final db = await databaseHelper.database;
    return await db.insert('user_sessions', session.toMap());
  }

  /// Get all sessions for a user
  Future<List<UserSessionModel>> getUserSessions(int userId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'user_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'login_time DESC',
    );
    return maps.map((map) => UserSessionModel.fromMap(map)).toList();
  }

  /// Get active session for a user
  Future<UserSessionModel?> getActiveSession(int userId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'user_sessions',
      where: 'user_id = ? AND logout_time IS NULL',
      whereArgs: [userId],
      orderBy: 'login_time DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserSessionModel.fromMap(maps.first);
  }

  /// Get session by ID
  Future<UserSessionModel?> getSessionById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'user_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserSessionModel.fromMap(maps.first);
  }

  /// End a session by setting logout time
  Future<void> endSession(int sessionId, {double? closingCash}) async {
    final db = await databaseHelper.database;
    final updateData = <String, dynamic>{
      'logout_time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    if (closingCash != null) {
      updateData['closing_cash'] = closingCash as num;
    }
    await db.update(
      'user_sessions',
      updateData,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Get recent sessions from last N days
  Future<List<UserSessionModel>> getRecentSessions(int days) async {
    final db = await databaseHelper.database;
    final cutoffTime =
        DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch ~/
        1000;
    final maps = await db.query(
      'user_sessions',
      where: 'login_time >= ?',
      whereArgs: [cutoffTime],
      orderBy: 'login_time DESC',
    );
    return maps.map((map) => UserSessionModel.fromMap(map)).toList();
  }

  /// Delete old sessions
  Future<void> deleteOldSessions(DateTime beforeDate) async {
    final db = await databaseHelper.database;
    final beforeTime = beforeDate.millisecondsSinceEpoch ~/ 1000;
    await db.delete(
      'user_sessions',
      where: 'login_time < ?',
      whereArgs: [beforeTime],
    );
  }
}
