import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import '../repositories/expense_repository.dart';

/// Use case for getting expense count grouped by category
/// Returns a map of category ID to count
class GetExpenseCountByCategoryUseCase {
  final ExpenseRepository repository;

  GetExpenseCountByCategoryUseCase({required this.repository});

  /// Execute the use case
  /// Returns a map where key is category ID and value is the count of expenses
  Future<Map<String, int>> execute() async {
    try {
      // Get all expenses and count by category
      final expenses = await repository.getExpenses();

      final Map<String, int> counts = {};
      for (final expense in expenses) {
        counts[expense.category] = (counts[expense.category] ?? 0) + 1;
      }

      return counts;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to load category counts: $e');
    }
  }
}
