/// Audit log entry for tracking sensitive operations
/// Used for security, compliance, and fraud detection
class AuditLog {
  final int? id;
  final String action;
  final String entityType;
  final String? entityId;
  final String? description;
  final String? username;
  final String? userId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  const AuditLog({
    this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    this.description,
    this.username,
    this.userId,
    this.oldValues,
    this.newValues,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  /// Create a copy with modified fields
  AuditLog copyWith({
    int? id,
    String? action,
    String? entityType,
    String? entityId,
    String? description,
    String? username,
    String? userId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
    String? userAgent,
    DateTime? createdAt,
  }) {
    return AuditLog(
      id: id ?? this.id,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      description: description ?? this.description,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      oldValues: oldValues ?? this.oldValues,
      newValues: newValues ?? this.newValues,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'description': description,
      'username': username,
      'user_id': userId,
      'old_values': oldValues?.toString(),
      'new_values': newValues?.toString(),
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'AuditLog(id: $id, action: $action, entityType: $entityType, entityId: $entityId, username: $username, createdAt: $createdAt)';
  }
}

/// Audit action types
enum AuditAction {
  // Product operations
  productCreated,
  productUpdated,
  productDeleted,
  priceChanged,

  // Transaction operations
  transactionCreated,
  transactionVoided,
  refundProcessed,

  // User operations
  userLoggedIn,
  userLoggedOut,
  userCreated,
  userUpdated,
  userDeleted,
  passwordChanged,

  // Shift operations
  shiftOpened,
  shiftClosed,

  // Settings operations
  settingsUpdated,

  // Inventory operations
  stockAdjusted,
}

/// Extension to get display name for audit actions
extension AuditActionExtension on AuditAction {
  String get displayName {
    switch (this) {
      case AuditAction.productCreated:
        return 'Produk Dibuat';
      case AuditAction.productUpdated:
        return 'Produk Diperbarui';
      case AuditAction.productDeleted:
        return 'Produk Dihapus';
      case AuditAction.priceChanged:
        return 'Harga Diubah';
      case AuditAction.transactionCreated:
        return 'Transaksi Dibuat';
      case AuditAction.transactionVoided:
        return 'Transaksi Dibatalkan';
      case AuditAction.refundProcessed:
        return 'Refund Diproses';
      case AuditAction.userLoggedIn:
        return 'Pengguna Masuk';
      case AuditAction.userLoggedOut:
        return 'Pengguna Keluar';
      case AuditAction.userCreated:
        return 'Pengguna Dibuat';
      case AuditAction.userUpdated:
        return 'Pengguna Diperbarui';
      case AuditAction.userDeleted:
        return 'Pengguna Dihapus';
      case AuditAction.passwordChanged:
        return 'Password Diubah';
      case AuditAction.shiftOpened:
        return 'Shift Dibuka';
      case AuditAction.shiftClosed:
        return 'Shift Ditutup';
      case AuditAction.settingsUpdated:
        return 'Pengaturan Diperbarui';
      case AuditAction.stockAdjusted:
        return 'Stok Disesuaikan';
    }
  }
}
