import '../entities/shift.dart';
import '../repositories/shift_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for opening a new cashier shift
class OpenShiftUseCase {
  final ShiftRepository shiftRepository;

  OpenShiftUseCase({required this.shiftRepository});

  /// Executes the use case to open a new shift
  /// Throws [ValidationException] if validation fails
  /// Throws [ConflictException] if there's already an active shift
  Future<Shift> execute({
    required String userName,
    required double openingBalance,
  }) async {
    try {
      AppLogger.useCase('OpenShift', details: 'User: $userName, Balance: $openingBalance');

      // Check if there's already an active shift
      final currentShift = await shiftRepository.getCurrentShift();
      if (currentShift != null) {
        throw ConflictException(
          'Shift sudah aktif untuk kasir ini. Tutup shift terlebih dahulu.',
          resourceType: 'Shift',
          resourceId: currentShift.id.toString(),
        );
      }

      // Validate inputs
      if (userName.trim().isEmpty) {
        throw const ValidationException(
          'Nama kasir wajib diisi',
          field: 'Nama Kasir',
        );
      }

      if (openingBalance < 0) {
        throw const ValidationException(
          'Saldo awal tidak boleh negatif',
          field: 'Saldo Awal',
        );
      }

      final shift = await shiftRepository.openShift(
        userName: userName.trim(),
        openingBalance: openingBalance,
      );

      AppLogger.info('Shift opened successfully - ID: ${shift.id}');
      return shift;
    } on ValidationException {
      rethrow;
    } on ConflictException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in OpenShiftUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuka shift',
        operation: 'OpenShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
