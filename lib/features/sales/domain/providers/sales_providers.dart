import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Core & Cross-Feature Dependencies
import '../../../../core/database/database_helper.dart';
import '../../../inventory/data/repositories/product_repository_impl.dart';
import '../../../inventory/data/repositories/category_repository_impl.dart';
import '../../../expenses/data/repositories/expense_repository_impl.dart';

// Sales Data & Domain
import '../../data/datasources/transaction_local_datasource_impl.dart';
import '../../data/datasources/promotion_local_datasource_impl.dart';
import '../../data/datasources/discount_preset_local_datasource_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/promotion_repository_impl.dart';
import '../../data/repositories/discount_preset_repository_impl.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/get_sales_report_usecase.dart';
import '../../domain/usecases/export_sales_to_csv_usecase.dart';
import '../../domain/usecases/refund_transaction_usecase.dart';
import '../../domain/usecases/get_promotions_usecase.dart';
import '../../domain/usecases/add_promotion_usecase.dart';
import '../../domain/usecases/update_promotion_usecase.dart';
import '../../domain/usecases/delete_promotion_usecase.dart';
import '../../domain/usecases/toggle_promotion_usecase.dart';
import '../../domain/usecases/get_discount_presets_usecase.dart';
import '../../domain/usecases/add_discount_preset_usecase.dart';
import '../../domain/usecases/update_discount_preset_usecase.dart';
import '../../domain/usecases/delete_discount_preset_usecase.dart';

// Sales Controllers
import '../../presentation/controllers/sales_history_controller.dart';
import '../../presentation/controllers/sales_report_controller.dart';
import '../../presentation/controllers/refund_controller.dart';
import '../../presentation/controllers/discount_controller.dart';
import '../../presentation/controllers/cart_controller.dart';

// Note: This specific UseCase lives in Sales but depends on Expenses
import '../../../expenses/domain/usecases/get_profit_report_usecase.dart';

List<SingleChildWidget> createSalesProviders() {
  return [
    // --- DATA LAYER ---
    ProxyProvider<DatabaseHelper, TransactionLocalDataSourceImpl>(
      update: (_, db, __) => TransactionLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<DatabaseHelper, PromotionLocalDataSourceImpl>(
      update: (_, db, __) => PromotionLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<DatabaseHelper, DiscountPresetLocalDataSourceImpl>(
      update: (_, db, __) =>
          DiscountPresetLocalDataSourceImpl(databaseHelper: db),
    ),

    // --- REPOSITORY LAYER ---
    ProxyProvider<TransactionLocalDataSourceImpl, TransactionRepositoryImpl>(
      update: (_, ds, __) => TransactionRepositoryImpl(localDataSource: ds),
    ),
    ProxyProvider<PromotionLocalDataSourceImpl, PromotionRepositoryImpl>(
      update: (_, ds, __) => PromotionRepositoryImpl(localDataSource: ds),
    ),
    ProxyProvider<
      DiscountPresetLocalDataSourceImpl,
      DiscountPresetRepositoryImpl
    >(update: (_, ds, __) => DiscountPresetRepositoryImpl(localDataSource: ds)),

    // --- DOMAIN LAYER (Transactions & Reports) ---
    ProxyProvider2<
      TransactionRepositoryImpl,
      ProductRepositoryImpl,
      CreateTransactionUseCase
    >(
      update: (_, txRepo, prodRepo, __) => CreateTransactionUseCase(
        transactionRepository: txRepo,
        productRepository: prodRepo,
      ),
    ),
    ProxyProvider<TransactionRepositoryImpl, GetTransactionsUseCase>(
      update: (_, repo, __) =>
          GetTransactionsUseCase(transactionRepository: repo),
    ),
    ProxyProvider3<
      TransactionRepositoryImpl,
      ProductRepositoryImpl,
      CategoryRepositoryImpl,
      GetSalesReportUseCase
    >(
      update: (_, txRepo, prodRepo, catRepo, __) => GetSalesReportUseCase(
        transactionRepository: txRepo,
        productRepository: prodRepo,
        categoryRepository: catRepo,
      ),
    ),
    Provider<ExportSalesToCsvUseCase>(create: (_) => ExportSalesToCsvUseCase()),
    ProxyProvider2<
      TransactionRepositoryImpl,
      ProductRepositoryImpl,
      RefundTransactionUseCase
    >(
      update: (_, txRepo, prodRepo, __) => RefundTransactionUseCase(
        transactionRepository: txRepo,
        productRepository: prodRepo,
      ),
    ),

    // --- DOMAIN LAYER (Discounts) ---
    ProxyProvider<PromotionRepositoryImpl, GetPromotionsUseCase>(
      update: (_, repo, __) => GetPromotionsUseCase(promotionRepository: repo),
    ),
    // ... (You can add AddPromotion, UpdatePromotion, etc. here following the same pattern)

    // --- PRESENTATION LAYER ---
    ChangeNotifierProvider<SalesHistoryController>(
      create: (context) =>
          SalesHistoryController(getTransactionsUseCase: context.read()),
    ),
    ChangeNotifierProvider<RefundController>(
      create: (context) =>
          RefundController(refundTransactionUseCase: context.read()),
    ),
    ChangeNotifierProvider<DiscountController>(
      create: (context) => DiscountController(
        getPromotionsUseCase: context.read(),
        addPromotionUseCase: context
            .read<
              AddPromotionUseCase
            >(), // Ensure these exist or use context.read()
        updatePromotionUseCase: context.read<UpdatePromotionUseCase>(),
        deletePromotionUseCase: context.read<DeletePromotionUseCase>(),
        togglePromotionUseCase: context.read<TogglePromotionUseCase>(),
        getDiscountPresetsUseCase: context.read<GetDiscountPresetsUseCase>(),
        addDiscountPresetUseCase: context.read<AddDiscountPresetUseCase>(),
        updateDiscountPresetUseCase: context
            .read<UpdateDiscountPresetUseCase>(),
        deleteDiscountPresetUseCase: context
            .read<DeleteDiscountPresetUseCase>(),
      ),
    ),
    ChangeNotifierProvider<SalesReportController>(
      create: (context) => SalesReportController(
        getSalesReportUseCase: context.read(),
        exportSalesToCsvUseCase: context.read(),
        getProfitReportUseCase: context.read(),
      ),
    ),
    ChangeNotifierProvider<CartController>(
      create: (context) => CartController(
        transactionRepository: context.read<TransactionRepositoryImpl>(),
      ),
    ),
  ];
}
