import 'package:flutter/foundation.dart';
import '../../domain/entities/shift.dart';
import '../../domain/usecases/open_shift_usecase.dart';
import '../../domain/usecases/close_shift_usecase.dart';
import '../../domain/usecases/get_current_shift_usecase.dart';
import '../../domain/usecases/get_shifts_usecase.dart';
import '../../domain/usecases/update_shift_totals_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing shift operations
class ShiftController extends ChangeNotifier {
  final OpenShiftUseCase openShiftUseCase;
  final CloseShiftUseCase closeShiftUseCase;
  final GetCurrentShiftUseCase getCurrentShiftUseCase;
  final GetShiftsUseCase getShiftsUseCase;
  final UpdateShiftTotalsUseCase updateShiftTotalsUseCase;

  bool _disposed = false;

  ShiftController({
    required this.openShiftUseCase,
    required this.closeShiftUseCase,
    required this.getCurrentShiftUseCase,
    required this.getShiftsUseCase,
    required this.updateShiftTotalsUseCase,
  }) {
    loadCurrentShift();
    loadShiftHistory();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  Shift? _currentShift;
  List<Shift> _shiftHistory = [];
  bool _isLoading = false;
  AppException? _error;
  String? _userName;

  // Getters
  Shift? get currentShift => _currentShift;
  List<Shift> get shiftHistory => _shiftHistory;
  bool get hasActiveShift => _currentShift != null;
  bool get isLoading => _isLoading;
  AppException? get error => _error;
  bool get hasError => _error != null;
  String? get userName => _userName;

  /// Load the current active shift
  Future<void> loadCurrentShift() async {
    try {
      AppLogger.ui('Loading current shift', details: 'ShiftController');
      _setLoading(true);
      _clearError();

      _currentShift = await getCurrentShiftUseCase.execute();

      AppLogger.info('Current shift loaded - ShiftController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load current shift - ShiftController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat shift aktif',
        operation: 'loadCurrentShift',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading current shift - ShiftController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Load shift history
  Future<void> loadShiftHistory() async {
    try {
      AppLogger.ui('Loading shift history', details: 'ShiftController');
      _setLoading(true);
      _clearError();

      _shiftHistory = await getShiftsUseCase.execute(limit: 100);

      AppLogger.info('Shift history loaded - ShiftController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load shift history - ShiftController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat riwayat shift',
        operation: 'loadShiftHistory',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading shift history - ShiftController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Open a new shift
  Future<bool> openShift({
    required String userName,
    required double openingBalance,
  }) async {
    try {
      AppLogger.ui('Opening shift', details: 'ShiftController');
      _setLoading(true);
      _clearError();

      _userName = userName;
      final shift = await openShiftUseCase.execute(
        userName: userName,
        openingBalance: openingBalance,
      );

      _currentShift = shift;
      _shiftHistory.insert(0, shift);

      AppLogger.info('Shift opened successfully - ShiftController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to open shift - ShiftController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal membuka shift',
        operation: 'openShift',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error opening shift - ShiftController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Close the current shift
  Future<bool> closeShift({
    required double closingBalance,
  }) async {
    try {
      AppLogger.ui('Closing shift', details: 'ShiftController');
      _setLoading(true);
      _clearError();

      if (_currentShift == null) {
        throw const ValidationException(
          'Tidak ada shift aktif untuk ditutup',
          field: 'Shift',
        );
      }

      final closedShift = await closeShiftUseCase.execute(
        shiftId: _currentShift!.id!,
        closingBalance: closingBalance,
      );

      // Update current shift and history
      _currentShift = null;
      final index = _shiftHistory.indexWhere((s) => s.id == closedShift.id);
      if (index != -1) {
        _shiftHistory[index] = closedShift;
      }

      AppLogger.info('Shift closed successfully - ShiftController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to close shift - ShiftController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menutup shift',
        operation: 'closeShift',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error closing shift - ShiftController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update shift totals after a transaction
  Future<void> updateTotals({
    required double cashSales,
    required double cardSales,
    required double qrSales,
    required double transferSales,
    required int transactionCount,
  }) async {
    try {
      if (_currentShift == null) return;

      AppLogger.ui('Updating shift totals', details: 'ShiftController');

      final updatedShift = await updateShiftTotalsUseCase.execute(
        shiftId: _currentShift!.id!,
        cashSales: cashSales,
        cardSales: cardSales,
        qrSales: qrSales,
        transferSales: transferSales,
        transactionCount: transactionCount,
      );

      _currentShift = updatedShift;

      // Update in history as well
      final index = _shiftHistory.indexWhere((s) => s.id == updatedShift.id);
      if (index != -1) {
        _shiftHistory[index] = updatedShift;
      }

      AppLogger.info('Shift totals updated - ShiftController');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update shift totals - ShiftController',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - transaction should succeed even if shift update fails
    }
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  // Private methods

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setError(AppException error) {
    _error = error;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _clearError() {
    _error = null;
    if (!_disposed) {
      notifyListeners();
    }
  }
}
