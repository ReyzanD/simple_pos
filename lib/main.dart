import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/controllers/theme_controller.dart';

// Services - Database
import 'services/database/database_helper.dart';

// Features - Inventory
import 'features/inventory/data/datasources/product_local_datasource_impl.dart';
import 'features/inventory/data/datasources/category_local_datasource_impl.dart';
import 'features/inventory/data/datasources/supplier_local_datasource_impl.dart';
import 'features/inventory/data/datasources/product_variant_local_datasource.dart';
import 'features/inventory/data/repositories/product_repository_impl.dart';
import 'features/inventory/data/repositories/category_repository_impl.dart';
import 'features/inventory/data/repositories/supplier_repository_impl.dart';
import 'features/inventory/data/repositories/product_variant_repository_impl.dart';
import 'features/inventory/domain/usecases/add_product_usecase.dart';
import 'features/inventory/domain/usecases/delete_product_usecase.dart';
import 'features/inventory/domain/usecases/get_products_usecase.dart';
import 'features/inventory/domain/usecases/search_products_usecase.dart';
import 'features/inventory/domain/usecases/update_product_usecase.dart';
import 'features/inventory/domain/usecases/category_usecases.dart';
import 'features/inventory/domain/usecases/supplier_usecases.dart';
import 'features/inventory/domain/usecases/get_product_variants_usecase.dart';
import 'features/inventory/domain/usecases/add_product_variant_usecase.dart';
import 'features/inventory/domain/usecases/update_product_variant_usecase.dart';
import 'features/inventory/domain/usecases/delete_product_variant_usecase.dart';
import 'features/inventory/domain/usecases/variant_attribute_usecases.dart';
import 'features/inventory/presentation/controllers/inventory_controller.dart';
import 'features/inventory/presentation/controllers/category_controller.dart';
import 'features/inventory/presentation/controllers/supplier_controller.dart';
import 'features/inventory/presentation/controllers/product_variant_controller.dart';

// Features - POS
import 'features/pos/data/repositories/cart_repository_impl.dart';
import 'features/pos/domain/usecases/add_to_cart_usecase.dart';
import 'features/pos/domain/usecases/checkout_usecase.dart';
import 'features/pos/domain/usecases/remove_from_cart_usecase.dart';
import 'features/pos/domain/usecases/update_cart_quantity_usecase.dart';
import 'features/pos/domain/usecases/save_cart_usecase.dart';
import 'features/pos/domain/usecases/get_held_carts_usecase.dart';
import 'features/pos/domain/usecases/load_cart_usecase.dart';
import 'features/pos/domain/usecases/delete_held_cart_usecase.dart';
import 'features/pos/presentation/controllers/pos_controller.dart';

// Features - Sales
import 'features/sales/data/datasources/transaction_local_datasource_impl.dart';
import 'features/sales/data/datasources/promotion_local_datasource_impl.dart';
import 'features/sales/data/datasources/discount_preset_local_datasource_impl.dart';
import 'features/sales/data/repositories/transaction_repository_impl.dart';
import 'features/sales/data/repositories/promotion_repository_impl.dart';
import 'features/sales/data/repositories/discount_preset_repository_impl.dart';
import 'features/sales/domain/usecases/create_transaction_usecase.dart';
import 'features/sales/domain/usecases/get_transactions_usecase.dart';
import 'features/sales/domain/usecases/get_sales_report_usecase.dart';
import 'features/sales/domain/usecases/export_sales_to_csv_usecase.dart';
import 'features/sales/domain/usecases/refund_transaction_usecase.dart';
import 'features/sales/domain/usecases/get_promotions_usecase.dart';
import 'features/sales/domain/usecases/add_promotion_usecase.dart';
import 'features/sales/domain/usecases/update_promotion_usecase.dart';
import 'features/sales/domain/usecases/delete_promotion_usecase.dart';
import 'features/sales/domain/usecases/toggle_promotion_usecase.dart';
import 'features/sales/domain/usecases/get_discount_presets_usecase.dart';
import 'features/sales/domain/usecases/add_discount_preset_usecase.dart';
import 'features/sales/domain/usecases/update_discount_preset_usecase.dart';
import 'features/sales/domain/usecases/delete_discount_preset_usecase.dart';
import 'features/sales/presentation/controllers/sales_history_controller.dart';
import 'features/sales/presentation/controllers/sales_report_controller.dart';
import 'features/sales/presentation/controllers/refund_controller.dart';
import 'features/sales/presentation/controllers/discount_controller.dart';

// Features - Settings
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';

// Shared
import 'features/shared/presentation/main_navigation.dart';

void main() {
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Controller
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController()..init(),
        ),

        // Database
        Provider<DatabaseHelper>(
          lazy: false,
          create: (_) => DatabaseHelper.instance,
        ),

        // Inventory - Data Layer
        ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(
          update: (_, db, _) => ProductLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(
          update: (_, dataSource, _) =>
              ProductRepositoryImpl(localDataSource: dataSource),
        ),

        // Inventory - Domain Layer (Use Cases)
        ProxyProvider<ProductRepositoryImpl, GetProductsUseCase>(
          update: (_, repo, _) => GetProductsUseCase(repository: repo),
        ),
        ProxyProvider<ProductRepositoryImpl, AddProductUseCase>(
          update: (_, repo, _) => AddProductUseCase(repository: repo),
        ),
        ProxyProvider<ProductRepositoryImpl, UpdateProductUseCase>(
          update: (_, repo, _) => UpdateProductUseCase(repository: repo),
        ),
        ProxyProvider<ProductRepositoryImpl, DeleteProductUseCase>(
          update: (_, repo, _) => DeleteProductUseCase(repository: repo),
        ),
        ProxyProvider<ProductRepositoryImpl, SearchProductsUseCase>(
          update: (_, repo, _) => SearchProductsUseCase(repository: repo),
        ),

        // Inventory - Presentation Layer (Controller)
        ChangeNotifierProxyProvider5<
          GetProductsUseCase,
          AddProductUseCase,
          UpdateProductUseCase,
          DeleteProductUseCase,
          SearchProductsUseCase,
          InventoryController
        >(
          create: (context) => InventoryController(
            getProductsUseCase: context.read(),
            addProductUseCase: context.read(),
            updateProductUseCase: context.read(),
            deleteProductUseCase: context.read(),
            searchProductsUseCase: context.read(),
          ),
          update: (_, getProducts, add, update, delete, search, _) =>
              InventoryController(
                getProductsUseCase: getProducts,
                addProductUseCase: add,
                updateProductUseCase: update,
                deleteProductUseCase: delete,
                searchProductsUseCase: search,
              ),
        ),

        // Category - Data Layer
        ProxyProvider<DatabaseHelper, CategoryLocalDataSourceImpl>(
          update: (_, db, _) => CategoryLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<CategoryLocalDataSourceImpl, CategoryRepositoryImpl>(
          update: (_, dataSource, _) =>
              CategoryRepositoryImpl(localDataSource: dataSource),
        ),

        // Category - Domain Layer (Use Cases)
        ProxyProvider<CategoryRepositoryImpl, GetCategoriesUseCase>(
          update: (_, repo, _) => GetCategoriesUseCase(repository: repo),
        ),
        ProxyProvider<CategoryRepositoryImpl, AddCategoryUseCase>(
          update: (_, repo, _) => AddCategoryUseCase(repository: repo),
        ),
        ProxyProvider<CategoryRepositoryImpl, UpdateCategoryUseCase>(
          update: (_, repo, _) => UpdateCategoryUseCase(repository: repo),
        ),
        ProxyProvider<CategoryRepositoryImpl, DeleteCategoryUseCase>(
          update: (_, repo, _) => DeleteCategoryUseCase(repository: repo),
        ),

        // Category - Presentation Layer (Controller)
        ChangeNotifierProxyProvider4<
          GetCategoriesUseCase,
          AddCategoryUseCase,
          UpdateCategoryUseCase,
          DeleteCategoryUseCase,
          CategoryController
        >(
          create: (context) => CategoryController(
            getCategoriesUseCase: context.read(),
            addCategoryUseCase: context.read(),
            updateCategoryUseCase: context.read(),
            deleteCategoryUseCase: context.read(),
          ),
          update: (_, get, add, update, delete, _) => CategoryController(
            getCategoriesUseCase: get,
            addCategoryUseCase: add,
            updateCategoryUseCase: update,
            deleteCategoryUseCase: delete,
          ),
        ),

        // Supplier - Data Layer
        ProxyProvider<DatabaseHelper, SupplierLocalDataSourceImpl>(
          update: (_, db, _) => SupplierLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<SupplierLocalDataSourceImpl, SupplierRepositoryImpl>(
          update: (_, dataSource, _) =>
              SupplierRepositoryImpl(localDataSource: dataSource),
        ),

        // Supplier - Domain Layer (Use Cases)
        ProxyProvider<SupplierRepositoryImpl, GetSuppliersUseCase>(
          update: (_, repo, _) => GetSuppliersUseCase(repository: repo),
        ),
        ProxyProvider<SupplierRepositoryImpl, AddSupplierUseCase>(
          update: (_, repo, _) => AddSupplierUseCase(repository: repo),
        ),
        ProxyProvider<SupplierRepositoryImpl, UpdateSupplierUseCase>(
          update: (_, repo, _) => UpdateSupplierUseCase(repository: repo),
        ),
        ProxyProvider<SupplierRepositoryImpl, DeleteSupplierUseCase>(
          update: (_, repo, _) => DeleteSupplierUseCase(repository: repo),
        ),

        // Supplier - Presentation Layer (Controller)
        ChangeNotifierProxyProvider4<
          GetSuppliersUseCase,
          AddSupplierUseCase,
          UpdateSupplierUseCase,
          DeleteSupplierUseCase,
          SupplierController
        >(
          create: (context) => SupplierController(
            getSuppliersUseCase: context.read(),
            addSupplierUseCase: context.read(),
            updateSupplierUseCase: context.read(),
            deleteSupplierUseCase: context.read(),
          ),
          update: (_, get, add, update, delete, _) => SupplierController(
            getSuppliersUseCase: get,
            addSupplierUseCase: add,
            updateSupplierUseCase: update,
            deleteSupplierUseCase: delete,
          ),
        ),

        // Product Variant - Data Layer
        ProxyProvider<DatabaseHelper, ProductVariantLocalDataSourceImpl>(
          update: (_, db, __) => ProductVariantLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<ProductVariantLocalDataSourceImpl, ProductVariantRepositoryImpl>(
          update: (_, dataSource, __) =>
              ProductVariantRepositoryImpl(dataSource: dataSource),
        ),

        ProxyProvider<DatabaseHelper, VariantAttributeLocalDataSourceImpl>(
          update: (_, db, __) => VariantAttributeLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<VariantAttributeLocalDataSourceImpl, VariantAttributeRepositoryImpl>(
          update: (_, dataSource, __) =>
              VariantAttributeRepositoryImpl(dataSource: dataSource),
        ),

        // Product Variant - Domain Layer (Use Cases)
        ProxyProvider<ProductVariantRepositoryImpl, GetProductVariantsUseCase>(
          update: (_, repo, _) => GetProductVariantsUseCase(repository: repo),
        ),
        ProxyProvider<ProductVariantRepositoryImpl, AddProductVariantUseCase>(
          update: (_, repo, _) => AddProductVariantUseCase(repository: repo),
        ),
        ProxyProvider<ProductVariantRepositoryImpl, AddProductVariantsBatchUseCase>(
          update: (_, repo, _) => AddProductVariantsBatchUseCase(repository: repo),
        ),
        ProxyProvider<ProductVariantRepositoryImpl, UpdateProductVariantUseCase>(
          update: (_, repo, _) => UpdateProductVariantUseCase(repository: repo),
        ),
        ProxyProvider<ProductVariantRepositoryImpl, UpdateVariantStockUseCase>(
          update: (_, repo, _) => UpdateVariantStockUseCase(repository: repo),
        ),
        ProxyProvider<ProductVariantRepositoryImpl, DeleteProductVariantUseCase>(
          update: (_, repo, _) => DeleteProductVariantUseCase(repository: repo),
        ),
        ProxyProvider<ProductVariantRepositoryImpl, DeleteProductVariantsByProductIdUseCase>(
          update: (_, repo, _) => DeleteProductVariantsByProductIdUseCase(repository: repo),
        ),

        ProxyProvider<VariantAttributeRepositoryImpl, GetVariantAttributesUseCase>(
          update: (_, repo, _) => GetVariantAttributesUseCase(repository: repo),
        ),
        ProxyProvider<VariantAttributeRepositoryImpl, AddVariantAttributeUseCase>(
          update: (_, repo, _) => AddVariantAttributeUseCase(repository: repo),
        ),
        ProxyProvider<VariantAttributeRepositoryImpl, AddVariantAttributesBatchUseCase>(
          update: (_, repo, _) => AddVariantAttributesBatchUseCase(repository: repo),
        ),
        ProxyProvider<VariantAttributeRepositoryImpl, DeleteVariantAttributesByProductIdUseCase>(
          update: (_, repo, _) => DeleteVariantAttributesByProductIdUseCase(repository: repo),
        ),

        // Product Variant - Presentation Layer (Controller)
        ChangeNotifierProvider<ProductVariantController>(
          create: (context) => ProductVariantController(
            getVariantsUseCase: context.read<GetProductVariantsUseCase>(),
            addVariantUseCase: context.read<AddProductVariantUseCase>(),
            addVariantsBatchUseCase: context.read<AddProductVariantsBatchUseCase>(),
            updateVariantUseCase: context.read<UpdateProductVariantUseCase>(),
            updateVariantStockUseCase: context.read<UpdateVariantStockUseCase>(),
            deleteVariantUseCase: context.read<DeleteProductVariantUseCase>(),
            deleteVariantsByProductIdUseCase: context.read<DeleteProductVariantsByProductIdUseCase>(),
            getAttributesUseCase: context.read<GetVariantAttributesUseCase>(),
            addAttributeUseCase: context.read<AddVariantAttributeUseCase>(),
            addAttributesBatchUseCase: context.read<AddVariantAttributesBatchUseCase>(),
            deleteAttributesByProductIdUseCase: context.read<DeleteVariantAttributesByProductIdUseCase>(),
          ),
        ),

        // Sales - Data Layer
        ProxyProvider<DatabaseHelper, TransactionLocalDataSourceImpl>(
          update: (_, db, _) =>
              TransactionLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<
          TransactionLocalDataSourceImpl,
          TransactionRepositoryImpl
        >(
          update: (_, dataSource, _) =>
              TransactionRepositoryImpl(localDataSource: dataSource),
        ),

        // Sales - Domain Layer (Use Cases)
        ProxyProvider2<
          TransactionRepositoryImpl,
          ProductRepositoryImpl,
          CreateTransactionUseCase
        >(
          update: (_, transactionRepo, productRepo, _) =>
              CreateTransactionUseCase(
                transactionRepository: transactionRepo,
                productRepository: productRepo,
              ),
        ),
        ProxyProvider<TransactionRepositoryImpl, GetTransactionsUseCase>(
          update: (_, repo, _) =>
              GetTransactionsUseCase(transactionRepository: repo),
        ),
        ProxyProvider3<
          TransactionRepositoryImpl,
          ProductRepositoryImpl,
          CategoryRepositoryImpl,
          GetSalesReportUseCase
        >(
          update: (_, transactionRepo, productRepo, categoryRepo, _) => GetSalesReportUseCase(
            transactionRepository: transactionRepo,
            productRepository: productRepo,
            categoryRepository: categoryRepo,
          ),
        ),
        Provider<ExportSalesToCsvUseCase>(
          create: (_) => ExportSalesToCsvUseCase(),
        ),
        ProxyProvider2<
          TransactionRepositoryImpl,
          ProductRepositoryImpl,
          RefundTransactionUseCase
        >(
          update: (_, transactionRepo, productRepo, _) => RefundTransactionUseCase(
            transactionRepository: transactionRepo,
            productRepository: productRepo,
          ),
        ),

        // Sales - Presentation Layer (Controllers)
        ChangeNotifierProvider<SalesHistoryController>(
          create: (context) =>
              SalesHistoryController(getTransactionsUseCase: context.read()),
        ),
        ChangeNotifierProvider<RefundController>(
          create: (context) =>
              RefundController(refundTransactionUseCase: context.read()),
        ),
        ChangeNotifierProvider<SalesReportController>(
          create: (context) =>
              SalesReportController(
                getSalesReportUseCase: context.read(),
                exportSalesToCsvUseCase: context.read(),
              ),
        ),

        // Settings - Data Layer
        Provider<SettingsLocalDataSource>(
          create: (_) => SettingsLocalDataSource(),
        ),

        Provider<SettingsRepositoryImpl>(
          create: (context) =>
              SettingsRepositoryImpl(localDataSource: context.read()),
        ),

        // Settings - Presentation Layer (Controller)
        ChangeNotifierProvider<SettingsController>(
          create: (context) => SettingsController(
            repository: context.read<SettingsRepositoryImpl>(),
          ),
        ),

        // POS - Data Layer
        ProxyProvider<DatabaseHelper, CartRepositoryImpl>(
          update: (_, db, __) => CartRepositoryImpl(databaseHelper: db),
        ),

        // POS - Domain Layer (Use Cases)
        Provider<SaveCartUseCase>(
          create: (context) => SaveCartUseCase(
            cartRepository: context.read<CartRepositoryImpl>(),
          ),
        ),
        Provider<GetHeldCartsUseCase>(
          create: (context) => GetHeldCartsUseCase(
            cartRepository: context.read<CartRepositoryImpl>(),
          ),
        ),
        Provider<LoadCartUseCase>(
          create: (context) => LoadCartUseCase(
            cartRepository: context.read<CartRepositoryImpl>(),
          ),
        ),
        Provider<DeleteHeldCartUseCase>(
          create: (context) => DeleteHeldCartUseCase(
            cartRepository: context.read<CartRepositoryImpl>(),
          ),
        ),

        // POS - Domain Layer (Use Cases)
        ProxyProvider2<
          ProductRepositoryImpl,
          GetProductsUseCase,
          AddToCartUseCase
        >(
          update: (_, repo, getProducts, _) =>
              AddToCartUseCase(productRepository: repo),
        ),
        Provider<RemoveFromCartUseCase>(create: (_) => RemoveFromCartUseCase()),
        Provider<UpdateCartQuantityUseCase>(
          create: (_) => UpdateCartQuantityUseCase(),
        ),
        ProxyProvider2<
          ProductRepositoryImpl,
          CreateTransactionUseCase,
          CheckoutUseCase
        >(
          update: (_, repo, createTransaction, _) => CheckoutUseCase(
            productRepository: repo,
            createTransactionUseCase: createTransaction,
          ),
        ),

        // POS - Presentation Layer (Controller)
        ChangeNotifierProvider<POSController>(
          create: (context) => POSController(
            getProductsUseCase: context.read(),
            addToCartUseCase: context.read(),
            removeFromCartUseCase: context.read(),
            updateCartQuantityUseCase: context.read(),
            checkoutUseCase: context.read(),
            saveCartUseCase: context.read(),
            getHeldCartsUseCase: context.read(),
            loadCartUseCase: context.read(),
            deleteHeldCartUseCase: context.read(),
          ),
        ),

        // ========== DISCOUNT MANAGEMENT ==========
        // Discount Management - Data Layer
        ProxyProvider<DatabaseHelper, PromotionLocalDataSourceImpl>(
          update: (_, db, _) =>
              PromotionLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<PromotionLocalDataSourceImpl, PromotionRepositoryImpl>(
          update: (_, dataSource, _) =>
              PromotionRepositoryImpl(localDataSource: dataSource),
        ),

        ProxyProvider<DatabaseHelper, DiscountPresetLocalDataSourceImpl>(
          update: (_, db, _) =>
              DiscountPresetLocalDataSourceImpl(databaseHelper: db),
        ),

        ProxyProvider<DiscountPresetLocalDataSourceImpl, DiscountPresetRepositoryImpl>(
          update: (_, dataSource, _) =>
              DiscountPresetRepositoryImpl(localDataSource: dataSource),
        ),

        // Discount Management - Domain Layer (Use Cases)
        ProxyProvider<PromotionRepositoryImpl, GetPromotionsUseCase>(
          update: (_, repo, _) => GetPromotionsUseCase(promotionRepository: repo),
        ),
        ProxyProvider<PromotionRepositoryImpl, AddPromotionUseCase>(
          update: (_, repo, _) => AddPromotionUseCase(promotionRepository: repo),
        ),
        ProxyProvider<PromotionRepositoryImpl, UpdatePromotionUseCase>(
          update: (_, repo, _) => UpdatePromotionUseCase(promotionRepository: repo),
        ),
        ProxyProvider<PromotionRepositoryImpl, DeletePromotionUseCase>(
          update: (_, repo, _) => DeletePromotionUseCase(promotionRepository: repo),
        ),
        ProxyProvider<PromotionRepositoryImpl, TogglePromotionUseCase>(
          update: (_, repo, _) => TogglePromotionUseCase(promotionRepository: repo),
        ),

        ProxyProvider<DiscountPresetRepositoryImpl, GetDiscountPresetsUseCase>(
          update: (_, repo, _) => GetDiscountPresetsUseCase(discountPresetRepository: repo),
        ),
        ProxyProvider<DiscountPresetRepositoryImpl, AddDiscountPresetUseCase>(
          update: (_, repo, _) => AddDiscountPresetUseCase(discountPresetRepository: repo),
        ),
        ProxyProvider<DiscountPresetRepositoryImpl, UpdateDiscountPresetUseCase>(
          update: (_, repo, _) => UpdateDiscountPresetUseCase(discountPresetRepository: repo),
        ),
        ProxyProvider<DiscountPresetRepositoryImpl, DeleteDiscountPresetUseCase>(
          update: (_, repo, _) => DeleteDiscountPresetUseCase(discountPresetRepository: repo),
        ),

        // Discount Management - Presentation Layer (Controller)
        ChangeNotifierProvider<DiscountController>(
          create: (context) => DiscountController(
            getPromotionsUseCase: context.read<GetPromotionsUseCase>(),
            addPromotionUseCase: context.read<AddPromotionUseCase>(),
            updatePromotionUseCase: context.read<UpdatePromotionUseCase>(),
            deletePromotionUseCase: context.read<DeletePromotionUseCase>(),
            togglePromotionUseCase: context.read<TogglePromotionUseCase>(),
            getDiscountPresetsUseCase: context.read<GetDiscountPresetsUseCase>(),
            addDiscountPresetUseCase: context.read<AddDiscountPresetUseCase>(),
            updateDiscountPresetUseCase: context.read<UpdateDiscountPresetUseCase>(),
            deleteDiscountPresetUseCase: context.read<DeleteDiscountPresetUseCase>(),
          ),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('id', ''), // Indonesian
            ],
            locale: const Locale('id', ''), // Default to Indonesian
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}
