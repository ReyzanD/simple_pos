import '../entities/promotion.dart';
import '../repositories/promotion_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for retrieving promotions
class GetPromotionsUseCase {
  final PromotionRepository promotionRepository;

  GetPromotionsUseCase({required this.promotionRepository});

  /// Executes the use case to get all promotions
  Future<List<Promotion>> execute() async {
    try {
      AppLogger.useCase('GetPromotions');

      final promotions = await promotionRepository.getPromotions();

      AppLogger.info('Retrieved ${promotions.length} promotions');

      return promotions;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetPromotionsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data promosi',
        operation: 'GetPromotions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Executes the use case to get only active promotions
  Future<List<Promotion>> executeActiveOnly() async {
    try {
      AppLogger.useCase('GetActivePromotions');

      final promotions = await promotionRepository.getActivePromotions();

      AppLogger.info('Retrieved ${promotions.length} active promotions');

      return promotions;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetActivePromotionsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data promosi aktif',
        operation: 'GetActivePromotions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Executes the use case to get a single promotion by ID
  Future<Promotion> executeById(int id) async {
    try {
      AppLogger.useCase('GetPromotionById', details: 'ID: $id');

      if (id <= 0) {
        throw ValidationException('ID promosi tidak valid', field: 'ID');
      }

      final promotion = await promotionRepository.getPromotionById(id);

      AppLogger.info('Retrieved promotion: $id');

      return promotion;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetPromotionById',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data promosi',
        operation: 'GetPromotionById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
