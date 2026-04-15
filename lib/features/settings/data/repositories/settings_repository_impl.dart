import '../datasources/settings_local_datasource.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/database/database_helper.dart';

/// Implementation of SettingsRepository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Settings> getSettings() async {
    return await localDataSource.getSettings();
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    await localDataSource.saveSettings(settings);
  }

  @override
  Future<void> resetSettings() async {
    await localDataSource.clearSettings();
  }

  @override
  Future<String> exportSettings() async {
    return await localDataSource.exportSettings();
  }

  @override
  Future<void> importSettings(String json) async {
    await localDataSource.importSettings(json);
  }

  @override
  Future<void> clearAllData() async {
    await DatabaseHelper.instance.clearAllData();
  }
}
