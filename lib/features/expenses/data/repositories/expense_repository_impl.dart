import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource_impl.dart';
import '../models/expense_model.dart';

/// Repository implementation for Expense data operations
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSourceImpl localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    final startDateInt = startDate != null ? startDate.millisecondsSinceEpoch ~/ 1000 : null;
    final endDateInt = endDate != null ? endDate.millisecondsSinceEpoch ~/ 1000 : null;

    final models = await localDataSource.getExpenses(
      startDate: startDateInt,
      endDate: endDateInt,
      category: category,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Expense?> getExpenseById(int id) async {
    final model = await localDataSource.getExpenseById(id);
    return model?.toEntity();
  }

  @override
  Future<int> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    return await localDataSource.addExpense(model);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await localDataSource.updateExpense(model);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await localDataSource.deleteExpense(id);
  }

  @override
  Future<Map<String, double>> getExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final startDateInt = startDate != null ? startDate.millisecondsSinceEpoch ~/ 1000 : null;
    final endDateInt = endDate != null ? endDate.millisecondsSinceEpoch ~/ 1000 : null;

    return await localDataSource.getExpenseSummary(
      startDate: startDateInt,
      endDate: endDateInt,
    );
  }

  @override
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final startDateInt = startDate != null ? startDate.millisecondsSinceEpoch ~/ 1000 : null;
    final endDateInt = endDate != null ? endDate.millisecondsSinceEpoch ~/ 1000 : null;

    return await localDataSource.getTotalExpenses(
      startDate: startDateInt,
      endDate: endDateInt,
    );
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final models = await localDataSource.getExpensesByCategory(category);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getTodayExpenses() async {
    final models = await localDataSource.getTodayExpenses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getThisMonthExpenses() async {
    final models = await localDataSource.getThisMonthExpenses();
    return models.map((m) => m.toEntity()).toList();
  }
}
