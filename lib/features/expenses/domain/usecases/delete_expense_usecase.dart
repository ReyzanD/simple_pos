import '../repositories/expense_repository.dart';

/// Use case for deleting an expense
class DeleteExpenseUseCase {
  final ExpenseRepository _repository;

  DeleteExpenseUseCase(this._repository);

  /// Execute the use case to delete an expense
  ///
  /// Returns true if successful, false otherwise
  Future<bool> execute(int expenseId) async {
    try {
      await _repository.deleteExpense(expenseId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
