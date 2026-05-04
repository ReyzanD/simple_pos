// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'POS & Inventory';

  @override
  String get pos => 'POS';

  @override
  String get inventory => 'Inventory';

  @override
  String get sales => 'Sales';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get display => 'Display';

  @override
  String get business_info => 'Business Info';

  @override
  String get business_name => 'Business Name';

  @override
  String get enter_business_name => 'Enter business name';

  @override
  String get address => 'Address';

  @override
  String get enter_address => 'Enter address';

  @override
  String get phone => 'Phone';

  @override
  String get enter_phone => 'Enter phone number';

  @override
  String get enter_email => 'Enter email';

  @override
  String get email => 'Email';

  @override
  String get not_filled => 'Not filled';

  @override
  String get tax => 'Tax';

  @override
  String get currency => 'Currency';

  @override
  String get currency_symbol => 'Currency Symbol';

  @override
  String get currency_code => 'Currency Code';

  @override
  String get receipt => 'Receipt';

  @override
  String get receipt_footer => 'Receipt Footer';

  @override
  String get footer_message_hint => 'Enter receipt footer message';

  @override
  String get enter_footer_message => 'Enter footer message';

  @override
  String get currency_symbol_hint => 'Example: Rp';

  @override
  String get currency_code_hint => 'Example: IDR';

  @override
  String get low_stock_threshold => 'Low Stock Threshold';

  @override
  String get data_management => 'Data Management';

  @override
  String get export_settings => 'Export Settings';

  @override
  String get save_settings => 'Save Settings to File';

  @override
  String get delete_all_data_desc => 'Delete all transaction and product data';

  @override
  String get export_data_backup => 'Export data and backup';

  @override
  String get save_settings_file => 'Save Settings to File';

  @override
  String get bluetooth_thermal => 'Bluetooth thermal printer';

  @override
  String get business_name_updated => 'Business name updated';

  @override
  String get address_updated => 'Address updated';

  @override
  String get phone_updated => 'Phone updated';

  @override
  String get email_updated => 'Email updated';

  @override
  String get currency_symbol_updated => 'Currency symbol updated';

  @override
  String get currency_code_updated => 'Currency code updated';

  @override
  String get receipt_footer_updated => 'Receipt footer updated';

  @override
  String get stock_threshold_updated => 'Stock threshold updated';

  @override
  String get settings_reset_default => 'Settings reset to default';

  @override
  String get all_data_deleted => 'All data deleted successfully';

  @override
  String get settings_exported => 'Settings exported';

  @override
  String get export_transactions_success =>
      'Transactions exported successfully';

  @override
  String export_failed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get export_products_success => 'Products exported successfully';

  @override
  String get export_expenses_success => 'Expenses exported successfully';

  @override
  String get backup_created_success => 'Backup created successfully';

  @override
  String get create_new_backup => 'Create New Backup';

  @override
  String get full_backup_desc => 'Full backup of all data';

  @override
  String get full_backup => 'Full Backup';

  @override
  String get incremental => 'Incremental';

  @override
  String get backup_and_restore => 'Backup & Restore';

  @override
  String get create_backup => 'Create Backup';

  @override
  String get schedule_backup => 'Schedule Backup';

  @override
  String get backup_scheduled => 'Backup Scheduled';

  @override
  String get backup_time => 'Backup Time';

  @override
  String get restore_backup => 'Restore Backup';

  @override
  String get choose_restore_mode => 'Choose how you want to restore your data:';

  @override
  String get merge => 'Merge';

  @override
  String get merge_desc => 'Keep existing data and add missing items';

  @override
  String get replace => 'Replace';

  @override
  String get replace_desc => 'Wipe current data and use backup instead';

  @override
  String get restore_now => 'Restore Now';

  @override
  String get restored => 'Restored';

  @override
  String get restore_failed => 'Restore Failed';

  @override
  String get delete_backup_title => 'Delete Backup';

  @override
  String get delete_backup_confirm => 'Delete Backup?';

  @override
  String delete_backup_warning(Object size) {
    return 'This will permanently delete the backup from $size. This cannot be undone.';
  }

  @override
  String get deleted => 'Deleted';

  @override
  String get delete_failed => 'Failed to delete';

  @override
  String get storage_details => 'Storage Details';

  @override
  String get storage_status => 'Storage Status';

  @override
  String get local_storage => 'Local Storage';

  @override
  String get google_drive => 'Google Drive';

  @override
  String get total_size => 'Total Size';

  @override
  String get local => 'Local';

  @override
  String get drive => 'Drive';

  @override
  String no_backups_found(Object type) {
    return 'No $type backups found';
  }

  @override
  String get retry => 'Retry';

  @override
  String get transactions => 'Transactions';

  @override
  String get products => 'Products';

  @override
  String get expenses => 'Expenses';

  @override
  String get full_backups => 'Full Backups';

  @override
  String get close => 'Close';

  @override
  String get schedule_name => 'Schedule Name';

  @override
  String get schedule_name_hint => 'e.g., Nightly Backup';

  @override
  String get frequency => 'Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get day_of_month => 'Day of Month';

  @override
  String get schedule => 'Schedule';

  @override
  String get confirm_delete_backup =>
      'Are you sure you want to delete this backup?';

  @override
  String get backup_deleted => 'Backup deleted';

  @override
  String get low_stock_hint => 'Enter quantity';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get reset_settings_title => 'Reset Settings';

  @override
  String get reset_confirm_message =>
      'Are you sure you want to reset all settings to default?';

  @override
  String get delete_all_data_warning =>
      'WARNING: This action will delete all data:';

  @override
  String get delete_all_data_items => '• All products and inventory';

  @override
  String get delete_all_data_transactions => '• All transaction history';

  @override
  String get delete_all_data_categories => '• All categories and suppliers';

  @override
  String get delete_all_data_cannot_undo => 'This action cannot be undone.';

  @override
  String get product_name => 'Product Name';

  @override
  String get product_price => 'Price';

  @override
  String get product_stock => 'Stock';

  @override
  String get product_category => 'Category';

  @override
  String get product_supplier => 'Supplier';

  @override
  String get product_barcode => 'Barcode';

  @override
  String get product_costPrice => 'Cost Price';

  @override
  String get product_profit => 'Profit';

  @override
  String get product_profitMargin => 'Profit Margin';

  @override
  String get product_discount => 'Discount';

  @override
  String get product_discountPercentage => 'Discount (%)';

  @override
  String get product_discountInvalid => 'Discount must be between 0-100';

  @override
  String get product_discountOptional => 'Leave empty if no discount';

  @override
  String get product_effectivePrice => 'Discounted Price';

  @override
  String get product_add => 'Add';

  @override
  String get product_edit => 'Edit Product';

  @override
  String get product_delete => 'Delete Product';

  @override
  String get product_addSuccess => 'Product added successfully';

  @override
  String get product_updateSuccess => 'Product updated successfully';

  @override
  String get product_deleteSuccess => 'Product deleted successfully';

  @override
  String get product_deleteConfirm =>
      'Are you sure you want to delete this product?';

  @override
  String get product_nameRequired => 'Product name is required';

  @override
  String get product_nameTooShort =>
      'Product name must be at least 3 characters';

  @override
  String get product_nameTooLong =>
      'Product name must be at most 100 characters';

  @override
  String get product_priceRequired => 'Price is required';

  @override
  String get product_priceInvalid => 'Price must be greater than 0';

  @override
  String get product_stockRequired => 'Stock is required';

  @override
  String get product_stockInvalid => 'Stock cannot be negative';

  @override
  String get product_outOfStock => 'Out of Stock';

  @override
  String get product_lowStock => 'Low Stock';

  @override
  String get product_search => 'Search products...';

  @override
  String get product_noProducts => 'No products found';

  @override
  String get product_selectCategory => 'Select Category';

  @override
  String get product_selectSupplier => 'Select Supplier';

  @override
  String get product_addCategory => 'Add Category';

  @override
  String get product_addSupplier => 'Add Supplier';

  @override
  String get product_tambah_produk => 'Add Product';

  @override
  String get product_semua => 'All';

  @override
  String get product_stok => 'Stock';

  @override
  String get product_adjust_stock => 'Adjust Stock';

  @override
  String get product_tambah_manual => 'Add Manual';

  @override
  String get product_manual_hint => 'Enter quantity manually';

  @override
  String get product_import_csv => 'Import CSV';

  @override
  String get product_import_hint => 'Import products from CSV file';

  @override
  String get product_stock_missing => 'Stock data missing';

  @override
  String get product_edit_produk => 'Edit Product';

  @override
  String get product_information => 'Product Information';

  @override
  String get product_nama => 'Product Name';

  @override
  String get product_harga => 'Price';

  @override
  String get product_harga_pokok => 'Cost Price';

  @override
  String get product_satuan => 'Unit';

  @override
  String get product_barcode_label => 'Barcode';

  @override
  String product_stock_low_badge(Object count) {
    return 'Low Stock: $count';
  }

  @override
  String get product_out_of_stock_badge => 'Out of Stock';

  @override
  String get product_stock_adjusted => 'Stock adjusted successfully';

  @override
  String get product_update_success_id => 'Product updated successfully';

  @override
  String get cart_title => 'Shopping Cart';

  @override
  String get cart_empty => 'Cart is empty';

  @override
  String get cart_addItem => 'Add to Cart';

  @override
  String get cart_removeItem => 'Remove from Cart';

  @override
  String get cart_quantity => 'Quantity';

  @override
  String get cart_updateQuantity => 'Update Quantity';

  @override
  String get cart_subtotal => 'Subtotal';

  @override
  String get cart_total => 'Total';

  @override
  String get cart_itemDiscount => 'Item Discount';

  @override
  String get cart_totalDiscount => 'Total Discount';

  @override
  String get cart_youSave => 'You save';

  @override
  String get cart_checkout => 'Checkout';

  @override
  String get cart_clear => 'Clear Cart';

  @override
  String get checkout_title => 'Checkout';

  @override
  String get checkout_confirmTitle => 'Confirm Checkout';

  @override
  String get checkout_confirmMessage =>
      'Are you sure you want to proceed with checkout?';

  @override
  String get checkout_processing => 'Processing...';

  @override
  String get checkout_success => 'Checkout successful!';

  @override
  String get checkout_failed => 'Checkout failed';

  @override
  String get checkout_emptyCart => 'Cart is empty';

  @override
  String get checkout_insufficientStock => 'Insufficient stock for';

  @override
  String get checkout_totalItems => 'Total Items';

  @override
  String get checkout_totalAmount => 'Total Amount';

  @override
  String get checkout_confirm => 'Confirm';

  @override
  String get checkout_cancel => 'Cancel';

  @override
  String get checkout_itemsProcessed => 'Items Processed';

  @override
  String get payment_title => 'Payment Method';

  @override
  String get payment_select => 'Select Payment Method';

  @override
  String get payment_cash => 'Cash';

  @override
  String get payment_card => 'Card';

  @override
  String get payment_qr => 'QRIS';

  @override
  String get payment_transfer => 'Transfer';

  @override
  String get payment_cashReceived => 'Cash Received';

  @override
  String get payment_cardLast4 => 'Last 4 Digits';

  @override
  String get payment_change => 'Change';

  @override
  String get payment_validate => 'Validate Payment';

  @override
  String get payment_invalidAmount => 'Invalid amount';

  @override
  String get payment_insufficientAmount => 'Amount received is less than total';

  @override
  String get receipt_title => 'Receipt';

  @override
  String get receipt_print => 'Print Receipt';

  @override
  String get receipt_share => 'Share Receipt';

  @override
  String get receipt_save => 'Save Receipt';

  @override
  String get receipt_printSuccess => 'Receipt printed successfully';

  @override
  String get receipt_shareSuccess => 'Receipt shared successfully';

  @override
  String get receipt_saveSuccess => 'Receipt saved successfully';

  @override
  String get receipt_transaction => 'Transaction';

  @override
  String get receipt_date => 'Date';

  @override
  String get receipt_cashier => 'Cashier';

  @override
  String get receipt_items => 'Items';

  @override
  String get receipt_qty => 'Qty';

  @override
  String get receipt_price => 'Price';

  @override
  String get receipt_subtotal => 'Subtotal';

  @override
  String get receipt_tax => 'Tax';

  @override
  String get receipt_discount => 'Discount';

  @override
  String get receipt_total => 'Total';

  @override
  String get receipt_paymentMethod => 'Payment Method';

  @override
  String get receipt_received => 'Received';

  @override
  String get receipt_thankYou => 'Thank you for your visit!';

  @override
  String get receipt_noReturn => 'Goods sold cannot be returned or exchanged';

  @override
  String get sales_title => 'Sales';

  @override
  String get sales_history => 'Sales History';

  @override
  String get sales_reports => 'Sales Reports';

  @override
  String get sales_transaction => 'Transaction';

  @override
  String get sales_date => 'Date';

  @override
  String get sales_items => 'Items';

  @override
  String get sales_amount => 'Amount';

  @override
  String get sales_status => 'Status';

  @override
  String get sales_paymentMethod => 'Payment Method';

  @override
  String get sales_completed => 'Completed';

  @override
  String get sales_pending => 'Pending';

  @override
  String get sales_cancelled => 'Cancelled';

  @override
  String get sales_refunded => 'Refunded';

  @override
  String get sales_totalTransactions => 'Total Transactions';

  @override
  String get sales_totalRevenue => 'Total Revenue';

  @override
  String get sales_totalProfit => 'Total Profit';

  @override
  String get sales_averageTransaction => 'Average Transaction';

  @override
  String get sales_dailyBreakdown => 'Daily Breakdown';

  @override
  String get sales_topProducts => 'Top Products';

  @override
  String get sales_paymentBreakdown => 'Payment Breakdown';

  @override
  String get sales_export => 'Export to CSV';

  @override
  String get sales_exportSuccess => 'Report exported successfully';

  @override
  String get sales_filterByDate => 'Filter by Date';

  @override
  String get sales_filterByPayment => 'Filter by Payment Method';

  @override
  String get sales_noTransactions => 'No transactions found';

  @override
  String get sales_search => 'Search transactions...';

  @override
  String get category_title => 'Category';

  @override
  String get category_name => 'Category Name';

  @override
  String get category_description => 'Description';

  @override
  String get category_add => 'Add Category';

  @override
  String get category_edit => 'Edit Category';

  @override
  String get category_delete => 'Delete Category';

  @override
  String get category_addSuccess => 'Category added successfully';

  @override
  String get category_updateSuccess => 'Category updated successfully';

  @override
  String get category_deleteSuccess => 'Category deleted successfully';

  @override
  String get category_deleteConfirm =>
      'Are you sure you want to delete this category?';

  @override
  String get category_nameRequired => 'Category name is required';

  @override
  String get category_nameTooShort =>
      'Category name must be at least 2 characters';

  @override
  String get category_nameTooLong =>
      'Category name must be at most 50 characters';

  @override
  String get category_nameExists => 'Category already exists';

  @override
  String get category_noCategories => 'No categories found';

  @override
  String get category_select => 'Select Category';

  @override
  String get category_uncategorized => 'Uncategorized';

  @override
  String get supplier_title => 'Supplier';

  @override
  String get supplier_name => 'Supplier Name';

  @override
  String get supplier_contactPerson => 'Contact Person';

  @override
  String get supplier_phone => 'Phone';

  @override
  String get supplier_email => 'Email';

  @override
  String get supplier_address => 'Address';

  @override
  String get supplier_add => 'Add Supplier';

  @override
  String get supplier_edit => 'Edit Supplier';

  @override
  String get supplier_delete => 'Delete Supplier';

  @override
  String get supplier_addSuccess => 'Supplier added successfully';

  @override
  String get supplier_updateSuccess => 'Supplier updated successfully';

  @override
  String get supplier_deleteSuccess => 'Supplier deleted successfully';

  @override
  String get supplier_deleteConfirm =>
      'Are you sure you want to delete this supplier?';

  @override
  String get supplier_nameRequired => 'Supplier name is required';

  @override
  String get supplier_nameTooShort =>
      'Supplier name must be at least 2 characters';

  @override
  String get supplier_nameTooLong =>
      'Supplier name must be at most 100 characters';

  @override
  String get supplier_nameExists => 'Supplier already exists';

  @override
  String get supplier_noSuppliers => 'No suppliers found';

  @override
  String get supplier_select => 'Select Supplier';

  @override
  String get supplier_invalidEmail => 'Invalid email format';

  @override
  String get supplier_invalidPhone => 'Invalid phone format';

  @override
  String get discount_title => 'Discount Management';

  @override
  String get discount_promotions => 'Promotions';

  @override
  String get discount_presets => 'Discount Presets';

  @override
  String get discount_categories => 'Category Discounts';

  @override
  String get discount_manageDiscounts => 'Manage Discounts';

  @override
  String get discount_promotionName => 'Promotion Name';

  @override
  String get discount_promotionDescription => 'Description';

  @override
  String get discount_discountPercentage => 'Discount (%)';

  @override
  String get discount_startDate => 'Start Date';

  @override
  String get discount_endDate => 'End Date';

  @override
  String get discount_isEnabled => 'Enabled';

  @override
  String get discount_active => 'Active';

  @override
  String get discount_inactive => 'Inactive';

  @override
  String get discount_scheduled => 'Scheduled';

  @override
  String get discount_expired => 'Expired';

  @override
  String get discount_activePromotions => 'Active Promotions';

  @override
  String get discount_noPromotions => 'No promotions yet';

  @override
  String get discount_noPromotionsHint => 'Press + to create a new promotion';

  @override
  String get discount_noPresets => 'No discount presets yet';

  @override
  String get discount_noPresetsHint =>
      'Press + to create a new discount preset';

  @override
  String get discount_noCategories => 'No categories yet';

  @override
  String get discount_noCategoriesHint =>
      'Create categories in Inventory to set discounts';

  @override
  String get discount_addPromotion => 'Add Promotion';

  @override
  String get discount_addPreset => 'Add Preset';

  @override
  String get discount_editPromotion => 'Edit Promotion';

  @override
  String get discount_editPreset => 'Edit Preset';

  @override
  String get discount_deletePromotion => 'Delete Promotion';

  @override
  String get discount_deletePreset => 'Delete Preset';

  @override
  String discount_deleteConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get discount_deletePromotionConfirm =>
      'Are you sure you want to delete this promotion?';

  @override
  String get discount_deletePresetConfirm =>
      'Are you sure you want to delete this discount preset?';

  @override
  String get discount_enable => 'Enable';

  @override
  String get discount_disable => 'Disable';

  @override
  String get discount_editCategoryDiscount => 'Edit Category Discount';

  @override
  String get discount_categoryDiscount => 'Category Discount';

  @override
  String get discount_noDiscount => 'No discount';

  @override
  String get discount_discountApplied =>
      'Discount applied to all products in this category';

  @override
  String get discount_presetName => 'Preset Name';

  @override
  String get discount_presetDescription => 'Description';

  @override
  String get discount_dateRange => 'Date Range';

  @override
  String get discount_toggleStatus => 'Toggle Status';

  @override
  String get discount_createPromotion => 'Create Promotion';

  @override
  String get discount_createPreset => 'Create Preset';

  @override
  String get discount_editCategory => 'Edit Category';

  @override
  String get discount_categoryHasDiscount => 'This category has a discount';

  @override
  String get discount_selectPreset => 'Select Preset';

  @override
  String get discount_flashSale => 'Flash Sale';

  @override
  String get discount_weekendSale => 'Weekend Sale';

  @override
  String get discount_clearance => 'Clearance';

  @override
  String get discount_memberDiscount => 'Member Discount';

  @override
  String get stock_title => 'Stock Alert';

  @override
  String get stock_lowStock => 'Low Stock';

  @override
  String get stock_outOfStock => 'Out of Stock';

  @override
  String get stock_lowStockCount => 'Low Stock Items';

  @override
  String get stock_viewAll => 'View All';

  @override
  String get stock_noLowStock => 'All stock levels are adequate';

  @override
  String get stock_products => 'Products';

  @override
  String get stock_stockLevel => 'Stock Level';

  @override
  String get stock_restock => 'Restock';

  @override
  String get stock_threshold => 'Low Stock Threshold';

  @override
  String get stock_dashboard => 'Low Stock Dashboard';

  @override
  String get stock_adequate => 'All Stock Levels Adequate';

  @override
  String get stock_noLow => 'No low stock items found';

  @override
  String get stock_out => 'Out of Stock';

  @override
  String get stock_low => 'Low Stock';

  @override
  String get stock_adjustmentTitle => 'Stock Adjustment';

  @override
  String get stock_adjustmentType => 'Adjustment Type';

  @override
  String get stock_setStock => 'Set Stock';

  @override
  String get stock_purchase => 'Purchase';

  @override
  String get stock_sale => 'Sale';

  @override
  String get stock_damage => 'Damage';

  @override
  String get stock_itemReturn => 'Return';

  @override
  String get stock_manual => 'Manual';

  @override
  String get stock_other => 'Other';

  @override
  String get stock_quantity => 'Quantity';

  @override
  String get stock_quantityHint => 'Enter quantity';

  @override
  String get stock_invalidNumber => 'Invalid number';

  @override
  String get stock_quantityMin => 'Must be greater than 0';

  @override
  String get stock_quantityMax => 'Quantity too large';

  @override
  String get stock_confirmAction => 'Confirm Action';

  @override
  String stock_removeQuantity(Object quantity) {
    return 'Remove $quantity items from stock?';
  }

  @override
  String get stock_cancel => 'Cancel';

  @override
  String get stock_confirm => 'Confirm';

  @override
  String get stock_processing => 'Processing...';

  @override
  String get stock_setStockAction => 'Set Stock';

  @override
  String get stock_removeStock => 'Remove Stock';

  @override
  String get stock_addStock => 'Add Stock';

  @override
  String get stock_history => 'Stock History';

  @override
  String get stock_noAdjustments => 'No stock adjustments recorded';

  @override
  String get stock_currentStock => 'Current Stock';

  @override
  String get stock_sellingPrice => 'Selling Price';

  @override
  String get stock_costPriceLabel => 'Cost Price';

  @override
  String get stock_stockLevelLabel => 'Stock Level';

  @override
  String stock_suggestionAdd(Object count) {
    return 'Suggestion: Add $count units to reach safe stock';
  }

  @override
  String get stock_editProduct => 'Edit Product';

  @override
  String get stock_manageInventory => 'Manage Inventory';

  @override
  String get stock_outOfStockShort => 'Out';

  @override
  String get report_title => 'Sales Report';

  @override
  String get report_period => 'Period';

  @override
  String get report_startDate => 'Start Date';

  @override
  String get report_endDate => 'End Date';

  @override
  String get report_generate => 'Generate Report';

  @override
  String get report_dailySales => 'Daily Sales';

  @override
  String get report_topProducts => 'Top Products';

  @override
  String get report_product => 'Product';

  @override
  String get report_quantitySold => 'Qty Sold';

  @override
  String get report_revenue => 'Revenue';

  @override
  String get report_profit => 'Profit';

  @override
  String get report_trend => 'Sales Trend';

  @override
  String get report_comparison => 'Comparison';

  @override
  String get report_exportCSV => 'Export to CSV';

  @override
  String get report_noData => 'No report data available';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_add => 'Add';

  @override
  String get common_update => 'Update';

  @override
  String get common_search => 'Search';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_sort => 'Sort';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get common_loadMore => 'Load More';

  @override
  String get common_noData => 'No Data Available';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_warning => 'Warning';

  @override
  String get common_info => 'Information';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Close';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_previous => 'Previous';

  @override
  String get common_done => 'Done';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_undo => 'Undo';

  @override
  String get common_copy => 'Copy';

  @override
  String get common_share => 'Share';

  @override
  String get common_print => 'Print';

  @override
  String get common_download => 'Download';

  @override
  String get common_upload => 'Upload';

  @override
  String get common_cannotOpenDialer => 'Cannot open dialer';

  @override
  String get common_cannotOpenEmail => 'Cannot open email app';

  @override
  String get common_supplierSaveSuccess => 'Supplier saved successfully';

  @override
  String get common_supplierSaveFailed => 'Failed to save supplier';

  @override
  String get common_supplierDeleteSuccess => 'Supplier deleted successfully';

  @override
  String get common_supplierDeleteFailed => 'Failed to delete supplier';

  @override
  String common_supplierNotFound(Object query) {
    return 'Supplier \"$query\" not found';
  }

  @override
  String get common_contactPersonOptional => 'Contact Person (Optional)';

  @override
  String get common_phoneOptional => 'Phone (Optional)';

  @override
  String get common_emailOptional => 'Email (Optional)';

  @override
  String get common_addressOptional => 'Address (Optional)';

  @override
  String get common_categoryNameRequired => 'Category name is required';

  @override
  String get common_supplierNameRequired => 'Supplier name is required';

  @override
  String get common_supplierNameMin =>
      'Supplier name must be at least 2 characters';

  @override
  String get common_noSupplier => 'No Supplier';

  @override
  String get common_addNewCategory => 'Add New Category';

  @override
  String get common_addNewSupplier => 'Add New Supplier';

  @override
  String get common_productName => 'Product Name';

  @override
  String get common_priceRp => 'Price (Rp)';

  @override
  String get common_stockQuantity => 'Stock Quantity';

  @override
  String get common_costPriceRp => 'Cost Price (Rp)';

  @override
  String get common_barcodeOptional => 'Barcode (Optional)';

  @override
  String common_editProductMessage(Object name) {
    return 'Edit product: $name';
  }

  @override
  String get common_deleteVariant => 'Delete Variant';

  @override
  String get common_variant => 'Variant';

  @override
  String get common_totalStock => 'Total Stock';

  @override
  String common_stockCount(Object count) {
    return 'Stock: $count';
  }

  @override
  String get common_outOfStockShort => 'Out';

  @override
  String common_lowStockCount(Object count) {
    return 'Low Stock: $count';
  }

  @override
  String common_skuLabel(Object sku) {
    return 'SKU: $sku';
  }

  @override
  String common_barcodeLabel(Object barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String get common_addVariant => 'Add Variant';

  @override
  String get common_addVariantHint => 'Add a variant for this product';

  @override
  String get common_emptyStateGetStarted =>
      'Get started by adding your first item';

  @override
  String get common_newCategory => 'New Category';

  @override
  String get common_newSupplier => 'New Supplier';

  @override
  String get common_switchToGrid => 'Switch to Grid';

  @override
  String get common_switchToList => 'Switch to List';

  @override
  String get dark_mode => 'Dark Mode';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get enable_tax => 'Enable Tax';

  @override
  String get reset_settings => 'Reset Settings';

  @override
  String get reset => 'Reset';

  @override
  String get delete_all_data => 'Delete All Data';

  @override
  String get manage_data => 'Manage Data';

  @override
  String get export_data => 'Export Data';

  @override
  String get full_backup_description => 'Full backup of all data';

  @override
  String get incremental_backup => 'Incremental';

  @override
  String get printer_settings => 'Printer Settings';

  @override
  String get bluetooth_thermal_printer => 'Bluetooth thermal printer';

  @override
  String get printer_connected => 'Printer Connected';

  @override
  String get no_printer_connected => 'No Printer Connected';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get paper_size => 'Paper Size';

  @override
  String get available_printers => 'Available Printers';

  @override
  String get no_printers_found => 'No Printers Found';

  @override
  String get bluetooth_pairing_hint =>
      'Make sure Bluetooth is active and printer is paired';

  @override
  String get rescan => 'Rescan';

  @override
  String get test_print => 'Test Print';

  @override
  String get how_to_use => 'How to Use';

  @override
  String get step1_bluetooth =>
      '1. Make sure Bluetooth is active on the device';

  @override
  String get step2_pair_printer =>
      '2. Pair thermal printer in Bluetooth settings';

  @override
  String get step3_select_printer => '3. Select printer from the list above';

  @override
  String get step4_test_print => '4. Tap Test Print to try';

  @override
  String get connected => 'Connected';

  @override
  String get connect => 'Connect';

  @override
  String get printer_connect_failed => 'Failed to connect to printer';

  @override
  String get printer_disconnected => 'Printer disconnected';

  @override
  String get test_print_success => 'Test Print successful';

  @override
  String test_print_failed(Object error) {
    return 'Test Print failed: $error';
  }

  @override
  String get merge_description => 'Keep existing data and add missing items';

  @override
  String get replace_description => 'Wipe current data and use backup instead';

  @override
  String get category_semua => 'All';

  @override
  String get product_manual_adjustment => 'Manual adjustment';

  @override
  String product_stock_count(Object count) {
    return '$count products';
  }

  @override
  String get product_costPriceInvalid =>
      'Cost price must be greater than or equal to 0';

  @override
  String get product_name_label => 'Product Name';

  @override
  String get product_name_required => 'Product name is required';

  @override
  String get product_sell_price => 'Selling Price';

  @override
  String get product_sell_price_required => 'Selling price is required';

  @override
  String get product_cost_price => 'Cost Price';

  @override
  String get product_stock_label => 'Stock';

  @override
  String get product_stock_required => 'Stock is required';

  @override
  String get product_invalid_number => 'Enter a valid number';

  @override
  String get product_barcode_hint => 'Optional - type or scan';

  @override
  String get product_scan_barcode => 'Scan Barcode';

  @override
  String get product_optional => 'Optional';

  @override
  String get product_no_valid_products => 'No valid products found in file';

  @override
  String get product_preview => 'Product Preview';

  @override
  String get product_import_success => 'Products imported successfully';

  @override
  String product_import_failed(Object error) {
    return 'Failed to import products: $error';
  }

  @override
  String get product_select_file => 'Select CSV File';

  @override
  String get product_view_guide => 'View Format Guide';

  @override
  String get product_format_guide => 'Format Guide';

  @override
  String get product_csv_columns_required =>
      'CSV file must have the following columns:';

  @override
  String get product_required_columns => 'Required columns (must exist):';

  @override
  String get product_optional_columns => 'Optional columns (can be empty):';

  @override
  String get product_format_example => 'Example format:';

  @override
  String get product_csv_file_hint => 'Select a CSV file to import:';

  @override
  String get product_ready_to_import => 'Ready to import';

  @override
  String get product_found_with_errors => 'Found with errors';

  @override
  String product_valid_count(Object total, Object valid) {
    return '$valid of $total products valid';
  }

  @override
  String get product_validation_errors => 'Validation errors:';

  @override
  String product_more_errors(Object count) {
    return '...and $count more errors';
  }

  @override
  String product_more_products(Object count) {
    return '...and $count more products';
  }

  @override
  String get product_edit_product => 'Edit Product';

  @override
  String get product_add_product => 'Add Product';

  @override
  String get product_save => 'Save';

  @override
  String get product_cancel => 'Cancel';

  @override
  String get product_update => 'Update';

  @override
  String get product_import => 'Import';

  @override
  String get product_close => 'Close';

  @override
  String product_editing_product(Object name) {
    return 'Edit product: $name';
  }

  @override
  String get product_import_title => 'Import Products from CSV';

  @override
  String get product_processing_file => 'Processing file...';

  @override
  String get product_importing_products => 'Importing products...';

  @override
  String product_file_pick_failed(Object error) {
    return 'Failed to select file: $error';
  }

  @override
  String product_file_parse_failed(Object error) {
    return 'Failed to process file: $error';
  }

  @override
  String get product_csv_format => 'CSV Format';

  @override
  String get product_no_category => 'No Category';

  @override
  String get product_add_new_category => 'Add New Category';

  @override
  String get product_add_new_supplier => 'Add New Supplier';

  @override
  String get product_supplier_label => 'Supplier';

  @override
  String get product_barcode_optional => 'Barcode (Optional)';

  @override
  String product_low_stock_items(Object count) {
    return '$count low stock items';
  }

  @override
  String product_out_of_stock_items(Object count) {
    return '$count out of stock items';
  }

  @override
  String get backup_type => 'Backup Type';

  @override
  String get backup_data_to_backup => 'Data to Backup';

  @override
  String get backup_storage_location => 'Storage Location';

  @override
  String get backup_create_title => 'Create Backup';

  @override
  String get backup_complete => 'Backup Complete';

  @override
  String get backup_failed => 'Backup Failed';

  @override
  String get backup_restore_title => 'Restore Backup';

  @override
  String get backup_choose_restore_mode =>
      'Choose how you want to restore your data:';

  @override
  String get backup_merge => 'Merge';

  @override
  String get backup_merge_desc => 'Keep existing data and add missing items';

  @override
  String get backup_replace => 'Replace';

  @override
  String get backup_replace_desc => 'Wipe current data and use backup instead';

  @override
  String get backup_restore_now => 'Restore Now';

  @override
  String get backup_restored => 'Restored';

  @override
  String get backup_restore_failed => 'Restore Failed';

  @override
  String get backup_schedule_title => 'Schedule Backup';

  @override
  String get backup_schedule_name => 'Schedule Name';

  @override
  String get backup_schedule_name_hint => 'e.g., Nightly Backup';

  @override
  String get backup_frequency => 'Frequency';

  @override
  String get backup_daily => 'Daily';

  @override
  String get backup_weekly => 'Weekly';

  @override
  String get backup_monthly => 'Monthly';

  @override
  String get backup_day_of_month => 'Day of Month';

  @override
  String get backup_selected => 'SELECTED';

  @override
  String get backup_restore => 'Restore';

  @override
  String get backup_delete => 'Delete';

  @override
  String get backup_full => 'Full';

  @override
  String get backup_incremental => 'Incremental';

  @override
  String get backup_local => 'Local';

  @override
  String get backup_drive => 'Drive';

  @override
  String get backup_storage_status => 'STORAGE STATUS';

  @override
  String get backup_total_size => 'Total Size';

  @override
  String get backup_local_count => 'Local';

  @override
  String get backup_drive_count => 'Drive';

  @override
  String get backup_refresh => 'Refresh';

  @override
  String get backup_details => 'Storage Details';

  @override
  String get backup_close => 'Close';

  @override
  String backup_no_backups(Object type) {
    return 'No $type backups found';
  }

  @override
  String get printer_settings_title => 'Printer Settings';

  @override
  String get printer_not_connected => 'No Printer Connected';

  @override
  String get printer_disconnect => 'Disconnect';

  @override
  String get printer_paper_size => 'Paper Size';

  @override
  String get printer_available => 'Available Printers';

  @override
  String get printer_no_printers => 'No Printers Found';

  @override
  String get printer_pairing_hint =>
      'Make sure Bluetooth is active and printer is paired';

  @override
  String get printer_rescan => 'Rescan';

  @override
  String get printer_test_print => 'Test Print';

  @override
  String get printer_how_to_use => 'How to Use';

  @override
  String get printer_step1 => '1. Make sure Bluetooth is active on the device';

  @override
  String get printer_step2 => '2. Pair thermal printer in Bluetooth settings';

  @override
  String get printer_step3 => '3. Select printer from the list above';

  @override
  String get printer_step4 => '4. Tap Test Print to try';

  @override
  String get printer_connected_status => 'Printer Connected';

  @override
  String get printer_not_connected_status => 'No Printer Connected';

  @override
  String get printer_connect => 'Connect';

  @override
  String get printer_test_success => 'Test Print successful';

  @override
  String get printer_test_failed => 'Test Print failed';

  @override
  String get backup_start => 'Start';

  @override
  String get variant_title => 'Variant';

  @override
  String get variant_add => 'Add Variant';

  @override
  String get variant_edit => 'Edit Variant';

  @override
  String get variant_delete => 'Delete Variant';

  @override
  String get variant_noVariants => 'No variants yet';

  @override
  String get common_delete_confirm =>
      'Are you sure you want to delete this item?';

  @override
  String get common_no_data => 'No Data Available';

  @override
  String get empty_state_get_started => 'Get started by adding your first item';

  @override
  String get delete => 'Delete';

  @override
  String get empty_state_no_results => 'No results found';

  @override
  String get empty_state_try_again => 'Try again';

  @override
  String get backup_preparing => 'Preparing backup...';

  @override
  String get backup_collecting => 'Collecting data...';

  @override
  String get backup_compressing => 'Compressing data...';

  @override
  String get backup_uploading => 'Uploading to cloud...';

  @override
  String get backup_downloading => 'Downloading backup...';

  @override
  String get backup_extracting => 'Extracting data...';

  @override
  String get backup_restoring => 'Restoring data...';

  @override
  String get backup_finalizing => 'Finalizing...';

  @override
  String get kpi_today_summary => 'Today\'s Summary';

  @override
  String get kpi_revenue => 'Revenue';

  @override
  String get kpi_transactions => 'Transactions';

  @override
  String get kpi_items_sold => 'Items Sold';

  @override
  String get image_picker_delete => 'Delete Image';

  @override
  String image_picker_failed_camera(Object error) {
    return 'Failed to take photo: $error';
  }

  @override
  String image_picker_failed_gallery(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get image_picker_title => 'Select Image';

  @override
  String get image_picker_camera => 'Camera';

  @override
  String get image_picker_gallery => 'Gallery';

  @override
  String get quick_favorites => 'Favorites';

  @override
  String get quick_held_orders => 'Held Orders';

  @override
  String get quick_quick_add => 'Quick Add';

  @override
  String get quick_quick_quantity => 'Quick Quantity';

  @override
  String get quick_today_summary => 'Today\'s Summary';

  @override
  String get quick_refresh => 'Refresh';

  @override
  String get common_archive => 'Archive';

  @override
  String get common_favorite => 'Favorite';

  @override
  String get validator_required => 'This field is required';

  @override
  String get validator_email => 'Please enter a valid email';

  @override
  String validator_min_length(Object min) {
    return 'Must be at least $min characters';
  }

  @override
  String validator_max_length(Object max) {
    return 'Must be at most $max characters';
  }

  @override
  String get validator_invalid_format => 'Invalid format';

  @override
  String get validator_positive_number => 'Must be a positive number';

  @override
  String get validator_non_negative => 'Must be zero or greater';

  @override
  String get validator_phone => 'Please enter a valid phone number';

  @override
  String get held_order_continue => 'Continue';

  @override
  String get held_order_current_cart => 'Current Cart';

  @override
  String get held_order_delete => 'Delete Order';

  @override
  String get held_order_delete_confirm =>
      'Are you sure you want to delete this held order?';

  @override
  String get held_order_hold => 'Hold Order';

  @override
  String get held_order_no_orders => 'No held orders';

  @override
  String get held_order_saved => 'Order saved';

  @override
  String get held_orders_title => 'Held Orders';

  @override
  String get nav_add_product => 'Add Product';

  @override
  String get nav_close => 'Close';

  @override
  String get nav_history => 'History';

  @override
  String get nav_inventory => 'Inventory';

  @override
  String get nav_pos => 'POS';

  @override
  String get nav_product_found => 'Product found';

  @override
  String get nav_product_not_found => 'Product not found';

  @override
  String get nav_reports => 'Reports';

  @override
  String get nav_scan_qr => 'Scan QR';

  @override
  String get nav_view_inventory => 'View Inventory';

  @override
  String get nav_scanned => 'Scanned';

  @override
  String get cart_empty_subtitle => 'Add products to get started';

  @override
  String get cart_keranjang => 'Cart';

  @override
  String get cart_removed_from_cart => 'Removed from cart';

  @override
  String get cart_total_discount => 'Total Discount';

  @override
  String get cart_total_items => 'Total Items';

  @override
  String get checkout_success_check =>
      'Checkout successful! Check your receipt.';

  @override
  String get checkout_error_discount => 'Invalid discount value';

  @override
  String get common_batal => 'Cancel';

  @override
  String get common_copied => 'Copied to clipboard';

  @override
  String get product_no_products => 'No products found';

  @override
  String get receipt_print_success => 'Receipt printed successfully';

  @override
  String get sales_analytics_title => 'Analytics';

  @override
  String get sales_cashier_colon => 'Cashier: ';

  @override
  String get sales_category_colon => 'Category: ';

  @override
  String get sales_cetak_struk => 'Print Receipt';

  @override
  String get sales_clear_date_filter => 'Clear Date Filter';

  @override
  String get sales_failed_create_receipt => 'Failed to create receipt';

  @override
  String get sales_filter_by_date => 'Filter by Date';

  @override
  String get sales_filter_by_payment => 'Filter by Payment Method';

  @override
  String get sales_from => 'From';

  @override
  String get sales_laporan => 'Reports';

  @override
  String get sales_loading_cashiers => 'Loading cashiers...';

  @override
  String get sales_loading_categories => 'Loading categories...';

  @override
  String get sales_no_data_found => 'No data found';

  @override
  String get sales_no_transactions => 'No transactions found';

  @override
  String get sales_purchase_items => 'Items Purchased';

  @override
  String get sales_refund => 'Refund';

  @override
  String get sales_refund_available_30_days =>
      'Refund available within 30 days';

  @override
  String get sales_refund_failed_msg => 'Refund failed';

  @override
  String get sales_refund_success => 'Refund successful';

  @override
  String get sales_riwayat => 'History';

  @override
  String get sales_to => 'To';

  @override
  String get sales_total_items_sold => 'Total Items Sold';

  @override
  String get sales_total_profit => 'Total Profit';

  @override
  String get sales_total_revenue => 'Total Revenue';

  @override
  String get sales_total_transactions => 'Total Transactions';

  @override
  String get sales_transaction_refunded_badge => 'Refunded';

  @override
  String get sales_tutup => 'Close';

  @override
  String get scan_order_held => 'Order held successfully';

  @override
  String get shift_no_active => 'No active shift';

  @override
  String get shift_open => 'Open Shift';

  @override
  String get shift_open_title => 'Open New Shift';

  @override
  String get sort_by_name => 'Sort by Name';

  @override
  String get sort_by_price => 'Sort by Price';

  @override
  String get sort_by_stock => 'Sort by Stock';

  @override
  String get tax_label => 'Tax';

  @override
  String get sales_top_products => 'Top Products';

  @override
  String get sales_peak_hours => 'Peak Hours';

  @override
  String get expenses_title => 'Expenses';
}
