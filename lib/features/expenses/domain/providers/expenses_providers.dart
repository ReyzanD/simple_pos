import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core & Sales Dependencies
import 'package:simple_pos/core/providers/core_providers.dart';
import 'package:simple_pos/features/sales/domain/providers/sales_providers.dart';

// Expense Data & Domain
import '../../data/datasources/expense_local_datasource_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_summary_usecase.dart';
import '../../domain/usecases/get_expense_count_by_category_usecase.dart';
import '../../domain/usecases/get_profit_report_usecase.dart';

// Expense Controller
import '../../presentation/controllers/expense_controller.dart';

// --- DATA LAYER ---

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSourceImpl>((
  ref,
) {
  final db = ref.watch(databaseHelperProvider);
  return ExpenseLocalDataSourceImpl(databaseHelper: db);
});

// --- REPOSITORY LAYER ---

final expenseRepositoryProvider = Provider<ExpenseRepositoryImpl>((ref) {
  return ExpenseRepositoryImpl(
    localDataSource: ref.watch(expenseLocalDataSourceProvider),
  );
});

// --- DOMAIN LAYER ---

final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>((ref) {
  return AddExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

final updateExpenseUseCaseProvider = Provider<UpdateExpenseUseCase>((ref) {
  return UpdateExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  return DeleteExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final getExpenseSummaryUseCaseProvider = Provider<GetExpenseSummaryUseCase>((
  ref,
) {
  return GetExpenseSummaryUseCase(ref.watch(expenseRepositoryProvider));
});

final getExpenseCountByCategoryUseCaseProvider =
    Provider<GetExpenseCountByCategoryUseCase>((ref) {
      return GetExpenseCountByCategoryUseCase(
        repository: ref.watch(expenseRepositoryProvider),
      );
    });

// Profit Report: depends on both Expense and Transaction repositories
final getProfitReportUseCaseProvider = Provider<GetProfitReportUseCase>((ref) {
  return GetProfitReportUseCase(
    expenseRepository: ref.watch(expenseRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
  );
});

// --- PRESENTATION LAYER ---

final expenseControllerProvider = ChangeNotifierProvider<ExpenseController>((
  ref,
) {
  return ExpenseController(
    addExpenseUseCase: ref.watch(addExpenseUseCaseProvider),
    getExpensesUseCase: ref.watch(getExpensesUseCaseProvider),
    updateExpenseUseCase: ref.watch(updateExpenseUseCaseProvider),
    deleteExpenseUseCase: ref.watch(deleteExpenseUseCaseProvider),
    getExpenseSummaryUseCase: ref.watch(getExpenseSummaryUseCaseProvider),
    getExpenseCountByCategoryUseCase: ref.watch(
      getExpenseCountByCategoryUseCaseProvider,
    ),
  );
});
