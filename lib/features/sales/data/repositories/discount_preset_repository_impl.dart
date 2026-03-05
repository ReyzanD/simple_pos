import '../../domain/entities/discount_preset.dart';
import '../../domain/repositories/discount_preset_repository.dart';
import '../datasources/discount_preset_local_datasource_impl.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Repository implementation for discount presets
class DiscountPresetRepositoryImpl implements DiscountPresetRepository {
  final DiscountPresetLocalDataSourceImpl localDataSource;

  DiscountPresetRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DiscountPreset>> getDiscountPresets() async {
    try {
      final models = await localDataSource.getDiscountPresets();
      return models.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DiscountPresetRepositoryImpl.getDiscountPresets',
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

  @override
  Future<DiscountPreset> getDiscountPresetById(int id) async {
    try {
      final model = await localDataSource.getDiscountPresetById(id);
      return model.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DiscountPresetRepositoryImpl.getDiscountPresetById',
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

  @override
  Future<DiscountPreset> createDiscountPreset(DiscountPreset preset) async {
    try {
      final model = await localDataSource.createDiscountPreset(preset);
      return model.toEntity();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DiscountPresetRepositoryImpl.createDiscountPreset',
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

  @override
  Future<DiscountPreset> updateDiscountPreset(DiscountPreset preset) async {
    try {
      final model = await localDataSource.updateDiscountPreset(preset);
      return model.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DiscountPresetRepositoryImpl.updateDiscountPreset',
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

  @override
  Future<void> deleteDiscountPreset(int id) async {
    try {
      await localDataSource.deleteDiscountPreset(id);
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DiscountPresetRepositoryImpl.deleteDiscountPreset',
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
