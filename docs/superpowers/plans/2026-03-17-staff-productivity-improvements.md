# Staff Productivity Improvements Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance staff productivity through mobile-first UX improvements including quick actions, favorites, recently used items, hold-to-repeat controls, streamlined checkout, quick scan mode, and bulk operations.

**Architecture:** Following Clean Architecture with Provider state management. New services and widgets integrate with existing POS, Inventory, and Shifts features. Data persisted via SharedPreferences.

**Tech Stack:** Flutter 3.10+, Provider, SharedPreferences, mobile_scanner, flutter_animate, Material 3

---

## Phase 1: Quick Wins (Week 1)

### Task 1: Quick Actions Menu Widget

**Files:**
- Create: `lib/core/widgets/quick_actions_menu.dart`
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart:40-50` (import and add to build)
- Test: `test/core/widgets/quick_actions_menu_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/quick_actions_menu_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/widgets/quick_actions_menu.dart';

void main() {
  testWidgets('QuickActionsMenu shows all actions on long press', (tester) async {
    bool favoritesTapped = false;
    bool heldOrdersTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActionsMenu(
            onFavorites: () => favoritesTapped = true,
            onHeldOrders: () => heldOrdersTapped = true,
            onQuickAdd: () {},
            onQuickQuantity: () {},
            onTodaySummary: () {},
            onRefresh: () {},
          ),
        ),
      ),
    );

    // Initially shows just the FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Long press to expand
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Now shows action buttons
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Held Orders'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/widgets/quick_actions_menu_test.dart
```
Expected: FAIL - "Widget not found"

- [ ] **Step 3: Create QuickActionsMenu widget**

```dart
// lib/core/widgets/quick_actions_menu.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';  // From lib/core/widgets/, go to lib/core/theme/

/// Quick Actions Menu - expands on long press of FAB
/// Shows 6 quick actions for common POS operations
class QuickActionsMenu extends StatefulWidget {
  final VoidCallback onFavorites;
  final VoidCallback onHeldOrders;
  final VoidCallback onQuickAdd;
  final VoidCallback onQuickQuantity;
  final VoidCallback onTodaySummary;
  final VoidCallback onRefresh;

  const QuickActionsMenu({
    super.key,
    required this.onFavorites,
    required this.onHeldOrders,
    required this.onQuickAdd,
    required this.onQuickQuantity,
    required this.onTodaySummary,
    required this.onRefresh,
  });

  @override
  State<QuickActionsMenu> createState() => _QuickActionsMenuState();
}

class _QuickActionsMenuState extends State<QuickActionsMenu>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  static const List<_QuickAction> _actions = [
    _QuickAction(Icons.star, 'Favorites', 'favorites'),
    _QuickAction(Icons.receipt_long, 'Held Orders', 'held_orders'),
    _QuickAction(Icons.add_circle, 'Quick Add', 'quick_add'),
    _QuickAction(Icons.pin, 'Quick Quantity', 'quick_quantity'),
    _QuickAction(Icons.bar_chart, 'Today\'s Summary', 'today_summary'),
    _QuickAction(Icons.refresh, 'Refresh', 'refresh'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  VoidCallback _getHandler(String action) {
    switch (action) {
      case 'favorites':
        return widget.onFavorites;
      case 'held_orders':
        return widget.onHeldOrders;
      case 'quick_add':
        return widget.onQuickAdd;
      case 'quick_quantity':
        return widget.onQuickQuantity;
      case 'today_summary':
        return widget.onTodaySummary;
      case 'refresh':
        return widget.onRefresh;
      default:
        return () {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Action buttons (arranged in arc around FAB)
          if (_isExpanded)
            ...List.generate(_actions.length, (index) {
              final action = _actions[index];
              final angle = 90 + (index * 45); // Arc from bottom
              return _buildActionButton(action, angle);
            }),

          // Main FAB
          GestureDetector(
            onLongPress: _toggle,
            onTap: _isExpanded ? _toggle : null,
            child: FloatingActionButton(
              heroTag: 'quick_actions_fab',
              backgroundColor: AppTheme.primaryColor,
              onPressed: _isExpanded ? _toggle : null,
              child: AnimatedIcon(
                icon: _isExpanded ? AnimatedIcons.close_menu : AnimatedIcons.menu_close,
                progress: _expandAnimation,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(_QuickAction action, double angle) {
    final radians = angle * 3.14159 / 180;
    final distance = 70.0;
    final x = distance * cos(radians);
    final y = distance * sin(radians);

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(x, y) * _expandAnimation.value,
          child: Opacity(
            opacity: _expandAnimation.value,
            child: child,
          ),
        );
      },
      child: Material(
        color: AppTheme.getCardColor(context),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: () {
            _toggle();
            _getHandler(action.key)();
          },
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: action.label,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                action.icon,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String key;

  const _QuickAction(this.icon, this.label, this.key);
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/core/widgets/quick_actions_menu_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/quick_actions_menu.dart test/core/widgets/quick_actions_menu_test.dart
git commit -m "feat(core): add quick actions menu widget with expandable FAB"
```

---

### Task 2: Favorites Repository and Controller

**Files:**
- Create: `lib/features/pos/data/repositories/favorites_repository.dart`
- Create: `lib/features/pos/presentation/controllers/favorites_controller.dart`
- Modify: `lib/main.dart:500` (add provider)
- Test: `test/features/pos/data/repositories/favorites_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/features/pos/data/repositories/favorites_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pos/features/pos/data/repositories/favorites_repository.dart';

void main() {
  test('FavoritesRepository: add and retrieve favorite product IDs', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = FavoritesRepository(prefs);

    repo.addFavorite('product_1');
    repo.addFavorite('product_2');

    expect(repo.getFavorites(), contains('product_1'));
    expect(repo.getFavorites(), contains('product_2'));
    expect(repo.getFavorites().length, 2);
  });

  test('FavoritesRepository: remove favorite', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = FavoritesRepository(prefs);

    repo.addFavorite('product_1');
    expect(repo.isFavorite('product_1'), true);

    repo.removeFavorite('product_1');
    expect(repo.isFavorite('product_1'), false);
  });

  test('FavoritesRepository: toggle favorite', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = FavoritesRepository(prefs);

    expect(repo.toggleFavorite('product_1'), true); // Added
    expect(repo.toggleFavorite('product_1'), false); // Removed
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/pos/data/repositories/favorites_repository_test.dart
```
Expected: FAIL - "FavoritesRepository not found"

- [ ] **Step 3: Create FavoritesRepository**

```dart
// lib/features/pos/data/repositories/favorites_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing favorite products
/// Persists favorite product IDs using SharedPreferences
class FavoritesRepository {
  final SharedPreferences _prefs;
  static const String _key = 'favorite_product_ids';

  FavoritesRepository(this._prefs);

  /// Get all favorite product IDs
  Set<String> getFavorites() {
    final List<String>? favorites = _prefs.getStringList(_key);
    return favorites?.toSet() ?? {};
  }

  /// Check if a product is favorited
  bool isFavorite(String productId) {
    return getFavorites().contains(productId);
  }

  /// Add a product to favorites
  void addFavorite(String productId) {
    final current = getFavorites();
    current.add(productId);
    _prefs.setStringList(_key, current.toList());
  }

  /// Remove a product from favorites
  void removeFavorite(String productId) {
    final current = getFavorites();
    current.remove(productId);
    _prefs.setStringList(_key, current.toList());
  }

  /// Toggle favorite status
  /// Returns true if added, false if removed
  bool toggleFavorite(String productId) {
    if (isFavorite(productId)) {
      removeFavorite(productId);
      return false;
    } else {
      addFavorite(productId);
      return true;
    }
  }

  /// Clear all favorites
  void clearFavorites() {
    _prefs.remove(_key);
  }
}
```

- [ ] **Step 4: Create FavoritesController**

```dart
// lib/features/pos/presentation/controllers/favorites_controller.dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/favorites_repository.dart';

/// Controller for managing favorites state
class FavoritesController extends ChangeNotifier {
  final FavoritesRepository _repository;

  FavoritesController(this._repository);

  Set<String> _favorites = {};

  /// Get current favorites
  Set<String> get favorites => _favorites;

  /// Check if product is favorited
  bool isFavorite(String productId) => _favorites.contains(productId);

  /// Load favorites from storage
  Future<void> loadFavorites() async {
    _favorites = _repository.getFavorites();
    notifyListeners();
  }

  /// Toggle favorite status
  bool toggleFavorite(String productId) {
    final added = _repository.toggleFavorite(productId);
    if (added) {
      _favorites.add(productId);
    } else {
      _favorites.remove(productId);
    }
    notifyListeners();
    return added;
  }

  /// Add to favorites
  void addFavorite(String productId) {
    _repository.addFavorite(productId);
    _favorites.add(productId);
    notifyListeners();
  }

  /// Remove from favorites
  void removeFavorite(String productId) {
    _repository.removeFavorite(productId);
    _favorites.remove(productId);
    notifyListeners();
  }

  /// Clear all favorites
  void clearFavorites() {
    _repository.clearFavorites();
    _favorites.clear();
    notifyListeners();
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/features/pos/data/repositories/favorites_repository_test.dart
```
Expected: PASS

- [ ] **Step 6: Add to main.dart providers**

```dart
// lib/main.dart - after line 500 (after other providers)
ProxyProvider<SharedPreferences, FavoritesRepository>(
  update: (_, prefs, __) => FavoritesRepository(prefs),
),
ChangeNotifierProvider<FavoritesController>(
  create: (context) => FavoritesController(context.read<FavoritesRepository>())
    ..loadFavorites(),
),
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/pos/data/repositories/favorites_repository.dart lib/features/pos/presentation/controllers/favorites_controller.dart test/features/pos/data/repositories/favorites_repository_test.dart
git commit -m "feat(pos): add favorites repository and controller"
```

---

### Task 3: Favorites Tab Widget

**Files:**
- Create: `lib/features/pos/presentation/widgets/favorites_tab.dart`
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart:200` (add to categories)

- [ ] **Step 1: Create FavoritesTab widget**

```dart
// lib/features/pos/presentation/widgets/favorites_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pos_controller.dart';
import '../controllers/favorites_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';
import 'product_grid_item.dart';

/// Favorites tab showing pinned products
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  void initState() {
    super.initState();
    // Load favorites on init
    context.read<FavoritesController>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final posController = context.watch<POSController>();
    final favoritesController = context.watch<FavoritesController>();
    final categoryController = context.watch<CategoryController>();
    final discountController = context.watch<DiscountController>();

    final favoriteIds = favoritesController.favorites;
    final products = posController.products.where((p) => favoriteIds.contains(p.id.toString())).toList();

    if (favoriteIds.isEmpty) {
      return _buildEmptyState(context);
    }

    if (products.isEmpty) {
      return _buildNoProductsState(context);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final quantity = posController.getCartItemQuantity(product.id!);

        return ProductGridItem(
          product: product,
          quantity: quantity,
          index: index,
          onTap: () => _handleAddToCart(posController, product),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Long-press products to add them to favorites',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Products Not Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your favorite products may have been deleted',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(POSController controller, dynamic product) {
    // Add to cart logic
    controller.addToCart(product);
  }
}
```

- [ ] **Step 2: Add long-press to favorite in ProductGridItem**

```dart
// lib/features/pos/presentation/widgets/product_grid_item.dart
// Add to existing Widget build (around line 100), wrap in GestureDetector:

onLongPress: () {
  // Toggle favorite
  context.read<FavoritesController>().toggleFavorite(widget.product.id.toString());

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        context.read<FavoritesController>().isFavorite(widget.product.id.toString())
            ? 'Added to favorites'
            : 'Removed from favorites',
      ),
      duration: const Duration(seconds: 1),
    ),
  );
},

// Add star badge overlay when favorited:
Consumer<FavoritesController>(
  builder: (context, favorites, _) {
    final isFavorite = favorites.isFavorite(widget.product.id.toString());
    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedOpacity(
        opacity: isFavorite ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.warningColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  },
),
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/pos/presentation/widgets/favorites_tab.dart lib/features/pos/presentation/widgets/product_grid_item.dart
git commit -m "feat(pos): add favorites tab with star badge indicator"
```

---

### Task 4: Recently Used Products Tab

**Files:**
- Create: `lib/features/pos/data/repositories/recent_products_repository.dart`
- Create: `lib/features/pos/presentation/widgets/recent_products_tab.dart`
- Modify: `lib/features/pos/presentation/controllers/pos_controller.dart:200` (add to checkout)

- [ ] **Step 1: Create RecentProductsRepository**

```dart
// lib/features/pos/data/repositories/recent_products_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing recently used products
/// Stores up to 10 unique product IDs, newest first
class RecentProductsRepository {
  final SharedPreferences _prefs;
  static const String _key = 'recent_product_ids';
  static const int _maxItems = 10;

  RecentProductsRepository(this._prefs);

  /// Get recent product IDs (newest first)
  List<String> getRecentProducts() {
    final List<String>? recent = _prefs.getStringList(_key);
    return recent ?? [];
  }

  /// Add a product to recent history
  void addRecentProduct(String productId) {
    final current = getRecentProducts();

    // Remove if already exists (will be re-added at front)
    current.remove(productId);

    // Add to front
    current.insert(0, productId);

    // Trim to max
    if (current.length > _maxItems) {
      current.removeRange(_maxItems, current.length);
    }

    _prefs.setStringList(_key, current);
  }

  /// Clear recent history
  void clearRecent() {
    _prefs.remove(_key);
  }
}
```

- [ ] **Step 2: Create RecentProductsTab widget**

```dart
// lib/features/pos/presentation/widgets/recent_products_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/pos_controller.dart';
import '../../data/repositories/recent_products_repository.dart';
import '../../../../core/theme/app_theme.dart';
import 'product_grid_item.dart';

/// Recent products tab showing last 10 sold items
class RecentProductsTab extends StatefulWidget {
  const RecentProductsTab({super.key});

  @override
  State<RecentProductsTab> createState() => _RecentProductsTabState();
}

class _RecentProductsTabState extends State<RecentProductsTab> {
  @override
  Widget build(BuildContext context) {
    final posController = context.watch<POSController>();
    final prefs = context.read<SharedPreferences>();
    final recentRepo = RecentProductsRepository(prefs);
    final recentIds = recentRepo.getRecentProducts();
    final products = posController.products
        .where((p) => recentIds.contains(p.id.toString()))
        .toList()
        ..sort((a, b) => recentIds.indexOf(a.id.toString())
            .compareTo(recentIds.indexOf(b.id.toString())));

    if (recentIds.isEmpty) {
      return _buildEmptyState(context);
    }

    if (products.isEmpty) {
      return _buildNoProductsState(context);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  recentRepo.clearRecent();
                  setState(() {});
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final quantity = posController.getCartItemQuantity(product.id!);

              return ProductGridItem(
                product: product,
                quantity: quantity,
                index: index,
                onTap: () => posController.addToCart(product),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recently sold products will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductsState(BuildContext context) {
    final prefs = context.read<SharedPreferences>();
    final repo = RecentProductsRepository(prefs);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Products Not Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              repo.clearRecent();
              setState(() {});
            },
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Add recent products tracking to POS screen**

```dart
// lib/features/pos/presentation/screens/pos_screen.dart
// After successful checkout, add:
final prefs = await SharedPreferences.getInstance();
final recentRepo = RecentProductsRepository(prefs);
for (final item in context.read<POSController>().cart) {
  recentRepo.addRecentProduct(item.product.id.toString());
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/pos/data/repositories/recent_products_repository.dart lib/features/pos/presentation/widgets/recent_products_tab.dart lib/features/pos/presentation/screens/pos_screen.dart
git commit -m "feat(pos): add recent products tab with history tracking"
```

---

### Task 5: Hold-to-Repeat Quantity Stepper

**Files:**
- Create: `lib/core/widgets/quantity_stepper.dart`
- Modify: `lib/features/pos/presentation/widgets/cart_modal.dart` (replace +/- buttons)

- [ ] **Step 1: Create QuantityStepper widget**

```dart
// lib/core/widgets/quantity_stepper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Quantity stepper with hold-to-repeat functionality
/// Press and hold +/- to continuously increment/decrement
class QuantityStepper extends StatefulWidget {
  final int value;
  final int minValue;
  final int? maxValue;
  final ValueChanged<int> onChanged;

  const QuantityStepper({
    super.key,
    required this.value,
    this.minValue = 0,
    this.maxValue,
    required this.onChanged,
  });

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  Timer? _incrementTimer;
  Timer? _decrementTimer;

  static const _initialDelay = Duration(milliseconds: 500);
  static const _repeatInterval = Duration(milliseconds: 150);

  @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    super.dispose();
  }

  void _increment() {
    if (widget.maxValue == null || widget.value < widget.maxValue!) {
      widget.onChanged(widget.value + 1);
      HapticFeedback.lightImpact();
    }
  }

  void _decrement() {
    if (widget.value > widget.minValue) {
      widget.onChanged(widget.value - 1);
      HapticFeedback.lightImpact();
    }
  }

  void _startIncrement() {
    _increment();
    _incrementTimer = Timer(_initialDelay, () {
      _incrementTimer = Timer.periodic(_repeatInterval, (_) => _increment());
    });
  }

  void _startDecrement() {
    _decrement();
    _decrementTimer = Timer(_initialDelay, () {
      _decrementTimer = Timer.periodic(_repeatInterval, (_) => _decrement());
    });
  }

  void _stopTimers() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    _incrementTimer = null;
    _decrementTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onTap: _decrement,
            onStart: _startDecrement,
            onEnd: _stopTimers,
          ),
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Text(
              '${widget.value}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onTap: _increment,
            onStart: _startIncrement,
            onEnd: _stopTimers,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onStart,
    required VoidCallback onEnd,
  }) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => onStart(),
      onTapUp: (_) => onEnd(),
      onTapCancel: onEnd,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Replace in CartModal**

```dart
// lib/features/pos/presentation/widgets/cart_modal.dart
// Replace existing +/- buttons with:
QuantityStepper(
  value: quantity,
  minValue: 1,
  maxValue: product.stock,
  onChanged: (value) => controller.updateCartItemQuantity(item, value),
),
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/widgets/quantity_stepper.dart lib/features/pos/presentation/widgets/cart_modal.dart
git commit -m "feat(core): add hold-to-repeat quantity stepper"
```

---

### Task 6: Quick Quantity Mode

**Files:**
- Create: `lib/core/widgets/quick_quantity_mode.dart`

- [ ] **Step 1: Create QuickQuantityMode widget**

```dart
// lib/core/widgets/quick_quantity_mode.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Full-screen quick quantity mode for fast product entry
/// Shows large buttons with hold-to-repeat and gesture support
class QuickQuantityMode extends StatefulWidget {
  final String productName;
  final String? productImageUrl;
  final double price;
  final int availableStock;
  final ValueChanged<int> onConfirm;
  final VoidCallback onSkip;
  final VoidCallback onClose;

  const QuickQuantityMode({
    super.key,
    required this.productName,
    this.productImageUrl,
    required this.price,
    required this.availableStock,
    required this.onConfirm,
    required this.onSkip,
    required this.onClose,
  });

  @override
  State<QuickQuantityMode> createState() => _QuickQuantityModeState();
}

class _QuickQuantityModeState extends State<QuickQuantityMode> {
  int _quantity = 1;
  final TextEditingController _controller = TextEditingController(text: '1');
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _increment() {
    if (_quantity < widget.availableStock) {
      setState(() {
        _quantity++;
        _controller.text = '$_quantity';
      });
      HapticFeedback.lightImpact();
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _controller.text = '$_quantity';
      });
      HapticFeedback.lightImpact();
    }
  }

  void _setQuantity(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0 && parsed <= widget.availableStock) {
      setState(() => _quantity = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              // Swipe right = add
              widget.onConfirm(_quantity);
            } else {
              // Swipe left = skip
              widget.onSkip();
            }
          }
        },
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close),
                    ),
                    Text(
                      'Quick Quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),

                // Product info
                if (widget.productImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.productImageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: AppTheme.getBorderColor(context),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                Text(
                  widget.productName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${widget.price.toInt().toString()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 32),

                // Quantity controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLargeButton(
                      icon: Icons.remove,
                      onTap: _decrement,
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: _setQuantity,
                      ),
                    ),
                    _buildLargeButton(
                      icon: Icons.add,
                      onTap: _increment,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Available: ${widget.availableStock}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onSkip,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => widget.onConfirm(_quantity),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '← Swipe to skip | Swipe to add →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 32,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/quick_quantity_mode.dart
git commit -m "feat(core): add quick quantity mode with gestures"
```

---

### Task 7: Enhanced Product Search

**Files:**
- Create: `lib/features/pos/presentation/widgets/enhanced_product_search.dart`
- Create: `lib/features/pos/data/repositories/recent_searches_repository.dart`

- [ ] **Step 1: Create RecentSearchesRepository**

```dart
// lib/features/pos/data/repositories/recent_searches_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing recent search queries
/// Stores up to 5 recent searches
class RecentSearchesRepository {
  final SharedPreferences _prefs;
  static const String _key = 'recent_searches';
  static const int _maxItems = 5;

  RecentSearchesRepository(this._prefs);

  List<String> getRecentSearches() {
    final List<String>? searches = _prefs.getStringList(_key);
    return searches ?? [];
  }

  void addSearch(String query) {
    if (query.trim().isEmpty) return;

    final current = getRecentSearches();
    current.remove(query); // Remove if exists
    current.insert(0, query); // Add to front

    if (current.length > _maxItems) {
      current.removeRange(_maxItems, current.length);
    }

    _prefs.setStringList(_key, current);
  }

  void clearSearches() {
    _prefs.remove(_key);
  }
}
```

- [ ] **Step 2: Create EnhancedProductSearch widget**

```dart
// lib/features/pos/presentation/widgets/enhanced_product_search.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/pos_controller.dart';
import '../../data/repositories/recent_searches_repository.dart';
import '../../../../core/theme/app_theme.dart';

/// Enhanced product search with:
/// - Real-time search as you type
/// - Search by name, barcode, or category
/// - Recent searches
/// - Highlighted matching text
class EnhancedProductSearch extends StatefulWidget {
  final VoidCallback onClose;
  final Function(dynamic product)? onProductTap;

  const EnhancedProductSearch({
    super.key,
    required this.onClose,
    this.onProductTap,
  });

  @override
  State<EnhancedProductSearch> createState() => _EnhancedProductSearchState();
}

class _EnhancedProductSearchState extends State<EnhancedProductSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final RecentSearchesRepository _recentRepo;

  List<String> _recentSearches = [];
  List _results = [];

  @override
  void initState() {
    super.initState();
    final prefs = context.read<SharedPreferences>();
    _recentRepo = RecentSearchesRepository(prefs);
    _loadRecentSearches();
    _focusNode.requestFocus();
  }

  void _loadRecentSearches() {
    _recentSearches = _recentRepo.getRecentSearches();
    setState(() {});
  }

  void _performSearch(String query) {
    final posController = context.read<POSController>();
    final allProducts = posController.products;

    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    final lowerQuery = query.toLowerCase();
    _results = allProducts.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          (p.barcode?.contains(lowerQuery) ?? false) ||
          false; // TODO: add category search
    }).toList();

    setState(() {});
  }

  void _selectRecentSearch(String query) {
    _controller.text = query;
    _performSearch(query);
    _recentRepo.addSearch(query);
    _loadRecentSearches();
  }

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      _recentRepo.addSearch(query);
      _performSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.getCardColor(context),
      child: Column(
        children: [
          // Search bar
          _buildSearchBar(context),

          // Content
          Expanded(
            child: _controller.text.isEmpty
                ? _buildRecentSearches(context)
                : _buildResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              onChanged: _performSearch,
              onSubmitted: (_) => _submitSearch(),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _results = []);
                        },
                      )
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    if (_recentSearches.isEmpty) {
      return const Center(child: Text('No recent searches'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  _recentRepo.clearSearches();
                  _loadRecentSearches();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map(
          (search) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(search),
            onTap: () => _selectRecentSearch(search),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_results.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final product = _results[index];
        return ListTile(
          title: _highlightMatch(product.name, _controller.text),
          subtitle: Text('Rp ${product.price}'),
          onTap: () {
            widget.onProductTap?.call(product);
            widget.onClose();
          },
        );
      },
    );
  }

  Widget _highlightMatch(String text, String query) {
    if (query.isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) return Text(text);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: TextStyle(
              backgroundColor: AppTheme.warningColor.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/pos/data/repositories/recent_searches_repository.dart lib/features/pos/presentation/widgets/enhanced_product_search.dart
git commit -m "feat(pos): add enhanced product search with recent searches"
```

---

## Phase 2: Workflow Improvements (Week 2-3)

### Task 8: Streamlined Checkout Dialog

**Files:**
- Create: `lib/features/pos/presentation/widgets/streamlined_checkout_dialog.dart`
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart:250` (replace checkout call)

- [ ] **Step 1: Create StreamlinedCheckoutDialog**

```dart
// lib/features/pos/presentation/widgets/streamlined_checkout_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/pos_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../sales/domain/entities/payment_method.dart';

/// Streamlined checkout dialog with single-page flow
/// Integrates payment selection, summary, and receipt options
class StreamlinedCheckoutDialog extends StatefulWidget {
  const StreamlinedCheckoutDialog({super.key});

  @override
  State<StreamlinedCheckoutDialog> createState() => _StreamlinedCheckoutDialogState();
}

class _StreamlinedCheckoutDialogState extends State<StreamlinedCheckoutDialog> {
  PaymentMethod _selectedPayment = PaymentMethod.cash;
  bool _isProcessing = false;
  bool _printReceipt = true;

  @override
  Widget build(BuildContext context) {
    final posController = context.watch<POSController>();
    final cart = posController.cart;
    final subtotal = posController.subtotal;
    final tax = posController.tax;
    final total = posController.totalAmount;
    final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 24),

            // Summary
            _buildSummary(context, totalItems, subtotal, tax, total),

            const SizedBox(height: 24),

            // Payment method selection
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethods(context),

            const SizedBox(height: 24),

            // Receipt option
            SwitchListTile(
              title: const Text('Print Receipt'),
              subtitle: const Text('Automatically print after checkout'),
              value: _printReceipt,
              onChanged: (value) => setState(() => _printReceipt = value),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleCheckout(posController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Complete • Rp ${CurrencyFormatter.format(total)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, int items, double subtotal, double tax, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, 'Items', '$items'),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Subtotal', CurrencyFormatter.format(subtotal)),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Tax', CurrencyFormatter.format(tax)),
          const Divider(height: 16),
          _buildSummaryRow(
            context,
            'Total',
            CurrencyFormatter.format(total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextSecondaryColor(context),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: PaymentMethod.values.map((method) {
        final isSelected = _selectedPayment == method;
        return ChoiceChip(
          label: Text(_getPaymentLabel(method)),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedPayment = method),
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextPrimaryColor(context),
          ),
        );
      }).toList(),
    );
  }

  String _getPaymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.qr:
        return 'QR';
      case PaymentMethod.transfer:
        return 'Transfer';
    }
  }

  Future<void> _handleCheckout(POSController controller) async {
    setState(() => _isProcessing = true);

    try {
      final success = await controller.checkout(
        paymentMethod: _selectedPayment,
      );

      if (success && mounted) {
        HapticFeedback.lightImpact();
        Navigator.pop(context, true); // Return success

        // TODO: Handle receipt printing based on _printReceipt flag
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/pos/presentation/widgets/streamlined_checkout_dialog.dart
git commit -m "feat(pos): add streamlined checkout dialog"
```

---

### Task 9: Quick Scan Mode

**Files:**
- Create: `lib/features/pos/presentation/widgets/quick_scan_screen.dart`
- Create: `lib/features/pos/presentation/controllers/quick_scan_controller.dart`

- [ ] **Step 1: Create QuickScanController**

```dart
// lib/features/pos/presentation/controllers/quick_scan_controller.dart
import 'package:flutter/foundation.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../controllers/pos_controller.dart';

/// Controller for quick scan mode
/// Manages high-volume barcode scanning with auto-add
class QuickScanController extends ChangeNotifier {
  final POSController posController;

  QuickScanController(this.posController);

  final List<CartItem> _scannedItems = [];
  bool _isScanning = false;

  List<CartItem> get scannedItems => List.unmodifiable(_scannedItems);
  bool get isScanning => _isScanning;
  int get totalItems => _scannedItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _scannedItems.fold(0.0, (sum, item) => sum + item.subtotal);

  void _setScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  /// Handle barcode scan
  Future<void> onBarcodeScanned(String barcode) async {
    if (!_isScanning) return;

    // Find product by barcode
    Product? product;
    try {
      product = posController.products.firstWhere(
        (p) => p.barcode == barcode,
      );
    } catch (e) {
      // Product not found
      product = null;
    }

    if (product == null) {
      // Product not found - show feedback
      return;
    }

    // Add to scanned items
    final existingIndex = _scannedItems.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      // Increment quantity
      _scannedItems[existingIndex] = CartItem(
        product: _scannedItems[existingIndex].product,
        quantity: _scannedItems[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      _scannedItems.add(CartItem(
        product: product,
        quantity: 1,
      ));
    }

    notifyListeners();

    // Also add to main cart
    posController.addToCart(product!, 1);
  }

  /// Start scanning
  void startScanning() => _setScanning(true);

  /// Stop scanning
  void stopScanning() => _setScanning(false);

  /// Clear scanned items
  void clear() {
    _scannedItems.clear();
    notifyListeners();
  }

  /// Remove item at index
  void removeItem(int index) {
    _scannedItems.removeAt(index);
    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    _scannedItems[index] = CartItem(
      product: _scannedItems[index].product,
      quantity: quantity,
    );
    notifyListeners();
  }
}
```

- [ ] **Step 2: Create QuickScanScreen widget**

```dart
// lib/features/pos/presentation/widgets/quick_scan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../controllers/pos_controller.dart';
import 'quick_scan_controller.dart';
import 'streamlined_checkout_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Full-screen quick scan mode for high-volume scanning
/// Auto-adds products as scanned, shows cart summary at bottom
class QuickScanScreen extends StatefulWidget {
  const QuickScanScreen({super.key});

  @override
  State<QuickScanScreen> createState() => _QuickScanScreenState();
}

class _QuickScanScreenState extends State<QuickScanScreen> {
  @override
  Widget build(BuildContext context) {
    final quickScanController = context.watch<QuickScanController>();
    final totalItems = quickScanController.totalItems;
    final totalAmount = quickScanController.totalAmount;

    return Scaffold(
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                quickScanController.onBarcodeScanned(barcode.rawValue!);
                HapticFeedback.lightImpact();
              }
            },
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: CustomPaint(
              painter: _ScannerOverlayPainter(),
            ),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filled(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Quick Scan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: quickScanController.clear,
                    icon: const Icon(Icons.clear_all),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom cart summary
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                  _showCartBottomSheet(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalItems items',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(totalAmount),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _showCartBottomSheet(context),
                            child: const Text('Edit', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCheckoutDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Checkout'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scanned Items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<QuickScanController>(
                  builder: (context, controller, _) {
                    final items = controller.scannedItems;
                    if (items.isEmpty) {
                      return const Center(child: Text('No items scanned yet'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          leading: Text('${item.quantity}x'),
                          title: Text(item.displayName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(CurrencyFormatter.format(item.subtotal)),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => controller.removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    // Use the streamlined checkout dialog
    showDialog(
      context: context,
      builder: (_) => const StreamlinedCheckoutDialog(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final scanSize = size.width * 0.7;

    // Draw corner brackets
    const cornerLength = 30.0;
    final topLeft = Offset(center.dx - scanSize / 2, center.dy - scanSize / 2);
    final topRight = Offset(center.dx + scanSize / 2, center.dy - scanSize / 2);
    final bottomLeft = Offset(center.dx - scanSize / 2, center.dy + scanSize / 2);
    final bottomRight = Offset(center.dx + scanSize / 2, center.dy + scanSize / 2);

    // Top-left
    canvas.drawLine(topLeft, topLeft.translate(cornerLength, 0), paint);
    canvas.drawLine(topLeft, topLeft.translate(0, cornerLength), paint);

    // Top-right
    canvas.drawLine(topRight, topRight.translate(-cornerLength, 0), paint);
    canvas.drawLine(topRight, topRight.translate(0, cornerLength), paint);

    // Bottom-left
    canvas.drawLine(bottomLeft, bottomLeft.translate(cornerLength, 0), paint);
    canvas.drawLine(bottomLeft, bottomLeft.translate(0, -cornerLength), paint);

    // Bottom-right
    canvas.drawLine(bottomRight, bottomRight.translate(-cornerLength, 0), paint);
    canvas.drawLine(bottomRight, bottomRight.translate(0, -cornerLength), paint);

    // Center line
    paint.color = AppTheme.successColor.withValues(alpha: 0.8);
    canvas.drawLine(
      Offset(center.dx - 50, center.dy),
      Offset(center.dx + 50, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 3: Add to main.dart providers**

```dart
// lib/main.dart - in the POS section (after POSController provider)
ChangeNotifierProxyProvider<POSController, QuickScanController>(
  update: (_, posController, __) => QuickScanController(
    posController: posController,
  ),
),
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/pos/presentation/controllers/quick_scan_controller.dart lib/features/pos/presentation/widgets/quick_scan_screen.dart lib/main.dart
git commit -m "feat(pos): add quick scan mode with auto-add"
```

---

### Task 10: Bulk Operations

**Files:**
- Create: `lib/features/inventory/presentation/controllers/bulk_operations_controller.dart`
- Create: `lib/features/inventory/presentation/widgets/bulk_actions_bottom_sheet.dart`
- Modify: `lib/features/inventory/presentation/screens/product_list_screen.dart` (add selection mode)

- [ ] **Step 1: Create BulkOperationsController**

```dart
// lib/features/inventory/presentation/controllers/bulk_operations_controller.dart
import 'package:flutter/foundation.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Controller for bulk operations on products
class BulkOperationsController extends ChangeNotifier {
  final ProductRepository _productRepository;

  final Set<String> _selectedIds = {};
  bool _isSelectMode = false;
  bool _isLoading = false;
  AppException? _error;

  BulkOperationsController({required ProductRepository productRepository})
      : _productRepository = productRepository;

  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);
  bool get isSelectMode => _isSelectMode;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectionCount => _selectedIds.length;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  void enterSelectMode() {
    _isSelectMode = true;
    _selectedIds.clear();
    notifyListeners();
  }

  void exitSelectMode() {
    _isSelectMode = false;
    _selectedIds.clear();
    _clearError();
    notifyListeners();
  }

  void toggleSelection(String productId) {
    if (_selectedIds.contains(productId)) {
      _selectedIds.remove(productId);
    } else {
      _selectedIds.add(productId);
    }
    notifyListeners();
  }

  void selectAll(List<Product> products) {
    _selectedIds.clear();
    for (final p in products) {
      if (p.id != null) {
        _selectedIds.add(p.id.toString());
      }
    }
    notifyListeners();
  }

  void deselectAll() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Bulk edit price for selected products
  Future<bool> bulkEditPrice({required double newPrice}) async {
    try {
      _setLoading(true);
      _clearError();

      for (final id in _selectedIds) {
        final product = await _productRepository.getProductById(int.parse(id));
        final updated = product.copyWith(price: newPrice);
        await _productRepository.updateProduct(updated);
      }

      exitSelectMode();
      AppLogger.info('Bulk price edit completed');
      return true;
    } on AppException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      _setError(DatabaseException(
        'Gagal mengubah harga',
        operation: 'bulkEditPrice',
        originalError: e,
      ));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Bulk apply discount percentage to selected products
  Future<bool> bulkApplyDiscount({required double discountPercentage}) async {
    try {
      _setLoading(true);
      _clearError();

      for (final id in _selectedIds) {
        final product = await _productRepository.getProductById(int.parse(id));
        final newPrice = product.price * (1 - discountPercentage / 100);
        final updated = product.copyWith(price: newPrice);
        await _productRepository.updateProduct(updated);
      }

      exitSelectMode();
      AppLogger.info('Bulk discount applied');
      return true;
    } on AppException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      _setError(DatabaseException(
        'Gagal menerapkan diskon',
        operation: 'bulkApplyDiscount',
        originalError: e,
      ));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Bulk edit stock for selected products
  Future<bool> bulkEditStock({required int adjustment}) async {
    try {
      _setLoading(true);
      _clearError();

      for (final id in _selectedIds) {
        final product = await _productRepository.getProductById(int.parse(id));
        final newStock = (product.stock + adjustment).clamp(0, double.infinity).toInt();
        final updated = product.copyWith(stock: newStock);
        await _productRepository.updateProduct(updated);
      }

      exitSelectMode();
      AppLogger.info('Bulk stock edit completed');
      return true;
    } on AppException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      _setError(DatabaseException(
        'Gagal mengubah stok',
        operation: 'bulkEditStock',
        originalError: e,
      ));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Bulk change category for selected products
  Future<bool> bulkChangeCategory({required String categoryId}) async {
    try {
      _setLoading(true);
      _clearError();

      for (final id in _selectedIds) {
        final product = await _productRepository.getProductById(int.parse(id));
        final updated = product.copyWith(categoryId: int.parse(categoryId));
        await _productRepository.updateProduct(updated);
      }

      exitSelectMode();
      AppLogger.info('Bulk category change completed');
      return true;
    } on AppException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      _setError(DatabaseException(
        'Gagal mengubah kategori',
        operation: 'bulkChangeCategory',
        originalError: e,
      ));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Bulk delete selected products
  Future<bool> bulkDelete() async {
    try {
      _setLoading(true);
      _clearError();

      for (final id in _selectedIds) {
        await _productRepository.deleteProduct(int.parse(id));
      }

      exitSelectMode();
      AppLogger.info('Bulk delete completed');
      return true;
    } on AppException catch (e) {
      _setError(e);
      return false;
    } catch (e) {
      _setError(DatabaseException(
        'Gagal menghapus produk',
        operation: 'bulkDelete',
        originalError: e,
      ));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(AppException error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
```

- [ ] **Step 2: Create BulkActionsBottomSheet**

```dart
// lib/features/inventory/presentation/widgets/bulk_actions_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/bulk_operations_controller.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom sheet showing bulk actions when products are selected
class BulkActionsBottomSheet extends StatelessWidget {
  const BulkActionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BulkOperationsController>(
      builder: (context, controller, _) {
        if (!controller.hasSelection) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            border: Border(
              top: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selection info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.selectionCount} selected',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: controller.selectAll,
                          child: const Text('Select All'),
                        ),
                        TextButton(
                          onPressed: controller.deselectAll,
                          child: const Text('Deselect'),
                        ),
                        IconButton(
                          onPressed: controller.exitSelectMode,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.attach_money,
                        label: 'Price',
                        onTap: () => _showBulkPriceDialog(context, controller),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.inventory_2,
                        label: 'Stock',
                        onTap: () => _showBulkStockDialog(context, controller),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.category,
                        label: 'Category',
                        onTap: () => _showBulkCategoryDialog(context, controller),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.delete,
                        label: 'Delete',
                        backgroundColor: AppTheme.errorColor,
                        onTap: () => _confirmBulkDelete(context, controller),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: backgroundColor ?? AppTheme.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkPriceDialog(BuildContext context, BulkOperationsController controller) {
    // TODO: Implement price edit dialog
  }

  void _showBulkStockDialog(BuildContext context, BulkOperationsController controller) {
    // TODO: Implement stock edit dialog
  }

  void _showBulkCategoryDialog(BuildContext context, BulkOperationsController controller) {
    // TODO: Implement category dialog
  }

  void _confirmBulkDelete(BuildContext context, BulkOperationsController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Products'),
        content: Text('Are you sure you want to delete ${controller.selectionCount} products?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Execute bulk delete
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Add to main.dart providers**

```dart
// lib/main.dart - in the inventory section (after InventoryController provider)
ChangeNotifierProxyProvider<ProductRepositoryImpl, BulkOperationsController>(
  update: (_, productRepository, __) => BulkOperationsController(
    productRepository: productRepository,
  ),
),
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/inventory/presentation/controllers/bulk_operations_controller.dart lib/features/inventory/presentation/widgets/bulk_actions_bottom_sheet.dart lib/main.dart
git commit -m "feat(inventory): add bulk operations controller and bottom sheet"
```

---

### Task 11: Improved Shift Handoff

**Files:**
- Create: `lib/features/shifts/presentation/widgets/shift_handoff_screen.dart`

- [ ] **Step 1: Create ShiftHandoffScreen**

```dart
// lib/features/shifts/presentation/widgets/shift_handoff_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/shift_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Improved shift handoff screen with comprehensive summary
/// Shows performance metrics, payment breakdown, and notes
class ShiftHandoffScreen extends StatefulWidget {
  const ShiftHandoffScreen({super.key});

  @override
  State<ShiftHandoffScreen> createState() => _ShiftHandoffScreenState();
}

class _ShiftHandoffScreenState extends State<ShiftHandoffScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Summary'),
      ),
      body: Consumer<ShiftController>(
        builder: (context, shiftController, _) {
          final shift = shiftController.currentShift;
          if (shift == null) return const SizedBox();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Today's Performance
                _buildSection(context, title: "Today's Performance", children: [
                  _buildMetricRow(context, 'Sales', CurrencyFormatter.format(shift.cashSales + shift.cardSales + shift.qrSales + shift.transferSales)),
                  _buildMetricRow(context, 'Transactions', '${shift.totalTransactions}'),
                ]),

                const SizedBox(height: 16),

                // Payment Breakdown
                _buildSection(context, title: 'Payment Breakdown', children: [
                  _buildMetricRow(context, 'Cash', CurrencyFormatter.format(shift.cashSales)),
                  _buildMetricRow(context, 'QR', CurrencyFormatter.format(shift.qrSales)),
                  _buildMetricRow(context, 'Card', CurrencyFormatter.format(shift.cardSales)),
                  _buildMetricRow(context, 'Transfer', CurrencyFormatter.format(shift.transferSales)),
                ]),

                const SizedBox(height: 16),

                // Notes
                _buildSection(context, title: 'Notes for Next Cashier', children: [
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add notes for the next cashier...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Print/share summary
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Print Report'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          shiftController.closeShift(
                            closingBalance: shift.cashSales, // Simplified
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Close Shift'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/shifts/presentation/widgets/shift_handoff_screen.dart
git commit -m "feat(shifts): add improved shift handoff screen"
```

---

## Integration & Final Steps

### Task 12: Connect Quick Actions to POS Screen

**Files:**
- Modify: `lib/features/pos/presentation/screens/pos_screen.dart`

- [ ] **Step 1: Add QuickActionsMenu to POS screen**

```dart
// In pos_screen.dart, add to the build method after the Scaffold:
floatingActionButton: QuickActionsMenu(
  onFavorites: () => _showFavoritesTab(),
  onHeldOrders: () => _showHeldOrders(),
  onQuickAdd: () => _showQuickAddDialog(),
  onQuickQuantity: () => _enableQuickQuantityMode(),
  onTodaySummary: () => _showTodaySummary(),
  onRefresh: () => context.read<POSController>().loadProducts(),
),
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/pos/presentation/screens/pos_screen.dart
git commit -m "feat(pos): connect quick actions menu to POS screen"
```

---

## Testing Checklist

After all tasks complete, verify:

- [ ] Quick Actions Menu expands and collapses smoothly
- [ ] Products can be favorited via long-press with star badge appearing
- [ ] Favorites tab shows pinned products
- [ ] Recent products tab shows last 10 sold items
- [ ] Hold-to-repeat works on cart quantity controls
- [ ] Quick quantity mode accepts gestures (+/- buttons, swipe)
- [ ] Enhanced search shows results in real-time with highlighting
- [ ] Recent searches are saved and shown
- [ ] Streamlined checkout completes in one dialog
- [ ] Quick scan mode auto-adds products on barcode scan
- [ ] Bulk operations bottom sheet appears on selection
- [ ] Shift handoff shows performance metrics

---

## Notes for Implementation

- Follow existing Material 3 theme patterns (see `AppTheme` class)
- Use Provider for state management
- Persist data via SharedPreferences
- Follow Clean Architecture (domain → data → presentation)
- Each task should commit individually
- Run `flutter analyze` after each commit
- Test on device for gesture behaviors
