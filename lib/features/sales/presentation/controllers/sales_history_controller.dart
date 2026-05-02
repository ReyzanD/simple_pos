import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../../../core/utils/logger.dart';

/// Controller for Sales History Screen
/// Manages state and business logic for sales history
class SalesHistoryController extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  SalesHistoryController({
    required GetTransactionsUseCase getTransactionsUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase {
    loadTransactions();
  }

  // State
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  PaymentMethod? _selectedPaymentMethod;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Cached KPI values
  int _cachedTodayItemsSold = 0;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  /// Only count completed transactions for KPI display in the history summary cards
  List<Transaction> get _completedTransactions =>
      _filteredTransactions
          .where((t) => t.paymentStatus == PaymentStatus.completed)
          .toList();

  int get transactionCount => _completedTransactions.length;
  double get totalRevenue =>
      _completedTransactions.fold<double>(0, (sum, t) => sum + t.totalAmount);
  double get averageTransaction =>
      transactionCount > 0 ? totalRevenue / transactionCount : 0.0;

  /// Get total profit from completed filtered transactions
  double get totalProfit =>
      _completedTransactions.fold<double>(0, (sum, t) => sum + t.profit);

  /// Get total items sold from completed filtered transactions
  int get totalItemsSold =>
      _completedTransactions.fold<int>(0, (sum, t) => sum + t.totalItems);

  /// Get today's transactions (only completed — excludes refunded/cancelled)
  List<Transaction> get todayTransactions {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return _transactions.where((t) {
      return t.paymentStatus == PaymentStatus.completed &&
          !t.transactionDate.isBefore(startOfDay) &&
          !t.transactionDate.isAfter(endOfDay);
    }).toList();
  }

  /// Get today's revenue
  double get todayRevenue =>
      todayTransactions.fold<double>(0, (sum, t) => sum + t.totalAmount);

  /// Get today's transaction count
  int get todayTransactionCount => todayTransactions.length;

  /// Get total items sold today (cached value)
  int get todayItemsSold => _cachedTodayItemsSold;

  /// Load all transactions from repository
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Loading transactions');
      final result = await _getTransactionsUseCase.execute();
      _transactions = result;
      _isLoading = false;

      // Calculate and cache today's items sold (completed transactions only)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final completedTodayTx = _transactions
          .where(
            (t) =>
                t.paymentStatus == PaymentStatus.completed &&
                !t.transactionDate.isBefore(startOfDay),
          )
          .toList();
      _cachedTodayItemsSold = completedTodayTx.fold<int>(
        0,
        (sum, t) => sum + t.totalItems,
      );

      _applyFilters();

      // Calculate today's stats for debugging
      final todayTx = completedTodayTx;
      AppLogger.info('Loaded ${_transactions.length} total transactions');
      AppLogger.info(
        'Today\'s transactions: ${todayTx.length}, revenue: $todayRevenue',
      );
      AppLogger.info('todayTransactionCount: $todayTransactionCount');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error(
        'Failed to load transactions',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Apply all filters to transactions
  void _applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      // Payment method filter
      if (_selectedPaymentMethod != null &&
          transaction.paymentMethod != _selectedPaymentMethod) {
        return false;
      }

      // Date range filter
      if (_startDate != null &&
          transaction.transactionDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null) {
        final endOfDay = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        if (transaction.transactionDate.isAfter(endOfDay)) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return transaction.items.any(
          (item) =>
              item.productName.toLowerCase().contains(query) ||
              transaction.id.toString().contains(query),
        );
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Set payment method filter
  void setPaymentMethodFilter(PaymentMethod? method) {
    _selectedPaymentMethod = method;
    _applyFilters();
  }

  /// Set date range filter
  void setDateRangeFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedPaymentMethod = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _applyFilters();
  }

  /// Refresh transactions
  Future<void> refresh() async {
    await loadTransactions();
  }

  @override
  void dispose() {
    super.dispose();
    AppLogger.info('Disposing SalesHistoryController');
  }
}
