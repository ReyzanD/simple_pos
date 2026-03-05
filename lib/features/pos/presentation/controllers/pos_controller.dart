import 'package:flutter/foundation.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';
import '../../domain/usecases/save_cart_usecase.dart';
import '../../domain/usecases/get_held_carts_usecase.dart';
import '../../domain/usecases/load_cart_usecase.dart';
import '../../domain/usecases/delete_held_cart_usecase.dart';
import '../../../inventory/domain/usecases/get_products_usecase.dart';
import '../../../inventory/domain/entities/category.dart' as inventory;
import '../../../sales/domain/entities/payment_method.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing POS state and operations
class POSController extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final CheckoutUseCase checkoutUseCase;
  final SaveCartUseCase saveCartUseCase;
  final GetHeldCartsUseCase getHeldCartsUseCase;
  final LoadCartUseCase loadCartUseCase;
  final DeleteHeldCartUseCase deleteHeldCartUseCase;

  bool _disposed = false;

  POSController({
    required this.getProductsUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.checkoutUseCase,
    required this.saveCartUseCase,
    required this.getHeldCartsUseCase,
    required this.loadCartUseCase,
    required this.deleteHeldCartUseCase,
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  List<Product> _products = [];
  List<CartItem> _cart = [];
  bool _isLoading = false;
  bool _isCheckingOut = false;
  bool _isLoadingHeldCarts = false;
  AppException? _error;
  String _searchQuery = '';
  inventory.Category? _selectedCategory;
  CartItem? _lastRemovedCartItem;
  List<HeldCart> _heldCarts = [];

  // Getters
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  bool get isLoading => _isLoading;
  bool get isCheckingOut => _isCheckingOut;
  bool get isLoadingHeldCarts => _isLoadingHeldCarts;
  AppException? get error => _error;
  bool get hasError => _error != null;
  bool get isCartEmpty => _cart.isEmpty;
  bool get hasProducts => _products.isNotEmpty;
  String get searchQuery => _searchQuery;
  inventory.Category? get selectedCategory => _selectedCategory;
  CartItem? get lastRemovedCartItem => _lastRemovedCartItem;
  List<HeldCart> get heldCarts => _heldCarts;

  /// Get filtered products based on search query and category
  List<Product> get filteredProducts {
    var filtered = _products;

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.categoryId == _selectedCategory!.id).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(query) ||
        (p.barcode?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return filtered;
  }

  /// Calculate cart total
  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Get total number of items in cart
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  /// Load products for POS
  Future<void> loadProducts() async {
    try {
      AppLogger.ui('Loading products for POS', details: 'POSController');
      _setLoading(true);
      _clearError();

      _products = await getProductsUseCase.execute();

      AppLogger.info('Products loaded for POS - POSController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load products - POSController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat produk',
        operation: 'loadProducts',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading products - POSController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Add product to cart
  Future<bool> addToCart(Product product) async {
    try {
      AppLogger.ui('Adding to cart', details: 'POSController');

      _cart = await addToCartUseCase.execute(
        currentCart: _cart,
        product: product,
      );

      // Notify listeners to update UI
      if (!_disposed) {
        notifyListeners();
      }

      AppLogger.info('Product added to cart - POSController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add to cart - POSController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan ke keranjang',
        operation: 'addToCart',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding to cart - POSController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Remove product from cart
  void removeFromCart(Product product) {
    try {
      AppLogger.ui('Removing from cart', details: 'POSController');

      // Store the cart item for undo before removing
      _lastRemovedCartItem = _cart.firstWhere((item) => item.product.id == product.id);

      _cart = removeFromCartUseCase.execute(
        currentCart: _cart,
        product: product,
      );

      if (!_disposed) {
        notifyListeners();
      }
      AppLogger.info('Product removed from cart - POSController');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to remove from cart - POSController',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Undo remove from cart - restore the last removed cart item
  void undoRemoveFromCart() {
    if (_lastRemovedCartItem == null) return;

    try {
      AppLogger.ui('Undoing remove from cart', details: 'POSController');

      // Restore the cart item
      _cart = [..._cart, _lastRemovedCartItem!];
      _lastRemovedCartItem = null;

      if (!_disposed) {
        notifyListeners();
      }
      AppLogger.info('Cart item restored successfully - POSController');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to undo remove from cart - POSController',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update cart item quantity
  bool updateCartQuantity(Product product, int quantity) {
    try {
      AppLogger.ui('Updating cart quantity', details: 'POSController');

      // Store the cart item for undo if quantity is being set to 0 (removing)
      if (quantity == 0) {
        _lastRemovedCartItem = _cart.firstWhere((item) => item.product.id == product.id);
      }

      _cart = updateCartQuantityUseCase.execute(
        currentCart: _cart,
        product: product,
        newQuantity: quantity,
      );

      if (!_disposed) {
        notifyListeners();
      }
      AppLogger.info('Cart quantity updated - POSController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error(
        'Failed to update cart quantity - POSController',
        error: e,
      );
      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error updating cart quantity - POSController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Process checkout
  Future<bool> checkout() async {
    if (_cart.isEmpty) {
      _setError(const EmptyCartException('Keranjang kosong'));
      return false;
    }

    try {
      AppLogger.ui('Processing checkout', details: 'POSController');
      _setCheckingOut(true);
      _clearError();

      // Process checkout with default cash payment
      final result = await checkoutUseCase.executeWithCashPayment(
        cart: _cart,
      );

      if (!result.success) {
        _setError(DatabaseException(
          result.message ?? 'Checkout gagal',
          operation: 'checkout',
        ));
        return false;
      }

      // Clear cart and reload products
      _cart.clear();
      await loadProducts();

      AppLogger.info('Checkout completed successfully - POSController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Checkout failed - POSController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memproses checkout',
        operation: 'checkout',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error during checkout - POSController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setCheckingOut(false);
    }
  }

  /// Process checkout with selected payment method
  Future<bool> checkoutWithPayment({
    required PaymentMethod paymentMethod,
    double? cashReceived,
    String? cardLast4Digits,
  }) async {
    if (_cart.isEmpty) {
      _setError(const EmptyCartException('Keranjang kosong'));
      return false;
    }

    try {
      AppLogger.ui('Processing checkout with $paymentMethod', details: 'POSController');
      _setCheckingOut(true);
      _clearError();

      // Process checkout with selected payment method
      final result = await checkoutUseCase.execute(
        cart: _cart,
        paymentMethod: paymentMethod,
        cashReceived: cashReceived,
        cardLast4Digits: cardLast4Digits,
      );

      if (!result.success) {
        _setError(DatabaseException(
          result.message ?? 'Checkout gagal',
          operation: 'checkout',
        ));
        return false;
      }

      // Clear cart and reload products
      _cart.clear();
      await loadProducts();

      AppLogger.info('Checkout completed successfully - POSController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Checkout failed - POSController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memproses checkout',
        operation: 'checkout',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error during checkout - POSController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setCheckingOut(false);
    }
  }

  /// Clear cart
  void clearCart() {
    AppLogger.ui('Clearing cart', details: 'POSController');
    _cart.clear();
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  /// Get cart item for a product
  CartItem? getCartItem(Product product) {
    try {
      return _cart.firstWhere((item) => item.product.id == product.id);
    } catch (_) {
      return null;
    }
  }

  /// Set search query for filtering products
  void setSearchQuery(String query) {
    _searchQuery = query;
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Set category filter
  void setCategoryFilter(inventory.Category? category) {
    _selectedCategory = category;
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Clear category filter
  void clearCategoryFilter() {
    _selectedCategory = null;
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Hold current cart - saves it to database and clears current cart
  Future<bool> holdCart(String customerName) async {
    if (_cart.isEmpty) {
      _error = const ValidationException('Keranjang kosong', field: 'Cart');
      notifyListeners();
      return false;
    }

    try {
      AppLogger.ui('Holding cart', details: 'Customer: $customerName');

      // Store items to save before clearing
      final itemsToSave = List<CartItem>.from(_cart);

      await saveCartUseCase.execute(
        customerName: customerName,
        items: itemsToSave,
      );

      // Clear current cart after save completes
      _cart.clear();
      _error = null;

      AppLogger.info('Cart held successfully - POSController');

      // Single notification at the end
      if (!_disposed) {
        notifyListeners();
      }

      return true;
    } on AppException catch (e) {
      _error = e;
      AppLogger.error('Failed to hold cart - POSController', error: e);
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } catch (e, stackTrace) {
      _error = DatabaseException(
        'Gagal menahan pesanan',
        operation: 'holdCart',
        originalError: e,
        stackTrace: stackTrace,
      );
      AppLogger.error(
        'Unexpected error holding cart - POSController',
        error: e,
        stackTrace: stackTrace,
      );
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    }
  }

  /// Load all held carts
  Future<void> loadHeldCarts() async {
    try {
      AppLogger.ui('Loading held carts', details: 'POSController');
      _setLoadingHeldCarts(true);
      _clearError();

      _heldCarts = await getHeldCartsUseCase.execute();

      AppLogger.info('Held carts loaded: ${_heldCarts.length} - POSController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load held carts - POSController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat pesanan tertahan',
        operation: 'loadHeldCarts',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading held carts - POSController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoadingHeldCarts(false);
    }
  }

  /// Resume a held cart - replaces current cart with held cart data
  Future<bool> resumeCart(int heldCartId) async {
    try {
      AppLogger.ui('Resuming cart', details: 'ID: $heldCartId');

      final cartModel = await loadCartUseCase.execute(heldCartId);

      // Replace current cart with held cart
      _cart = cartModel.items;
      _error = null;

      AppLogger.info('Cart resumed successfully - POSController');

      // Single notification at the end
      if (!_disposed) {
        notifyListeners();
      }

      return true;
    } on AppException catch (e) {
      _error = e;
      AppLogger.error('Failed to resume cart - POSController', error: e);
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } catch (e, stackTrace) {
      _error = DatabaseException(
        'Gagal melanjutkan pesanan',
        operation: 'resumeCart',
        originalError: e,
        stackTrace: stackTrace,
      );
      AppLogger.error(
        'Unexpected error resuming cart - POSController',
        error: e,
        stackTrace: stackTrace,
      );
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    }
  }

  /// Delete a held cart
  Future<bool> deleteHeldCart(int heldCartId) async {
    try {
      AppLogger.ui('Deleting held cart', details: 'ID: $heldCartId');
      _clearError();

      await deleteHeldCartUseCase.execute(heldCartId);

      // Remove from local list
      _heldCarts.removeWhere((cart) => cart.id == heldCartId);

      if (!_disposed) {
        notifyListeners();
      }

      AppLogger.info('Held cart deleted successfully - POSController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete held cart - POSController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus pesanan tertahan',
        operation: 'deleteHeldCart',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error deleting held cart - POSController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Private methods

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setCheckingOut(bool value) {
    _isCheckingOut = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setLoadingHeldCarts(bool value) {
    _isLoadingHeldCarts = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setError(AppException error) {
    _error = error;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _clearError() {
    _error = null;
    if (!_disposed) {
      notifyListeners();
    }
  }
}
