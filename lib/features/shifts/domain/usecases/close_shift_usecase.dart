import '../entities/shift.dart';
import '../repositories/shift_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for closing a cashier shift
class CloseShiftUseCase {
  final ShiftRepository shiftRepository;

  CloseShiftUseCase({required this.shiftRepository});

  /// Executes the use case to close an active shift
  /// Throws [ValidationException] if validation fails
  /// Throws [NotFoundException] if shift is not found
  Future<Shift> execute({
    required int shiftId,
    required double closingBalance,
  }) async {
    try {
      AppLogger.useCase('CloseShift', details: 'Shift ID: $shiftId, Closing Balance: $closingBalance');

      // Validate inputs
      if (closingBalance < 0) {
        throw const ValidationException(
          'Saldo akhir tidak boleh negatif',
          field: 'Saldo Akhir',
        );
      }

      // Get the current shift to validate
      final shift = await shiftRepository.getShiftById(shiftId);
      if (shift == null) {
        throw NotFoundException(
          'Shift tidak ditemukan',
          resourceType: 'Shift',
          resourceId: shiftId.toString(),
        );
      }

      if (!shift.isActive) {
        throw ValidationException(
          'Shift sudah ditutup',
          field: 'Shift',
        );
      }

      final closedShift = await shiftRepository.closeShift(
        shiftId: shiftId,
        closingBalance: closingBalance,
      );

      // Log if there's a discrepancy
      if (closedShift.hasDiscrepancy) {
        final discrepancy = closedShift.discrepancy!;
        AppLogger.ui(
          'Cash discrepancy detected',
          details: 'Expected: ${closedShift.expectedClosingBalance}, '
              'Actual: ${closedShift.closingBalance}, '
              'Difference: ${discrepancy > 0 ? '+' : ''}${discrepancy.toStringAsFixed(2)}',
        );
      }

      AppLogger.info('Shift closed successfully - ID: $shiftId');
      return closedShift;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CloseShiftUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menutup shift',
        operation: 'CloseShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
