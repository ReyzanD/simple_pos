import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../../../core/utils/logger.dart';

/// Controller for Sales History Screen
/// Manages state and business logic for sales history
class SalesHistoryController extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  SalesHistoryController({
    required GetTransactionsUseCase getTransactionsUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase {
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

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  int get transactionCount => _filteredTransactions.length;
  double get totalRevenue => _filteredTransactions.fold<double>(
        0,
        (sum, t) => sum + t.totalAmount,
      );
  double get averageTransaction => transactionCount > 0
      ? totalRevenue / transactionCount
      : 0.0;

  /// Load all transactions from repository
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Loading transactions');
      final result = await _getTransactionsUseCase.execute();
      _transactions = result;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      AppLogger.info('Loaded ${_transactions.length} transactions');
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
      if (_startDate != null && transaction.transactionDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null) {
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        if (transaction.transactionDate.isAfter(endOfDay)) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return transaction.items.any((item) =>
            item.productName.toLowerCase().contains(query) ||
            transaction.id.toString().contains(query));
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
}
