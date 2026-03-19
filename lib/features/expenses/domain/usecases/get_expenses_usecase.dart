import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for getting expenses
class GetExpensesUseCase {
  final ExpenseRepository _repository;

  GetExpensesUseCase(this._repository);

  /// Get all expenses
  Future<List<Expense>> execute({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    return await _repository.getExpenses(
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }

  /// Get expense by ID
  Future<Expense?> getById(int id) async {
    return await _repository.getExpenseById(id);
  }

  /// Get today's expenses
  Future<List<Expense>> getToday() async {
    return await _repository.getTodayExpenses();
  }

  /// Get this month's expenses
  Future<List<Expense>> getThisMonth() async {
    return await _repository.getThisMonthExpenses();
  }

  /// Get expenses by category
  Future<List<Expense>> getByCategory(String category) async {
    return await _repository.getExpensesByCategory(category);
  }
}
