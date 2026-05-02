// lib/features/shared/presentation/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core
import '../../../core/database/database_helper.dart';
// --- Theme ---
import '../../../core/controllers/theme_controller.dart';

// --- Backup ---
import '../../../core/services/backup_data_collector.dart';
import '../../backup/data/datasources/backup_drive_datasource.dart';
import '../../backup/data/datasources/backup_local_datasource.dart';
import '../../backup/data/repositories/backup_repository_impl.dart';
import '../../backup/presentation/controllers/backup_controller.dart';

import '../../../core/services/backup_service.dart';
import '../../../core/services/printer_service.dart';
// --- Expenses ---
import '../../expenses/presentation/controllers/expense_controller.dart';
import '../../expenses/domain/usecases/add_expense_usecase.dart';
import '../../expenses/domain/usecases/get_expenses_usecase.dart';
import '../../expenses/domain/usecases/update_expense_usecase.dart';
import '../../expenses/domain/usecases/delete_expense_usecase.dart';
import '../../expenses/domain/usecases/get_expense_summary_usecase.dart';
import '../../expenses/domain/usecases/get_expense_count_by_category_usecase.dart';

// --- Inventory (Suppliers) ---
import '../../inventory/data/datasources/stock_adjustment_local_datasource_impl.dart';
import '../../inventory/data/repositories/stock_adjustment_repository_impl.dart';
import '../../inventory/domain/repositories/stock_adjustment_repository.dart';
import '../../inventory/presentation/controllers/supplier_controller.dart';
import '../../inventory/domain/usecases/supplier_usecases.dart';

// --- POS (Favorites) ---
import '../../pos/presentation/controllers/favorites_controller.dart';

// --- Sales (Analytics, Cart, Discount) ---
import '../../sales/presentation/controllers/analytics_controller.dart';
import '../../sales/presentation/controllers/cart_controller.dart';
import '../../sales/presentation/controllers/discount_controller.dart';
import '../../sales/domain/usecases/get_sales_analytics_usecase.dart';
import '../../sales/domain/usecases/get_promotions_usecase.dart';
import '../../sales/domain/usecases/add_promotion_usecase.dart';
import '../../sales/domain/usecases/update_promotion_usecase.dart';
import '../../sales/domain/usecases/delete_promotion_usecase.dart';
import '../../sales/domain/usecases/toggle_promotion_usecase.dart';
import '../../sales/domain/usecases/get_discount_presets_usecase.dart';
import '../../sales/domain/usecases/add_discount_preset_usecase.dart';
import '../../sales/domain/usecases/update_discount_preset_usecase.dart';
import '../../sales/domain/usecases/delete_discount_preset_usecase.dart';

// --- Settings ---
import '../../settings/presentation/controllers/settings_controller.dart';
import '../../settings/data/datasources/settings_local_datasource.dart';
// --- Users ---
import '../../users/data/datasources/user_local_datasource_impl.dart';
import '../../users/data/repositories/user_repository_impl.dart';
import '../../users/domain/usecases/login_usecase.dart';
import '../../users/domain/usecases/get_users_usecase.dart';
import '../../users/domain/usecases/create_user_usecase.dart';
import '../../users/domain/usecases/update_user_usecase.dart';
import '../../users/domain/usecases/delete_user_usecase.dart';
import '../../users/presentation/controllers/auth_controller.dart';

// --- Inventory ---
import '../../inventory/data/datasources/product_local_datasource_impl.dart';
import '../../inventory/data/datasources/category_local_datasource_impl.dart';
import '../../inventory/data/repositories/product_repository_impl.dart';
import '../../inventory/data/repositories/category_repository_impl.dart';
import '../../inventory/domain/usecases/get_products_usecase.dart';
import '../../inventory/domain/usecases/add_product_usecase.dart';
import '../../inventory/domain/usecases/update_product_usecase.dart';
import '../../inventory/domain/usecases/delete_product_usecase.dart';
import '../../inventory/domain/usecases/search_products_usecase.dart';
import '../../inventory/domain/usecases/import_products_from_csv_usecase.dart';
import '../../inventory/domain/usecases/adjust_stock_usecase.dart';
import '../../inventory/presentation/controllers/inventory_controller.dart';

// --- POS ---
import '../../pos/data/repositories/cart_repository_impl.dart';
import '../../pos/domain/usecases/add_to_cart_usecase.dart';
import '../../pos/domain/usecases/checkout_usecase.dart';
import '../../pos/domain/usecases/remove_from_cart_usecase.dart';
import '../../pos/domain/usecases/update_cart_quantity_usecase.dart';
import '../../pos/domain/usecases/save_cart_usecase.dart';
import '../../pos/domain/usecases/get_held_carts_usecase.dart';
import '../../pos/domain/usecases/load_cart_usecase.dart';
import '../../pos/domain/usecases/delete_held_cart_usecase.dart';
import '../../pos/presentation/controllers/pos_controller.dart';

// --- Sales ---
import '../../sales/data/datasources/transaction_local_datasource_impl.dart';
import '../../sales/data/repositories/transaction_repository_impl.dart';
import '../../sales/domain/usecases/create_transaction_usecase.dart';
import '../../sales/domain/usecases/get_transactions_usecase.dart';
import '../../sales/domain/usecases/get_sales_report_usecase.dart';
import '../../sales/domain/usecases/export_sales_to_csv_usecase.dart';
import '../../sales/presentation/controllers/sales_history_controller.dart';
import '../../sales/presentation/controllers/sales_report_controller.dart';
import '../../sales/presentation/controllers/refund_controller.dart';
import '../../sales/domain/usecases/refund_transaction_usecase.dart';

// --- Category ---
import '../../inventory/domain/usecases/category_usecases.dart';
import '../../inventory/presentation/controllers/category_controller.dart';

// --- Shifts ---
import '../../shifts/data/datasources/shift_local_datasource_impl.dart';
import '../../shifts/data/repositories/shift_repository_impl.dart';
import '../../shifts/domain/usecases/open_shift_usecase.dart';
import '../../shifts/domain/usecases/close_shift_usecase.dart';
import '../../shifts/domain/usecases/get_current_shift_usecase.dart';
import '../../shifts/domain/usecases/get_shifts_usecase.dart';
import '../../shifts/domain/usecases/update_shift_totals_usecase.dart';
import '../../shifts/domain/usecases/save_cash_count_usecase.dart';
import '../../shifts/domain/usecases/get_cash_count_by_shift_usecase.dart';
import '../../shifts/presentation/controllers/shift_controller.dart';
import '../../shifts/data/datasources/cash_count_local_datasource_impl.dart';
import '../../shifts/data/repositories/cash_count_repository_impl.dart';

// --- Product Variants ---
import '../../inventory/data/repositories/product_variant_repository_impl.dart';
import '../../inventory/domain/usecases/get_product_variants_usecase.dart';
import '../../inventory/domain/usecases/add_product_variant_usecase.dart';
import '../../inventory/domain/usecases/update_product_variant_usecase.dart';
import '../../inventory/domain/usecases/delete_product_variant_usecase.dart';
import '../../inventory/domain/usecases/variant_attribute_usecases.dart';
import '../../inventory/presentation/controllers/product_variant_controller.dart';
import '../../inventory/data/datasources/product_variant_local_datasource.dart';

import '../../expenses/data/repositories/expense_repository_impl.dart';
import '../../inventory/data/repositories/supplier_repository_impl.dart';
import '../../sales/data/repositories/promotion_repository_impl.dart';
import '../../sales/data/repositories/discount_preset_repository_impl.dart';
import '../../settings/data/repositories/settings_repository_impl.dart';
import '../../expenses/data/datasources/expense_local_datasource_impl.dart';
import '../../inventory/data/datasources/supplier_local_datasource_impl.dart';
import '../../pos/data/repositories/favorites_repository.dart';
import '../../sales/data/datasources/promotion_local_datasource_impl.dart';
import '../../sales/data/datasources/discount_preset_local_datasource_impl.dart';

// ============================================================
// CORE
// ============================================================
final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper.instance,
);

// ============================================================
// USERS
// ============================================================

final _userLocalDataSourceProvider = Provider(
  (ref) => UserLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);

final _userRepositoryProvider = Provider(
  (ref) => UserRepositoryImpl(
    localDataSource: ref.watch(_userLocalDataSourceProvider),
  ),
);

final _loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(_userRepositoryProvider)),
);
final _getUsersUseCaseProvider = Provider(
  (ref) => GetUsersUseCase(ref.watch(_userRepositoryProvider)),
);
final _createUserUseCaseProvider = Provider(
  (ref) => CreateUserUseCase(ref.watch(_userRepositoryProvider)),
);
final _updateUserUseCaseProvider = Provider(
  (ref) => UpdateUserUseCase(ref.watch(_userRepositoryProvider)),
);
final _deleteUserUseCaseProvider = Provider(
  (ref) => DeleteUserUseCase(ref.watch(_userRepositoryProvider)),
);

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(
    loginUseCase: ref.watch(_loginUseCaseProvider),
    getUsersUseCase: ref.watch(_getUsersUseCaseProvider),
    createUserUseCase: ref.watch(_createUserUseCaseProvider),
    updateUserUseCase: ref.watch(_updateUserUseCaseProvider),
    deleteUserUseCase: ref.watch(_deleteUserUseCaseProvider),
  ),
);

// ============================================================
// INVENTORY
// ============================================================

final _productLocalDataSourceProvider = Provider(
  (ref) => ProductLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _categoryLocalDataSourceProvider = Provider(
  (ref) => CategoryLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final productRepositoryProvider = Provider(
  (ref) => ProductRepositoryImpl(
    localDataSource: ref.watch(_productLocalDataSourceProvider),
  ),
);
final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepositoryImpl(
    localDataSource: ref.watch(_categoryLocalDataSourceProvider),
  ),
);

// STOCK ADJUSTMENT - data source
final _stockAdjustmentLocalDataSourceProvider =
    Provider<StockAdjustmentLocalDataSourceImpl>(
      (ref) => StockAdjustmentLocalDataSourceImpl(
        databaseHelper: ref.watch(databaseHelperProvider),
      ),
    );
// STOCK ADJUSTMENT - repository
final stockAdjustmentRepositoryProvider = Provider<StockAdjustmentRepository>(
  (ref) => StockAdjustmentRepositoryImpl(
    localDataSource: ref.watch(_stockAdjustmentLocalDataSourceProvider),
  ),
);
// STOCK ADJUSTMENT - use case
final _adjustStockUseCaseProvider = Provider(
  (ref) => AdjustStockUseCase(
    productRepository: ref.watch(productRepositoryProvider),
    stockAdjustmentRepository: ref.watch(stockAdjustmentRepositoryProvider),
  ),
);

// Use cases for inventory
final _getProductsUseCaseProvider = Provider(
  (ref) => GetProductsUseCase(repository: ref.watch(productRepositoryProvider)),
);
final _addProductUseCaseProvider = Provider(
  (ref) => AddProductUseCase(repository: ref.watch(productRepositoryProvider)),
);
final _updateProductUseCaseProvider = Provider(
  (ref) =>
      UpdateProductUseCase(repository: ref.watch(productRepositoryProvider)),
);
final _deleteProductUseCaseProvider = Provider(
  (ref) =>
      DeleteProductUseCase(repository: ref.watch(productRepositoryProvider)),
);
final _searchProductsUseCaseProvider = Provider(
  (ref) =>
      SearchProductsUseCase(repository: ref.watch(productRepositoryProvider)),
);
final _importProductsFromCsvUseCaseProvider = Provider(
  (ref) => ImportProductsFromCsvUseCase(
    productRepository: ref.watch(productRepositoryProvider),
  ),
);

final inventoryControllerProvider = ChangeNotifierProvider<InventoryController>(
  (ref) => InventoryController(
    getProductsUseCase: ref.watch(_getProductsUseCaseProvider),
    addProductUseCase: ref.watch(_addProductUseCaseProvider),
    updateProductUseCase: ref.watch(_updateProductUseCaseProvider),
    deleteProductUseCase: ref.watch(_deleteProductUseCaseProvider),
    searchProductsUseCase: ref.watch(_searchProductsUseCaseProvider),
    importProductsFromCsvUseCase: ref.watch(
      _importProductsFromCsvUseCaseProvider,
    ),
    adjustStockUseCase: ref.watch(_adjustStockUseCaseProvider),
  ),
);

// ============================================================
// SALES (declared before POS because POS depends on CheckoutUseCase → CreateTransactionUseCase)
// ============================================================

final _transactionLocalDataSourceProvider = Provider(
  (ref) => TransactionLocalDataSourceImpl(
    transactionDao: ref.watch(databaseHelperProvider).transactions,
  ),
);

final _transactionRepositoryProvider = Provider(
  (ref) => TransactionRepositoryImpl(
    localDataSource: ref.watch(_transactionLocalDataSourceProvider),
  ),
);

final _createTransactionUseCaseProvider = Provider(
  (ref) => CreateTransactionUseCase(
    transactionRepository: ref.watch(_transactionRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
  ),
);

final _getTransactionsUseCaseProvider = Provider(
  (ref) => GetTransactionsUseCase(
    transactionRepository: ref.watch(_transactionRepositoryProvider),
  ),
);

final _getSalesReportUseCaseProvider = Provider(
  (ref) => GetSalesReportUseCase(
    transactionRepository: ref.watch(_transactionRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  ),
);

final _exportSalesToCsvUseCaseProvider = Provider(
  (ref) => ExportSalesToCsvUseCase(),
);

final salesHistoryControllerProvider =
    ChangeNotifierProvider<SalesHistoryController>(
      (ref) => SalesHistoryController(
        getTransactionsUseCase: ref.watch(_getTransactionsUseCaseProvider),
      ),
    );

final salesReportControllerProvider =
    ChangeNotifierProvider<SalesReportController>(
      (ref) => SalesReportController(
        getSalesReportUseCase: ref.watch(_getSalesReportUseCaseProvider),
        exportSalesToCsvUseCase: ref.watch(_exportSalesToCsvUseCaseProvider),
        // getProfitReportUseCase is optional — add it when you migrate expenses
      ),
    );

// --- REFUND ---
final _refundTransactionUseCaseProvider = Provider(
  (ref) => RefundTransactionUseCase(
    transactionRepository: ref.watch(_transactionRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
    productVariantRepository: ref.watch(_productVariantRepositoryProvider),
    stockAdjustmentRepository: ref.watch(stockAdjustmentRepositoryProvider),
  ),
);
final refundControllerProvider = ChangeNotifierProvider<RefundController>(
  (ref) => RefundController(
    refundTransactionUseCase: ref.watch(_refundTransactionUseCaseProvider),
  ),
);
// ============================================================
// POS
// ============================================================

final _cartRepositoryProvider = Provider(
  (ref) =>
      CartRepositoryImpl(databaseHelper: ref.watch(databaseHelperProvider)),
);

final _addToCartUseCaseProvider = Provider(
  (ref) =>
      AddToCartUseCase(productRepository: ref.watch(productRepositoryProvider)),
);
final _removeFromCartUseCaseProvider = Provider(
  (ref) => RemoveFromCartUseCase(),
);
final _updateCartQuantityUseCaseProvider = Provider(
  (ref) => UpdateCartQuantityUseCase(),
);
final _saveCartUseCaseProvider = Provider(
  (ref) => SaveCartUseCase(cartRepository: ref.watch(_cartRepositoryProvider)),
);
final _getHeldCartsUseCaseProvider = Provider(
  (ref) =>
      GetHeldCartsUseCase(cartRepository: ref.watch(_cartRepositoryProvider)),
);
final _loadCartUseCaseProvider = Provider(
  (ref) => LoadCartUseCase(cartRepository: ref.watch(_cartRepositoryProvider)),
);
final _deleteHeldCartUseCaseProvider = Provider(
  (ref) =>
      DeleteHeldCartUseCase(cartRepository: ref.watch(_cartRepositoryProvider)),
);
final _checkoutUseCaseProvider = Provider(
  (ref) => CheckoutUseCase(
    productRepository: ref.watch(productRepositoryProvider),
    createTransactionUseCase: ref.watch(_createTransactionUseCaseProvider),
  ),
);

final posControllerProvider = ChangeNotifierProvider<POSController>(
  (ref) => POSController(
    getProductsUseCase: ref.watch(_getProductsUseCaseProvider),
    addToCartUseCase: ref.watch(_addToCartUseCaseProvider),
    removeFromCartUseCase: ref.watch(_removeFromCartUseCaseProvider),
    updateCartQuantityUseCase: ref.watch(_updateCartQuantityUseCaseProvider),
    checkoutUseCase: ref.watch(_checkoutUseCaseProvider),
    saveCartUseCase: ref.watch(_saveCartUseCaseProvider),
    getHeldCartsUseCase: ref.watch(_getHeldCartsUseCaseProvider),
    loadCartUseCase: ref.watch(_loadCartUseCaseProvider),
    deleteHeldCartUseCase: ref.watch(_deleteHeldCartUseCaseProvider),
  ),
);

// ============================================================
// CATEGORY
// ============================================================
final _getCategoriesUseCaseProvider = Provider(
  (ref) =>
      GetCategoriesUseCase(repository: ref.watch(categoryRepositoryProvider)),
);
final _addCategoryUseCaseProvider = Provider(
  (ref) =>
      AddCategoryUseCase(repository: ref.watch(categoryRepositoryProvider)),
);
final _updateCategoryUseCaseProvider = Provider(
  (ref) =>
      UpdateCategoryUseCase(repository: ref.watch(categoryRepositoryProvider)),
);
final _deleteCategoryUseCaseProvider = Provider(
  (ref) =>
      DeleteCategoryUseCase(repository: ref.watch(categoryRepositoryProvider)),
);
final categoryControllerProvider = ChangeNotifierProvider<CategoryController>(
  (ref) => CategoryController(
    getCategoriesUseCase: ref.watch(_getCategoriesUseCaseProvider),
    addCategoryUseCase: ref.watch(_addCategoryUseCaseProvider),
    updateCategoryUseCase: ref.watch(_updateCategoryUseCaseProvider),
    deleteCategoryUseCase: ref.watch(_deleteCategoryUseCaseProvider),
  ),
);

// ============================================================
// SHIFTS
// ============================================================
final _shiftLocalDataSourceProvider = Provider(
  (ref) => ShiftLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _shiftRepositoryProvider = Provider(
  (ref) => ShiftRepositoryImpl(
    localDataSource: ref.watch(_shiftLocalDataSourceProvider),
  ),
);
final _openShiftUseCaseProvider = Provider(
  (ref) =>
      OpenShiftUseCase(shiftRepository: ref.watch(_shiftRepositoryProvider)),
);
final _closeShiftUseCaseProvider = Provider(
  (ref) =>
      CloseShiftUseCase(shiftRepository: ref.watch(_shiftRepositoryProvider)),
);
final _getCurrentShiftUseCaseProvider = Provider(
  (ref) => GetCurrentShiftUseCase(
    shiftRepository: ref.watch(_shiftRepositoryProvider),
  ),
);
final _getShiftsUseCaseProvider = Provider(
  (ref) =>
      GetShiftsUseCase(shiftRepository: ref.watch(_shiftRepositoryProvider)),
);
final _updateShiftTotalsUseCaseProvider = Provider(
  (ref) => UpdateShiftTotalsUseCase(
    shiftRepository: ref.watch(_shiftRepositoryProvider),
  ),
);
final _cashCountLocalDataSourceProvider = Provider(
  (ref) => CashCountLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _cashCountRepositoryProvider = Provider(
  (ref) => CashCountRepositoryImpl(
    localDataSource: ref.watch(_cashCountLocalDataSourceProvider),
  ),
);
final _saveCashCountUseCaseProvider = Provider(
  (ref) => SaveCashCountUseCase(
    cashCountRepository: ref.watch(_cashCountRepositoryProvider),
  ),
);
final _getCashCountByShiftUseCaseProvider = Provider(
  (ref) => GetCashCountByShiftUseCase(
    cashCountRepository: ref.watch(_cashCountRepositoryProvider),
  ),
);

final shiftControllerProvider = ChangeNotifierProvider<ShiftController>(
  (ref) => ShiftController(
    openShiftUseCase: ref.watch(_openShiftUseCaseProvider),
    closeShiftUseCase: ref.watch(_closeShiftUseCaseProvider),
    getCurrentShiftUseCase: ref.watch(_getCurrentShiftUseCaseProvider),
    getShiftsUseCase: ref.watch(_getShiftsUseCaseProvider),
    updateShiftTotalsUseCase: ref.watch(_updateShiftTotalsUseCaseProvider),
    saveCashCountUseCase: ref.watch(_saveCashCountUseCaseProvider),
    getCashCountByShiftUseCase: ref.watch(_getCashCountByShiftUseCaseProvider),
  ),
);

// ============================================================
// PRODUCT VARIANTS
// ============================================================
final _productVariantLocalDataSourceProvider = Provider(
  (ref) => ProductVariantLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);

final _productVariantRepositoryProvider = Provider(
  (ref) => ProductVariantRepositoryImpl(
    dataSource: ref.watch(_productVariantLocalDataSourceProvider),
  ),
);
final _variantAttributeLocalDataSourceProvider = Provider(
  (ref) => VariantAttributeLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _variantAttributeRepositoryProvider = Provider(
  (ref) => VariantAttributeRepositoryImpl(
    dataSource: ref.watch(_variantAttributeLocalDataSourceProvider),
  ),
);
final _getVariantsUseCaseProvider = Provider(
  (ref) => GetProductVariantsUseCase(
    repository: ref.watch(_productVariantRepositoryProvider),
  ),
);
final _addVariantUseCaseProvider = Provider(
  (ref) => AddProductVariantUseCase(
    repository: ref.watch(_productVariantRepositoryProvider),
  ),
);
final _addVariantsBatchUseCaseProvider = Provider(
  (ref) => AddProductVariantsBatchUseCase(
    repository: ref.watch(_productVariantRepositoryProvider),
  ),
);
final _updateVariantUseCaseProvider = Provider(
  (ref) => UpdateProductVariantUseCase(
    repository: ref.watch(_productVariantRepositoryProvider),
  ),
);
final _updateVariantStockUseCaseProvider = Provider(
  (ref) => UpdateVariantStockUseCase(
    repository: ref.watch(_productVariantRepositoryProvider),
  ),
);
final _deleteVariantUseCaseProvider = Provider(
  (ref) => DeleteProductVariantUseCase(
    repository: ref.watch(_productVariantRepositoryProvider),
  ),
);
final _deleteVariantsByProductIdUseCaseProvider = Provider(
  (ref) => DeleteProductVariantsByProductIdUseCase(
    repository: ref.watch(_productVariantRepositoryProvider),
  ),
);
final _getAttributesUseCaseProvider = Provider(
  (ref) => GetVariantAttributesUseCase(
    repository: ref.watch(_variantAttributeRepositoryProvider),
  ),
);
final _addAttributeUseCaseProvider = Provider(
  (ref) => AddVariantAttributeUseCase(
    repository: ref.watch(_variantAttributeRepositoryProvider),
  ),
);
final _addAttributesBatchUseCaseProvider = Provider(
  (ref) => AddVariantAttributesBatchUseCase(
    repository: ref.watch(_variantAttributeRepositoryProvider),
  ),
);
final _deleteAttributesByProductIdUseCaseProvider = Provider(
  (ref) => DeleteVariantAttributesByProductIdUseCase(
    repository: ref.watch(_variantAttributeRepositoryProvider),
  ),
);
final productVariantControllerProvider =
    ChangeNotifierProvider<ProductVariantController>(
      (ref) => ProductVariantController(
        getVariantsUseCase: ref.watch(_getVariantsUseCaseProvider),
        addVariantUseCase: ref.watch(_addVariantUseCaseProvider),
        addVariantsBatchUseCase: ref.watch(_addVariantsBatchUseCaseProvider),
        updateVariantUseCase: ref.watch(_updateVariantUseCaseProvider),
        updateVariantStockUseCase: ref.watch(
          _updateVariantStockUseCaseProvider,
        ),
        deleteVariantUseCase: ref.watch(_deleteVariantUseCaseProvider),
        deleteVariantsByProductIdUseCase: ref.watch(
          _deleteVariantsByProductIdUseCaseProvider,
        ),
        getAttributesUseCase: ref.watch(_getAttributesUseCaseProvider),
        addAttributeUseCase: ref.watch(_addAttributeUseCaseProvider),
        addAttributesBatchUseCase: ref.watch(
          _addAttributesBatchUseCaseProvider,
        ),
        deleteAttributesByProductIdUseCase: ref.watch(
          _deleteAttributesByProductIdUseCaseProvider,
        ),
      ),
    );
// ============================================================
// THEME
// ============================================================
final themeControllerProvider = ChangeNotifierProvider<ThemeController>(
  (ref) => ThemeController(),
);

// ============================================================
// BACKUP
// ============================================================
final _backupLocalDataSourceProvider = Provider(
  (ref) => BackupLocalDataSource(),
);
final _backupDriveDataSourceProvider = Provider(
  (ref) => BackupDriveDataSource(),
);
final _backupRepositoryProvider = Provider(
  (ref) => BackupRepositoryImpl(
    localDataSource: ref.watch(_backupLocalDataSourceProvider),
    driveDataSource: ref.watch(_backupDriveDataSourceProvider),
  ),
);
final _backupDataCollectorProvider = Provider(
  (ref) =>
      BackupDataCollector(databaseHelper: ref.watch(databaseHelperProvider)),
);
final backupControllerProvider = ChangeNotifierProvider<BackupController>(
  (ref) => BackupController(
    backupService: BackupService(
      backupRepository: ref.watch(_backupRepositoryProvider),
      dataCollector: ref.watch(_backupDataCollectorProvider),
      databaseHelper: ref.watch(databaseHelperProvider),
    ),
  ),
);
// ============================================================
// EXPENSES
// ============================================================
final _expenseLocalDataSourceProvider = Provider(
  (ref) => ExpenseLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _expenseRepositoryProvider = Provider(
  (ref) => ExpenseRepositoryImpl(
    localDataSource: ref.watch(_expenseLocalDataSourceProvider),
  ),
);
final _addExpenseUseCaseProvider = Provider(
  (ref) => AddExpenseUseCase(ref.watch(_expenseRepositoryProvider)),
);
final _getExpensesUseCaseProvider = Provider(
  (ref) => GetExpensesUseCase(ref.watch(_expenseRepositoryProvider)),
);
final _updateExpenseUseCaseProvider = Provider(
  (ref) => UpdateExpenseUseCase(ref.watch(_expenseRepositoryProvider)),
);
final _deleteExpenseUseCaseProvider = Provider(
  (ref) => DeleteExpenseUseCase(ref.watch(_expenseRepositoryProvider)),
);
final _getExpenseSummaryUseCaseProvider = Provider(
  (ref) => GetExpenseSummaryUseCase(ref.watch(_expenseRepositoryProvider)),
);
final _getExpenseCountByCategoryUseCaseProvider = Provider(
  (ref) => GetExpenseCountByCategoryUseCase(
    repository: ref.watch(_expenseRepositoryProvider),
  ),
);
final expenseControllerProvider = ChangeNotifierProvider<ExpenseController>(
  (ref) => ExpenseController(
    addExpenseUseCase: ref.watch(_addExpenseUseCaseProvider),
    getExpensesUseCase: ref.watch(_getExpensesUseCaseProvider),
    updateExpenseUseCase: ref.watch(_updateExpenseUseCaseProvider),
    deleteExpenseUseCase: ref.watch(_deleteExpenseUseCaseProvider),
    getExpenseSummaryUseCase: ref.watch(_getExpenseSummaryUseCaseProvider),
    getExpenseCountByCategoryUseCase: ref.watch(
      _getExpenseCountByCategoryUseCaseProvider,
    ),
  ),
);

// ============================================================
// SUPPLIERS
// ============================================================
final _supplierLocalDataSourceProvider = Provider(
  (ref) => SupplierLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _supplierRepositoryProvider = Provider(
  (ref) => SupplierRepositoryImpl(
    localDataSource: ref.watch(_supplierLocalDataSourceProvider),
  ),
);
final _getSuppliersUseCaseProvider = Provider(
  (ref) =>
      GetSuppliersUseCase(repository: ref.watch(_supplierRepositoryProvider)),
);
final _addSupplierUseCaseProvider = Provider(
  (ref) =>
      AddSupplierUseCase(repository: ref.watch(_supplierRepositoryProvider)),
);
final _updateSupplierUseCaseProvider = Provider(
  (ref) =>
      UpdateSupplierUseCase(repository: ref.watch(_supplierRepositoryProvider)),
);
final _deleteSupplierUseCaseProvider = Provider(
  (ref) =>
      DeleteSupplierUseCase(repository: ref.watch(_supplierRepositoryProvider)),
);
final supplierControllerProvider = ChangeNotifierProvider<SupplierController>(
  (ref) => SupplierController(
    getSuppliersUseCase: ref.watch(_getSuppliersUseCaseProvider),
    addSupplierUseCase: ref.watch(_addSupplierUseCaseProvider),
    updateSupplierUseCase: ref.watch(_updateSupplierUseCaseProvider),
    deleteSupplierUseCase: ref.watch(_deleteSupplierUseCaseProvider),
  ),
);

// ============================================================
// FAVORITES
// ============================================================
final favoritesControllerProvider = ChangeNotifierProvider<FavoritesController>(
  (ref) => FavoritesController(FavoritesRepository()),
);

// ============================================================
// ANALYTICS
// ============================================================
final _getSalesAnalyticsUseCaseProvider = Provider(
  (ref) => GetSalesAnalyticsUseCase(
    productRepository: ref.watch(productRepositoryProvider),
    transactionRepository: ref.watch(_transactionRepositoryProvider),
  ),
);
final analyticsControllerProvider = ChangeNotifierProvider<AnalyticsController>(
  (ref) => AnalyticsController(
    getSalesAnalyticsUseCase: ref.watch(_getSalesAnalyticsUseCaseProvider),
  ),
);

// ============================================================
// CART
// ============================================================
final cartControllerProvider = ChangeNotifierProvider<CartController>(
  (ref) => CartController(
    transactionRepository: ref.watch(_transactionRepositoryProvider),
  ),
);

// ============================================================
// DISCOUNT (PROMOTIONS & PRESETS)
// ============================================================
final _promotionLocalDataSourceProvider = Provider(
  (ref) => PromotionLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _promotionRepositoryProvider = Provider(
  (ref) => PromotionRepositoryImpl(
    localDataSource: ref.watch(_promotionLocalDataSourceProvider),
  ),
);
final _discountPresetLocalDataSourceProvider = Provider(
  (ref) => DiscountPresetLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);
final _discountPresetRepositoryProvider = Provider(
  (ref) => DiscountPresetRepositoryImpl(
    localDataSource: ref.watch(_discountPresetLocalDataSourceProvider),
  ),
);
final _getPromotionsUseCaseProvider = Provider(
  (ref) => GetPromotionsUseCase(
    promotionRepository: ref.watch(_promotionRepositoryProvider),
  ),
);
final _addPromotionUseCaseProvider = Provider(
  (ref) => AddPromotionUseCase(
    promotionRepository: ref.watch(_promotionRepositoryProvider),
  ),
);
final _updatePromotionUseCaseProvider = Provider(
  (ref) => UpdatePromotionUseCase(
    promotionRepository: ref.watch(_promotionRepositoryProvider),
  ),
);
final _deletePromotionUseCaseProvider = Provider(
  (ref) => DeletePromotionUseCase(
    promotionRepository: ref.watch(_promotionRepositoryProvider),
  ),
);
final _togglePromotionUseCaseProvider = Provider(
  (ref) => TogglePromotionUseCase(
    promotionRepository: ref.watch(_promotionRepositoryProvider),
  ),
);
final _getDiscountPresetsUseCaseProvider = Provider(
  (ref) => GetDiscountPresetsUseCase(
    discountPresetRepository: ref.watch(_discountPresetRepositoryProvider),
  ),
);
final _addDiscountPresetUseCaseProvider = Provider(
  (ref) => AddDiscountPresetUseCase(
    discountPresetRepository: ref.watch(_discountPresetRepositoryProvider),
  ),
);
final _updateDiscountPresetUseCaseProvider = Provider(
  (ref) => UpdateDiscountPresetUseCase(
    discountPresetRepository: ref.watch(_discountPresetRepositoryProvider),
  ),
);
final _deleteDiscountPresetUseCaseProvider = Provider(
  (ref) => DeleteDiscountPresetUseCase(
    discountPresetRepository: ref.watch(_discountPresetRepositoryProvider),
  ),
);
final discountControllerProvider = ChangeNotifierProvider<DiscountController>(
  (ref) => DiscountController(
    getPromotionsUseCase: ref.watch(_getPromotionsUseCaseProvider),
    addPromotionUseCase: ref.watch(_addPromotionUseCaseProvider),
    updatePromotionUseCase: ref.watch(_updatePromotionUseCaseProvider),
    deletePromotionUseCase: ref.watch(_deletePromotionUseCaseProvider),
    togglePromotionUseCase: ref.watch(_togglePromotionUseCaseProvider),
    getDiscountPresetsUseCase: ref.watch(_getDiscountPresetsUseCaseProvider),
    addDiscountPresetUseCase: ref.watch(_addDiscountPresetUseCaseProvider),
    updateDiscountPresetUseCase: ref.watch(
      _updateDiscountPresetUseCaseProvider,
    ),
    deleteDiscountPresetUseCase: ref.watch(
      _deleteDiscountPresetUseCaseProvider,
    ),
  ),
);

// ============================================================
// SETTINGS
// ============================================================
final _settingsLocalDataSourceProvider = Provider(
  (ref) => SettingsLocalDataSource(),
);
final _settingsRepositoryProvider = Provider(
  (ref) => SettingsRepositoryImpl(
    localDataSource: ref.watch(_settingsLocalDataSourceProvider),
  ),
);
final settingsControllerProvider = ChangeNotifierProvider<SettingsController>(
  (ref) =>
      SettingsController(repository: ref.watch(_settingsRepositoryProvider)),
);

// ============================================================
// PRINTER SERVICE
// ============================================================
final printerServiceProvider = ChangeNotifierProvider<PrinterService>(
  (ref) => PrinterService(),
);
