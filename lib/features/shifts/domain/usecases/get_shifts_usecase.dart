import '../entities/shift.dart';
import '../repositories/shift_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for getting shifts history
class GetShiftsUseCase {
  final ShiftRepository shiftRepository;

  GetShiftsUseCase({required this.shiftRepository});

  /// Executes the use case to get shifts history
  Future<List<Shift>> execute({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      AppLogger.useCase('GetShifts', details: 'Limit: $limit, Offset: $offset');

      final shifts = await shiftRepository.getShifts(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      AppLogger.info('Retrieved ${shifts.length} shifts');
      return shifts;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetShiftsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil riwayat shift',
        operation: 'GetShifts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
