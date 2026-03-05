import '../entities/discount_preset.dart';
import '../repositories/discount_preset_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for updating an existing discount preset
class UpdateDiscountPresetUseCase {
  final DiscountPresetRepository discountPresetRepository;

  UpdateDiscountPresetUseCase({required this.discountPresetRepository});

  /// Executes the use case to update a discount preset
  Future<DiscountPreset> execute(DiscountPreset preset) async {
    try {
      AppLogger.useCase('UpdateDiscountPreset', details: 'ID: ${preset.id}');

      if (preset.id == null) {
        throw ValidationException('ID preset diperlukan untuk update', field: 'ID');
      }

      // Validate
      preset.validate();

      final updated = await discountPresetRepository.updateDiscountPreset(preset);

      AppLogger.info('Discount preset updated successfully - ID: ${updated.id}');

      return updated;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in UpdateDiscountPresetUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengupdate preset diskon',
        operation: 'UpdateDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
