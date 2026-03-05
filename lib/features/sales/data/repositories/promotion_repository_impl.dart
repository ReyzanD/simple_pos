import '../../domain/entities/promotion.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_local_datasource_impl.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Repository implementation for promotions
class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionLocalDataSourceImpl localDataSource;

  PromotionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Promotion>> getPromotions() async {
    try {
      final models = await localDataSource.getPromotions();
      return models.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in PromotionRepositoryImpl.getPromotions',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data promosi',
        operation: 'getPromotions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final models = await localDataSource.getActivePromotions();
      return models.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in PromotionRepositoryImpl.getActivePromotions',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data promosi aktif',
        operation: 'getActivePromotions',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Promotion> getPromotionById(int id) async {
    try {
      final model = await localDataSource.getPromotionById(id);
      return model.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in PromotionRepositoryImpl.getPromotionById',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data promosi',
        operation: 'getPromotionById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Promotion> createPromotion(Promotion promotion) async {
    try {
      final model = await localDataSource.createPromotion(promotion);
      return model.toEntity();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in PromotionRepositoryImpl.createPromotion',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuat promosi',
        operation: 'createPromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Promotion> updatePromotion(Promotion promotion) async {
    try {
      final model = await localDataSource.updatePromotion(promotion);
      return model.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in PromotionRepositoryImpl.updatePromotion',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengupdate promosi',
        operation: 'updatePromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deletePromotion(int id) async {
    try {
      await localDataSource.deletePromotion(id);
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in PromotionRepositoryImpl.deletePromotion',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menghapus promosi',
        operation: 'deletePromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Promotion> togglePromotion(int id, bool isEnabled) async {
    try {
      final model = await localDataSource.togglePromotion(id, isEnabled);
      return model.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in PromotionRepositoryImpl.togglePromotion',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengubah status promosi',
        operation: 'togglePromotion',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
