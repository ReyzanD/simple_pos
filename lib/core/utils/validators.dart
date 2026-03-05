import '../constants/app_constants.dart';
import '../exceptions/app_exceptions.dart';

/// Utility class for validating input data
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Validates product name
  /// Throws [ValidationException] if validation fails
  /// Returns the trimmed name if valid
  static String validateProductName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      throw const ValidationException('Nama produk tidak boleh kosong', field: 'Nama Produk');
    }

    if (trimmed.length < 3) {
      throw const ValidationException('Nama produk minimal 3 karakter', field: 'Nama Produk');
    }

    if (trimmed.length > 100) {
      throw const ValidationException('Nama produk maksimal 100 karakter', field: 'Nama Produk');
    }

    return trimmed;
  }

  /// Validates product price
  /// Throws [ValidationException] if validation fails
  /// Returns the price if valid
  static double validatePrice(dynamic value) {
    double price;

    if (value is double) {
      price = value;
    } else if (value is int) {
      price = value.toDouble();
    } else if (value is String) {
      price = double.tryParse(value) ?? 0.0;
    } else {
      price = 0.0;
    }

    if (price < 0) {
      throw const ValidationException('Harga tidak boleh negatif', field: 'Harga');
    }

    if (price == 0) {
      throw const ValidationException('Harga harus lebih dari 0', field: 'Harga');
    }

    return price;
  }

  /// Validates stock quantity
  /// Throws [ValidationException] if validation fails
  /// Returns the stock if valid
  static int validateStock(dynamic value) {
    int stock;

    if (value is int) {
      stock = value;
    } else if (value is double) {
      stock = value.toInt();
    } else if (value is String) {
      stock = int.tryParse(value) ?? 0;
    } else {
      stock = 0;
    }

    if (stock < 0) {
      throw const ValidationException('Stok tidak boleh negatif', field: 'Stok');
    }

    return stock;
  }

  /// Validates product ID
  /// Throws [ValidationException] if validation fails
  /// Returns the ID if valid
  static int validateProductId(dynamic id) {
    if (id == null) {
      throw const ValidationException('ID produk tidak boleh kosong', field: 'ID');
    }

    int productId;

    if (id is int) {
      productId = id;
    } else if (id is String) {
      productId = int.tryParse(id) ?? 0;
    } else {
      productId = 0;
    }

    if (productId <= 0) {
      throw const ValidationException('ID produk tidak valid', field: 'ID');
    }

    return productId;
  }

  /// Validates if a product is out of stock
  static bool isOutOfStock(int stock) {
    return stock <= AppConstants.outOfStockThreshold;
  }

  /// Validates if a product has low stock
  static bool isLowStock(int stock) {
    return stock > AppConstants.outOfStockThreshold &&
        stock <= AppConstants.lowStockThreshold;
  }

  /// Checks if requested quantity is available in stock
  /// Throws [InsufficientStockException] if not enough stock
  static void validateStockAvailability(int requested, int available) {
    if (requested > available) {
      throw InsufficientStockException(
        'Stok tidak mencukupi',
        requested: requested,
        available: available,
      );
    }
  }

  /// Validates promotion/preset name
  /// Throws [ValidationException] if validation fails
  static String validatePromotionName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      throw const ValidationException('Nama promosi tidak boleh kosong', field: 'Nama Promosi');
    }

    if (trimmed.length < 2) {
      throw const ValidationException('Nama promosi minimal 2 karakter', field: 'Nama Promosi');
    }

    if (trimmed.length > 50) {
      throw const ValidationException('Nama promosi maksimal 50 karakter', field: 'Nama Promosi');
    }

    return trimmed;
  }
}
