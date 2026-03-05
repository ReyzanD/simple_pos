// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'POS & Inventaris';

  @override
  String get pos => 'Kasir';

  @override
  String get inventory => 'Inventaris';

  @override
  String get sales => 'Penjualan';

  @override
  String get reports => 'Laporan';

  @override
  String get settings => 'Pengaturan';
}
