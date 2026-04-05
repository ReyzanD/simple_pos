import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../inventory/presentation/controllers/inventory_controller.dart';
import '../../inventory/presentation/screens/inventory_screen.dart';
import '../../pos/presentation/screens/pos_screen.dart';
import '../../pos/presentation/controllers/pos_controller.dart';
import '../../../core/presentation/widgets/barcode_scanner_screen.dart';
import '../../sales/presentation/screens/sales_history_screen.dart';
import '../../sales/presentation/screens/sales_report_screen.dart';
import '../../sales/presentation/controllers/sales_history_controller.dart';
import '../../sales/presentation/controllers/sales_report_controller.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../users/presentation/controllers/auth_controller.dart';
import '../../users/presentation/screens/login_screen.dart';
import '../../users/domain/entities/user_role.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../../../core/utils/haptic_helper.dart';
import 'drawer_header.dart';
import 'drawer_sections.dart';

/// Main navigation widget with floating glassmorphic bottom tab bar
/// Shows login screen if not authenticated, otherwise shows main app
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _scannerPulseController;
  late Animation<double> _scannerPulseAnimation;
  late AnimationController _navSlideController;
  late Animation<Offset> _navSlideAnimation;
  final GlobalKey<POSScreenState> _posScreenKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Scanner button pulse animation
    _scannerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scannerPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _scannerPulseController,
      curve: Curves.easeInOut,
    ));

    // Nav slide animation
    _navSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _navSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _navSlideController,
      curve: AnimationCurves.easeOut,
    ));

    _navSlideController.forward();
  }

  @override
  void dispose() {
    _scannerPulseController.dispose();
    _navSlideController.dispose();
    super.dispose();
  }

  late final List<Widget> _screens = [
    POSScreen(
      key: _posScreenKey,
      onCheckoutSuccess: _refreshAllScreens,
    ),
    const InventoryScreen(),
    const SalesHistoryScreen(),
    const SalesReportScreen(),
    const SettingsScreen(),
  ];

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
    final inventoryController = context.read<InventoryController>();
    SalesHistoryController? salesHistoryController;
    SalesReportController? salesReportController;

    try {
      salesHistoryController = context.read<SalesHistoryController>();
    } catch (_) {
      // Controller may not be initialized yet
    }

    try {
      salesReportController = context.read<SalesReportController>();
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
        final inventoryController = context.read<InventoryController>();
        await inventoryController.loadProducts();
        break;
      case 2: // Sales History
        try {
          final salesHistoryController = context.read<SalesHistoryController>();
          await salesHistoryController.refresh();
        } catch (_) {
          // Controller may not be initialized yet
        }
        break;
      case 3: // Sales Report
        try {
          final salesReportController = context.read<SalesReportController>();
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
        final posController = context.read<POSController>();
        posController.enterScanMode();
        break;

      case 1: // Inventory - Preview with validation
        final inventoryController = context.read<InventoryController>();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => BarcodeScannerScreen(
              title: 'Scan to Add Product',
              instruction: 'Align barcode within frame to add new product',
              mode: ScannerMode.preview,
              enableManualEntry: true,
              enableHistory: true,
              onValidate: (barcode) {
                final existing = inventoryController.allProducts
                    .where((p) => p.barcode == barcode)
                    .firstOrNull;
                if (existing != null) {
                  return 'Barcode sudah terdaftar untuk "${existing.name}"';
                }
                return null;
              },
              onScanned: (barcode) {
                Navigator.pop(ctx, barcode);
              },
            ),
          ),
        );

        if (result != null && result is String && mounted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Barcode scanned: $result'),
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
    return Consumer<AuthController>(
      builder: (context, auth, _) {
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
      },
    );
  }

  Widget _buildFloatingBottomNav() {
    return SlideTransition(
      position: _navSlideAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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

            // Scrollable content
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  // Quick Categories Section
                  DrawerCategoryChips(),

                  // Store Stats Card
                  DrawerStoreStats(),

                  // Quick Actions
                  DrawerLowStockItem(),
                  DrawerDiscountItem(),
                  DrawerExpensesItem(),
                  DrawerShiftsItem(),
                  DrawerUsersItem(),
                  DrawerThemeToggle(),

                  // Recent Products Section
                  DrawerRecentProducts(),

                  SizedBox(height: 8),
                ],
              ),
            ),

            // App Info Section (fixed at bottom)
            const Divider(height: 1),
            const DrawerAppInfo(),

            // Logout Button
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
              ),
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
class _GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onScannerPressed;
  final Animation<double> scannerAnimation;

  const _GlassBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onScannerPressed,
    required this.scannerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? AppTheme.darkBorderColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side nav items
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

              // Center scanner button
              _buildScannerButton(),

              // Right side nav items
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
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticHelper.selection(); // Haptic feedback on nav change
          onTap(index);
        },
        child: AnimatedContainer(
          duration: AnimationDurations.fast,
          curve: AnimationCurves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect for selected item
                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Icon
                  AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: AnimationDurations.fast,
                    curve: AnimationCurves.easeOut,
                    child: AnimatedContainer(
                      duration: AnimationDurations.fast,
                      padding: EdgeInsets.all(isSelected ? 10 : 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.getTextSecondaryColor(context),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AnimationDurations.fast,
                curve: AnimationCurves.easeOut,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.getTextSecondaryColor(context),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerButton() {
    return AnimatedBuilder(
      animation: scannerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scannerAnimation.value,
          child: GestureDetector(
            onTap: onScannerPressed,
            child: Container(
              width: 58,
              height: 58,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.ocean,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.infoColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}
