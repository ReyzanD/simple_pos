import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for updating an expense
class UpdateExpenseUseCase {
  final ExpenseRepository _repository;

  UpdateExpenseUseCase(this._repository);

  /// Execute the use case to update an expense
  ///
  /// Returns true if successful, false otherwise
  Future<bool> execute(Expense expense) async {
    if (expense.id == null) return false;
    if (expense.amount <= 0) return false;
    if (expense.category.isEmpty) return false;

    try {
      await _repository.updateExpense(expense);
      return true;
    } catch (e) {
      return false;
    }
  }
}
