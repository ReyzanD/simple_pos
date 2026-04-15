import '../models/discount_preset_model.dart';
import '../../domain/entities/discount_preset.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Local data source implementation for discount presets using SQLite
class DiscountPresetLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  DiscountPresetLocalDataSourceImpl({required this.databaseHelper});

  /// Retrieves all discount presets from database
  Future<List<DiscountPresetModel>> getDiscountPresets() async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching all discount presets');

      final result = await db.query(
        'discount_presets',
        orderBy: 'created_at DESC',
      );

      AppLogger.database(
        'Discount presets fetched',
        details: '${result.length} items',
      );
      return result.map((map) => DiscountPresetModel.fromMap(map)).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch discount presets',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data preset diskon',
        operation: 'getDiscountPresets',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves a single discount preset by ID
  Future<DiscountPresetModel> getDiscountPresetById(int id) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Fetching discount preset', details: 'ID: $id');

      final results = await db.query(
        'discount_presets',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        throw NotFoundException('Preset diskon dengan ID $id tidak ditemukan');
      }

      AppLogger.database('Discount preset fetched', details: 'ID: $id');
      return DiscountPresetModel.fromMap(results.first);
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch discount preset',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data preset diskon',
        operation: 'getDiscountPresetById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Creates a new discount preset
  Future<DiscountPresetModel> createDiscountPreset(
    DiscountPreset preset,
  ) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Creating discount preset', details: preset.name);

      final model = DiscountPresetModel.fromEntity(preset);
      final id = await db.insert('discount_presets', model.toMap());

      final created = model.copyWith(id: id);

      AppLogger.database('Discount preset created', details: 'ID: $id');
      return created;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create discount preset',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuat preset diskon',
        operation: 'createDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing discount preset
  Future<DiscountPresetModel> updateDiscountPreset(
    DiscountPreset preset,
  ) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database(
        'Updating discount preset',
        details: 'ID: ${preset.id}',
      );

      if (preset.id == null) {
        throw ValidationException('ID preset diperlukan', field: 'ID');
      }

      final model = DiscountPresetModel.fromEntity(preset);
      final count = await db.update(
        'discount_presets',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [preset.id],
      );

      if (count == 0) {
        throw NotFoundException(
          'Preset diskon dengan ID ${preset.id} tidak ditemukan',
        );
      }

      AppLogger.database(
        'Discount preset updated',
        details: 'ID: ${preset.id}',
      );
      return model;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update discount preset',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengupdate preset diskon',
        operation: 'updateDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a discount preset
  Future<void> deleteDiscountPreset(int id) async {
    try {
      final db = await databaseHelper.database;
      AppLogger.database('Deleting discount preset', details: 'ID: $id');

      final count = await db.delete(
        'discount_presets',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Preset diskon dengan ID $id tidak ditemukan');
      }

      AppLogger.database('Discount preset deleted', details: 'ID: $id');
    } on NotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete discount preset',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menghapus preset diskon',
        operation: 'deleteDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
