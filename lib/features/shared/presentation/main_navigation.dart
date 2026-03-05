import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../inventory/presentation/controllers/inventory_controller.dart';
import '../../inventory/presentation/screens/inventory_screen.dart';
import '../../inventory/presentation/screens/low_stock_dashboard_screen.dart';
import '../../pos/presentation/screens/pos_screen.dart';
import '../../../core/presentation/widgets/barcode_scanner_screen.dart';
import '../../sales/presentation/screens/sales_history_screen.dart';
import '../../sales/presentation/screens/sales_report_screen.dart';
import '../../sales/presentation/screens/discount_management_screen.dart';
import '../../sales/presentation/controllers/discount_controller.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../../../core/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Main navigation widget with bottom tab bar and universal QR scanner FAB
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<POSScreenState> _posScreenKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late final List<Widget> _screens = [
    POSScreen(key: _posScreenKey),
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

  Future<void> _handleQRScan() async {
    // Smart scanner that adapts based on current screen
    switch (_currentIndex) {
      case 0: // POS - Instant scan, add to cart
        if (_posScreenKey.currentState != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeScannerScreen(
                title: 'Scan Product',
                instruction: 'Align barcode within frame to add to cart',
                mode: ScannerMode.instant,
                enableManualEntry: true,
                enableHistory: true,
                onScanned: (barcode) {
                  Navigator.pop(context, barcode);
                },
              ),
            ),
          );

          if (result != null && result is String && mounted) {
            _posScreenKey.currentState?.handleBarcodeScanned(result);
          }
        }
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
          // Show snackbar with barcode - user can tap "Add Product" to use it
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Barcode scanned: $result'),
                action: SnackBarAction(
                  label: 'Copy',
                  textColor: AppTheme.primaryColor,
                  onPressed: () {
                    // TODO: Copy to clipboard
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
                onPressed: () {
                  // TODO: Copy to clipboard
                },
              ),
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: _buildDrawer(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(_getScreenTitle()),
      centerTitle: true,
    );
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Point of Sale';
      case 1:
        return 'Inventory';
      case 2:
        return 'Sales History';
      case 3:
        return 'Sales Reports';
      case 4:
        return 'Settings';
      default:
        return '';
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Left side nav items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      icon: Icons.point_of_sale,
                      label: 'POS',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.inventory,
                      label: 'Inventory',
                      index: 1,
                    ),
                  ],
                ),
              ),

              // Center scanner button (larger, inline)
              _buildScannerButton(),

              // Right side nav items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      icon: Icons.history,
                      label: 'History',
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.bar_chart,
                      label: 'Reports',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildScannerButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.infoColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.infoColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleQRScan,
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.store,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola bisnis Anda',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            // Low Stock Dashboard
            ListTile(
              leading: Icon(Icons.warning_amber, color: AppTheme.warningColor),
              title: Text('Dashboard Stok Rendah'),
              subtitle: Text('Lihat produk dengan stok rendah'),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer<InventoryController>(
                  builder: (context, controller, _) {
                    final lowStockCount = controller.allProducts
                        .where((p) => p.isLowStock || p.isOutOfStock)
                        .length;
                    return Text(
                      '$lowStockCount',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: context.read<InventoryController>(),
                      child: const LowStockDashboardScreen(),
                    ),
                  ),
                );
              },
            ),

            Divider(),

            // Discount Management
            ListTile(
              leading: Icon(Icons.discount, color: AppTheme.successColor),
              title: Text('Diskon'),
              subtitle: Text('Kelola promosi & diskon'),
              trailing: Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: context.read<DiscountController>(),
                      child: const DiscountManagementScreen(),
                    ),
                  ),
                );
              },
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.textSecondary),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
          ],
        ),
      ),
    );
  }
}
