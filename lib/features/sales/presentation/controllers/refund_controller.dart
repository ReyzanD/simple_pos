import 'package:flutter/foundation.dart';
import '../../domain/usecases/refund_transaction_usecase.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing transaction refunds
class RefundController extends ChangeNotifier {
  final RefundTransactionUseCase _refundTransactionUseCase;

  RefundController({
    required RefundTransactionUseCase refundTransactionUseCase,
  }) : _refundTransactionUseCase = refundTransactionUseCase;

  // State
  bool _isRefunding = false;
  String? _errorMessage;

  // Getters
  bool get isRefunding => _isRefunding;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Refund a transaction
  Future<bool> refundTransaction(int transactionId) async {
    _isRefunding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.ui('Refunding transaction', details: 'ID: $transactionId');

      await _refundTransactionUseCase.execute(transactionId);

      _isRefunding = false;
      notifyListeners();

      AppLogger.info('Transaction refunded successfully');
      return true;
    } catch (e, stackTrace) {
      _isRefunding = false;
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error(
        'Failed to refund transaction',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
