import '../entities/cash_count.dart';
import '../repositories/cash_count_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for saving cash count during shift closing
class SaveCashCountUseCase {
  final CashCountRepository cashCountRepository;

  SaveCashCountUseCase({required this.cashCountRepository});

  /// Execute the use case to save cash count
  Future<CashCount> execute(CashCount cashCount) async {
    try {
      AppLogger.useCase('SaveCashCount', details: 'Shift: ${cashCount.shiftId}');

      // Validate
      if (cashCount.shiftId <= 0) {
        throw const ValidationException(
          'ID shift tidak valid',
          field: 'Shift',
        );
      }

      final saved = await cashCountRepository.saveCashCount(cashCount);

      AppLogger.info('Cash count saved - ID: ${saved.id}');
      return saved;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in SaveCashCountUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menyimpan hitungan uang',
        operation: 'SaveCashCount',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
