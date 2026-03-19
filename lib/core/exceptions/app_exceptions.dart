/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';

  String get userMessage => message;
}

/// Exception thrown when database operations fail
class DatabaseException extends AppException {
  final String? operation;

  const DatabaseException(
    super.message, {
    this.operation,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage {
    if (operation != null) {
      return 'Gagal melakukan $operation. Silakan coba lagi.';
    }
    return 'Terjadi kesalahan database. Silakan coba lagi.';
  }

  @override
  String toString() =>
      'DatabaseException(operation: $operation, message: $message)';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final String? field;

  const ValidationException(
    super.message, {
    this.field,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage {
    if (field != null) {
      return '$field tidak valid: $message';
    }
    return 'Validasi gagal: $message';
  }

  @override
  String toString() => 'ValidationException(field: $field, message: $message)';
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  final String? resourceType;
  final String? resourceId;

  const NotFoundException(
    super.message, {
    this.resourceType,
    this.resourceId,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage {
    if (resourceType != null && resourceId != null) {
      return '$resourceType dengan ID $resourceId tidak ditemukan.';
    }
    if (resourceType != null) {
      return '$resourceType tidak ditemukan.';
    }
    return 'Data tidak ditemukan.';
  }

  @override
  String toString() =>
      'NotFoundException(type: $resourceType, id: $resourceId, message: $message)';
}

/// Exception thrown when a resource conflict occurs (e.g., duplicate entry)
class ConflictException extends AppException {
  final String? resourceType;
  final String? resourceId;

  const ConflictException(
    super.message, {
    this.resourceType,
    this.resourceId,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage {
    if (resourceType != null && resourceId != null) {
      return '$resourceType dengan ID $resourceId sudah ada.';
    }
    if (resourceType != null) {
      return '$resourceType sudah ada.';
    }
    return 'Konflik data. Silakan periksa kembali.';
  }

  @override
  String toString() =>
      'ConflictException(type: $resourceType, id: $resourceId, message: $message)';
}

/// Exception thrown when there's insufficient stock
class InsufficientStockException extends AppException {
  final int requested;
  final int available;

  const InsufficientStockException(
    super.message, {
    required this.requested,
    required this.available,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage =>
      'Stok tidak mencukupi. Diminta: $requested, Tersedia: $available';

  @override
  String toString() =>
      'InsufficientStockException(requested: $requested, available: $available, message: $message)';
}

/// Exception thrown when cart is empty but operation requires items
class EmptyCartException extends AppException {
  const EmptyCartException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Keranjang masih kosong. Tambahkan produk terlebih dahulu.';

  @override
  String toString() => 'EmptyCartException(message: $message)';
}
