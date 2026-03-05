import '../entities/promotion.dart';
import '../repositories/promotion_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';

/// Use case for adding a new promotion
class AddPromotionUseCase {
  final PromotionRepository promotionRepository;

  AddPromotionUseCase({required this.promotionRepository});

  /// Executes the use case to add a promotion
  Future<Promotion> execute(Promotion promotion) async {
    try {
      AppLogger.useCase('AddPromotion', details: promotion.name);

      // Validate
      Validators.validatePromotionName(promotion.name);

      final created = await promotionRepository.createPromotion(promotion);

      AppLogger.info('Promotion created successfully - ID: ${created.id}');

      return created;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddPromotionUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menambahkan promosi',
        operation: 'AddPromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
