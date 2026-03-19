import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import '../entities/profit_report.dart';
import '../repositories/expense_repository.dart';
import 'package:simple_pos/features/sales/domain/repositories/transaction_repository.dart';

/// Use case for generating profit reports
/// Combines transaction revenue/profit with expense data
class GetProfitReportUseCase {
  final ExpenseRepository expenseRepository;
  final TransactionRepository transactionRepository;

  GetProfitReportUseCase({
    required this.expenseRepository,
    required this.transactionRepository,
  });

  /// Execute the use case
  /// Returns a ProfitReport containing:
  /// - grossProfit: Total profit from sales (before expenses)
  /// - totalRevenue: Total sales revenue
  /// - totalExpenses: Total expenses for the period
  /// - netProfit: grossProfit - totalExpenses
  /// - profitMargin: netProfit / totalRevenue (as decimal)
  /// - expenseRatio: totalExpenses / totalRevenue (as decimal)
  Future<ProfitReport> execute({required DateTime startDate, required DateTime endDate}) async {
    try {
      // Get transactions for the period to calculate gross profit and revenue
      final transactions = await transactionRepository.getTransactionsByDateRange(
        startDate,
        endDate,
      );

      double totalRevenue = 0;
      double grossProfit = 0;

      for (final tx in transactions) {
        totalRevenue += tx.totalAmount;
        grossProfit += tx.profit;
      }

      // Get total expenses
      final expenses = await expenseRepository.getExpenses(
        startDate: startDate,
        endDate: endDate,
      );

      final totalExpenses = expenses.fold<double>(
        0,
        (sum, e) => sum + e.amount,
      );

      // Calculate metrics
      final netProfit = grossProfit - totalExpenses;
      final profitMargin = totalRevenue > 0 ? netProfit / totalRevenue : 0.0;
      final expenseRatio = totalRevenue > 0 ? totalExpenses / totalRevenue : 0.0;

      return ProfitReport(
        grossProfit: grossProfit,
        totalRevenue: totalRevenue,
        totalExpenses: totalExpenses,
        netProfit: netProfit,
        profitMargin: profitMargin,
        expenseRatio: expenseRatio,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to generate profit report: $e');
    }
  }
}
