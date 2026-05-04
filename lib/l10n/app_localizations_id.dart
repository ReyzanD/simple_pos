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

  @override
  String get display => 'Tampilan';

  @override
  String get business_info => 'Informasi Bisnis';

  @override
  String get business_name => 'Nama Bisnis';

  @override
  String get enter_business_name => 'Masukkan nama bisnis';

  @override
  String get address => 'Alamat';

  @override
  String get enter_address => 'Masukkan alamat';

  @override
  String get phone => 'Telepon';

  @override
  String get enter_phone => 'Masukkan nomor telepon';

  @override
  String get enter_email => 'Masukkan email';

  @override
  String get email => 'Email';

  @override
  String get not_filled => 'Belum diisi';

  @override
  String get tax => 'Pajak';

  @override
  String get currency => 'Mata Uang';

  @override
  String get currency_symbol => 'Simbol Mata Uang';

  @override
  String get currency_code => 'Kode Mata Uang';

  @override
  String get receipt => 'Struk';

  @override
  String get receipt_footer => 'Footer Struk';

  @override
  String get footer_message_hint => 'Enter receipt footer message';

  @override
  String get enter_footer_message => 'Enter footer message';

  @override
  String get currency_symbol_hint => 'Example: Rp';

  @override
  String get currency_code_hint => 'Example: IDR';

  @override
  String get low_stock_threshold => 'Batas Stok Rendah';

  @override
  String get data_management => 'Manajemen Data';

  @override
  String get export_settings => 'Ekspor Pengaturan';

  @override
  String get save_settings => 'Simpan Pengaturan ke File';

  @override
  String get delete_all_data_desc => 'Hapus semua data transaksi dan produk';

  @override
  String get export_data_backup => 'Export data and backup';

  @override
  String get save_settings_file => 'Save Settings to File';

  @override
  String get bluetooth_thermal => 'Bluetooth thermal printer';

  @override
  String get business_name_updated => 'Nama bisnis diperbarui';

  @override
  String get address_updated => 'Alamat diperbarui';

  @override
  String get phone_updated => 'Telepon diperbarui';

  @override
  String get email_updated => 'Email diperbarui';

  @override
  String get currency_symbol_updated => 'Simbol mata uang diperbarui';

  @override
  String get currency_code_updated => 'Kode mata uang diperbarui';

  @override
  String get receipt_footer_updated => 'Footer struk diperbarui';

  @override
  String get stock_threshold_updated => 'Batas stok diperbarui';

  @override
  String get settings_reset_default => 'Pengaturan direset ke default';

  @override
  String get all_data_deleted => 'Semua data berhasil dihapus';

  @override
  String get settings_exported => 'Pengaturan diekspor';

  @override
  String get export_transactions_success => 'Ekspor transaksi berhasil';

  @override
  String export_failed(Object error) {
    return 'Gagal mengekspor: $error';
  }

  @override
  String get export_products_success => 'Ekspor produk berhasil';

  @override
  String get export_expenses_success => 'Ekspor pengeluaran berhasil';

  @override
  String get backup_created_success => 'Backup berhasil dibuat';

  @override
  String get create_new_backup => 'Buat Backup Baru';

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
  String get backup_scheduled => 'Backup Dijadwalkan';

  @override
  String get backup_time => 'Waktu Backup';

  @override
  String get restore_backup => 'Restore Backup';

  @override
  String get choose_restore_mode => 'Pilih cara memulihkan data:';

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
  String get restored => 'Dipulihkan';

  @override
  String get restore_failed => 'Pemulihan Gagal';

  @override
  String get delete_backup_title => 'Hapus Backup';

  @override
  String get delete_backup_confirm => 'Hapus Backup?';

  @override
  String delete_backup_warning(Object size) {
    return 'Tindakan ini akan menghapus backup secara permanen dari $size. Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get deleted => 'Dihapus';

  @override
  String get delete_failed => 'Gagal menghapus';

  @override
  String get storage_details => 'Detail Penyimpanan';

  @override
  String get storage_status => 'STATUS PENYIMPANAN';

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
    return 'Tidak ada backup $type ditemukan';
  }

  @override
  String get retry => 'Retry';

  @override
  String get transactions => 'Transaksi';

  @override
  String get products => 'Produk';

  @override
  String get expenses => 'Pengeluaran';

  @override
  String get full_backups => 'Full Backups';

  @override
  String get close => 'Close';

  @override
  String get schedule_name => 'Nama Jadwal';

  @override
  String get schedule_name_hint => 'Contoh: Nightly Backup';

  @override
  String get frequency => 'Frekuensi';

  @override
  String get daily => 'Harian';

  @override
  String get weekly => 'Mingguan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get day_of_month => 'Tanggal Bulan';

  @override
  String get schedule => 'Jadwalkan';

  @override
  String get confirm_delete_backup =>
      'Apakah Anda yakin ingin menghapus backup ini?';

  @override
  String get backup_deleted => 'Backup dihapus';

  @override
  String get low_stock_hint => 'Masukkan jumlah';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get reset_settings_title => 'Reset Pengaturan';

  @override
  String get reset_confirm_message =>
      'Apakah Anda yakin ingin mereset semua pengaturan ke nilai default?';

  @override
  String get delete_all_data_warning =>
      'PERINGATAN: Tindakan ini akan menghapus semua data:';

  @override
  String get delete_all_data_items => '• Semua produk dan inventaris';

  @override
  String get delete_all_data_transactions => '• Semua riwayat transaksi';

  @override
  String get delete_all_data_categories => '• Semua kategori dan supplier';

  @override
  String get delete_all_data_cannot_undo =>
      'Tindakan ini tidak dapat dibatalkan.';

  @override
  String get product_name => 'Product Name';

  @override
  String get product_price => 'Price';

  @override
  String get product_stock => 'Stock';

  @override
  String get product_category => 'Kategori';

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
  String get product_add => 'Tambah';

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
  String get product_search => 'Cari produk...';

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
  String get product_tambah_produk => 'Tambah Produk';

  @override
  String get product_semua => 'All';

  @override
  String get product_stok => 'Stok';

  @override
  String get product_adjust_stock => 'Sesuaikan Stok';

  @override
  String get product_tambah_manual => 'Tambah Manual';

  @override
  String get product_manual_hint => 'Masukkan jumlah secara manual';

  @override
  String get product_import_csv => 'Import CSV';

  @override
  String get product_import_hint => 'Import produk dari file CSV';

  @override
  String get product_stock_missing => 'Data stok hilang';

  @override
  String get product_edit_produk => 'Edit Produk';

  @override
  String get product_information => 'Informasi Produk';

  @override
  String get product_nama => 'Nama Produk';

  @override
  String get product_harga => 'Harga';

  @override
  String get product_harga_pokok => 'Harga Modal';

  @override
  String get product_satuan => 'Satuan';

  @override
  String get product_barcode_label => 'Barcode';

  @override
  String product_stock_low_badge(Object count) {
    return 'Stok Menipis: $count';
  }

  @override
  String get product_out_of_stock_badge => 'Stok Habis';

  @override
  String get product_stock_adjusted => 'Stok berhasil disesuaikan';

  @override
  String get product_update_success_id => 'Produk berhasil diupdate';

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
  String get dark_mode => 'Mode Gelap';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Nonaktif';

  @override
  String get enable_tax => 'Aktifkan Pajak';

  @override
  String get reset_settings => 'Reset Pengaturan';

  @override
  String get reset => 'Reset';

  @override
  String get delete_all_data => 'Hapus Semua Data';

  @override
  String get manage_data => 'Kelola Data';

  @override
  String get export_data => 'Ekspor Data';

  @override
  String get full_backup_description => 'Backup lengkap semua data';

  @override
  String get incremental_backup => 'Incremental';

  @override
  String get printer_settings => 'Pengaturan Printer';

  @override
  String get bluetooth_thermal_printer => 'Printer thermal Bluetooth';

  @override
  String get printer_connected => 'Printer Terhubung';

  @override
  String get no_printer_connected => 'Tidak Ada Printer Terhubung';

  @override
  String get disconnect => 'Putuskan';

  @override
  String get paper_size => 'Ukuran Kertas';

  @override
  String get available_printers => 'Printer Tersedia';

  @override
  String get no_printers_found => 'Tidak Ada Printer Ditemukan';

  @override
  String get bluetooth_pairing_hint =>
      'Pastikan Bluetooth aktif dan printer sudah dipasangkan';

  @override
  String get rescan => 'Scan Ulang';

  @override
  String get test_print => 'Test Print';

  @override
  String get how_to_use => 'Cara Menggunakan';

  @override
  String get step1_bluetooth => '1. Pastikan Bluetooth aktif di perangkat';

  @override
  String get step2_pair_printer =>
      '2. Pair printer thermal di pengaturan Bluetooth';

  @override
  String get step3_select_printer => '3. Pilih printer dari daftar di atas';

  @override
  String get step4_test_print => '4. Tap \"Test Print\" untuk mencoba';

  @override
  String get connected => 'Terhubung';

  @override
  String get connect => 'Hubungkan';

  @override
  String get printer_connect_failed => 'Gagal terhubung ke printer';

  @override
  String get printer_disconnected => 'Printer terputus';

  @override
  String get test_print_success => 'Test print berhasil';

  @override
  String test_print_failed(Object error) {
    return 'Test print gagal: $error';
  }

  @override
  String get merge_description =>
      'Pertahankan data yang ada dan tambahkan item yang hilang';

  @override
  String get replace_description =>
      'Hapus data saat ini dan gunakan backup sebagai gantinya';

  @override
  String get category_semua => 'Semua';

  @override
  String get product_manual_adjustment => 'Penyesuaian manual';

  @override
  String product_stock_count(Object count) {
    return '$count produk';
  }

  @override
  String get product_costPriceInvalid =>
      'Harga modal harus lebih dari atau sama dengan 0';

  @override
  String get product_name_label => 'Nama Produk';

  @override
  String get product_name_required => 'Nama produk wajib diisi';

  @override
  String get product_sell_price => 'Harga Jual';

  @override
  String get product_sell_price_required => 'Harga jual wajib diisi';

  @override
  String get product_cost_price => 'Harga Modal';

  @override
  String get product_stock_label => 'Stok';

  @override
  String get product_stock_required => 'Stok wajib diisi';

  @override
  String get product_invalid_number => 'Masukkan angka yang valid';

  @override
  String get product_barcode_hint => 'Opsional - ketik atau scan';

  @override
  String get product_scan_barcode => 'Scan Barcode';

  @override
  String get product_optional => 'Opsional';

  @override
  String get product_no_valid_products =>
      'Tidak ada produk valid ditemukan dalam file';

  @override
  String get product_preview => 'Preview Produk';

  @override
  String get product_import_success => 'Produk berhasil diimpor';

  @override
  String product_import_failed(Object error) {
    return 'Gagal mengimpor produk: $error';
  }

  @override
  String get product_select_file => 'Pilih File CSV';

  @override
  String get product_view_guide => 'Lihat Panduan Format';

  @override
  String get product_format_guide => 'Panduan Format';

  @override
  String get product_csv_columns_required =>
      'File CSV harus memiliki kolom berikut:';

  @override
  String get product_required_columns => 'Kolom wajib (harus ada):';

  @override
  String get product_optional_columns => 'Kolom opsional (boleh kosong):';

  @override
  String get product_format_example => 'Contoh format:';

  @override
  String get product_csv_file_hint => 'Pilih file CSV untuk diimport:';

  @override
  String get product_ready_to_import => 'Siap diimport';

  @override
  String get product_found_with_errors => 'Ditemukan dengan error';

  @override
  String product_valid_count(Object total, Object valid) {
    return '$valid dari $total produk valid';
  }

  @override
  String get product_validation_errors => 'Error validasi:';

  @override
  String product_more_errors(Object count) {
    return '...dan $count error lainnya';
  }

  @override
  String product_more_products(Object count) {
    return '...dan $count produk lainnya';
  }

  @override
  String get product_edit_product => 'Edit Produk';

  @override
  String get product_add_product => 'Tambah Produk';

  @override
  String get product_save => 'Simpan';

  @override
  String get product_cancel => 'Batal';

  @override
  String get product_update => 'Update';

  @override
  String get product_import => 'Import';

  @override
  String get product_close => 'Tutup';

  @override
  String product_editing_product(Object name) {
    return 'Edit produk: $name';
  }

  @override
  String get product_import_title => 'Import Produk dari CSV';

  @override
  String get product_processing_file => 'Memproses file...';

  @override
  String get product_importing_products => 'Mengimpor produk...';

  @override
  String product_file_pick_failed(Object error) {
    return 'Gagal memilih file: $error';
  }

  @override
  String product_file_parse_failed(Object error) {
    return 'Gagal memproses file: $error';
  }

  @override
  String get product_csv_format => 'Format CSV';

  @override
  String get product_no_category => 'Tanpa Kategori';

  @override
  String get product_add_new_category => 'Tambah Kategori Baru';

  @override
  String get product_add_new_supplier => 'Tambah Pemasok Baru';

  @override
  String get product_supplier_label => 'Pemasok';

  @override
  String get product_barcode_optional => 'Barcode (Opsional)';

  @override
  String product_low_stock_items(Object count) {
    return '$count item stok menipis';
  }

  @override
  String product_out_of_stock_items(Object count) {
    return '$count item stok habis';
  }

  @override
  String get backup_type => 'Tipe Backup';

  @override
  String get backup_data_to_backup => 'Data untuk Backup';

  @override
  String get backup_storage_location => 'Lokasi Penyimpanan';

  @override
  String get backup_create_title => 'Buat Backup';

  @override
  String get backup_complete => 'Backup Selesai';

  @override
  String get backup_failed => 'Backup Gagal';

  @override
  String get backup_restore_title => 'Pulihkan Backup';

  @override
  String get backup_choose_restore_mode => 'Pilih cara memulihkan data:';

  @override
  String get backup_merge => 'Gabungkan';

  @override
  String get backup_merge_desc =>
      'Pertahankan data yang ada dan tambahkan item yang hilang';

  @override
  String get backup_replace => 'Ganti';

  @override
  String get backup_replace_desc =>
      'Hapus data saat ini dan gunakan backup sebagai gantinya';

  @override
  String get backup_restore_now => 'Pulihkan Sekarang';

  @override
  String get backup_restored => 'Dipulihkan';

  @override
  String get backup_restore_failed => 'Pemulihan Gagal';

  @override
  String get backup_schedule_title => 'Jadwalkan Backup';

  @override
  String get backup_schedule_name => 'Nama Jadwal';

  @override
  String get backup_schedule_name_hint => 'Contoh: Backup Malam';

  @override
  String get backup_frequency => 'Frekuensi';

  @override
  String get backup_daily => 'Harian';

  @override
  String get backup_weekly => 'Mingguan';

  @override
  String get backup_monthly => 'Bulanan';

  @override
  String get backup_day_of_month => 'Tanggal Bulan';

  @override
  String get backup_selected => 'TERPILIH';

  @override
  String get backup_restore => 'Pulihkan';

  @override
  String get backup_delete => 'Hapus';

  @override
  String get backup_full => 'Full';

  @override
  String get backup_incremental => 'Incremental';

  @override
  String get backup_local => 'Lokal';

  @override
  String get backup_drive => 'Drive';

  @override
  String get backup_storage_status => 'STATUS PENYIMPANAN';

  @override
  String get backup_total_size => 'Total Size';

  @override
  String get backup_local_count => 'Lokal';

  @override
  String get backup_drive_count => 'Drive';

  @override
  String get backup_refresh => 'Refresh';

  @override
  String get backup_details => 'Detail Penyimpanan';

  @override
  String get backup_close => 'Tutup';

  @override
  String backup_no_backups(Object type) {
    return 'Tidak ada backup $type ditemukan';
  }

  @override
  String get printer_settings_title => 'Pengaturan Printer';

  @override
  String get printer_not_connected => 'Tidak Ada Printer Terhubung';

  @override
  String get printer_disconnect => 'Putuskan';

  @override
  String get printer_paper_size => 'Ukuran Kertas';

  @override
  String get printer_available => 'Printer Tersedia';

  @override
  String get printer_no_printers => 'Tidak Ada Printer Ditemukan';

  @override
  String get printer_pairing_hint =>
      'Pastikan Bluetooth aktif dan printer sudah dipasangkan';

  @override
  String get printer_rescan => 'Scan Ulang';

  @override
  String get printer_test_print => 'Test Print';

  @override
  String get printer_how_to_use => 'Cara Menggunakan';

  @override
  String get printer_step1 => '1. Pastikan Bluetooth aktif di perangkat';

  @override
  String get printer_step2 => '2. Pair printer thermal di pengaturan Bluetooth';

  @override
  String get printer_step3 => '3. Pilih printer dari daftar di atas';

  @override
  String get printer_step4 => '4. Tap \"Test Print\" untuk mencoba';

  @override
  String get printer_connected_status => 'Printer Terhubung';

  @override
  String get printer_not_connected_status => 'Tidak Ada Printer Terhubung';

  @override
  String get printer_connect => 'Hubungkan';

  @override
  String get printer_test_success => 'Test print berhasil';

  @override
  String get printer_test_failed => 'Test print gagal';

  @override
  String get backup_start => 'Mulai';

  @override
  String get variant_title => 'Varian';

  @override
  String get variant_add => 'Tambah Varian';

  @override
  String get variant_edit => 'Edit Varian';

  @override
  String get variant_delete => 'Hapus Varian';

  @override
  String get variant_noVariants => 'Belum ada varian';

  @override
  String get common_delete_confirm =>
      'Apakah Anda yakin ingin menghapus item ini?';

  @override
  String get common_no_data => 'Tidak Ada Data';

  @override
  String get empty_state_get_started =>
      'Mulai dengan menambahkan item pertama Anda';

  @override
  String get delete => 'Hapus';

  @override
  String get empty_state_no_results => 'Tidak ada hasil ditemukan';

  @override
  String get empty_state_try_again => 'Coba lagi';

  @override
  String get backup_preparing => 'Menyiapkan backup...';

  @override
  String get backup_collecting => 'Mengumpulkan data...';

  @override
  String get backup_compressing => 'Mengompres data...';

  @override
  String get backup_uploading => 'Mengunggah ke cloud...';

  @override
  String get backup_downloading => 'Mengunduh backup...';

  @override
  String get backup_extracting => 'Mengekstrak data...';

  @override
  String get backup_restoring => 'Memulihkan data...';

  @override
  String get backup_finalizing => 'Menyelesaikan...';

  @override
  String get kpi_today_summary => 'Ringkasan Hari Ini';

  @override
  String get kpi_revenue => 'Pendapatan';

  @override
  String get kpi_transactions => 'Transaksi';

  @override
  String get kpi_items_sold => 'Item Terjual';

  @override
  String get image_picker_delete => 'Hapus Gambar';

  @override
  String image_picker_failed_camera(Object error) {
    return 'Gagal mengambil foto: $error';
  }

  @override
  String image_picker_failed_gallery(Object error) {
    return 'Gagal memilih gambar: $error';
  }

  @override
  String get image_picker_title => 'Pilih Gambar';

  @override
  String get image_picker_camera => 'Kamera';

  @override
  String get image_picker_gallery => 'Galeri';

  @override
  String get quick_favorites => 'Favorit';

  @override
  String get quick_held_orders => 'Pesanan Ditahan';

  @override
  String get quick_quick_add => 'Tambah Cepat';

  @override
  String get quick_quick_quantity => 'Kuantitas Cepat';

  @override
  String get quick_today_summary => 'Ringkasan Hari Ini';

  @override
  String get quick_refresh => 'Segarkan';

  @override
  String get common_archive => 'Arsip';

  @override
  String get common_favorite => 'Favorit';

  @override
  String get validator_required => 'Kolom ini wajib diisi';

  @override
  String get validator_email => 'Masukkan email yang valid';

  @override
  String validator_min_length(Object min) {
    return 'Minimal $min karakter';
  }

  @override
  String validator_max_length(Object max) {
    return 'Maksimal $max karakter';
  }

  @override
  String get validator_invalid_format => 'Format tidak valid';

  @override
  String get validator_positive_number => 'Harus berupa angka positif';

  @override
  String get validator_non_negative => 'Harus nol atau lebih';

  @override
  String get validator_phone => 'Masukkan nomor telepon yang valid';

  @override
  String get held_order_continue => 'Lanjutkan';

  @override
  String get held_order_current_cart => 'Keranjang Saat Ini';

  @override
  String get held_order_delete => 'Hapus Pesanan';

  @override
  String get held_order_delete_confirm =>
      'Apakah Anda yakin ingin menghapus pesanan yang ditahan ini?';

  @override
  String get held_order_hold => 'Tahan Pesanan';

  @override
  String get held_order_no_orders => 'Tidak ada pesanan ditahan';

  @override
  String get held_order_saved => 'Pesanan disimpan';

  @override
  String get held_orders_title => 'Pesanan Ditahan';

  @override
  String get nav_add_product => 'Tambah Produk';

  @override
  String get nav_close => 'Tutup';

  @override
  String get nav_history => 'Riwayat';

  @override
  String get nav_inventory => 'Inventaris';

  @override
  String get nav_pos => 'POS';

  @override
  String get nav_product_found => 'Produk ditemukan';

  @override
  String get nav_product_not_found => 'Produk tidak ditemukan';

  @override
  String get nav_reports => 'Laporan';

  @override
  String get nav_scan_qr => 'Scan QR';

  @override
  String get nav_view_inventory => 'Lihat Inventaris';

  @override
  String get nav_scanned => 'Terscan';

  @override
  String get cart_empty_subtitle => 'Tambahkan produk untuk memulai';

  @override
  String get cart_keranjang => 'Keranjang';

  @override
  String get cart_removed_from_cart => 'Dihapus dari keranjang';

  @override
  String get cart_total_discount => 'Total Diskon';

  @override
  String get cart_total_items => 'Total Item';

  @override
  String get checkout_success_check => 'Checkout berhasil! Periksa struk Anda.';

  @override
  String get checkout_error_discount => 'Nilai diskon tidak valid';

  @override
  String get common_batal => 'Batal';

  @override
  String get common_copied => 'Disalin ke clipboard';

  @override
  String get product_no_products => 'Tidak ada produk ditemukan';

  @override
  String get receipt_print_success => 'Struk berhasil dicetak';

  @override
  String get sales_analytics_title => 'Analitik';

  @override
  String get sales_cashier_colon => 'Kasir: ';

  @override
  String get sales_category_colon => 'Kategori: ';

  @override
  String get sales_cetak_struk => 'Cetak Struk';

  @override
  String get sales_clear_date_filter => 'Hapus Filter Tanggal';

  @override
  String get sales_failed_create_receipt => 'Gagal membuat struk';

  @override
  String get sales_filter_by_date => 'Filter berdasarkan Tanggal';

  @override
  String get sales_filter_by_payment => 'Filter berdasarkan Metode Pembayaran';

  @override
  String get sales_from => 'Dari';

  @override
  String get sales_laporan => 'Laporan';

  @override
  String get sales_loading_cashiers => 'Memuat kasir...';

  @override
  String get sales_loading_categories => 'Memuat kategori...';

  @override
  String get sales_no_data_found => 'Tidak ada data ditemukan';

  @override
  String get sales_no_transactions => 'Tidak ada transaksi ditemukan';

  @override
  String get sales_purchase_items => 'Item Dibeli';

  @override
  String get sales_refund => 'Pengembalian Dana';

  @override
  String get sales_refund_available_30_days =>
      'Pengembalian tersedia dalam 30 hari';

  @override
  String get sales_refund_failed_msg => 'Pengembalian dana gagal';

  @override
  String get sales_refund_success => 'Pengembalian dana berhasil';

  @override
  String get sales_riwayat => 'Riwayat';

  @override
  String get sales_to => 'Ke';

  @override
  String get sales_total_items_sold => 'Total Item Terjual';

  @override
  String get sales_total_profit => 'Total Keuntungan';

  @override
  String get sales_total_revenue => 'Total Pendapatan';

  @override
  String get sales_total_transactions => 'Total Transaksi';

  @override
  String get sales_transaction_refunded_badge => 'Dikembalikan';

  @override
  String get sales_tutup => 'Tutup';

  @override
  String get scan_order_held => 'Pesanan berhasil ditahan';

  @override
  String get shift_no_active => 'Tidak ada shift aktif';

  @override
  String get shift_open => 'Buka Shift';

  @override
  String get shift_open_title => 'Buka Shift Baru';

  @override
  String get sort_by_name => 'Urutkan berdasarkan Nama';

  @override
  String get sort_by_price => 'Urutkan berdasarkan Harga';

  @override
  String get sort_by_stock => 'Urutkan berdasarkan Stok';

  @override
  String get tax_label => 'Pajak';

  @override
  String get sales_top_products => 'Produk Terlaris';

  @override
  String get sales_peak_hours => 'Jam Sibuk';

  @override
  String get expenses_title => 'Pengeluaran';
}
