import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Core & Inventory Dependencies
import '../../../../core/database/database_helper.dart';
import '../../../inventory/data/repositories/product_repository_impl.dart';
import '../../../inventory/domain/usecases/get_products_usecase.dart';

// POS Specifics
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';
import '../../domain/usecases/save_cart_usecase.dart';
import '../../domain/usecases/get_held_carts_usecase.dart';
import '../../domain/usecases/load_cart_usecase.dart';
import '../../domain/usecases/delete_held_cart_usecase.dart';
import '../../presentation/controllers/pos_controller.dart';
import '../../presentation/controllers/favorites_controller.dart';

// Note: Sales dependency (We will migrate Sales next)
import '../../../sales/domain/usecases/create_transaction_usecase.dart';

List<SingleChildWidget> createPOSProviders() {
  return [
    // --- DATA LAYER ---
    ProxyProvider<DatabaseHelper, CartRepositoryImpl>(
      update: (_, db, __) => CartRepositoryImpl(databaseHelper: db),
    ),
    Provider<FavoritesRepository>(create: (_) => FavoritesRepository()),

    // --- DOMAIN LAYER (Use Cases) ---
    Provider<SaveCartUseCase>(
      create: (context) => SaveCartUseCase(cartRepository: context.read()),
    ),
    Provider<GetHeldCartsUseCase>(
      create: (context) => GetHeldCartsUseCase(cartRepository: context.read()),
    ),
    Provider<LoadCartUseCase>(
      create: (context) => LoadCartUseCase(cartRepository: context.read()),
    ),
    Provider<DeleteHeldCartUseCase>(
      create: (context) =>
          DeleteHeldCartUseCase(cartRepository: context.read()),
    ),
    ProxyProvider2<ProductRepositoryImpl, GetProductsUseCase, AddToCartUseCase>(
      update: (_, repo, __, ___) => AddToCartUseCase(productRepository: repo),
    ),
    Provider<RemoveFromCartUseCase>(create: (_) => RemoveFromCartUseCase()),
    Provider<UpdateCartQuantityUseCase>(
      create: (_) => UpdateCartQuantityUseCase(),
    ),

    // This one depends on Sales (Ensure Sales providers are added in main.dart soon)
    ProxyProvider2<
      ProductRepositoryImpl,
      CreateTransactionUseCase,
      CheckoutUseCase
    >(
      update: (_, repo, createTx, __) => CheckoutUseCase(
        productRepository: repo,
        createTransactionUseCase: createTx,
      ),
    ),

    // --- PRESENTATION LAYER ---
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
    ChangeNotifierProvider<FavoritesController>(
      create: (context) => FavoritesController(context.read())..loadFavorites(),
    ),
  ];
}
