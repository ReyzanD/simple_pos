import 'package:flutter/foundation.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_payment_method.dart';
import '../../domain/constants/expense_categories.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_summary_usecase.dart';
import '../../domain/usecases/get_expense_count_by_category_usecase.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';

/// ExpenseController manages expense state and operations
class ExpenseController extends ChangeNotifier {
  final AddExpenseUseCase _addExpenseUseCase;
  final GetExpensesUseCase _getExpensesUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final GetExpenseSummaryUseCase _getExpenseSummaryUseCase;
  final GetExpenseCountByCategoryUseCase _getExpenseCountByCategoryUseCase;

  List<Expense> _expenses = [];
  Map<String, double> _categorySummary = {};
  Map<String, int> _categoryCounts = {};
  double _totalExpenses = 0;
  double? _periodComparison;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  // AppException for better error handling
  AppException? _error;

  ExpenseController({
    required AddExpenseUseCase addExpenseUseCase,
    required GetExpensesUseCase getExpensesUseCase,
    required UpdateExpenseUseCase updateExpenseUseCase,
    required DeleteExpenseUseCase deleteExpenseUseCase,
    required GetExpenseSummaryUseCase getExpenseSummaryUseCase,
    required GetExpenseCountByCategoryUseCase getExpenseCountByCategoryUseCase,
  })  : _addExpenseUseCase = addExpenseUseCase,
        _getExpensesUseCase = getExpensesUseCase,
        _updateExpenseUseCase = updateExpenseUseCase,
        _deleteExpenseUseCase = deleteExpenseUseCase,
        _getExpenseSummaryUseCase = getExpenseSummaryUseCase,
        _getExpenseCountByCategoryUseCase = getExpenseCountByCategoryUseCase;

  // Getters
  List<Expense> get expenses => _expenses;
  Map<String, double> get categorySummary => _categorySummary;
  Map<String, int> get categoryCounts => _categoryCounts;
  double get totalExpenses => _totalExpenses;
  double? get periodComparison => _periodComparison;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  AppException? get error => _error;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Get available categories
  List<String> get categories => ExpenseCategories.predefined;

  /// Check if filters are active
  bool get hasFilters => _selectedCategory != null || _startDate != null || _endDate != null;

  /// Load expenses with optional filters
  Future<void> loadExpenses({DateTime? start, DateTime? end, String? category}) async {
    _setLoading(true);
    _clearError();

    try {
      _startDate = start;
      _endDate = end;
      _selectedCategory = category;

      _expenses = await _getExpensesUseCase.execute(
        startDate: start,
        endDate: end,
        category: category,
      );

      await _loadSummary(start: start, end: end);

      _setLoading(false);
    } catch (e) {
      _setError('Gagal memuat pengeluaran: $e');
      _setLoading(false);
    }
  }

  /// Load today's expenses
  Future<void> loadTodayExpenses() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    await loadExpenses(start: startOfDay, end: endOfDay);
  }

  /// Load this month's expenses
  Future<void> loadThisMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    await loadExpenses(start: startOfMonth, end: endOfMonth);
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _startDate = null;
    _endDate = null;
    loadExpenses();
  }

  /// Set category filter
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    loadExpenses(start: _startDate, end: _endDate, category: _selectedCategory);
  }

  /// Set date range filter
  void setDateRangeFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadExpenses(start: _startDate, end: _endDate, category: _selectedCategory);
  }

  /// Add new expense
  Future<bool> addExpense({
    required String category,
    required double amount,
    String? description,
    ExpensePaymentMethod paymentMethod = ExpensePaymentMethod.cash,
    String? receiptImagePath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final expense = Expense(
        category: category,
        amount: amount,
        description: description,
        paymentMethod: paymentMethod,
        receiptImagePath: receiptImagePath,
      );

      final id = await _addExpenseUseCase.execute(expense);

      if (id > 0) {
        // Refresh expenses list
        await loadExpenses(
          start: _startDate,
          end: _endDate,
          category: _selectedCategory,
        );
        _setLoading(false);
        return true;
      } else {
        _setError('Gagal menambah pengeluaran');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Gagal menambah pengeluaran: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update existing expense
  Future<bool> updateExpense(Expense expense) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _updateExpenseUseCase.execute(expense);

      if (success) {
        // Refresh expenses list
        await loadExpenses(
          start: _startDate,
          end: _endDate,
          category: _selectedCategory,
        );
        _setLoading(false);
        return true;
      } else {
        _setError('Gagal memperbarui pengeluaran');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Gagal memperbarui pengeluaran: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(int expenseId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _deleteExpenseUseCase.execute(expenseId);

      if (success) {
        // Refresh expenses list
        await loadExpenses(
          start: _startDate,
          end: _endDate,
          category: _selectedCategory,
        );
        _setLoading(false);
        return true;
      } else {
        _setError('Gagal menghapus pengeluaran');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Gagal menghapus pengeluaran: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Load expense summary
  Future<void> _loadSummary({DateTime? start, DateTime? end}) async {
    try {
      _categorySummary = await _getExpenseSummaryUseCase.execute(
        startDate: start,
        endDate: end,
      );
      _totalExpenses = await _getExpenseSummaryUseCase.getTotal(
        startDate: start,
        endDate: end,
      );
    } catch (e) {
      // Don't fail the whole operation if summary fails
      _categorySummary = {};
      _totalExpenses = 0;
    }
  }

  // Private state setters
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setErrorFromException(AppException e) {
    _error = e;
    _errorMessage = e.userMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    _errorMessage = null;
  }

  /// Load category counts for the categories tab
  Future<void> loadCategoryCounts() async {
    try {
      _setLoading(true);
      _clearError();
      _categoryCounts = await _getExpenseCountByCategoryUseCase.execute();
    } on AppException catch (e) {
      _setErrorFromException(e);
    } catch (e) {
      _setError('Gagal memuat jumlah kategori: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load summary data for the summary tab with period comparison
  Future<void> loadSummary({required DateTime startDate, required DateTime endDate}) async {
    try {
      _setLoading(true);
      _clearError();
      _startDate = startDate;
      _endDate = endDate;

      _categorySummary = await _getExpenseSummaryUseCase.execute(
        startDate: startDate,
        endDate: endDate,
      );

      _totalExpenses = await _getExpenseSummaryUseCase.getTotal(
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate period comparison (previous period of same duration)
      final duration = endDate.difference(startDate);
      final prevStart = startDate.subtract(duration);
      final prevEnd = startDate;

      final prevTotal = await _getExpenseSummaryUseCase.getTotal(
        startDate: prevStart,
        endDate: prevEnd,
      );

      if (prevTotal > 0) {
        _periodComparison = ((_totalExpenses - prevTotal) / prevTotal) * 100;
      } else {
        _periodComparison = null;
      }
    } on AppException catch (e) {
      _setErrorFromException(e);
    } catch (e) {
      _setError('Gagal memuat ringkasan: $e');
    } finally {
      _setLoading(false);
    }
  }
}
