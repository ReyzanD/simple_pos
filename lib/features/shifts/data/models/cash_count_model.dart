import '../../domain/entities/cash_count.dart';

/// Model for CashCount database operations
class CashCountModel {
  final int? id;
  final int shiftId;
  final String billCountsJson; // JSON string of Map<int, int>
  final int totalCounted;
  final int expectedAmount;
  final int discrepancy;
  final int countedAt; // milliseconds since epoch
  final String countedBy;

  const CashCountModel({
    this.id,
    required this.shiftId,
    required this.billCountsJson,
    required this.totalCounted,
    required this.expectedAmount,
    required this.discrepancy,
    required this.countedAt,
    required this.countedBy,
  });

  /// Creates CashCountModel from domain entity
  factory CashCountModel.fromEntity(CashCount entity) {
    // Convert Map to JSON string format "key:value,key:value"
    final billCountsJson = entity.billCounts.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');

    return CashCountModel(
      id: entity.id,
      shiftId: entity.shiftId,
      billCountsJson: billCountsJson,
      totalCounted: entity.totalCounted,
      expectedAmount: entity.expectedAmount,
      discrepancy: entity.discrepancy,
      countedAt: entity.countedAt.millisecondsSinceEpoch,
      countedBy: entity.countedBy,
    );
  }

  /// Converts model to domain entity
  CashCount toEntity() {
    // Parse JSON string to Map
    final Map<String, dynamic> billCountsMap = {};
    if (billCountsJson.isNotEmpty) {
      final parts = billCountsJson.split(',');
      for (final part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          billCountsMap[keyValue[0]] = int.parse(keyValue[1]);
        }
      }
    }

    // Convert string keys back to int
    final Map<int, int> billCounts = {};
    billCountsMap.forEach((key, value) {
      billCounts[int.parse(key)] = value;
    });

    return CashCount(
      id: id,
      shiftId: shiftId,
      billCounts: billCounts,
      totalCounted: totalCounted,
      expectedAmount: expectedAmount,
      discrepancy: discrepancy,
      countedAt: DateTime.fromMillisecondsSinceEpoch(countedAt),
      countedBy: countedBy,
    );
  }

  /// Creates CashCountModel from database map
  factory CashCountModel.fromMap(Map<String, dynamic> map) {
    return CashCountModel(
      id: map['id'] as int?,
      shiftId: map['shift_id'] as int,
      billCountsJson: map['denomination'] as String,
      totalCounted: map['count'] as int,
      expectedAmount: (map['expected_amount'] as num?)?.toInt() ?? 0,
      discrepancy: (map['discrepancy'] as num?)?.toInt() ?? 0,
      countedAt: map['counted_at'] as int,
      countedBy: map['counted_by'] as String,
    );
  }

  /// Converts model to map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'shift_id': shiftId,
      'denomination': billCountsJson,
      'count': totalCounted,
      'expected_amount': expectedAmount,
      'discrepancy': discrepancy,
      'counted_at': countedAt,
      'counted_by': countedBy,
    };
  }

  /// Creates a copy with the given fields replaced
  CashCountModel copyWith({
    int? id,
    int? shiftId,
    String? billCountsJson,
    int? totalCounted,
    int? expectedAmount,
    int? discrepancy,
    int? countedAt,
    String? countedBy,
  }) {
    return CashCountModel(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      billCountsJson: billCountsJson ?? this.billCountsJson,
      totalCounted: totalCounted ?? this.totalCounted,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      discrepancy: discrepancy ?? this.discrepancy,
      countedAt: countedAt ?? this.countedAt,
      countedBy: countedBy ?? this.countedBy,
    );
  }

  @override
  String toString() =>
      'CashCountModel(id: $id, shiftId: $shiftId, totalCounted: $totalCounted, discrepancy: $discrepancy)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CashCountModel &&
        other.id == id &&
        other.shiftId == shiftId &&
        other.billCountsJson == billCountsJson &&
        other.totalCounted == totalCounted &&
        other.expectedAmount == expectedAmount &&
        other.discrepancy == discrepancy &&
        other.countedAt == countedAt &&
        other.countedBy == countedBy;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      shiftId.hashCode ^
      billCountsJson.hashCode ^
      totalCounted.hashCode ^
      expectedAmount.hashCode ^
      discrepancy.hashCode ^
      countedAt.hashCode ^
      countedBy.hashCode;
}
