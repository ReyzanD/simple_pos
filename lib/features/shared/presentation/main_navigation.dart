import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/presentation/screens/inventory_screen.dart';
import '../../pos/presentation/screens/pos_screen.dart';
import '../../../core/presentation/widgets/barcode_scanner_screen.dart';
import '../../sales/presentation/screens/sales_history_screen.dart';
import '../../sales/presentation/screens/sales_report_screen.dart';
import '../../sales/presentation/controllers/sales_history_controller.dart';
import '../../sales/presentation/controllers/sales_report_controller.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../users/presentation/screens/login_screen.dart';
import '../../users/domain/entities/user_role.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/logger.dart' as logger;
import 'providers.dart';
import 'drawer_header.dart';
import 'drawer_sections.dart';
import '../../users/presentation/controllers/auth_controller.dart';
import '../../inventory/presentation/widgets/add_product_dialog.dart';

/// Main navigation widget with floating glassmorphic bottom tab bar
/// Shows login screen if not authenticated, otherwise shows main app
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends ConsumerState<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _scannerPulseController;
  late Animation<double> _scannerPulseAnimation;
  late AnimationController _navSlideController;
  late Animation<Offset> _navSlideAnimation;
  final GlobalKey<POSScreenState> _posScreenKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      POSScreen(
        key: _posScreenKey,
        onCheckoutSuccess: () => _refreshAllScreens(),
      ),
      const InventoryScreen(),
      const SalesHistoryScreen(),
      const SalesReportScreen(),
      const SettingsScreen(),
    ];
    // Scanner button pulse animation
    _scannerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scannerPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _scannerPulseController, curve: Curves.easeInOut),
    );

    // Nav slide animation
    _navSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _navSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _navSlideController,
            curve: AnimationCurves.easeOut,
          ),
        );

    _navSlideController.forward();
  }

  @override
  void dispose() {
    _scannerPulseController.dispose();
    _navSlideController.dispose();
    super.dispose();
  }

  void navigateToSettings() {
    setState(() {
      _currentIndex = 4;
    });
  }

  /// Open the drawer - can be called from child screens
  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  /// Refresh all screens after checkout - updates inventory, sales history, and reports
  Future<void> _refreshAllScreens({bool delay = true}) async {
    if (!mounted) return;

    // Get controllers before any async operations to avoid BuildContext across async gaps
    final inventoryController = ref.read(inventoryControllerProvider);
    SalesHistoryController? salesHistoryController;
    SalesReportController? salesReportController;

    try {
      salesHistoryController = ref.read(salesHistoryControllerProvider);
    } catch (_) {
      // Controller may not be initialized yet
    }

    try {
      salesReportController = ref.read(salesReportControllerProvider);
    } catch (_) {
      // Controller may not be initialized yet
    }

    // Add small delay to ensure database transaction is fully committed
    if (delay) {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Refresh Inventory controller (stock levels changed)
    await inventoryController.loadProducts();

    // Refresh POS controller (product list needs updating)
    if (_posScreenKey.currentState != null) {
      _posScreenKey.currentState!.refreshProducts();
    }

    // Refresh Sales History (new transaction added)
    await salesHistoryController?.refresh();

    // Refresh Sales Report (new data)
    await salesReportController?.refresh();
  }

  /// Refresh data for the currently visible tab
  Future<void> _refreshCurrentTab() async {
    if (!mounted) return;

    switch (_currentIndex) {
      case 0: // POS - Already handled by tab switch
        if (_posScreenKey.currentState != null) {
          _posScreenKey.currentState!.refreshProducts();
        }
        break;
      case 1: // Inventory
        final inventoryController = ref.read(inventoryControllerProvider);
        await inventoryController.loadProducts();
        break;
      case 2: // Sales History
        try {
          final salesHistoryController = ref.read(
            salesHistoryControllerProvider,
          );
          await salesHistoryController.refresh();
        } catch (_) {
          // Controller may not be initialized yet
        }
        break;
      case 3: // Sales Report
        try {
          final salesReportController = ref.read(salesReportControllerProvider);
          await salesReportController.refresh();
        } catch (_) {
          // Controller may not be initialized yet
        }
        break;
    }
  }

  Future<void> _handleQRScan() async {
    // Smart scanner that adapts based on current screen
    switch (_currentIndex) {
      case 0: // POS - Full-screen scan mode
        final posController = ref.read(posControllerProvider);
        posController.enterScanMode();
        break;

      case 1: // Inventory - Show product details or add prompt
        final inventoryController = ref.read(inventoryControllerProvider);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => BarcodeScannerScreen(
              title: 'Scan Product',
              instruction: 'Align barcode within frame to scan product',
              mode: ScannerMode.preview,
              enableManualEntry: true,
              enableHistory: true,
              productLookup: (barcode) {
                // Look up product in inventory
                final product = inventoryController.allProducts
                    .where((p) => p.barcode == barcode)
                    .firstOrNull;
                if (product != null) {
                  return {
                    'name': product.name,
                    'price': product.price.toStringAsFixed(0),
                    'stock': product.stock.toString(),
                  };
                }
                return null; // Product not found
              },
              onConfirmWithProduct: (barcode, productInfo) async {
                logger.AppLogger.info(
                  'Inventory confirm scan: $barcode, product: $productInfo',
                  tag: 'INVENTORY',
                );

                if (productInfo != null) {
                  // Product exists - show details and keep scanner open
                  if (mounted) {
                    final product = inventoryController.allProducts
                        .where((p) => p.barcode == barcode)
                        .firstOrNull;

                    if (product != null) {
                      // Show product details dialog without closing scanner
                      await showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Product Found'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${product.name}'),
                              Text(
                                'Price: Rp ${product.price.toStringAsFixed(0)}',
                              ),
                              Text('Stock: ${product.stock}'),
                              if (product.isLowStock)
                                const Text(
                                  '⚠️ Low Stock',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              if (product.isOutOfStock)
                                const Text(
                                  '❌ Out of Stock',
                                  style: TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Close'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                Navigator.pop(
                                  context,
                                  barcode,
                                ); // Close scanner and return to inventory
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                              ),
                              child: const Text('View in Inventory'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  return false; // Keep scanner open
                } else {
                  // Product not found - show add product dialog
                  if (mounted) {
                    final shouldAdd = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Product Not Found'),
                        content: Text('Barcode $barcode is not in inventory.'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text('Add Product'),
                          ),
                        ],
                      ),
                    );

                    if (shouldAdd == true) {
                      // Navigate to add product dialog


                      if (!mounted) return false;

                      await showDialog(
                        context: context,
                        builder: (dialogContext) => AddProductDialog(
                          onAdd:
                              ({
                                required String name,
                                required double price,
                                required double costPrice,
                                required int stock,
                                int? categoryId,
                                int? supplierId,
                                String? barcode,
                                String? imagePath,
                                String? unitOfMeasurement,
                                bool hasVariants = false,
                              }) async {
                                return await inventoryController.addProduct(
                                  name: name,
                                  price: price,
                                  costPrice: costPrice,
                                  stock: stock,
                                  categoryId: categoryId,
                                  supplierId: supplierId,
                                  barcode: barcode,
                                  imagePath: imagePath,
                                  unitOfMeasurement: unitOfMeasurement,
                                  hasVariants: hasVariants,
                                );
                              },
                          initialBarcode: barcode,
                        ),
                      );

                      // Reload inventory and close scanner
                      await inventoryController.loadProducts();
                      return true; // Close scanner
                    }
                  }
                  return false; // Keep scanner open
                }
              },
            ),
          ),
        );
        break;

      default: // Other screens - Just scan and show result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarcodeScannerScreen(
              title: 'Scan Barcode',
              instruction: 'Align barcode within frame',
              mode: ScannerMode.preview,
              enableManualEntry: true,
              enableHistory: true,
              onScanned: (barcode) {
                Navigator.pop(context, barcode);
              },
            ),
          ),
        );

        if (result != null && result is String && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned: $result'),
              action: SnackBarAction(
                label: 'Copy',
                textColor: AppTheme.primaryColor,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: result));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    // Show login screen if not authenticated
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // Show main app if authenticated
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: _buildFloatingBottomNav(),
      drawer: _buildDrawer(context, auth),
    );
  }

  // EVERYTHING BELOW HERE IS IDENTICAL - DON'T TOUCH!
  Widget _buildFloatingBottomNav() {
    final isVerySmall = ResponsiveHelper.isVerySmallScreen(context);

    return SlideTransition(
      position: _navSlideAnimation,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isVerySmall ? 12 : 20,
          0,
          isVerySmall ? 12 : 20,
          isVerySmall ? 0 : 20,
        ),
        child: _GlassBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex != index) {
              setState(() => _currentIndex = index);
              // Refresh data when switching to any tab
              _refreshCurrentTab();
            }
          },
          onScannerPressed: _handleQRScan,
          scannerAnimation: _scannerPulseAnimation,
          isCompact: isVerySmall,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthController auth) {
    final currentUser = auth.currentUser;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User Header
            UserDrawerHeader(
              userName: currentUser?.fullName ?? 'Admin',
              userRole: currentUser != null
                  ? (currentUser.role == UserRole.admin ? 'Admin' : 'Kasir')
                  : 'Store Manager',
              storeName: AppConstants.appName,
              onSettingsTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4); // Go to settings
              },
            ),

            const Divider(height: 1),

            // Scrollable content - all drawer sections
            const Expanded(child: DrawerSections()),

            // Logout Button
            ListTile(
              leading: Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              title: Text(
                'Keluar',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                auth.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Glassmorphic bottom navigation bar
class _GlassBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onScannerPressed;
  final Animation<double> scannerAnimation;
  final bool isCompact;
  const _GlassBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onScannerPressed,
    required this.scannerAnimation,
    required this.isCompact,
  });
  @override
  State<_GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<_GlassBottomNav> {
  int _pressedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          (widget.isCompact ? 60 : 70) + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.point_of_sale_rounded,
                  label: 'POS',
                  index: 0,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Inventory',
                  index: 1,
                ),
              ],
            ),
          ),
          _buildScannerButton(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.history_rounded,
                  label: 'History',
                  index: 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  index: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.currentIndex == index;
    final isPressed = _pressedIndex == index;
    return Expanded(
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _pressedIndex = index);
          },
          onTapUp: (_) {
            setState(() => _pressedIndex = -1);
            HapticHelper.selection();
            widget.onTap(index);
          },
          onTapCancel: () {
            setState(() => _pressedIndex = -1);
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([]),
            builder: (context, _) {
              final offset = isPressed ? const Offset(4.0, 4.0) : Offset.zero;
              return Transform.translate(
                offset: offset,
                child: widget.isCompact
                    ? _buildCompactNavItem(icon, isSelected, isPressed)
                    : _buildExpandedNavItem(icon, label, isSelected, isPressed),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactNavItem(IconData icon, bool isSelected, bool isPressed) {
    return Container(
      height: 44,
      width: 44,
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(color: Colors.black, width: 2),
            )
          : null,
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _buildExpandedNavItem(
    IconData icon,
    String label,
    bool isSelected,
    bool isPressed,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(color: Colors.black, width: 2),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.black : Colors.white,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? Colors.black : Colors.white,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerButton() {
    final isPressed = _pressedIndex == 999;
    return AnimatedBuilder(
      animation: widget.scannerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.scannerAnimation.value,
          child: Tooltip(
            message: 'Scan QR Code',
            waitDuration: const Duration(milliseconds: 500),
            showDuration: const Duration(seconds: 2),
            child: GestureDetector(
              onTapDown: (_) {
                setState(() => _pressedIndex = 999);
              },
              onTapUp: (_) {
                setState(() => _pressedIndex = -1);
                HapticHelper.selection();
                widget.onScannerPressed();
              },
              onTapCancel: () {
                setState(() => _pressedIndex = -1);
              },
              child: AnimatedBuilder(
                animation: Listenable.merge([]),
                builder: (context, _) {
                  final offset = isPressed
                      ? const Offset(4.0, 4.0)
                      : Offset.zero;
                  final shadowAlpha = isPressed ? 0.1 : 0.3;
                  return Transform.translate(
                    offset: offset,
                    child: Container(
                      width: widget.isCompact ? 40 : 56,
                      height: widget.isCompact ? 40 : 56,
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.isCompact ? 4 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          widget.isCompact ? 8 : NeoBrutalTheme.radiusMedium,
                        ),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: shadowAlpha),
                            offset: const Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: NeoBrutalTheme.primary,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
