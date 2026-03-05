import '../../domain/entities/promotion.dart';

/// PromotionModel for data transfer between database and domain layer
class PromotionModel {
  final int? id;
  final String name;
  final String description;
  final double discountPercentage;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEnabled;
  final DateTime createdAt;

  const PromotionModel({
    this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    this.startDate,
    this.endDate,
    this.isEnabled = true,
    required this.createdAt,
  });

  /// Creates PromotionModel from domain entity
  factory PromotionModel.fromEntity(Promotion promotion) {
    return PromotionModel(
      id: promotion.id,
      name: promotion.name,
      description: promotion.description,
      discountPercentage: promotion.discountPercentage,
      startDate: promotion.startDate,
      endDate: promotion.endDate,
      isEnabled: promotion.isEnabled,
      createdAt: promotion.createdAt,
    );
  }

  /// Converts to domain entity
  Promotion toEntity() {
    return Promotion(
      id: id,
      name: name,
      description: description,
      discountPercentage: discountPercentage,
      startDate: startDate,
      endDate: endDate,
      isEnabled: isEnabled,
      createdAt: createdAt,
    );
  }

  /// Creates PromotionModel from database map
  factory PromotionModel.fromMap(Map<String, dynamic> map) {
    return PromotionModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      discountPercentage: (map['discount_percentage'] as num).toDouble(),
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'] as String)
          : null,
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      isEnabled: (map['is_enabled'] as int) == 1,
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
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with the given fields replaced
  PromotionModel copyWith({
    int? id,
    String? name,
    String? description,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'PromotionModel(id: $id, name: $name, discount: $discountPercentage%)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PromotionModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.discountPercentage == discountPercentage &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isEnabled == isEnabled &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      discountPercentage.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isEnabled.hashCode ^
      createdAt.hashCode;
}
