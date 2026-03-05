import 'dart:convert';

/// Variant attribute entity representing a variant option type
/// (e.g., "Size" with values ["S", "M", "L", "XL"])
class VariantAttribute {
  final int? id;
  final int productId;
  final String name; // e.g., "Size", "Color"
  final List<String> values; // e.g., ["S", "M", "L"] or ["Red", "Blue"]
  final int sortOrder;

  const VariantAttribute({
    this.id,
    required this.productId,
    required this.name,
    required this.values,
    this.sortOrder = 0,
  });

  /// Creates a copy of this attribute with the given fields replaced
  VariantAttribute copyWith({
    int? id,
    int? productId,
    String? name,
    List<String>? values,
    int? sortOrder,
  }) {
    return VariantAttribute(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      values: values ?? this.values,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Converts attribute to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'attribute_name': name,
      'attribute_values': jsonEncode(values),
      'sort_order': sortOrder,
    };
  }

  /// Creates a VariantAttribute from a database map
  factory VariantAttribute.fromMap(Map<String, dynamic> map) {
    return VariantAttribute(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      name: map['attribute_name'] as String,
      values: List<String>.from(jsonDecode(map['attribute_values'] as String)),
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  @override
  String toString() =>
      'VariantAttribute(id: $id, productId: $productId, name: $name, values: $values)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VariantAttribute && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
