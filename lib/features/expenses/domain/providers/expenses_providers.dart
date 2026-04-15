import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Core & Sales Dependencies
import '../../../../core/database/database_helper.dart';
import '../../../sales/data/repositories/transaction_repository_impl.dart';

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

List<SingleChildWidget> createExpensesProviders() {
  return [
    // --- DATA LAYER ---
    ProxyProvider<DatabaseHelper, ExpenseLocalDataSourceImpl>(
      update: (_, db, _) => ExpenseLocalDataSourceImpl(databaseHelper: db),
    ),

    // --- REPOSITORY LAYER ---
    ProxyProvider<ExpenseLocalDataSourceImpl, ExpenseRepositoryImpl>(
      update: (_, ds, _) => ExpenseRepositoryImpl(localDataSource: ds),
    ),

    // --- DOMAIN LAYER ---
    ProxyProvider<ExpenseRepositoryImpl, AddExpenseUseCase>(
      update: (_, repo, _) => AddExpenseUseCase(repo),
    ),
    ProxyProvider<ExpenseRepositoryImpl, GetExpensesUseCase>(
      update: (_, repo, _) => GetExpensesUseCase(repo),
    ),
    ProxyProvider<ExpenseRepositoryImpl, UpdateExpenseUseCase>(
      update: (_, repo, _) => UpdateExpenseUseCase(repo),
    ),
    ProxyProvider<ExpenseRepositoryImpl, DeleteExpenseUseCase>(
      update: (_, repo, _) => DeleteExpenseUseCase(repo),
    ),
    ProxyProvider<ExpenseRepositoryImpl, GetExpenseSummaryUseCase>(
      update: (_, repo, _) => GetExpenseSummaryUseCase(repo),
    ),
    ProxyProvider<ExpenseRepositoryImpl, GetExpenseCountByCategoryUseCase>(
      update: (_, repo, _) =>
          GetExpenseCountByCategoryUseCase(repository: repo),
    ),

    // Profit Report: Depends on both Expenses and Sales repositories
    ProxyProvider2<
      ExpenseRepositoryImpl,
      TransactionRepositoryImpl,
      GetProfitReportUseCase
    >(
      update: (_, expenseRepo, transactionRepo, _) => GetProfitReportUseCase(
        expenseRepository: expenseRepo,
        transactionRepository: transactionRepo,
      ),
    ),

    // --- PRESENTATION LAYER ---
    ChangeNotifierProvider<ExpenseController>(
      create: (context) => ExpenseController(
        addExpenseUseCase: context.read<AddExpenseUseCase>(),
        getExpensesUseCase: context.read<GetExpensesUseCase>(),
        updateExpenseUseCase: context.read<UpdateExpenseUseCase>(),
        deleteExpenseUseCase: context.read<DeleteExpenseUseCase>(),
        getExpenseSummaryUseCase: context.read<GetExpenseSummaryUseCase>(),
        getExpenseCountByCategoryUseCase: context
            .read<GetExpenseCountByCategoryUseCase>(),
      ),
    ),
  ];
}
