import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'POS & Inventory'**
  String get appTitle;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @business_info.
  ///
  /// In en, this message translates to:
  /// **'Business Info'**
  String get business_info;

  /// No description provided for @business_name.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get business_name;

  /// No description provided for @enter_business_name.
  ///
  /// In en, this message translates to:
  /// **'Enter business name'**
  String get enter_business_name;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enter_address.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get enter_address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enter_email;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @not_filled.
  ///
  /// In en, this message translates to:
  /// **'Not filled'**
  String get not_filled;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currency_symbol.
  ///
  /// In en, this message translates to:
  /// **'Currency Symbol'**
  String get currency_symbol;

  /// No description provided for @currency_code.
  ///
  /// In en, this message translates to:
  /// **'Currency Code'**
  String get currency_code;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @receipt_footer.
  ///
  /// In en, this message translates to:
  /// **'Receipt Footer'**
  String get receipt_footer;

  /// No description provided for @footer_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter receipt footer message'**
  String get footer_message_hint;

  /// No description provided for @enter_footer_message.
  ///
  /// In en, this message translates to:
  /// **'Enter footer message'**
  String get enter_footer_message;

  /// No description provided for @currency_symbol_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: Rp'**
  String get currency_symbol_hint;

  /// No description provided for @currency_code_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: IDR'**
  String get currency_code_hint;

  /// No description provided for @low_stock_threshold.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Threshold'**
  String get low_stock_threshold;

  /// No description provided for @data_management.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get data_management;

  /// No description provided for @export_settings.
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get export_settings;

  /// No description provided for @save_settings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings to File'**
  String get save_settings;

  /// No description provided for @delete_all_data_desc.
  ///
  /// In en, this message translates to:
  /// **'Delete all transaction and product data'**
  String get delete_all_data_desc;

  /// No description provided for @export_data_backup.
  ///
  /// In en, this message translates to:
  /// **'Export data and backup'**
  String get export_data_backup;

  /// No description provided for @save_settings_file.
  ///
  /// In en, this message translates to:
  /// **'Save Settings to File'**
  String get save_settings_file;

  /// No description provided for @bluetooth_thermal.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth thermal printer'**
  String get bluetooth_thermal;

  /// No description provided for @business_name_updated.
  ///
  /// In en, this message translates to:
  /// **'Business name updated'**
  String get business_name_updated;

  /// No description provided for @address_updated.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get address_updated;

  /// No description provided for @phone_updated.
  ///
  /// In en, this message translates to:
  /// **'Phone updated'**
  String get phone_updated;

  /// No description provided for @email_updated.
  ///
  /// In en, this message translates to:
  /// **'Email updated'**
  String get email_updated;

  /// No description provided for @currency_symbol_updated.
  ///
  /// In en, this message translates to:
  /// **'Currency symbol updated'**
  String get currency_symbol_updated;

  /// No description provided for @currency_code_updated.
  ///
  /// In en, this message translates to:
  /// **'Currency code updated'**
  String get currency_code_updated;

  /// No description provided for @receipt_footer_updated.
  ///
  /// In en, this message translates to:
  /// **'Receipt footer updated'**
  String get receipt_footer_updated;

  /// No description provided for @stock_threshold_updated.
  ///
  /// In en, this message translates to:
  /// **'Stock threshold updated'**
  String get stock_threshold_updated;

  /// No description provided for @settings_reset_default.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to default'**
  String get settings_reset_default;

  /// No description provided for @all_data_deleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted successfully'**
  String get all_data_deleted;

  /// No description provided for @settings_exported.
  ///
  /// In en, this message translates to:
  /// **'Settings exported'**
  String get settings_exported;

  /// No description provided for @export_transactions_success.
  ///
  /// In en, this message translates to:
  /// **'Transactions exported successfully'**
  String get export_transactions_success;

  /// No description provided for @export_failed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String export_failed(Object error);

  /// No description provided for @export_products_success.
  ///
  /// In en, this message translates to:
  /// **'Products exported successfully'**
  String get export_products_success;

  /// No description provided for @export_expenses_success.
  ///
  /// In en, this message translates to:
  /// **'Expenses exported successfully'**
  String get export_expenses_success;

  /// No description provided for @backup_created_success.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backup_created_success;

  /// No description provided for @create_new_backup.
  ///
  /// In en, this message translates to:
  /// **'Create New Backup'**
  String get create_new_backup;

  /// No description provided for @full_backup_desc.
  ///
  /// In en, this message translates to:
  /// **'Full backup of all data'**
  String get full_backup_desc;

  /// No description provided for @full_backup.
  ///
  /// In en, this message translates to:
  /// **'Full Backup'**
  String get full_backup;

  /// No description provided for @incremental.
  ///
  /// In en, this message translates to:
  /// **'Incremental'**
  String get incremental;

  /// No description provided for @backup_and_restore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup_and_restore;

  /// No description provided for @create_backup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get create_backup;

  /// No description provided for @schedule_backup.
  ///
  /// In en, this message translates to:
  /// **'Schedule Backup'**
  String get schedule_backup;

  /// No description provided for @backup_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Backup Scheduled'**
  String get backup_scheduled;

  /// No description provided for @backup_time.
  ///
  /// In en, this message translates to:
  /// **'Backup Time'**
  String get backup_time;

  /// No description provided for @restore_backup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restore_backup;

  /// No description provided for @choose_restore_mode.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to restore your data:'**
  String get choose_restore_mode;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @merge_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep existing data and add missing items'**
  String get merge_desc;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @replace_desc.
  ///
  /// In en, this message translates to:
  /// **'Wipe current data and use backup instead'**
  String get replace_desc;

  /// No description provided for @restore_now.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get restore_now;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// No description provided for @restore_failed.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get restore_failed;

  /// No description provided for @delete_backup_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Backup'**
  String get delete_backup_title;

  /// No description provided for @delete_backup_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Backup?'**
  String get delete_backup_confirm;

  /// No description provided for @delete_backup_warning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the backup from {size}. This cannot be undone.'**
  String delete_backup_warning(Object size);

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get delete_failed;

  /// No description provided for @storage_details.
  ///
  /// In en, this message translates to:
  /// **'Storage Details'**
  String get storage_details;

  /// No description provided for @storage_status.
  ///
  /// In en, this message translates to:
  /// **'Storage Status'**
  String get storage_status;

  /// No description provided for @local_storage.
  ///
  /// In en, this message translates to:
  /// **'Local Storage'**
  String get local_storage;

  /// No description provided for @google_drive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get google_drive;

  /// No description provided for @total_size.
  ///
  /// In en, this message translates to:
  /// **'Total Size'**
  String get total_size;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @drive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get drive;

  /// No description provided for @no_backups_found.
  ///
  /// In en, this message translates to:
  /// **'No {type} backups found'**
  String no_backups_found(Object type);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @full_backups.
  ///
  /// In en, this message translates to:
  /// **'Full Backups'**
  String get full_backups;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @schedule_name.
  ///
  /// In en, this message translates to:
  /// **'Schedule Name'**
  String get schedule_name;

  /// No description provided for @schedule_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Nightly Backup'**
  String get schedule_name_hint;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @day_of_month.
  ///
  /// In en, this message translates to:
  /// **'Day of Month'**
  String get day_of_month;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @confirm_delete_backup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this backup?'**
  String get confirm_delete_backup;

  /// No description provided for @backup_deleted.
  ///
  /// In en, this message translates to:
  /// **'Backup deleted'**
  String get backup_deleted;

  /// No description provided for @low_stock_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get low_stock_hint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reset_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get reset_settings_title;

  /// No description provided for @reset_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to default?'**
  String get reset_confirm_message;

  /// No description provided for @delete_all_data_warning.
  ///
  /// In en, this message translates to:
  /// **'WARNING: This action will delete all data:'**
  String get delete_all_data_warning;

  /// No description provided for @delete_all_data_items.
  ///
  /// In en, this message translates to:
  /// **'• All products and inventory'**
  String get delete_all_data_items;

  /// No description provided for @delete_all_data_transactions.
  ///
  /// In en, this message translates to:
  /// **'• All transaction history'**
  String get delete_all_data_transactions;

  /// No description provided for @delete_all_data_categories.
  ///
  /// In en, this message translates to:
  /// **'• All categories and suppliers'**
  String get delete_all_data_categories;

  /// No description provided for @delete_all_data_cannot_undo.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get delete_all_data_cannot_undo;

  /// No description provided for @product_name.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get product_name;

  /// No description provided for @product_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get product_price;

  /// No description provided for @product_stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get product_stock;

  /// No description provided for @product_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get product_category;

  /// No description provided for @product_supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get product_supplier;

  /// No description provided for @product_barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get product_barcode;

  /// No description provided for @product_costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get product_costPrice;

  /// No description provided for @product_profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get product_profit;

  /// No description provided for @product_profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get product_profitMargin;

  /// No description provided for @product_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get product_discount;

  /// No description provided for @product_discountPercentage.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get product_discountPercentage;

  /// No description provided for @product_discountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Discount must be between 0-100'**
  String get product_discountInvalid;

  /// No description provided for @product_discountOptional.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if no discount'**
  String get product_discountOptional;

  /// No description provided for @product_effectivePrice.
  ///
  /// In en, this message translates to:
  /// **'Discounted Price'**
  String get product_effectivePrice;

  /// No description provided for @product_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get product_add;

  /// No description provided for @product_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get product_edit;

  /// No description provided for @product_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get product_delete;

  /// No description provided for @product_addSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get product_addSuccess;

  /// No description provided for @product_updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get product_updateSuccess;

  /// No description provided for @product_deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get product_deleteSuccess;

  /// No description provided for @product_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get product_deleteConfirm;

  /// No description provided for @product_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get product_nameRequired;

  /// No description provided for @product_nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Product name must be at least 3 characters'**
  String get product_nameTooShort;

  /// No description provided for @product_nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Product name must be at most 100 characters'**
  String get product_nameTooLong;

  /// No description provided for @product_priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get product_priceRequired;

  /// No description provided for @product_priceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get product_priceInvalid;

  /// No description provided for @product_stockRequired.
  ///
  /// In en, this message translates to:
  /// **'Stock is required'**
  String get product_stockRequired;

  /// No description provided for @product_stockInvalid.
  ///
  /// In en, this message translates to:
  /// **'Stock cannot be negative'**
  String get product_stockInvalid;

  /// No description provided for @product_outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get product_outOfStock;

  /// No description provided for @product_lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get product_lowStock;

  /// No description provided for @product_search.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get product_search;

  /// No description provided for @product_noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get product_noProducts;

  /// No description provided for @product_selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get product_selectCategory;

  /// No description provided for @product_selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get product_selectSupplier;

  /// No description provided for @product_addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get product_addCategory;

  /// No description provided for @product_addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get product_addSupplier;

  /// No description provided for @product_tambah_produk.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get product_tambah_produk;

  /// No description provided for @product_semua.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get product_semua;

  /// No description provided for @product_stok.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get product_stok;

  /// No description provided for @product_adjust_stock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get product_adjust_stock;

  /// No description provided for @product_tambah_manual.
  ///
  /// In en, this message translates to:
  /// **'Add Manual'**
  String get product_tambah_manual;

  /// No description provided for @product_manual_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity manually'**
  String get product_manual_hint;

  /// No description provided for @product_import_csv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get product_import_csv;

  /// No description provided for @product_import_hint.
  ///
  /// In en, this message translates to:
  /// **'Import products from CSV file'**
  String get product_import_hint;

  /// No description provided for @product_stock_missing.
  ///
  /// In en, this message translates to:
  /// **'Stock data missing'**
  String get product_stock_missing;

  /// No description provided for @product_edit_produk.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get product_edit_produk;

  /// No description provided for @product_information.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get product_information;

  /// No description provided for @product_nama.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get product_nama;

  /// No description provided for @product_harga.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get product_harga;

  /// No description provided for @product_harga_pokok.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get product_harga_pokok;

  /// No description provided for @product_satuan.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get product_satuan;

  /// No description provided for @product_barcode_label.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get product_barcode_label;

  /// No description provided for @product_stock_low_badge.
  ///
  /// In en, this message translates to:
  /// **'Low Stock: {count}'**
  String product_stock_low_badge(Object count);

  /// No description provided for @product_out_of_stock_badge.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get product_out_of_stock_badge;

  /// No description provided for @product_stock_adjusted.
  ///
  /// In en, this message translates to:
  /// **'Stock adjusted successfully'**
  String get product_stock_adjusted;

  /// No description provided for @product_update_success_id.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get product_update_success_id;

  /// No description provided for @cart_title.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cart_title;

  /// No description provided for @cart_empty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cart_empty;

  /// No description provided for @cart_addItem.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get cart_addItem;

  /// No description provided for @cart_removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove from Cart'**
  String get cart_removeItem;

  /// No description provided for @cart_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get cart_quantity;

  /// No description provided for @cart_updateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Update Quantity'**
  String get cart_updateQuantity;

  /// No description provided for @cart_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cart_subtotal;

  /// No description provided for @cart_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cart_total;

  /// No description provided for @cart_itemDiscount.
  ///
  /// In en, this message translates to:
  /// **'Item Discount'**
  String get cart_itemDiscount;

  /// No description provided for @cart_totalDiscount.
  ///
  /// In en, this message translates to:
  /// **'Total Discount'**
  String get cart_totalDiscount;

  /// No description provided for @cart_youSave.
  ///
  /// In en, this message translates to:
  /// **'You save'**
  String get cart_youSave;

  /// No description provided for @cart_checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cart_checkout;

  /// No description provided for @cart_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get cart_clear;

  /// No description provided for @checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout_title;

  /// No description provided for @checkout_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Checkout'**
  String get checkout_confirmTitle;

  /// No description provided for @checkout_confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed with checkout?'**
  String get checkout_confirmMessage;

  /// No description provided for @checkout_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get checkout_processing;

  /// No description provided for @checkout_success.
  ///
  /// In en, this message translates to:
  /// **'Checkout successful!'**
  String get checkout_success;

  /// No description provided for @checkout_failed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed'**
  String get checkout_failed;

  /// No description provided for @checkout_emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get checkout_emptyCart;

  /// No description provided for @checkout_insufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock for'**
  String get checkout_insufficientStock;

  /// No description provided for @checkout_totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get checkout_totalItems;

  /// No description provided for @checkout_totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get checkout_totalAmount;

  /// No description provided for @checkout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get checkout_confirm;

  /// No description provided for @checkout_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get checkout_cancel;

  /// No description provided for @checkout_itemsProcessed.
  ///
  /// In en, this message translates to:
  /// **'Items Processed'**
  String get checkout_itemsProcessed;

  /// No description provided for @payment_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_title;

  /// No description provided for @payment_select.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get payment_select;

  /// No description provided for @payment_cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payment_cash;

  /// No description provided for @payment_card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get payment_card;

  /// No description provided for @payment_qr.
  ///
  /// In en, this message translates to:
  /// **'QRIS'**
  String get payment_qr;

  /// No description provided for @payment_transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get payment_transfer;

  /// No description provided for @payment_cashReceived.
  ///
  /// In en, this message translates to:
  /// **'Cash Received'**
  String get payment_cashReceived;

  /// No description provided for @payment_cardLast4.
  ///
  /// In en, this message translates to:
  /// **'Last 4 Digits'**
  String get payment_cardLast4;

  /// No description provided for @payment_change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get payment_change;

  /// No description provided for @payment_validate.
  ///
  /// In en, this message translates to:
  /// **'Validate Payment'**
  String get payment_validate;

  /// No description provided for @payment_invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get payment_invalidAmount;

  /// No description provided for @payment_insufficientAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount received is less than total'**
  String get payment_insufficientAmount;

  /// No description provided for @receipt_title.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt_title;

  /// No description provided for @receipt_print.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get receipt_print;

  /// No description provided for @receipt_share.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get receipt_share;

  /// No description provided for @receipt_save.
  ///
  /// In en, this message translates to:
  /// **'Save Receipt'**
  String get receipt_save;

  /// No description provided for @receipt_printSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt printed successfully'**
  String get receipt_printSuccess;

  /// No description provided for @receipt_shareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt shared successfully'**
  String get receipt_shareSuccess;

  /// No description provided for @receipt_saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved successfully'**
  String get receipt_saveSuccess;

  /// No description provided for @receipt_transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get receipt_transaction;

  /// No description provided for @receipt_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get receipt_date;

  /// No description provided for @receipt_cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get receipt_cashier;

  /// No description provided for @receipt_items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get receipt_items;

  /// No description provided for @receipt_qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get receipt_qty;

  /// No description provided for @receipt_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get receipt_price;

  /// No description provided for @receipt_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get receipt_subtotal;

  /// No description provided for @receipt_tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get receipt_tax;

  /// No description provided for @receipt_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get receipt_discount;

  /// No description provided for @receipt_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get receipt_total;

  /// No description provided for @receipt_paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get receipt_paymentMethod;

  /// No description provided for @receipt_received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receipt_received;

  /// No description provided for @receipt_thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your visit!'**
  String get receipt_thankYou;

  /// No description provided for @receipt_noReturn.
  ///
  /// In en, this message translates to:
  /// **'Goods sold cannot be returned or exchanged'**
  String get receipt_noReturn;

  /// No description provided for @sales_title.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales_title;

  /// No description provided for @sales_history.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get sales_history;

  /// No description provided for @sales_reports.
  ///
  /// In en, this message translates to:
  /// **'Sales Reports'**
  String get sales_reports;

  /// No description provided for @sales_transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get sales_transaction;

  /// No description provided for @sales_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sales_date;

  /// No description provided for @sales_items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get sales_items;

  /// No description provided for @sales_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get sales_amount;

  /// No description provided for @sales_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sales_status;

  /// No description provided for @sales_paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get sales_paymentMethod;

  /// No description provided for @sales_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sales_completed;

  /// No description provided for @sales_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sales_pending;

  /// No description provided for @sales_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get sales_cancelled;

  /// No description provided for @sales_refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get sales_refunded;

  /// No description provided for @sales_totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get sales_totalTransactions;

  /// No description provided for @sales_totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get sales_totalRevenue;

  /// No description provided for @sales_totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get sales_totalProfit;

  /// No description provided for @sales_averageTransaction.
  ///
  /// In en, this message translates to:
  /// **'Average Transaction'**
  String get sales_averageTransaction;

  /// No description provided for @sales_dailyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Daily Breakdown'**
  String get sales_dailyBreakdown;

  /// No description provided for @sales_topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get sales_topProducts;

  /// No description provided for @sales_paymentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payment Breakdown'**
  String get sales_paymentBreakdown;

  /// No description provided for @sales_export.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get sales_export;

  /// No description provided for @sales_exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get sales_exportSuccess;

  /// No description provided for @sales_filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get sales_filterByDate;

  /// No description provided for @sales_filterByPayment.
  ///
  /// In en, this message translates to:
  /// **'Filter by Payment Method'**
  String get sales_filterByPayment;

  /// No description provided for @sales_noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get sales_noTransactions;

  /// No description provided for @sales_search.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get sales_search;

  /// No description provided for @category_title.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category_title;

  /// No description provided for @category_name.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get category_name;

  /// No description provided for @category_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get category_description;

  /// No description provided for @category_add.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get category_add;

  /// No description provided for @category_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get category_edit;

  /// No description provided for @category_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get category_delete;

  /// No description provided for @category_addSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get category_addSuccess;

  /// No description provided for @category_updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get category_updateSuccess;

  /// No description provided for @category_deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get category_deleteSuccess;

  /// No description provided for @category_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get category_deleteConfirm;

  /// No description provided for @category_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get category_nameRequired;

  /// No description provided for @category_nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Category name must be at least 2 characters'**
  String get category_nameTooShort;

  /// No description provided for @category_nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Category name must be at most 50 characters'**
  String get category_nameTooLong;

  /// No description provided for @category_nameExists.
  ///
  /// In en, this message translates to:
  /// **'Category already exists'**
  String get category_nameExists;

  /// No description provided for @category_noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get category_noCategories;

  /// No description provided for @category_select.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get category_select;

  /// No description provided for @category_uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get category_uncategorized;

  /// No description provided for @supplier_title.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier_title;

  /// No description provided for @supplier_name.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplier_name;

  /// No description provided for @supplier_contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get supplier_contactPerson;

  /// No description provided for @supplier_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get supplier_phone;

  /// No description provided for @supplier_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get supplier_email;

  /// No description provided for @supplier_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get supplier_address;

  /// No description provided for @supplier_add.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get supplier_add;

  /// No description provided for @supplier_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get supplier_edit;

  /// No description provided for @supplier_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Supplier'**
  String get supplier_delete;

  /// No description provided for @supplier_addSuccess.
  ///
  /// In en, this message translates to:
  /// **'Supplier added successfully'**
  String get supplier_addSuccess;

  /// No description provided for @supplier_updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Supplier updated successfully'**
  String get supplier_updateSuccess;

  /// No description provided for @supplier_deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Supplier deleted successfully'**
  String get supplier_deleteSuccess;

  /// No description provided for @supplier_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this supplier?'**
  String get supplier_deleteConfirm;

  /// No description provided for @supplier_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Supplier name is required'**
  String get supplier_nameRequired;

  /// No description provided for @supplier_nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Supplier name must be at least 2 characters'**
  String get supplier_nameTooShort;

  /// No description provided for @supplier_nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Supplier name must be at most 100 characters'**
  String get supplier_nameTooLong;

  /// No description provided for @supplier_nameExists.
  ///
  /// In en, this message translates to:
  /// **'Supplier already exists'**
  String get supplier_nameExists;

  /// No description provided for @supplier_noSuppliers.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found'**
  String get supplier_noSuppliers;

  /// No description provided for @supplier_select.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get supplier_select;

  /// No description provided for @supplier_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get supplier_invalidEmail;

  /// No description provided for @supplier_invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone format'**
  String get supplier_invalidPhone;

  /// No description provided for @discount_title.
  ///
  /// In en, this message translates to:
  /// **'Discount Management'**
  String get discount_title;

  /// No description provided for @discount_promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get discount_promotions;

  /// No description provided for @discount_presets.
  ///
  /// In en, this message translates to:
  /// **'Discount Presets'**
  String get discount_presets;

  /// No description provided for @discount_categories.
  ///
  /// In en, this message translates to:
  /// **'Category Discounts'**
  String get discount_categories;

  /// No description provided for @discount_manageDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Discounts'**
  String get discount_manageDiscounts;

  /// No description provided for @discount_promotionName.
  ///
  /// In en, this message translates to:
  /// **'Promotion Name'**
  String get discount_promotionName;

  /// No description provided for @discount_promotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get discount_promotionDescription;

  /// No description provided for @discount_discountPercentage.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discount_discountPercentage;

  /// No description provided for @discount_startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get discount_startDate;

  /// No description provided for @discount_endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get discount_endDate;

  /// No description provided for @discount_isEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get discount_isEnabled;

  /// No description provided for @discount_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get discount_active;

  /// No description provided for @discount_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get discount_inactive;

  /// No description provided for @discount_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get discount_scheduled;

  /// No description provided for @discount_expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get discount_expired;

  /// No description provided for @discount_activePromotions.
  ///
  /// In en, this message translates to:
  /// **'Active Promotions'**
  String get discount_activePromotions;

  /// No description provided for @discount_noPromotions.
  ///
  /// In en, this message translates to:
  /// **'No promotions yet'**
  String get discount_noPromotions;

  /// No description provided for @discount_noPromotionsHint.
  ///
  /// In en, this message translates to:
  /// **'Press + to create a new promotion'**
  String get discount_noPromotionsHint;

  /// No description provided for @discount_noPresets.
  ///
  /// In en, this message translates to:
  /// **'No discount presets yet'**
  String get discount_noPresets;

  /// No description provided for @discount_noPresetsHint.
  ///
  /// In en, this message translates to:
  /// **'Press + to create a new discount preset'**
  String get discount_noPresetsHint;

  /// No description provided for @discount_noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get discount_noCategories;

  /// No description provided for @discount_noCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Create categories in Inventory to set discounts'**
  String get discount_noCategoriesHint;

  /// No description provided for @discount_addPromotion.
  ///
  /// In en, this message translates to:
  /// **'Add Promotion'**
  String get discount_addPromotion;

  /// No description provided for @discount_addPreset.
  ///
  /// In en, this message translates to:
  /// **'Add Preset'**
  String get discount_addPreset;

  /// No description provided for @discount_editPromotion.
  ///
  /// In en, this message translates to:
  /// **'Edit Promotion'**
  String get discount_editPromotion;

  /// No description provided for @discount_editPreset.
  ///
  /// In en, this message translates to:
  /// **'Edit Preset'**
  String get discount_editPreset;

  /// No description provided for @discount_deletePromotion.
  ///
  /// In en, this message translates to:
  /// **'Delete Promotion'**
  String get discount_deletePromotion;

  /// No description provided for @discount_deletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get discount_deletePreset;

  /// No description provided for @discount_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String discount_deleteConfirm(Object name);

  /// No description provided for @discount_deletePromotionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this promotion?'**
  String get discount_deletePromotionConfirm;

  /// No description provided for @discount_deletePresetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this discount preset?'**
  String get discount_deletePresetConfirm;

  /// No description provided for @discount_enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get discount_enable;

  /// No description provided for @discount_disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get discount_disable;

  /// No description provided for @discount_editCategoryDiscount.
  ///
  /// In en, this message translates to:
  /// **'Edit Category Discount'**
  String get discount_editCategoryDiscount;

  /// No description provided for @discount_categoryDiscount.
  ///
  /// In en, this message translates to:
  /// **'Category Discount'**
  String get discount_categoryDiscount;

  /// No description provided for @discount_noDiscount.
  ///
  /// In en, this message translates to:
  /// **'No discount'**
  String get discount_noDiscount;

  /// No description provided for @discount_discountApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount applied to all products in this category'**
  String get discount_discountApplied;

  /// No description provided for @discount_presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset Name'**
  String get discount_presetName;

  /// No description provided for @discount_presetDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get discount_presetDescription;

  /// No description provided for @discount_dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get discount_dateRange;

  /// No description provided for @discount_toggleStatus.
  ///
  /// In en, this message translates to:
  /// **'Toggle Status'**
  String get discount_toggleStatus;

  /// No description provided for @discount_createPromotion.
  ///
  /// In en, this message translates to:
  /// **'Create Promotion'**
  String get discount_createPromotion;

  /// No description provided for @discount_createPreset.
  ///
  /// In en, this message translates to:
  /// **'Create Preset'**
  String get discount_createPreset;

  /// No description provided for @discount_editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get discount_editCategory;

  /// No description provided for @discount_categoryHasDiscount.
  ///
  /// In en, this message translates to:
  /// **'This category has a discount'**
  String get discount_categoryHasDiscount;

  /// No description provided for @discount_selectPreset.
  ///
  /// In en, this message translates to:
  /// **'Select Preset'**
  String get discount_selectPreset;

  /// No description provided for @discount_flashSale.
  ///
  /// In en, this message translates to:
  /// **'Flash Sale'**
  String get discount_flashSale;

  /// No description provided for @discount_weekendSale.
  ///
  /// In en, this message translates to:
  /// **'Weekend Sale'**
  String get discount_weekendSale;

  /// No description provided for @discount_clearance.
  ///
  /// In en, this message translates to:
  /// **'Clearance'**
  String get discount_clearance;

  /// No description provided for @discount_memberDiscount.
  ///
  /// In en, this message translates to:
  /// **'Member Discount'**
  String get discount_memberDiscount;

  /// No description provided for @stock_title.
  ///
  /// In en, this message translates to:
  /// **'Stock Alert'**
  String get stock_title;

  /// No description provided for @stock_lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get stock_lowStock;

  /// No description provided for @stock_outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get stock_outOfStock;

  /// No description provided for @stock_lowStockCount.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Items'**
  String get stock_lowStockCount;

  /// No description provided for @stock_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get stock_viewAll;

  /// No description provided for @stock_noLowStock.
  ///
  /// In en, this message translates to:
  /// **'All stock levels are adequate'**
  String get stock_noLowStock;

  /// No description provided for @stock_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get stock_products;

  /// No description provided for @stock_stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stock_stockLevel;

  /// No description provided for @stock_restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get stock_restock;

  /// No description provided for @stock_threshold.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Threshold'**
  String get stock_threshold;

  /// No description provided for @stock_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Dashboard'**
  String get stock_dashboard;

  /// No description provided for @stock_adequate.
  ///
  /// In en, this message translates to:
  /// **'All Stock Levels Adequate'**
  String get stock_adequate;

  /// No description provided for @stock_noLow.
  ///
  /// In en, this message translates to:
  /// **'No low stock items found'**
  String get stock_noLow;

  /// No description provided for @stock_out.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get stock_out;

  /// No description provided for @stock_low.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get stock_low;

  /// No description provided for @stock_adjustmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Adjustment'**
  String get stock_adjustmentTitle;

  /// No description provided for @stock_adjustmentType.
  ///
  /// In en, this message translates to:
  /// **'Adjustment Type'**
  String get stock_adjustmentType;

  /// No description provided for @stock_setStock.
  ///
  /// In en, this message translates to:
  /// **'Set Stock'**
  String get stock_setStock;

  /// No description provided for @stock_purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get stock_purchase;

  /// No description provided for @stock_sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get stock_sale;

  /// No description provided for @stock_damage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get stock_damage;

  /// No description provided for @stock_itemReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get stock_itemReturn;

  /// No description provided for @stock_manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get stock_manual;

  /// No description provided for @stock_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get stock_other;

  /// No description provided for @stock_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get stock_quantity;

  /// No description provided for @stock_quantityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get stock_quantityHint;

  /// No description provided for @stock_invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get stock_invalidNumber;

  /// No description provided for @stock_quantityMin.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get stock_quantityMin;

  /// No description provided for @stock_quantityMax.
  ///
  /// In en, this message translates to:
  /// **'Quantity too large'**
  String get stock_quantityMax;

  /// No description provided for @stock_confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get stock_confirmAction;

  /// No description provided for @stock_removeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Remove {quantity} items from stock?'**
  String stock_removeQuantity(Object quantity);

  /// No description provided for @stock_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get stock_cancel;

  /// No description provided for @stock_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get stock_confirm;

  /// No description provided for @stock_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get stock_processing;

  /// No description provided for @stock_setStockAction.
  ///
  /// In en, this message translates to:
  /// **'Set Stock'**
  String get stock_setStockAction;

  /// No description provided for @stock_removeStock.
  ///
  /// In en, this message translates to:
  /// **'Remove Stock'**
  String get stock_removeStock;

  /// No description provided for @stock_addStock.
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get stock_addStock;

  /// No description provided for @stock_history.
  ///
  /// In en, this message translates to:
  /// **'Stock History'**
  String get stock_history;

  /// No description provided for @stock_noAdjustments.
  ///
  /// In en, this message translates to:
  /// **'No stock adjustments recorded'**
  String get stock_noAdjustments;

  /// No description provided for @stock_currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get stock_currentStock;

  /// No description provided for @stock_sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get stock_sellingPrice;

  /// No description provided for @stock_costPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get stock_costPriceLabel;

  /// No description provided for @stock_stockLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stock_stockLevelLabel;

  /// No description provided for @stock_suggestionAdd.
  ///
  /// In en, this message translates to:
  /// **'Suggestion: Add {count} units to reach safe stock'**
  String stock_suggestionAdd(Object count);

  /// No description provided for @stock_editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get stock_editProduct;

  /// No description provided for @stock_manageInventory.
  ///
  /// In en, this message translates to:
  /// **'Manage Inventory'**
  String get stock_manageInventory;

  /// No description provided for @stock_outOfStockShort.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get stock_outOfStockShort;

  /// No description provided for @report_title.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get report_title;

  /// No description provided for @report_period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get report_period;

  /// No description provided for @report_startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get report_startDate;

  /// No description provided for @report_endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get report_endDate;

  /// No description provided for @report_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get report_generate;

  /// No description provided for @report_dailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get report_dailySales;

  /// No description provided for @report_topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get report_topProducts;

  /// No description provided for @report_product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get report_product;

  /// No description provided for @report_quantitySold.
  ///
  /// In en, this message translates to:
  /// **'Qty Sold'**
  String get report_quantitySold;

  /// No description provided for @report_revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get report_revenue;

  /// No description provided for @report_profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get report_profit;

  /// No description provided for @report_trend.
  ///
  /// In en, this message translates to:
  /// **'Sales Trend'**
  String get report_trend;

  /// No description provided for @report_comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get report_comparison;

  /// No description provided for @report_exportCSV.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get report_exportCSV;

  /// No description provided for @report_noData.
  ///
  /// In en, this message translates to:
  /// **'No report data available'**
  String get report_noData;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get common_update;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get common_filter;

  /// No description provided for @common_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get common_sort;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @common_loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get common_loadMore;

  /// No description provided for @common_noData.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get common_noData;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get common_warning;

  /// No description provided for @common_info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get common_info;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get common_previous;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get common_undo;

  /// No description provided for @common_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get common_copy;

  /// No description provided for @common_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// No description provided for @common_print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get common_print;

  /// No description provided for @common_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get common_download;

  /// No description provided for @common_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get common_upload;

  /// No description provided for @common_cannotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Cannot open dialer'**
  String get common_cannotOpenDialer;

  /// No description provided for @common_cannotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Cannot open email app'**
  String get common_cannotOpenEmail;

  /// No description provided for @common_supplierSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Supplier saved successfully'**
  String get common_supplierSaveSuccess;

  /// No description provided for @common_supplierSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save supplier'**
  String get common_supplierSaveFailed;

  /// No description provided for @common_supplierDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Supplier deleted successfully'**
  String get common_supplierDeleteSuccess;

  /// No description provided for @common_supplierDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete supplier'**
  String get common_supplierDeleteFailed;

  /// No description provided for @common_supplierNotFound.
  ///
  /// In en, this message translates to:
  /// **'Supplier \"{query}\" not found'**
  String common_supplierNotFound(Object query);

  /// No description provided for @common_contactPersonOptional.
  ///
  /// In en, this message translates to:
  /// **'Contact Person (Optional)'**
  String get common_contactPersonOptional;

  /// No description provided for @common_phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (Optional)'**
  String get common_phoneOptional;

  /// No description provided for @common_emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get common_emailOptional;

  /// No description provided for @common_addressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (Optional)'**
  String get common_addressOptional;

  /// No description provided for @common_categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get common_categoryNameRequired;

  /// No description provided for @common_supplierNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Supplier name is required'**
  String get common_supplierNameRequired;

  /// No description provided for @common_supplierNameMin.
  ///
  /// In en, this message translates to:
  /// **'Supplier name must be at least 2 characters'**
  String get common_supplierNameMin;

  /// No description provided for @common_noSupplier.
  ///
  /// In en, this message translates to:
  /// **'No Supplier'**
  String get common_noSupplier;

  /// No description provided for @common_addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get common_addNewCategory;

  /// No description provided for @common_addNewSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add New Supplier'**
  String get common_addNewSupplier;

  /// No description provided for @common_productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get common_productName;

  /// No description provided for @common_priceRp.
  ///
  /// In en, this message translates to:
  /// **'Price (Rp)'**
  String get common_priceRp;

  /// No description provided for @common_stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get common_stockQuantity;

  /// No description provided for @common_costPriceRp.
  ///
  /// In en, this message translates to:
  /// **'Cost Price (Rp)'**
  String get common_costPriceRp;

  /// No description provided for @common_barcodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Barcode (Optional)'**
  String get common_barcodeOptional;

  /// No description provided for @common_editProductMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit product: {name}'**
  String common_editProductMessage(Object name);

  /// No description provided for @common_deleteVariant.
  ///
  /// In en, this message translates to:
  /// **'Delete Variant'**
  String get common_deleteVariant;

  /// No description provided for @common_variant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get common_variant;

  /// No description provided for @common_totalStock.
  ///
  /// In en, this message translates to:
  /// **'Total Stock'**
  String get common_totalStock;

  /// No description provided for @common_stockCount.
  ///
  /// In en, this message translates to:
  /// **'Stock: {count}'**
  String common_stockCount(Object count);

  /// No description provided for @common_outOfStockShort.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get common_outOfStockShort;

  /// No description provided for @common_lowStockCount.
  ///
  /// In en, this message translates to:
  /// **'Low Stock: {count}'**
  String common_lowStockCount(Object count);

  /// No description provided for @common_skuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU: {sku}'**
  String common_skuLabel(Object sku);

  /// No description provided for @common_barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode: {barcode}'**
  String common_barcodeLabel(Object barcode);

  /// No description provided for @common_addVariant.
  ///
  /// In en, this message translates to:
  /// **'Add Variant'**
  String get common_addVariant;

  /// No description provided for @common_addVariantHint.
  ///
  /// In en, this message translates to:
  /// **'Add a variant for this product'**
  String get common_addVariantHint;

  /// No description provided for @common_emptyStateGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started by adding your first item'**
  String get common_emptyStateGetStarted;

  /// No description provided for @common_newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get common_newCategory;

  /// No description provided for @common_newSupplier.
  ///
  /// In en, this message translates to:
  /// **'New Supplier'**
  String get common_newSupplier;

  /// No description provided for @common_switchToGrid.
  ///
  /// In en, this message translates to:
  /// **'Switch to Grid'**
  String get common_switchToGrid;

  /// No description provided for @common_switchToList.
  ///
  /// In en, this message translates to:
  /// **'Switch to List'**
  String get common_switchToList;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @enable_tax.
  ///
  /// In en, this message translates to:
  /// **'Enable Tax'**
  String get enable_tax;

  /// No description provided for @reset_settings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get reset_settings;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get delete_all_data;

  /// No description provided for @manage_data.
  ///
  /// In en, this message translates to:
  /// **'Manage Data'**
  String get manage_data;

  /// No description provided for @export_data.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get export_data;

  /// No description provided for @full_backup_description.
  ///
  /// In en, this message translates to:
  /// **'Full backup of all data'**
  String get full_backup_description;

  /// No description provided for @incremental_backup.
  ///
  /// In en, this message translates to:
  /// **'Incremental'**
  String get incremental_backup;

  /// No description provided for @printer_settings.
  ///
  /// In en, this message translates to:
  /// **'Printer Settings'**
  String get printer_settings;

  /// No description provided for @bluetooth_thermal_printer.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth thermal printer'**
  String get bluetooth_thermal_printer;

  /// No description provided for @printer_connected.
  ///
  /// In en, this message translates to:
  /// **'Printer Connected'**
  String get printer_connected;

  /// No description provided for @no_printer_connected.
  ///
  /// In en, this message translates to:
  /// **'No Printer Connected'**
  String get no_printer_connected;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @paper_size.
  ///
  /// In en, this message translates to:
  /// **'Paper Size'**
  String get paper_size;

  /// No description provided for @available_printers.
  ///
  /// In en, this message translates to:
  /// **'Available Printers'**
  String get available_printers;

  /// No description provided for @no_printers_found.
  ///
  /// In en, this message translates to:
  /// **'No Printers Found'**
  String get no_printers_found;

  /// No description provided for @bluetooth_pairing_hint.
  ///
  /// In en, this message translates to:
  /// **'Make sure Bluetooth is active and printer is paired'**
  String get bluetooth_pairing_hint;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @test_print.
  ///
  /// In en, this message translates to:
  /// **'Test Print'**
  String get test_print;

  /// No description provided for @how_to_use.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get how_to_use;

  /// No description provided for @step1_bluetooth.
  ///
  /// In en, this message translates to:
  /// **'1. Make sure Bluetooth is active on the device'**
  String get step1_bluetooth;

  /// No description provided for @step2_pair_printer.
  ///
  /// In en, this message translates to:
  /// **'2. Pair thermal printer in Bluetooth settings'**
  String get step2_pair_printer;

  /// No description provided for @step3_select_printer.
  ///
  /// In en, this message translates to:
  /// **'3. Select printer from the list above'**
  String get step3_select_printer;

  /// No description provided for @step4_test_print.
  ///
  /// In en, this message translates to:
  /// **'4. Tap Test Print to try'**
  String get step4_test_print;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @printer_connect_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to printer'**
  String get printer_connect_failed;

  /// No description provided for @printer_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Printer disconnected'**
  String get printer_disconnected;

  /// No description provided for @test_print_success.
  ///
  /// In en, this message translates to:
  /// **'Test Print successful'**
  String get test_print_success;

  /// No description provided for @test_print_failed.
  ///
  /// In en, this message translates to:
  /// **'Test Print failed: {error}'**
  String test_print_failed(Object error);

  /// No description provided for @merge_description.
  ///
  /// In en, this message translates to:
  /// **'Keep existing data and add missing items'**
  String get merge_description;

  /// No description provided for @replace_description.
  ///
  /// In en, this message translates to:
  /// **'Wipe current data and use backup instead'**
  String get replace_description;

  /// No description provided for @category_semua.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get category_semua;

  /// No description provided for @product_manual_adjustment.
  ///
  /// In en, this message translates to:
  /// **'Manual adjustment'**
  String get product_manual_adjustment;

  /// No description provided for @product_stock_count.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String product_stock_count(Object count);

  /// No description provided for @product_costPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Cost price must be greater than or equal to 0'**
  String get product_costPriceInvalid;

  /// No description provided for @product_name_label.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get product_name_label;

  /// No description provided for @product_name_required.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get product_name_required;

  /// No description provided for @product_sell_price.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get product_sell_price;

  /// No description provided for @product_sell_price_required.
  ///
  /// In en, this message translates to:
  /// **'Selling price is required'**
  String get product_sell_price_required;

  /// No description provided for @product_cost_price.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get product_cost_price;

  /// No description provided for @product_stock_label.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get product_stock_label;

  /// No description provided for @product_stock_required.
  ///
  /// In en, this message translates to:
  /// **'Stock is required'**
  String get product_stock_required;

  /// No description provided for @product_invalid_number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get product_invalid_number;

  /// No description provided for @product_barcode_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional - type or scan'**
  String get product_barcode_hint;

  /// No description provided for @product_scan_barcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get product_scan_barcode;

  /// No description provided for @product_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get product_optional;

  /// No description provided for @product_no_valid_products.
  ///
  /// In en, this message translates to:
  /// **'No valid products found in file'**
  String get product_no_valid_products;

  /// No description provided for @product_preview.
  ///
  /// In en, this message translates to:
  /// **'Product Preview'**
  String get product_preview;

  /// No description provided for @product_import_success.
  ///
  /// In en, this message translates to:
  /// **'Products imported successfully'**
  String get product_import_success;

  /// No description provided for @product_import_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import products: {error}'**
  String product_import_failed(Object error);

  /// No description provided for @product_select_file.
  ///
  /// In en, this message translates to:
  /// **'Select CSV File'**
  String get product_select_file;

  /// No description provided for @product_view_guide.
  ///
  /// In en, this message translates to:
  /// **'View Format Guide'**
  String get product_view_guide;

  /// No description provided for @product_format_guide.
  ///
  /// In en, this message translates to:
  /// **'Format Guide'**
  String get product_format_guide;

  /// No description provided for @product_csv_columns_required.
  ///
  /// In en, this message translates to:
  /// **'CSV file must have the following columns:'**
  String get product_csv_columns_required;

  /// No description provided for @product_required_columns.
  ///
  /// In en, this message translates to:
  /// **'Required columns (must exist):'**
  String get product_required_columns;

  /// No description provided for @product_optional_columns.
  ///
  /// In en, this message translates to:
  /// **'Optional columns (can be empty):'**
  String get product_optional_columns;

  /// No description provided for @product_format_example.
  ///
  /// In en, this message translates to:
  /// **'Example format:'**
  String get product_format_example;

  /// No description provided for @product_csv_file_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a CSV file to import:'**
  String get product_csv_file_hint;

  /// No description provided for @product_ready_to_import.
  ///
  /// In en, this message translates to:
  /// **'Ready to import'**
  String get product_ready_to_import;

  /// No description provided for @product_found_with_errors.
  ///
  /// In en, this message translates to:
  /// **'Found with errors'**
  String get product_found_with_errors;

  /// No description provided for @product_valid_count.
  ///
  /// In en, this message translates to:
  /// **'{valid} of {total} products valid'**
  String product_valid_count(Object total, Object valid);

  /// No description provided for @product_validation_errors.
  ///
  /// In en, this message translates to:
  /// **'Validation errors:'**
  String get product_validation_errors;

  /// No description provided for @product_more_errors.
  ///
  /// In en, this message translates to:
  /// **'...and {count} more errors'**
  String product_more_errors(Object count);

  /// No description provided for @product_more_products.
  ///
  /// In en, this message translates to:
  /// **'...and {count} more products'**
  String product_more_products(Object count);

  /// No description provided for @product_edit_product.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get product_edit_product;

  /// No description provided for @product_add_product.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get product_add_product;

  /// No description provided for @product_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get product_save;

  /// No description provided for @product_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get product_cancel;

  /// No description provided for @product_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get product_update;

  /// No description provided for @product_import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get product_import;

  /// No description provided for @product_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get product_close;

  /// No description provided for @product_editing_product.
  ///
  /// In en, this message translates to:
  /// **'Edit product: {name}'**
  String product_editing_product(Object name);

  /// No description provided for @product_import_title.
  ///
  /// In en, this message translates to:
  /// **'Import Products from CSV'**
  String get product_import_title;

  /// No description provided for @product_processing_file.
  ///
  /// In en, this message translates to:
  /// **'Processing file...'**
  String get product_processing_file;

  /// No description provided for @product_importing_products.
  ///
  /// In en, this message translates to:
  /// **'Importing products...'**
  String get product_importing_products;

  /// No description provided for @product_file_pick_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select file: {error}'**
  String product_file_pick_failed(Object error);

  /// No description provided for @product_file_parse_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process file: {error}'**
  String product_file_parse_failed(Object error);

  /// No description provided for @product_csv_format.
  ///
  /// In en, this message translates to:
  /// **'CSV Format'**
  String get product_csv_format;

  /// No description provided for @product_no_category.
  ///
  /// In en, this message translates to:
  /// **'No Category'**
  String get product_no_category;

  /// No description provided for @product_add_new_category.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get product_add_new_category;

  /// No description provided for @product_add_new_supplier.
  ///
  /// In en, this message translates to:
  /// **'Add New Supplier'**
  String get product_add_new_supplier;

  /// No description provided for @product_supplier_label.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get product_supplier_label;

  /// No description provided for @product_barcode_optional.
  ///
  /// In en, this message translates to:
  /// **'Barcode (Optional)'**
  String get product_barcode_optional;

  /// No description provided for @product_low_stock_items.
  ///
  /// In en, this message translates to:
  /// **'{count} low stock items'**
  String product_low_stock_items(Object count);

  /// No description provided for @product_out_of_stock_items.
  ///
  /// In en, this message translates to:
  /// **'{count} out of stock items'**
  String product_out_of_stock_items(Object count);

  /// No description provided for @backup_type.
  ///
  /// In en, this message translates to:
  /// **'Backup Type'**
  String get backup_type;

  /// No description provided for @backup_data_to_backup.
  ///
  /// In en, this message translates to:
  /// **'Data to Backup'**
  String get backup_data_to_backup;

  /// No description provided for @backup_storage_location.
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get backup_storage_location;

  /// No description provided for @backup_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get backup_create_title;

  /// No description provided for @backup_complete.
  ///
  /// In en, this message translates to:
  /// **'Backup Complete'**
  String get backup_complete;

  /// No description provided for @backup_failed.
  ///
  /// In en, this message translates to:
  /// **'Backup Failed'**
  String get backup_failed;

  /// No description provided for @backup_restore_title.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get backup_restore_title;

  /// No description provided for @backup_choose_restore_mode.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to restore your data:'**
  String get backup_choose_restore_mode;

  /// No description provided for @backup_merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get backup_merge;

  /// No description provided for @backup_merge_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep existing data and add missing items'**
  String get backup_merge_desc;

  /// No description provided for @backup_replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backup_replace;

  /// No description provided for @backup_replace_desc.
  ///
  /// In en, this message translates to:
  /// **'Wipe current data and use backup instead'**
  String get backup_replace_desc;

  /// No description provided for @backup_restore_now.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get backup_restore_now;

  /// No description provided for @backup_restored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get backup_restored;

  /// No description provided for @backup_restore_failed.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get backup_restore_failed;

  /// No description provided for @backup_schedule_title.
  ///
  /// In en, this message translates to:
  /// **'Schedule Backup'**
  String get backup_schedule_title;

  /// No description provided for @backup_schedule_name.
  ///
  /// In en, this message translates to:
  /// **'Schedule Name'**
  String get backup_schedule_name;

  /// No description provided for @backup_schedule_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Nightly Backup'**
  String get backup_schedule_name_hint;

  /// No description provided for @backup_frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get backup_frequency;

  /// No description provided for @backup_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get backup_daily;

  /// No description provided for @backup_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get backup_weekly;

  /// No description provided for @backup_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get backup_monthly;

  /// No description provided for @backup_day_of_month.
  ///
  /// In en, this message translates to:
  /// **'Day of Month'**
  String get backup_day_of_month;

  /// No description provided for @backup_selected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get backup_selected;

  /// No description provided for @backup_restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backup_restore;

  /// No description provided for @backup_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get backup_delete;

  /// No description provided for @backup_full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get backup_full;

  /// No description provided for @backup_incremental.
  ///
  /// In en, this message translates to:
  /// **'Incremental'**
  String get backup_incremental;

  /// No description provided for @backup_local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get backup_local;

  /// No description provided for @backup_drive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get backup_drive;

  /// No description provided for @backup_storage_status.
  ///
  /// In en, this message translates to:
  /// **'STORAGE STATUS'**
  String get backup_storage_status;

  /// No description provided for @backup_total_size.
  ///
  /// In en, this message translates to:
  /// **'Total Size'**
  String get backup_total_size;

  /// No description provided for @backup_local_count.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get backup_local_count;

  /// No description provided for @backup_drive_count.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get backup_drive_count;

  /// No description provided for @backup_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get backup_refresh;

  /// No description provided for @backup_details.
  ///
  /// In en, this message translates to:
  /// **'Storage Details'**
  String get backup_details;

  /// No description provided for @backup_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get backup_close;

  /// No description provided for @backup_no_backups.
  ///
  /// In en, this message translates to:
  /// **'No {type} backups found'**
  String backup_no_backups(Object type);

  /// No description provided for @printer_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Printer Settings'**
  String get printer_settings_title;

  /// No description provided for @printer_not_connected.
  ///
  /// In en, this message translates to:
  /// **'No Printer Connected'**
  String get printer_not_connected;

  /// No description provided for @printer_disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get printer_disconnect;

  /// No description provided for @printer_paper_size.
  ///
  /// In en, this message translates to:
  /// **'Paper Size'**
  String get printer_paper_size;

  /// No description provided for @printer_available.
  ///
  /// In en, this message translates to:
  /// **'Available Printers'**
  String get printer_available;

  /// No description provided for @printer_no_printers.
  ///
  /// In en, this message translates to:
  /// **'No Printers Found'**
  String get printer_no_printers;

  /// No description provided for @printer_pairing_hint.
  ///
  /// In en, this message translates to:
  /// **'Make sure Bluetooth is active and printer is paired'**
  String get printer_pairing_hint;

  /// No description provided for @printer_rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get printer_rescan;

  /// No description provided for @printer_test_print.
  ///
  /// In en, this message translates to:
  /// **'Test Print'**
  String get printer_test_print;

  /// No description provided for @printer_how_to_use.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get printer_how_to_use;

  /// No description provided for @printer_step1.
  ///
  /// In en, this message translates to:
  /// **'1. Make sure Bluetooth is active on the device'**
  String get printer_step1;

  /// No description provided for @printer_step2.
  ///
  /// In en, this message translates to:
  /// **'2. Pair thermal printer in Bluetooth settings'**
  String get printer_step2;

  /// No description provided for @printer_step3.
  ///
  /// In en, this message translates to:
  /// **'3. Select printer from the list above'**
  String get printer_step3;

  /// No description provided for @printer_step4.
  ///
  /// In en, this message translates to:
  /// **'4. Tap Test Print to try'**
  String get printer_step4;

  /// No description provided for @printer_connected_status.
  ///
  /// In en, this message translates to:
  /// **'Printer Connected'**
  String get printer_connected_status;

  /// No description provided for @printer_not_connected_status.
  ///
  /// In en, this message translates to:
  /// **'No Printer Connected'**
  String get printer_not_connected_status;

  /// No description provided for @printer_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get printer_connect;

  /// No description provided for @printer_test_success.
  ///
  /// In en, this message translates to:
  /// **'Test Print successful'**
  String get printer_test_success;

  /// No description provided for @printer_test_failed.
  ///
  /// In en, this message translates to:
  /// **'Test Print failed'**
  String get printer_test_failed;

  /// No description provided for @backup_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get backup_start;

  /// No description provided for @variant_title.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variant_title;

  /// No description provided for @variant_add.
  ///
  /// In en, this message translates to:
  /// **'Add Variant'**
  String get variant_add;

  /// No description provided for @variant_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Variant'**
  String get variant_edit;

  /// No description provided for @variant_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Variant'**
  String get variant_delete;

  /// No description provided for @variant_noVariants.
  ///
  /// In en, this message translates to:
  /// **'No variants yet'**
  String get variant_noVariants;

  /// No description provided for @common_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get common_delete_confirm;

  /// No description provided for @common_no_data.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get common_no_data;

  /// No description provided for @empty_state_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started by adding your first item'**
  String get empty_state_get_started;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @empty_state_no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get empty_state_no_results;

  /// No description provided for @empty_state_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get empty_state_try_again;

  /// No description provided for @backup_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing backup...'**
  String get backup_preparing;

  /// No description provided for @backup_collecting.
  ///
  /// In en, this message translates to:
  /// **'Collecting data...'**
  String get backup_collecting;

  /// No description provided for @backup_compressing.
  ///
  /// In en, this message translates to:
  /// **'Compressing data...'**
  String get backup_compressing;

  /// No description provided for @backup_uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading to cloud...'**
  String get backup_uploading;

  /// No description provided for @backup_downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading backup...'**
  String get backup_downloading;

  /// No description provided for @backup_extracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting data...'**
  String get backup_extracting;

  /// No description provided for @backup_restoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring data...'**
  String get backup_restoring;

  /// No description provided for @backup_finalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing...'**
  String get backup_finalizing;

  /// No description provided for @kpi_today_summary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get kpi_today_summary;

  /// No description provided for @kpi_revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get kpi_revenue;

  /// No description provided for @kpi_transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get kpi_transactions;

  /// No description provided for @kpi_items_sold.
  ///
  /// In en, this message translates to:
  /// **'Items Sold'**
  String get kpi_items_sold;

  /// No description provided for @image_picker_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get image_picker_delete;

  /// No description provided for @image_picker_failed_camera.
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo: {error}'**
  String image_picker_failed_camera(Object error);

  /// No description provided for @image_picker_failed_gallery.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String image_picker_failed_gallery(Object error);

  /// No description provided for @image_picker_title.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get image_picker_title;

  /// No description provided for @image_picker_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get image_picker_camera;

  /// No description provided for @image_picker_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get image_picker_gallery;

  /// No description provided for @quick_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get quick_favorites;

  /// No description provided for @quick_held_orders.
  ///
  /// In en, this message translates to:
  /// **'Held Orders'**
  String get quick_held_orders;

  /// No description provided for @quick_quick_add.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quick_quick_add;

  /// No description provided for @quick_quick_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quick Quantity'**
  String get quick_quick_quantity;

  /// No description provided for @quick_today_summary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get quick_today_summary;

  /// No description provided for @quick_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get quick_refresh;

  /// No description provided for @common_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get common_archive;

  /// No description provided for @common_favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get common_favorite;

  /// No description provided for @validator_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validator_required;

  /// No description provided for @validator_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validator_email;

  /// No description provided for @validator_min_length.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min} characters'**
  String validator_min_length(Object min);

  /// No description provided for @validator_max_length.
  ///
  /// In en, this message translates to:
  /// **'Must be at most {max} characters'**
  String validator_max_length(Object max);

  /// No description provided for @validator_invalid_format.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get validator_invalid_format;

  /// No description provided for @validator_positive_number.
  ///
  /// In en, this message translates to:
  /// **'Must be a positive number'**
  String get validator_positive_number;

  /// No description provided for @validator_non_negative.
  ///
  /// In en, this message translates to:
  /// **'Must be zero or greater'**
  String get validator_non_negative;

  /// No description provided for @validator_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validator_phone;

  /// No description provided for @held_order_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get held_order_continue;

  /// No description provided for @held_order_current_cart.
  ///
  /// In en, this message translates to:
  /// **'Current Cart'**
  String get held_order_current_cart;

  /// No description provided for @held_order_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Order'**
  String get held_order_delete;

  /// No description provided for @held_order_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this held order?'**
  String get held_order_delete_confirm;

  /// No description provided for @held_order_hold.
  ///
  /// In en, this message translates to:
  /// **'Hold Order'**
  String get held_order_hold;

  /// No description provided for @held_order_no_orders.
  ///
  /// In en, this message translates to:
  /// **'No held orders'**
  String get held_order_no_orders;

  /// No description provided for @held_order_saved.
  ///
  /// In en, this message translates to:
  /// **'Order saved'**
  String get held_order_saved;

  /// No description provided for @held_orders_title.
  ///
  /// In en, this message translates to:
  /// **'Held Orders'**
  String get held_orders_title;

  /// No description provided for @nav_add_product.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get nav_add_product;

  /// No description provided for @nav_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get nav_close;

  /// No description provided for @nav_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get nav_history;

  /// No description provided for @nav_inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get nav_inventory;

  /// No description provided for @nav_pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get nav_pos;

  /// No description provided for @nav_product_found.
  ///
  /// In en, this message translates to:
  /// **'Product found'**
  String get nav_product_found;

  /// No description provided for @nav_product_not_found.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get nav_product_not_found;

  /// No description provided for @nav_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get nav_reports;

  /// No description provided for @nav_scan_qr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get nav_scan_qr;

  /// No description provided for @nav_view_inventory.
  ///
  /// In en, this message translates to:
  /// **'View Inventory'**
  String get nav_view_inventory;

  /// No description provided for @nav_scanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get nav_scanned;

  /// No description provided for @cart_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add products to get started'**
  String get cart_empty_subtitle;

  /// No description provided for @cart_keranjang.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart_keranjang;

  /// No description provided for @cart_removed_from_cart.
  ///
  /// In en, this message translates to:
  /// **'Removed from cart'**
  String get cart_removed_from_cart;

  /// No description provided for @cart_total_discount.
  ///
  /// In en, this message translates to:
  /// **'Total Discount'**
  String get cart_total_discount;

  /// No description provided for @cart_total_items.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get cart_total_items;

  /// No description provided for @checkout_success_check.
  ///
  /// In en, this message translates to:
  /// **'Checkout successful! Check your receipt.'**
  String get checkout_success_check;

  /// No description provided for @checkout_error_discount.
  ///
  /// In en, this message translates to:
  /// **'Invalid discount value'**
  String get checkout_error_discount;

  /// No description provided for @common_batal.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_batal;

  /// No description provided for @common_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get common_copied;

  /// No description provided for @product_no_products.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get product_no_products;

  /// No description provided for @receipt_print_success.
  ///
  /// In en, this message translates to:
  /// **'Receipt printed successfully'**
  String get receipt_print_success;

  /// No description provided for @sales_analytics_title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get sales_analytics_title;

  /// No description provided for @sales_cashier_colon.
  ///
  /// In en, this message translates to:
  /// **'Cashier: '**
  String get sales_cashier_colon;

  /// No description provided for @sales_category_colon.
  ///
  /// In en, this message translates to:
  /// **'Category: '**
  String get sales_category_colon;

  /// No description provided for @sales_cetak_struk.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get sales_cetak_struk;

  /// No description provided for @sales_clear_date_filter.
  ///
  /// In en, this message translates to:
  /// **'Clear Date Filter'**
  String get sales_clear_date_filter;

  /// No description provided for @sales_failed_create_receipt.
  ///
  /// In en, this message translates to:
  /// **'Failed to create receipt'**
  String get sales_failed_create_receipt;

  /// No description provided for @sales_filter_by_date.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get sales_filter_by_date;

  /// No description provided for @sales_filter_by_payment.
  ///
  /// In en, this message translates to:
  /// **'Filter by Payment Method'**
  String get sales_filter_by_payment;

  /// No description provided for @sales_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get sales_from;

  /// No description provided for @sales_laporan.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get sales_laporan;

  /// No description provided for @sales_loading_cashiers.
  ///
  /// In en, this message translates to:
  /// **'Loading cashiers...'**
  String get sales_loading_cashiers;

  /// No description provided for @sales_loading_categories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get sales_loading_categories;

  /// No description provided for @sales_no_data_found.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get sales_no_data_found;

  /// No description provided for @sales_no_transactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get sales_no_transactions;

  /// No description provided for @sales_purchase_items.
  ///
  /// In en, this message translates to:
  /// **'Items Purchased'**
  String get sales_purchase_items;

  /// No description provided for @sales_refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get sales_refund;

  /// No description provided for @sales_refund_available_30_days.
  ///
  /// In en, this message translates to:
  /// **'Refund available within 30 days'**
  String get sales_refund_available_30_days;

  /// No description provided for @sales_refund_failed_msg.
  ///
  /// In en, this message translates to:
  /// **'Refund failed'**
  String get sales_refund_failed_msg;

  /// No description provided for @sales_refund_success.
  ///
  /// In en, this message translates to:
  /// **'Refund successful'**
  String get sales_refund_success;

  /// No description provided for @sales_riwayat.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sales_riwayat;

  /// No description provided for @sales_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get sales_to;

  /// No description provided for @sales_total_items_sold.
  ///
  /// In en, this message translates to:
  /// **'Total Items Sold'**
  String get sales_total_items_sold;

  /// No description provided for @sales_total_profit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get sales_total_profit;

  /// No description provided for @sales_total_revenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get sales_total_revenue;

  /// No description provided for @sales_total_transactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get sales_total_transactions;

  /// No description provided for @sales_transaction_refunded_badge.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get sales_transaction_refunded_badge;

  /// No description provided for @sales_tutup.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get sales_tutup;

  /// No description provided for @scan_order_held.
  ///
  /// In en, this message translates to:
  /// **'Order held successfully'**
  String get scan_order_held;

  /// No description provided for @shift_no_active.
  ///
  /// In en, this message translates to:
  /// **'No active shift'**
  String get shift_no_active;

  /// No description provided for @shift_open.
  ///
  /// In en, this message translates to:
  /// **'Open Shift'**
  String get shift_open;

  /// No description provided for @shift_open_title.
  ///
  /// In en, this message translates to:
  /// **'Open New Shift'**
  String get shift_open_title;

  /// No description provided for @sort_by_name.
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sort_by_name;

  /// No description provided for @sort_by_price.
  ///
  /// In en, this message translates to:
  /// **'Sort by Price'**
  String get sort_by_price;

  /// No description provided for @sort_by_stock.
  ///
  /// In en, this message translates to:
  /// **'Sort by Stock'**
  String get sort_by_stock;

  /// No description provided for @tax_label.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax_label;

  /// No description provided for @sales_top_products.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get sales_top_products;

  /// No description provided for @sales_peak_hours.
  ///
  /// In en, this message translates to:
  /// **'Peak Hours'**
  String get sales_peak_hours;

  /// No description provided for @expenses_title.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses_title;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
