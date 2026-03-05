import '../entities/promotion.dart';
import '../repositories/promotion_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for toggling promotion enabled status
class TogglePromotionUseCase {
  final PromotionRepository promotionRepository;

  TogglePromotionUseCase({required this.promotionRepository});

  /// Executes the use case to toggle promotion
  Future<Promotion> execute(int id, bool isEnabled) async {
    try {
      AppLogger.useCase('TogglePromotion', details: 'ID: $id, enabled: $isEnabled');

      if (id <= 0) {
        throw ValidationException('ID promosi tidak valid', field: 'ID');
      }

      final promotion = await promotionRepository.togglePromotion(id, isEnabled);

      AppLogger.info('Promotion toggled successfully - ID: $id');

      return promotion;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in TogglePromotionUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengubah status promosi',
        operation: 'TogglePromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
