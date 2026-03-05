import '../repositories/promotion_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for deleting a promotion
class DeletePromotionUseCase {
  final PromotionRepository promotionRepository;

  DeletePromotionUseCase({required this.promotionRepository});

  /// Executes the use case to delete a promotion
  Future<void> execute(int id) async {
    try {
      AppLogger.useCase('DeletePromotion', details: 'ID: $id');

      if (id <= 0) {
        throw ValidationException('ID promosi tidak valid', field: 'ID');
      }

      await promotionRepository.deletePromotion(id);

      AppLogger.info('Promotion deleted successfully - ID: $id');
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DeletePromotionUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menghapus promosi',
        operation: 'DeletePromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
