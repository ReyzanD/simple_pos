import '../repositories/discount_preset_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for deleting a discount preset
class DeleteDiscountPresetUseCase {
  final DiscountPresetRepository discountPresetRepository;

  DeleteDiscountPresetUseCase({required this.discountPresetRepository});

  /// Executes the use case to delete a discount preset
  Future<void> execute(int id) async {
    try {
      AppLogger.useCase('DeleteDiscountPreset', details: 'ID: $id');

      if (id <= 0) {
        throw ValidationException('ID preset tidak valid', field: 'ID');
      }

      await discountPresetRepository.deleteDiscountPreset(id);

      AppLogger.info('Discount preset deleted successfully - ID: $id');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DeleteDiscountPresetUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menghapus preset diskon',
        operation: 'DeleteDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
