import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Use package imports to fix "Undefined class" errors
import 'package:simple_pos/core/controllers/theme_controller.dart';
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/services/printer_service.dart';

List<SingleChildWidget> createCoreProviders() {
  return [
    // 1. Theme Controller
    ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController()..init(),
    ),

    // 2. Database Helper (The single source of truth)
    Provider<DatabaseHelper>(
      lazy: false,
      create: (_) => DatabaseHelper.instance,
    ),

    // 3. Printer Service
    ChangeNotifierProvider<PrinterService>(create: (_) => PrinterService()),
  ];
}
