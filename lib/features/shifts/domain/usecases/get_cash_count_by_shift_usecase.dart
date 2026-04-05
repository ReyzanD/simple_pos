import '../entities/cash_count.dart';
import '../repositories/cash_count_repository.dart';
import '../../../../core/utils/logger.dart';

/// Use case for retrieving cash count for a shift
class GetCashCountByShiftUseCase {
  final CashCountRepository cashCountRepository;

  GetCashCountByShiftUseCase({required this.cashCountRepository});

  /// Execute the use case to get cash count by shift
  Future<CashCount?> execute(int shiftId) async {
    try {
      AppLogger.useCase('GetCashCountByShift', details: 'Shift: $shiftId');

      final cashCount = await cashCountRepository.getCashCountByShift(shiftId);

      AppLogger.info('Cash count retrieved - Found: ${cashCount != null}');
      return cashCount;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetCashCountByShiftUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
