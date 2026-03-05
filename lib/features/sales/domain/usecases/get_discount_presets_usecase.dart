import '../entities/discount_preset.dart';
import '../repositories/discount_preset_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for retrieving discount presets
class GetDiscountPresetsUseCase {
  final DiscountPresetRepository discountPresetRepository;

  GetDiscountPresetsUseCase({required this.discountPresetRepository});

  /// Executes the use case to get all discount presets
  Future<List<DiscountPreset>> execute() async {
    try {
      AppLogger.useCase('GetDiscountPresets');

      final presets = await discountPresetRepository.getDiscountPresets();

      AppLogger.info('Retrieved ${presets.length} discount presets');

      return presets;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetDiscountPresetsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data preset diskon',
        operation: 'GetDiscountPresets',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Executes the use case to get a single discount preset by ID
  Future<DiscountPreset> executeById(int id) async {
    try {
      AppLogger.useCase('GetDiscountPresetById', details: 'ID: $id');

      if (id <= 0) {
        throw ValidationException('ID preset tidak valid', field: 'ID');
      }

      final preset = await discountPresetRepository.getDiscountPresetById(id);

      AppLogger.info('Retrieved discount preset: $id');

      return preset;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetDiscountPresetById',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data preset diskon',
        operation: 'GetDiscountPresetById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
