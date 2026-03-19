import 'package:simple_pos/services/database/database_helper.dart';
import '../models/user_model.dart';

/// Local data source implementation for User using SQLite
class UserLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  UserLocalDataSourceImpl({required this.databaseHelper});

  /// Get all users from database
  Future<List<UserModel>> getUsers() async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Get user by ID
  Future<UserModel?> getUserById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  /// Create new user with password hash
  Future<int> createUser(UserModel user, String passwordHash) async {
    final db = await databaseHelper.database;
    final map = user.toMap();
    map['password_hash'] = passwordHash;
    map['created_at'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return await db.insert('users', map);
  }

  /// Update existing user
  Future<void> updateUser(UserModel user) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Delete user (set isActive to 0 - soft delete)
  Future<void> deleteUser(int id) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get password hash for user
  Future<String?> getPasswordHash(int userId) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'users',
      columns: ['password_hash'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return maps.first['password_hash'] as String?;
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(int userId) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      {'last_login': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Check if username exists
  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  /// Change user password
  Future<void> changePassword(int userId, String newPasswordHash) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      {'password_hash': newPasswordHash},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
