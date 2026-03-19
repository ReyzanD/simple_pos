import '../entities/shift.dart';

/// Repository interface for Shift operations
/// Abstracts the data source for shift management
abstract class ShiftRepository {
  /// Opens a new shift with the given opening balance
  Future<Shift> openShift({
    required String userName,
    required double openingBalance,
  });

  /// Closes an active shift with the given closing balance
  Future<Shift> closeShift({
    required int shiftId,
    required double closingBalance,
  });

  /// Gets the currently active shift (if any)
  Future<Shift?> getCurrentShift();

  /// Gets all shifts, optionally filtered by date range
  Future<List<Shift>> getShifts({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  });

  /// Gets a shift by ID
  Future<Shift?> getShiftById(int id);

  /// Updates shift totals after a transaction
  Future<Shift> updateShiftTotals({
    required int shiftId,
    required double cashSales,
    required double cardSales,
    required double qrSales,
    required double transferSales,
    required int transactionCount,
  });

  /// Deletes a shift (typically for testing/correction purposes)
  Future<bool> deleteShift(int shiftId);
}
