import 'package:provider/provider.dart';
import '../../../services/database/database_helper.dart';
import '../controllers/theme_controller.dart';

/// Core app-wide providers
///
/// Provides fundamental services that the entire app depends on:
/// - DatabaseHelper: SQLite database instance
/// - ThemeController: App theme management
List createCoreProviders() {
  return [
    // Database - must be first as other providers depend on it
    Provider<DatabaseHelper>(
      create: (_) => DatabaseHelper.instance,
    ),

    // Theme management
    ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController()..init(),
    ),
  ];
}
