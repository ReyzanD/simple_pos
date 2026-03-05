import '../entities/promotion.dart';
import '../repositories/promotion_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for updating an existing promotion
class UpdatePromotionUseCase {
  final PromotionRepository promotionRepository;

  UpdatePromotionUseCase({required this.promotionRepository});

  /// Executes the use case to update a promotion
  Future<Promotion> execute(Promotion promotion) async {
    try {
      AppLogger.useCase('UpdatePromotion', details: 'ID: ${promotion.id}');

      if (promotion.id == null) {
        throw ValidationException('ID promosi diperlukan untuk update', field: 'ID');
      }

      // Validate
      promotion.validate();

      final updated = await promotionRepository.updatePromotion(promotion);

      AppLogger.info('Promotion updated successfully - ID: ${updated.id}');

      return updated;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in UpdatePromotionUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengupdate promosi',
        operation: 'UpdatePromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
