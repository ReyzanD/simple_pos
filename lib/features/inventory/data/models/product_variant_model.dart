import 'dart:convert';
import '../../domain/entities/product_variant.dart';

/// Model for ProductVariant with database serialization support
class ProductVariantModel {
  final int? id;
  final int productId;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double costPrice;
  final int stock;
  final Map<String, String>? attributes;
  final bool isActive;
  final DateTime createdAt;

  const ProductVariantModel({
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

  /// Creates a ProductVariantModel from a database map
  factory ProductVariantModel.fromMap(Map<String, dynamic> map) {
    return ProductVariantModel(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      name: map['name'] as String,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      price: (map['price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
      stock: map['stock'] as int? ?? 0,
      attributes: map['attributes'] != null
          ? _parseAttributes(map['attributes'] as String)
          : null,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Parses JSON attributes string to Map
  static Map<String, String>? _parseAttributes(String attributesJson) {
    try {
      if (attributesJson.isEmpty) return null;
      final decoded = json.decode(attributesJson) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return null;
    }
  }

  /// Converts to database map
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
      'attributes': attributes != null ? json.encode(attributes) : null,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Converts to entity
  ProductVariant toEntity() {
    return ProductVariant(
      id: id,
      productId: productId,
      name: name,
      sku: sku,
      barcode: barcode,
      price: price,
      costPrice: costPrice,
      stock: stock,
      attributes: attributes,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Creates model from entity
  factory ProductVariantModel.fromEntity(ProductVariant entity) {
    return ProductVariantModel(
      id: entity.id,
      productId: entity.productId,
      name: entity.name,
      sku: entity.sku,
      barcode: entity.barcode,
      price: entity.price,
      costPrice: entity.costPrice,
      stock: entity.stock,
      attributes: entity.attributes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  /// Creates a copy with selected fields replaced
  ProductVariantModel copyWith({
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
    return ProductVariantModel(
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
}
