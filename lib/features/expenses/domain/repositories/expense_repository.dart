import '../entities/expense.dart';

/// Repository interface for Expense data operations
abstract class ExpenseRepository {
  /// Get all expenses with optional filters
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  });

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id);

  /// Create a new expense
  Future<int> addExpense(Expense expense);

  /// Update existing expense
  Future<void> updateExpense(Expense expense);

  /// Delete expense
  Future<void> deleteExpense(int id);

  /// Get expense summary grouped by category
  Future<Map<String, double>> getExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get total expenses for a date range
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category);

  /// Get expenses for today
  Future<List<Expense>> getTodayExpenses();

  /// Get expenses for this month
  Future<List<Expense>> getThisMonthExpenses();
}
