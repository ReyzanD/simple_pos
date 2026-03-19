import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case for adding a new expense
class AddExpenseUseCase {
  final ExpenseRepository _repository;

  AddExpenseUseCase(this._repository);

  /// Execute the use case to add a new expense
  ///
  /// Returns the ID of the created expense, or -1 if creation failed
  Future<int> execute(Expense expense) async {
    // Validate amount
    if (expense.amount <= 0) {
      return -1;
    }

    // Validate category
    if (expense.category.isEmpty) {
      return -1;
    }

    return await _repository.addExpense(expense);
  }
}
