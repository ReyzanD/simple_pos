import '../entities/cash_count.dart';

/// Repository interface for cash count operations
abstract class CashCountRepository {
  /// Save cash count for a shift
  Future<CashCount> saveCashCount(CashCount cashCount);

  /// Get cash count by shift ID
  Future<CashCount?> getCashCountByShift(int shiftId);

  /// Get all cash counts for a shift (audit trail)
  Future<List<CashCount>> getCashCountHistory(int shiftId);

  /// Delete cash count
  Future<bool> deleteCashCount(int id);
}
