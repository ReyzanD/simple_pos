import '../entities/shift.dart';
import '../repositories/shift_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for getting the currently active shift
class GetCurrentShiftUseCase {
  final ShiftRepository shiftRepository;

  GetCurrentShiftUseCase({required this.shiftRepository});

  /// Executes the use case to get the current active shift
  /// Returns null if no active shift exists
  Future<Shift?> execute() async {
    try {
      AppLogger.useCase('GetCurrentShift');

      final shift = await shiftRepository.getCurrentShift();

      if (shift != null) {
        AppLogger.info('Active shift found - ID: ${shift.id}');
      } else {
        AppLogger.info('No active shift found');
      }

      return shift;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetCurrentShiftUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil shift aktif',
        operation: 'GetCurrentShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
