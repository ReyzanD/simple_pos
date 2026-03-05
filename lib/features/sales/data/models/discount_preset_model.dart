import '../../domain/entities/discount_preset.dart';

/// DiscountPresetModel for data transfer between database and domain layer
class DiscountPresetModel {
  final int? id;
  final String name;
  final String description;
  final double discountPercentage;
  final DateTime createdAt;

  const DiscountPresetModel({
    this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.createdAt,
  });

  /// Creates DiscountPresetModel from domain entity
  factory DiscountPresetModel.fromEntity(DiscountPreset preset) {
    return DiscountPresetModel(
      id: preset.id,
      name: preset.name,
      description: preset.description,
      discountPercentage: preset.discountPercentage,
      createdAt: preset.createdAt,
    );
  }

  /// Converts to domain entity
  DiscountPreset toEntity() {
    return DiscountPreset(
      id: id,
      name: name,
      description: description,
      discountPercentage: discountPercentage,
      createdAt: createdAt,
    );
  }

  /// Creates DiscountPresetModel from database map
  factory DiscountPresetModel.fromMap(Map<String, dynamic> map) {
    return DiscountPresetModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      discountPercentage: (map['discount_percentage'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts to map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with the given fields replaced
  DiscountPresetModel copyWith({
    int? id,
    String? name,
    String? description,
    double? discountPercentage,
    DateTime? createdAt,
  }) {
    return DiscountPresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'DiscountPresetModel(id: $id, name: $name, discount: $discountPercentage%)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DiscountPresetModel &&
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
