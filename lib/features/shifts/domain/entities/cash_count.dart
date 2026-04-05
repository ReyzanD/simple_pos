/// Entity representing a cash count with denomination breakdown
class CashCount {
  final int? id;
  final int shiftId;
  final Map<int, int> billCounts; // denomination value -> count
  final int totalCounted;
  final int expectedAmount;
  final int discrepancy;
  final DateTime countedAt;
  final String countedBy;

  const CashCount({
    this.id,
    required this.shiftId,
    required this.billCounts,
    required this.totalCounted,
    required this.expectedAmount,
    required this.discrepancy,
    required this.countedAt,
    required this.countedBy,
  });

  /// Calculates total from bill counts
  static int calculateTotal(Map<int, int> billCounts) {
    return billCounts.entries
        .fold<int>(0, (sum, entry) => sum + (entry.key * entry.value));
  }

  /// Creates a copy with fields replaced
  CashCount copyWith({
    int? id,
    int? shiftId,
    Map<int, int>? billCounts,
    int? totalCounted,
    int? expectedAmount,
    int? discrepancy,
    DateTime? countedAt,
    String? countedBy,
  }) {
    return CashCount(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      billCounts: billCounts ?? this.billCounts,
      totalCounted: totalCounted ?? this.totalCounted,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      discrepancy: discrepancy ?? this.discrepancy,
      countedAt: countedAt ?? this.countedAt,
      countedBy: countedBy ?? this.countedBy,
    );
  }

  @override
  String toString() =>
      'CashCount(id: $id, shiftId: $shiftId, total: $totalCounted, discrepancy: $discrepancy)';
}
