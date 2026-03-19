import '../entities/shift.dart';
import '../repositories/shift_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for updating shift totals after a transaction
class UpdateShiftTotalsUseCase {
  final ShiftRepository shiftRepository;

  UpdateShiftTotalsUseCase({required this.shiftRepository});

  /// Executes the use case to update shift totals
  Future<Shift> execute({
    required int shiftId,
    required double cashSales,
    required double cardSales,
    required double qrSales,
    required double transferSales,
    required int transactionCount,
  }) async {
    try {
      AppLogger.useCase('UpdateShiftTotals', details: 'Shift ID: $shiftId');

      // Validate inputs
      if (cashSales < 0 || cardSales < 0 || qrSales < 0 || transferSales < 0) {
        throw const ValidationException(
          'Penjualan tidak boleh negatif',
          field: 'Penjualan',
        );
      }

      if (transactionCount < 0) {
        throw const ValidationException(
          'Jumlah transaksi tidak boleh negatif',
          field: 'Jumlah Transaksi',
        );
      }

      final updatedShift = await shiftRepository.updateShiftTotals(
        shiftId: shiftId,
        cashSales: cashSales,
        cardSales: cardSales,
        qrSales: qrSales,
        transferSales: transferSales,
        transactionCount: transactionCount,
      );

      AppLogger.info('Shift totals updated - ID: $shiftId');
      return updatedShift;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in UpdateShiftTotalsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengupdate total shift',
        operation: 'UpdateShiftTotals',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
