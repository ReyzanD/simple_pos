import '../repositories/expense_repository.dart';

/// Use case for getting expense summary and statistics
class GetExpenseSummaryUseCase {
  final ExpenseRepository _repository;

  GetExpenseSummaryUseCase(this._repository);

  /// Get expense summary grouped by category
  Future<Map<String, double>> execute({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getExpenseSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get total expenses for a date range
  Future<double> getTotal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTotalExpenses(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get today's total expenses
  Future<double> getTodayTotal() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return await _repository.getTotalExpenses(startDate: startOfDay);
  }

  /// Get this month's total expenses
  Future<double> getThisMonthTotal() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return await _repository.getTotalExpenses(startDate: startOfMonth);
  }
}
