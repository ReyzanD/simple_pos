import '../../domain/entities/category.dart';

/// Category model for data layer
class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    super.description,
    super.discountPercentage,
    required super.createdAt,
  });

  /// Creates CategoryModel from domain Category
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      discountPercentage: category.discountPercentage,
      createdAt: category.createdAt,
    );
  }

  /// Converts to domain Category
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      discountPercentage: discountPercentage,
      createdAt: createdAt,
    );
  }

  /// Creates CategoryModel from database map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      discountPercentage: map['discount_percentage'] != null
          ? (map['discount_percentage'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts to map for database storage
  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
