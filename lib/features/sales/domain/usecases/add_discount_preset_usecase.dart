import '../entities/discount_preset.dart';
import '../repositories/discount_preset_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';

/// Use case for adding a new discount preset
class AddDiscountPresetUseCase {
  final DiscountPresetRepository discountPresetRepository;

  AddDiscountPresetUseCase({required this.discountPresetRepository});

  /// Executes the use case to add a discount preset
  Future<DiscountPreset> execute(DiscountPreset preset) async {
    try {
      AppLogger.useCase('AddDiscountPreset', details: preset.name);

      // Validate
      Validators.validatePromotionName(preset.name);

      final created = await discountPresetRepository.createDiscountPreset(preset);

      AppLogger.info('Discount preset created successfully - ID: ${created.id}');

      return created;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddDiscountPresetUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menambahkan preset diskon',
        operation: 'AddDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
