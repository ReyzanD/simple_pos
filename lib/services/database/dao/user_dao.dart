import 'package:sqflite/sqflite.dart';
import 'package:simple_pos/services/database/database_connection.dart';
import 'package:simple_pos/core/utils/logger.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;

/// Data Access Object (DAO) for User table operations.
///
/// This class provides a clean abstraction layer for all User-related database
/// operations, using DatabaseConnection for database access. It follows the DAO
/// pattern to encapsulate all data access logic for User entities.
///
/// Usage:
/// ```dart
/// final dao = UserDao.instance;
/// final users = await dao.getAll();
/// final user = await dao.insert({'username': 'john', 'password_hash': 'hash', 'full_name': 'John Doe'});
/// ```
class UserDao {
  // Private constructor to prevent instantiation
  UserDao._();

  // Singleton instance
  static final UserDao instance = UserDao._();

  // Database connection
  final DatabaseConnection _connection = DatabaseConnection.instance;

  /// Gets database instance from connection manager.
  Future<Database> get _db async => await _connection.database;

  // ==================== CRUD Operations ====================

  /// Inserts a new user into the database.
  ///
  /// [user] - A map containing user fields (username, password_hash, full_name, role, is_active, created_at, last_login)
  /// Returns the created user map with generated ID
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>> insert(Map<String, dynamic> user) async {
    try {
      AppLogger.database('Inserting user', details: user['username']);

      final db = await _db;
      final id = await db.insert('users', user);

      AppLogger.database('User inserted', details: 'ID: $id');

      // Return the user with its ID
      return {...user, 'id': id};
    } catch (e, stackTrace) {
      AppLogger.error('Failed to insert user',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menambahkan user',
        operation: 'insert user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves all users from database.
  ///
  /// Returns a list of user maps, ordered by full_name (A-Z)
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      AppLogger.database('Fetching all users from database');

      final db = await _db;
      final users = await db.query(
        'users',
        columns: ['id', 'username', 'full_name', 'role', 'is_active', 'created_at', 'last_login'],
        orderBy: 'full_name ASC',
      );

      AppLogger.database('Users fetched successfully',
          details: 'Count: ${users.length}');

      return users;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch all users',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua user',
        operation: 'get all users',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single user by its ID.
  ///
  /// [id] - The user ID to retrieve
  /// Returns user map if found, null otherwise
  /// Note: Password hash is excluded from the result for security
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      AppLogger.database('Fetching user by ID', details: 'ID: $id');

      final db = await _db;
      final results = await db.query(
        'users',
        columns: ['id', 'username', 'full_name', 'role', 'is_active', 'created_at', 'last_login'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('User fetched successfully', details: 'ID: $id');
        return results.first;
      } else {
        AppLogger.database('User not found', details: 'ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch user by ID',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil user',
        operation: 'get user by ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a user by username (for authentication).
  ///
  /// [username] - The username to search for
  /// Returns user map including password hash if found, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> getByUsername(String username) async {
    try {
      AppLogger.database('Fetching user by username', details: username);

      final db = await _db;
      final results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('User found', details: 'Username: $username');
        return results.first;
      } else {
        AppLogger.database('User not found', details: 'Username: $username');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch user by username',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil user berdasarkan username',
        operation: 'get user by username',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing user in database.
  ///
  /// [id] - The user ID to update
  /// [values] - A map containing user fields to update (password_hash can be updated but will be handled carefully)
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if user not found
  Future<int> update(int id, Map<String, dynamic> values) async {
    try {
      AppLogger.database('Updating user in database',
          details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'users',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'User tidak ditemukan',
          resourceType: 'User',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('User updated successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update user',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate user',
        operation: 'update user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates user's last login timestamp.
  ///
  /// [id] - The user ID to update
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> updateLastLogin(int id) async {
    try {
      AppLogger.database('Updating user last login', details: 'ID: $id');

      final db = await _db;
      final count = await db.update(
        'users',
        {'last_login': DateTime.now().millisecondsSinceEpoch ~/ 1000},
        where: 'id = ?',
        whereArgs: [id],
      );

      AppLogger.database('Last login updated', details: 'ID: $id');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update last login',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate last login',
        operation: 'update last login',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a user by ID.
  ///
  /// [id] - The user ID to delete
  /// Returns number of rows affected
  /// Throws [app_exceptions.DatabaseException] if operation fails
  /// Throws [app_exceptions.NotFoundException] if user not found
  Future<int> delete(int id) async {
    try {
      AppLogger.database('Deleting user', details: 'ID: $id');

      final db = await _db;
      final count = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw app_exceptions.NotFoundException(
          'User tidak ditemukan',
          resourceType: 'User',
          resourceId: id.toString(),
        );
      }

      AppLogger.database('User deleted successfully',
          details: 'ID: $id, Affected rows: $count');

      return count;
    } on app_exceptions.NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete user',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghapus user',
        operation: 'delete user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== Query Operations ====================

  /// Retrieves users by role.
  ///
  /// [role] - The role to filter by (e.g., 'admin', 'cashier')
  /// Returns a list of user maps for the specified role
  /// Note: Password hash is excluded from results
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getByRole(String role) async {
    try {
      AppLogger.database('Fetching users by role', details: role);

      final db = await _db;
      final users = await db.query(
        'users',
        columns: ['id', 'username', 'full_name', 'role', 'is_active', 'created_at', 'last_login'],
        where: 'role = ?',
        whereArgs: [role],
        orderBy: 'full_name ASC',
      );

      AppLogger.database('Users by role fetched successfully',
          details: 'Role: $role, Count: ${users.length}');

      return users;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch users by role',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil user berdasarkan role',
        operation: 'get users by role',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves active users only.
  ///
  /// Returns a list of active user maps
  /// Note: Password hash is excluded from results
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<List<Map<String, dynamic>>> getActiveUsers() async {
    try {
      AppLogger.database('Fetching active users');

      final db = await _db;
      final users = await db.query(
        'users',
        columns: ['id', 'username', 'full_name', 'role', 'is_active', 'created_at', 'last_login'],
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'full_name ASC',
      );

      AppLogger.database('Active users fetched successfully',
          details: 'Count: ${users.length}');

      return users;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch active users',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengambil user aktif',
        operation: 'get active users',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if a username already exists (for validation).
  ///
  /// [username] - The username to check
  /// [excludeId] - Optional ID to exclude from check (for updates)
  /// Returns true if username exists, false otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<bool> usernameExists(String username, {int? excludeId}) async {
    try {
      AppLogger.database('Checking if username exists', details: username);

      final db = await _db;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE username = ? AND id != ?',
        [username, excludeId ?? 0],
      );
      final count = Sqflite.firstIntValue(results) ?? 0;

      AppLogger.database('Username check completed',
          details: 'Username: $username, Exists: ${count > 0}');

      return count > 0;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check username',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal memeriksa username',
        operation: 'check username',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Authenticates a user by verifying username and password.
  ///
  /// [username] - The username to authenticate
  /// [passwordHash] - The password hash to verify
  /// Returns user map without password if authentication succeeds, null otherwise
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<Map<String, dynamic>?> authenticate(String username, String passwordHash) async {
    try {
      AppLogger.database('Authenticating user', details: username);

      final db = await _db;
      final results = await db.query(
        'users',
        columns: ['id', 'username', 'full_name', 'role', 'is_active', 'created_at', 'last_login'],
        where: 'username = ? AND password_hash = ? AND is_active = ?',
        whereArgs: [username, passwordHash, 1],
        limit: 1,
      );

      if (results.isNotEmpty) {
        AppLogger.database('Authentication successful', details: 'Username: $username');

        // Update last login
        await updateLastLogin(results.first['id'] as int);

        return results.first;
      } else {
        AppLogger.database('Authentication failed', details: 'Username: $username');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to authenticate user',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal mengautentikasi user',
        operation: 'authenticate user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts total number of users in database.
  ///
  /// Returns total count of users
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> count() async {
    try {
      AppLogger.database('Counting total users');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Total users counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count users',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah user',
        operation: 'count users',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Counts active users in database.
  ///
  /// Returns count of active users
  /// Throws [app_exceptions.DatabaseException] if operation fails
  Future<int> countActive() async {
    try {
      AppLogger.database('Counting active users');

      final db = await _db;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM users WHERE is_active = 1');
      final count = Sqflite.firstIntValue(result) ?? 0;

      AppLogger.database('Active users counted', details: 'Count: $count');

      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to count active users',
          error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        'Gagal menghitung jumlah user aktif',
        operation: 'count active users',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
