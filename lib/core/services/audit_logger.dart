import '../domain/entities/audit_log.dart';
import '../utils/logger.dart';
import '../database/database_helper.dart';

/// Service for logging audit events
/// Tracks sensitive operations for security, compliance, and fraud detection
class AuditLogger {
  static final AuditLogger instance = AuditLogger._init();
  bool _isEnabled = true;

  AuditLogger._init();

  /// Enable or disable audit logging
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    AppLogger.info('Audit logging ${enabled ? "enabled" : "disabled"}');
  }

  /// Check if audit logging is enabled
  bool get isEnabled => _isEnabled;

  /// Log an audit event
  Future<void> log({
    required AuditAction action,
    required String entityType,
    String? entityId,
    String? description,
    String? username,
    String? userId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    if (!_isEnabled) return;

    try {
      final auditLog = AuditLog(
        action: action.displayName,
        entityType: entityType,
        entityId: entityId,
        description: description,
        username: username ?? 'System',
        userId: userId,
        oldValues: oldValues,
        newValues: newValues,
        createdAt: DateTime.now(),
      );

      final db = await DatabaseHelper.instance.database;
      await db.insert('audit_logs', auditLog.toJson());

      AppLogger.debug('Audit log created', tag: 'AuditLogger');
    } catch (e, stackTrace) {
      // Don't throw - audit logging failures shouldn't break the app
      AppLogger.error(
        'Failed to create audit log',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuditLogger',
      );
    }
  }

  /// Log user login
  Future<void> logLogin({required String username, String? userId}) async {
    await log(
      action: AuditAction.userLoggedIn,
      entityType: 'User',
      entityId: userId,
      username: username,
      userId: userId,
      description: 'User logged in',
    );
  }

  /// Log user logout
  Future<void> logLogout({required String username, String? userId}) async {
    await log(
      action: AuditAction.userLoggedOut,
      entityType: 'User',
      entityId: userId,
      username: username,
      userId: userId,
      description: 'User logged out',
    );
  }

  /// Log product creation
  Future<void> logProductCreated({
    required String username,
    String? userId,
    required String productName,
    required int productId,
  }) async {
    await log(
      action: AuditAction.productCreated,
      entityType: 'Product',
      entityId: productId.toString(),
      username: username,
      userId: userId,
      newValues: {'name': productName},
      description: 'Product "$productName" created',
    );
  }

  /// Log product update
  Future<void> logProductUpdated({
    required String username,
    String? userId,
    required String productName,
    required int productId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    // Check if price was changed
    if (oldValues != null && newValues != null) {
      final oldPrice = oldValues['price'];
      final newPrice = newValues['price'];
      if (oldPrice != null && newPrice != null && oldPrice != newPrice) {
        await log(
          action: AuditAction.priceChanged,
          entityType: 'Product',
          entityId: productId.toString(),
          username: username,
          userId: userId,
          oldValues: {'price': oldPrice},
          newValues: {'price': newPrice},
          description:
              'Price changed for "$productName": $oldPrice → $newPrice',
        );
        return;
      }
    }

    await log(
      action: AuditAction.productUpdated,
      entityType: 'Product',
      entityId: productId.toString(),
      username: username,
      userId: userId,
      oldValues: oldValues,
      newValues: newValues,
      description: 'Product "$productName" updated',
    );
  }

  /// Log product deletion
  Future<void> logProductDeleted({
    required String username,
    String? userId,
    required String productName,
    required int productId,
    Map<String, dynamic>? oldValues,
  }) async {
    await log(
      action: AuditAction.productDeleted,
      entityType: 'Product',
      entityId: productId.toString(),
      username: username,
      userId: userId,
      oldValues: oldValues,
      description: 'Product "$productName" deleted',
    );
  }

  /// Log transaction creation
  Future<void> logTransactionCreated({
    String? username,
    String? userId,
    required int transactionId,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    await log(
      action: AuditAction.transactionCreated,
      entityType: 'Transaction',
      entityId: transactionId.toString(),
      username: username,
      userId: userId,
      newValues: {'total': totalAmount, 'payment_method': paymentMethod},
      description: 'Transaction created: $paymentMethod $totalAmount',
    );
  }

  /// Log transaction void
  Future<void> logTransactionVoided({
    required String username,
    String? userId,
    required int transactionId,
    required double totalAmount,
  }) async {
    await log(
      action: AuditAction.transactionVoided,
      entityType: 'Transaction',
      entityId: transactionId.toString(),
      username: username,
      userId: userId,
      description: 'Transaction voided: $totalAmount',
    );
  }

  /// Log refund
  Future<void> logRefundProcessed({
    required String username,
    String? userId,
    required int transactionId,
    required double refundAmount,
  }) async {
    await log(
      action: AuditAction.refundProcessed,
      entityType: 'Transaction',
      entityId: transactionId.toString(),
      username: username,
      userId: userId,
      newValues: {'refund_amount': refundAmount},
      description: 'Refund processed: $refundAmount',
    );
  }

  /// Log user created
  Future<void> logUserCreated({
    required String username,
    String? userId,
    required String newUsername,
    required int newUserId,
  }) async {
    await log(
      action: AuditAction.userCreated,
      entityType: 'User',
      entityId: newUserId.toString(),
      username: username,
      userId: userId,
      newValues: {'username': newUsername},
      description: 'User "$newUsername" created',
    );
  }

  /// Log user updated
  Future<void> logUserUpdated({
    required String username,
    String? userId,
    required String targetUsername,
    required int targetUserId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    await log(
      action: AuditAction.userUpdated,
      entityType: 'User',
      entityId: targetUserId.toString(),
      username: username,
      userId: userId,
      oldValues: oldValues,
      newValues: newValues,
      description: 'User "$targetUsername" updated',
    );
  }

  /// Log user deleted
  Future<void> logUserDeleted({
    required String username,
    String? userId,
    required String targetUsername,
    required int targetUserId,
  }) async {
    await log(
      action: AuditAction.userDeleted,
      entityType: 'User',
      entityId: targetUserId.toString(),
      username: username,
      userId: userId,
      description: 'User "$targetUsername" deleted',
    );
  }

  /// Log password changed
  Future<void> logPasswordChanged({
    required String username,
    String? userId,
    required String targetUsername,
    required int targetUserId,
  }) async {
    await log(
      action: AuditAction.passwordChanged,
      entityType: 'User',
      entityId: targetUserId.toString(),
      username: username,
      userId: userId,
      description: 'Password changed for user "$targetUsername"',
    );
  }

  /// Log shift opened
  Future<void> logShiftOpened({
    required String username,
    String? userId,
    required int shiftId,
  }) async {
    await log(
      action: AuditAction.shiftOpened,
      entityType: 'Shift',
      entityId: shiftId.toString(),
      username: username,
      userId: userId,
      description: 'Shift opened',
    );
  }

  /// Log shift closed
  Future<void> logShiftClosed({
    required String username,
    String? userId,
    required int shiftId,
    required double closingBalance,
  }) async {
    await log(
      action: AuditAction.shiftClosed,
      entityType: 'Shift',
      entityId: shiftId.toString(),
      username: username,
      userId: userId,
      newValues: {'closing_balance': closingBalance},
      description: 'Shift closed: $closingBalance',
    );
  }

  /// Log stock adjusted
  Future<void> logStockAdjusted({
    required String username,
    String? userId,
    required String productName,
    required int productId,
    required int oldStock,
    required int newStock,
    required String reason,
  }) async {
    await log(
      action: AuditAction.stockAdjusted,
      entityType: 'Product',
      entityId: productId.toString(),
      username: username,
      userId: userId,
      oldValues: {'stock': oldStock},
      newValues: {'stock': newStock},
      description:
          'Stock adjusted for "$productName": $oldStock → $newStock ($reason)',
    );
  }

  /// Get audit logs for an entity
  Future<List<AuditLog>> getLogsForEntity({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final data = await db.query(
        'audit_logs',
        where: 'entity_type = ? AND entity_id = ?',
        whereArgs: [entityType, entityId],
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return data.map((map) => _mapToAuditLog(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get audit logs',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuditLogger',
      );
      return [];
    }
  }

  /// Get recent audit logs
  Future<List<AuditLog>> getRecentLogs({int limit = 100}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final data = await db.query(
        'audit_logs',
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return data.map((map) => _mapToAuditLog(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get recent audit logs',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuditLogger',
      );
      return [];
    }
  }

  /// Map database row to AuditLog object
  AuditLog _mapToAuditLog(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as int?,
      action: map['action'] as String,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String?,
      description: map['description'] as String?,
      username: map['username'] as String?,
      userId: map['user_id'] as String?,
      ipAddress: map['ip_address'] as String?,
      userAgent: map['user_agent'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
