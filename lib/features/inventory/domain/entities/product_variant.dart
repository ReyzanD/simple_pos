import 'dart:convert';
import '../../../../core/constants/app_constants.dart';

/// Product variant entity representing a specific variant of a product
/// (e.g., "Red / Small", "Blue / Large")
class ProductVariant {
  final int? id;
  final int productId;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double costPrice;
  final int stock;
  final Map<String, String>? attributes; // e.g., {"size": "S", "color": "Red"}
  final bool isActive;
  final DateTime createdAt;

  const ProductVariant({
    this.id,
    required this.productId,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    this.costPrice = 0,
    this.stock = 0,
    this.attributes,
    this.isActive = true,
    required this.createdAt,
  });

  /// Checks if the variant is out of stock
  bool get isOutOfStock => stock <= AppConstants.outOfStockThreshold;

  /// Checks if the variant has low stock
  bool get isLowStock =>
      stock > AppConstants.outOfStockThreshold &&
      stock <= AppConstants.lowStockThreshold;

  /// Calculates profit amount
  double get profit => price - costPrice;

  /// Calculates profit margin percentage
  double get profitMargin {
    if (costPrice <= 0 || price <= 0) return 0;
    return ((price - costPrice) / price * 100);
  }

  /// Gets display name for the variant
  /// If attributes exist, formats them as "Color: Red, Size: S"
  /// Otherwise returns the name
  String get displayName {
    if (attributes != null && attributes!.isNotEmpty) {
      final formatted = attributes!.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      return formatted.isEmpty ? name : formatted;
    }
    return name;
  }

  /// Creates a copy of this variant with the given fields replaced
  ProductVariant copyWith({
    int? id,
    int? productId,
    String? name,
    String? sku,
    String? barcode,
    double? price,
    double? costPrice,
    int? stock,
    Map<String, String>? attributes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      attributes: attributes ?? this.attributes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts variant to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'attributes': attributes != null ? jsonEncode(attributes) : null,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a ProductVariant from a database map
  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      name: map['name'] as String,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      price: (map['price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
      stock: map['stock'] as int? ?? 0,
      attributes: map['attributes'] != null
          ? Map<String, String>.from(jsonDecode(map['attributes'] as String))
          : null,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'ProductVariant(id: $id, productId: $productId, name: $name, price: $price, stock: $stock)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductVariant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
