import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/shared/presentation/main_navigation.dart';
import 'features/shared/presentation/providers.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: POSApp()));
}

class POSApp extends ConsumerStatefulWidget {
  const POSApp({super.key});

  @override
  ConsumerState<POSApp> createState() => _POSAppState();
}

class _POSAppState extends ConsumerState<POSApp> {
  late ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ref.read(themeControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _themeController.init();
      ref.read(authControllerProvider).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider).themeMode;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      locale: const Locale('id'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigation(),
    );
  }
}
