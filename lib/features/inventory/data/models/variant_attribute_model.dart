import 'dart:convert';
import '../../domain/entities/variant_attribute.dart';

/// Model for VariantAttribute with database serialization support
class VariantAttributeModel {
  final int? id;
  final int productId;
  final String name;
  final List<String> values;
  final int sortOrder;

  const VariantAttributeModel({
    this.id,
    required this.productId,
    required this.name,
    required this.values,
    this.sortOrder = 0,
  });

  /// Creates a VariantAttributeModel from a database map
  factory VariantAttributeModel.fromMap(Map<String, dynamic> map) {
    return VariantAttributeModel(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      name: map['attribute_name'] as String,
      values: _parseValues(map['attribute_values'] as String),
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  /// Parses JSON values string to List
  static List<String> _parseValues(String valuesJson) {
    try {
      if (valuesJson.isEmpty) return [];
      final decoded = json.decode(valuesJson) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'attribute_name': name,
      'attribute_values': json.encode(values),
      'sort_order': sortOrder,
    };
  }

  /// Converts to entity
  VariantAttribute toEntity() {
    return VariantAttribute(
      id: id,
      productId: productId,
      name: name,
      values: values,
      sortOrder: sortOrder,
    );
  }

  /// Creates model from entity
  factory VariantAttributeModel.fromEntity(VariantAttribute entity) {
    return VariantAttributeModel(
      id: entity.id,
      productId: entity.productId,
      name: entity.name,
      values: entity.values,
      sortOrder: entity.sortOrder,
    );
  }

  /// Creates a copy with selected fields replaced
  VariantAttributeModel copyWith({
    int? id,
    int? productId,
    String? name,
    List<String>? values,
    int? sortOrder,
  }) {
    return VariantAttributeModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      values: values ?? this.values,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
