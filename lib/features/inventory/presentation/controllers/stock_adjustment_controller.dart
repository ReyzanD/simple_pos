import 'package:flutter/foundation.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:simple_pos/features/inventory/domain/usecases/adjust_stock_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/get_stock_history_usecase.dart';

class StockAdjustmentController extends ChangeNotifier {
  final AdjustStockUseCase adjustStockUseCase;
  final GetStockHistoryUseCase getStockHistoryUseCase;

  List<StockAdjustment> _adjustments = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  AppException? _error;

  StockAdjustmentController({
    required this.adjustStockUseCase,
    required this.getStockHistoryUseCase,
  });

  List<StockAdjustment> get adjustments => _adjustments;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get hasError => _error != null;
  AppException? get error => _error;

  Future<void> adjustStock({
    required int productId,
    required int adjustmentAmount,
    required StockAdjustmentType adjustmentType,
    required String? reason,
    required String createdBy,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await adjustStockUseCase.execute(
        productId: productId,
        adjustmentAmount: adjustmentAmount,
        adjustmentType: adjustmentType,
        reason: reason,
        createdBy: createdBy,
      );
    } on AppException catch (e) {
      _setError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStockHistory(int productId) async {
    try {
      _setLoadingHistory(true);
      _clearError();

      _adjustments = await getStockHistoryUseCase.execute(productId: productId);
    } on AppException catch (e) {
      _setError(e);
    } finally {
      _setLoadingHistory(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingHistory(bool value) {
    _isLoadingHistory = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(AppException exception) {
    _error = exception;
    notifyListeners();
  }
}
