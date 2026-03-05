import '../../../../core/utils/validators.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// DiscountPreset entity representing reusable discount templates
/// Merchants can create preset discounts like "Flash Sale 20%" or "Weekend Sale 15%"
class DiscountPreset {
  final int? id;
  final String name;
  final String description;
  final double discountPercentage; // 0-100
  final DateTime createdAt;

  const DiscountPreset({
    this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.createdAt,
  });

  /// Creates a copy of this discount preset with the given fields replaced
  DiscountPreset copyWith({
    int? id,
    String? name,
    String? description,
    double? discountPercentage,
    DateTime? createdAt,
  }) {
    return DiscountPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Validates the discount preset data
  /// Throws [ValidationException] if validation fails
  void validate() {
    Validators.validatePromotionName(name);

    if (discountPercentage < 0 || discountPercentage > 100) {
      throw const ValidationException(
        'Diskon harus antara 0-100',
        field: 'Diskon Persen',
      );
    }
  }

  /// Converts discount preset to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a DiscountPreset from a database map
  factory DiscountPreset.fromMap(Map<String, dynamic> map) {
    return DiscountPreset(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      discountPercentage: (map['discount_percentage'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'DiscountPreset(id: $id, name: $name, discount: $discountPercentage%)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DiscountPreset &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.discountPercentage == discountPercentage &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      discountPercentage.hashCode ^
      createdAt.hashCode;
}
