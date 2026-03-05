import '../models/promotion_model.dart';
import '../../domain/entities/promotion.dart';
import '../../../../services/database/database_helper.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Local data source implementation for promotions using SQLite
class PromotionLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  PromotionLocalDataSourceImpl({required this.databaseHelper});

  /// Retrieves all promotions from database
  Future<List<PromotionModel>> getPromotions() async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching all promotions');

      final result = await db.query(
        'promotions',
        orderBy: 'created_at DESC',
      );

      AppLogger.database('Promotions fetched', details: '${result.length} items');
      return result.map((map) => PromotionModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch promotions',
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

  /// Retrieves only active promotions
  Future<List<PromotionModel>> getActivePromotions() async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().toIso8601String();

      final result = await db.rawQuery('''
        SELECT * FROM promotions
        WHERE is_enabled = 1
        AND (start_date IS NULL OR start_date <= ?)
        AND (end_date IS NULL OR end_date >= ?)
        ORDER BY created_at DESC
      ''', [now, now]);

      return result.map((map) => PromotionModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch active promotions',
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

  /// Retrieves a single promotion by ID
  Future<PromotionModel> getPromotionById(int id) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching promotion', details: 'ID: $id');

      final results = await db.query(
        'promotions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        throw NotFoundException('Promosi dengan ID $id tidak ditemukan');
      }

      AppLogger.database('Promotion fetched', details: 'ID: $id');
      return PromotionModel.fromMap(results.first);
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch promotion',
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

  /// Creates a new promotion
  Future<PromotionModel> createPromotion(Promotion promotion) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Creating promotion', details: promotion.name);

      final model = PromotionModel.fromEntity(promotion);
      final id = await db.insert('promotions', model.toMap());

      final created = model.copyWith(id: id);

      AppLogger.database('Promotion created', details: 'ID: $id');
      return created;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create promotion',
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

  /// Updates an existing promotion
  Future<PromotionModel> updatePromotion(Promotion promotion) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Updating promotion', details: 'ID: ${promotion.id}');

      if (promotion.id == null) {
        throw ValidationException('ID promosi diperlukan', field: 'ID');
      }

      final model = PromotionModel.fromEntity(promotion);
      final count = await db.update(
        'promotions',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [promotion.id],
      );

      if (count == 0) {
        throw NotFoundException('Promosi dengan ID ${promotion.id} tidak ditemukan');
      }

      AppLogger.database('Promotion updated', details: 'ID: ${promotion.id}');
      return model;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update promotion',
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

  /// Deletes a promotion
  Future<void> deletePromotion(int id) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Deleting promotion', details: 'ID: $id');

      final count = await db.delete(
        'promotions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Promosi dengan ID $id tidak ditemukan');
      }

      AppLogger.database('Promotion deleted', details: 'ID: $id');
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete promotion',
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

  /// Toggles promotion enabled status
  Future<PromotionModel> togglePromotion(int id, bool isEnabled) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Toggling promotion', details: 'ID: $id, enabled: $isEnabled');

      final count = await db.update(
        'promotions',
        {'is_enabled': isEnabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Promosi dengan ID $id tidak ditemukan');
      }

      // Fetch and return the updated promotion
      return await getPromotionById(id);
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to toggle promotion',
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
