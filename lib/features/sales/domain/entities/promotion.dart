import '../../../../core/utils/validators.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Promotion entity representing time-limited discount campaigns
/// Promotions can be scheduled with date ranges and manually toggled on/off
class Promotion {
  final int? id;
  final String name;
  final String description;
  final double discountPercentage; // 0-100
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEnabled;
  final DateTime createdAt;

  const Promotion({
    this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    this.startDate,
    this.endDate,
    this.isEnabled = true,
    required this.createdAt,
  });

  /// Creates a copy of this promotion with the given fields replaced
  Promotion copyWith({
    int? id,
    String? name,
    String? description,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return Promotion(
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

  /// Checks if the promotion is currently active
  /// A promotion is active if enabled AND within date range (if specified)
  bool get isActive {
    if (!isEnabled) return false;

    final now = DateTime.now();

    // Check start date
    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }

    // Check end date
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }

    return true;
  }

  /// Checks if this promotion has a date range set
  bool get hasDateRange => startDate != null || endDate != null;

  /// Checks if the promotion is scheduled (has dates and not yet started)
  bool get isScheduled {
    if (startDate == null) return false;
    return DateTime.now().isBefore(startDate!);
  }

  /// Checks if the promotion has expired
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Validates the promotion data
  /// Throws [ValidationException] if validation fails
  void validate() {
    Validators.validatePromotionName(name);

    if (discountPercentage < 0 || discountPercentage > 100) {
      throw const ValidationException(
        'Diskon harus antara 0-100',
        field: 'Diskon Persen',
      );
    }

    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      throw const ValidationException(
        'Tanggal selesai harus setelah tanggal mulai',
        field: 'Tanggal',
      );
    }
  }

  /// Converts promotion to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a Promotion from a database map
  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
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

  @override
  String toString() =>
      'Promotion(id: $id, name: $name, discount: $discountPercentage%, '
      'enabled: $isEnabled, start: $startDate, end: $endDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Promotion &&
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
