import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:simple_pos/core/providers/core_providers.dart';
import 'package:simple_pos/features/expenses/domain/providers/expenses_providers.dart';
import 'package:simple_pos/features/inventory/domain/providers/inventory_providers.dart';
import 'package:simple_pos/features/sales/domain/providers/sales_providers.dart';
import 'package:simple_pos/features/users/domain/providers/users_providers.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/provider_groups.dart';
import 'core/controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/pos/domain/providers/pos_providers.dart';
import 'features/shared/presentation/main_navigation.dart';

void main() => runApp(const POSApp());

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...createCoreProviders(), // Starting with ONLY core to test
        ...createInventoryProviders(),
        ...createUserProviders(),
        ...createSalesProviders(),
        ...createExpensesProviders(),
        ...createPOSProviders(),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('id')],
          locale: const Locale('id'),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const MainNavigation(),
        ),
      ),
    );
  }
}
