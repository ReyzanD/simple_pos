import '../../../../core/exceptions/app_exceptions.dart';

/// Category entity for product categorization
/// Categories can have optional percentage discounts that apply to all products in the category
class Category {
  final int? id;
  final String name;
  final String? description;
  final double? discountPercentage; // 0-100, optional category-wide discount
  final DateTime createdAt;

  const Category({
    this.id,
    required this.name,
    this.description,
    this.discountPercentage,
    required this.createdAt,
  });

  /// Creates a copy of this category with the given fields replaced
  Category copyWith({
    int? id,
    String? name,
    String? description,
    double? discountPercentage,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Checks if this category has a discount
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// Calculates the effective price after applying category discount
  /// Returns the discounted price if category has discount, otherwise returns original price
  double effectivePrice(double basePrice) {
    if (!hasDiscount) return basePrice;
    return basePrice * (1 - discountPercentage! / 100);
  }

  /// Calculates the discount amount for a given base price
  double discountAmount(double basePrice) {
    if (!hasDiscount) return 0;
    return basePrice - effectivePrice(basePrice);
  }

  /// Validates the category data
  /// Throws [ValidationException] if validation fails
  void validate() {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw const ValidationException('Nama kategori tidak boleh kosong', field: 'Nama Kategori');
    }

    if (trimmedName.length < 2) {
      throw const ValidationException('Nama kategori minimal 2 karakter', field: 'Nama Kategori');
    }

    if (trimmedName.length > 50) {
      throw const ValidationException('Nama kategori maksimal 50 karakter', field: 'Nama Kategori');
    }

    if (discountPercentage != null && (discountPercentage! < 0 || discountPercentage! > 100)) {
      throw const ValidationException(
        'Diskon kategori harus antara 0-100',
        field: 'Diskon Kategori',
      );
    }
  }

  /// Converts category to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a Category from a database map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      discountPercentage: map['discount_percentage'] != null
          ? (map['discount_percentage'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'Category(id: $id, name: $name, description: $description, discount: $discountPercentage%)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.discountPercentage == discountPercentage;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      discountPercentage.hashCode;
}
