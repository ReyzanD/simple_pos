import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../users/presentation/screens/login_screen.dart';
import '../../users/domain/entities/user_role.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'providers.dart';
import 'drawer_header.dart';
import 'drawer_sections.dart';
import '../../users/presentation/controllers/auth_controller.dart';

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

      case 1: // Inventory - Preview with validation
        final inventoryController = ref.read(inventoryControllerProvider);
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
class _GlassBottomNav extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      height: (isCompact ? 60 : 70) + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockYellow,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
        child: GestureDetector(
          onTap: () {
            HapticHelper.selection(); // Haptic feedback on nav change
            onTap(index);
          },
          child: isCompact
              ? SizedBox(
                  height: 40, // ✅ Proper touch target (was 28)
                  child: Center(
                    child: Icon(
                      icon,
                      size: 22, // ✅ Proper icon size (was 18)
                      color: isSelected ? NeoBrutalTheme.primary : Colors.black,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Proper sizing for good touch targets
                    final maxHeight = constraints.maxHeight;
                    final iconSize = (maxHeight * 0.35).clamp(
                      20.0,
                      26.0,
                    ); // ✅ Larger icons
                    final textSize = (maxHeight * 0.18).clamp(
                      11.0,
                      13.0,
                    ); // ✅ Readable text
                    final spacing = maxHeight * 0.08; // ✅ Proper spacing

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with NO container - just the icon
                        Icon(
                          icon,
                          size: iconSize,
                          color: isSelected
                              ? NeoBrutalTheme.primary
                              : Colors.black,
                        ),
                        // Responsive label
                        SizedBox(height: spacing),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: Colors.black,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
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
          child: Tooltip(
            message: 'Scan QR Code',
            waitDuration: const Duration(milliseconds: 500),
            showDuration: const Duration(seconds: 2),
            child: GestureDetector(
              onTap: onScannerPressed,
              child: Container(
                width: isCompact
                    ? 40
                    : 56, // ✅ Proper touch targets (was 28/48)
                height: isCompact
                    ? 40
                    : 56, // ✅ Proper touch targets (was 28/48)
                margin: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 8),
                decoration: BoxDecoration(
                  color: NeoBrutalTheme.secondary,
                  borderRadius: BorderRadius.circular(
                    isCompact ? 8 : NeoBrutalTheme.radiusMedium,
                  ),
                  border: Border.all(
                    color: Colors.black,
                    width: isCompact ? 3 : 4, // ✅ Bold borders
                  ),
                  boxShadow: isCompact ? [] : NeoBrutalTheme.chunkyShadow,
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: isCompact ? 20 : 26, // ✅ Proper icon sizes (was 12/20)
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
