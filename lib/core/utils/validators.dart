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
      if (value.trim().isEmpty) {
        throw const ValidationException('Harga tidak boleh kosong', field: 'Harga');
      }
      final parsed = double.tryParse(value);
      if (parsed == null) {
        throw const ValidationException('Format harga tidak valid', field: 'Harga');
      }
      price = parsed;
    } else {
      throw const ValidationException('Tipe harga tidak valid', field: 'Harga');
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
  /// Note: Stock can be 0 (out of stock), but not negative
  static int validateStock(dynamic value) {
    int stock;

    if (value is int) {
      stock = value;
    } else if (value is double) {
      stock = value.truncate(); // Use truncate for explicit behavior
    } else if (value is String) {
      if (value.trim().isEmpty) {
        throw const ValidationException('Stok tidak boleh kosong', field: 'Stok');
      }
      final parsed = int.tryParse(value);
      if (parsed == null) {
        throw const ValidationException('Format stok tidak valid', field: 'Stok');
      }
      stock = parsed;
    } else {
      throw const ValidationException('Tipe stok tidak valid', field: 'Stok');
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
      if (id.trim().isEmpty) {
        throw const ValidationException('ID produk tidak boleh kosong', field: 'ID');
      }
      final parsed = int.tryParse(id);
      if (parsed == null) {
        throw const ValidationException('Format ID produk tidak valid', field: 'ID');
      }
      productId = parsed;
    } else {
      throw const ValidationException('Tipe ID produk tidak valid', field: 'ID');
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
    if (available <= 0) {
      throw InsufficientStockException(
        'Produk sedang habis (stok: 0)',
        requested: requested,
        available: available,
      );
    }

    if (requested > available) {
      throw InsufficientStockException(
        'Stok tidak mencukupi (tersedia: $available, diminta: $requested)',
        requested: requested,
        available: available,
      );
    }

    if (requested <= 0) {
      throw const ValidationException(
        'Jumlah permintaan harus lebih dari 0',
        field: 'Quantity',
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
