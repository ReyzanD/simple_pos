import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Settings Data Layer
import 'package:simple_pos/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:simple_pos/features/settings/data/repositories/settings_repository_impl.dart';

// Settings Presentation Layer (Controller)
import 'package:simple_pos/features/settings/presentation/controllers/settings_controller.dart';

/// Settings feature providers
///
/// Manages all dependencies for settings management:
/// - App settings (business info, tax, currency, etc.)
/// - Settings persistence via SharedPreferences
List<SingleChildWidget> createSettingsProviders() {
  return [
    // Settings data source
    Provider<SettingsLocalDataSource>(
      create: (_) => SettingsLocalDataSource(),
    ),

    // Settings repository
    ProxyProvider<SettingsLocalDataSource, SettingsRepositoryImpl>(
      update: (_, dataSource, _) => SettingsRepositoryImpl(
        localDataSource: dataSource,
      ),
    ),

    // Settings controller
    ChangeNotifierProvider<SettingsController>(
      create: (context) => SettingsController(
        repository: context.read<SettingsRepositoryImpl>(),
      ),
    ),
  ];
}
