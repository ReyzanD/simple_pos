import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_low_stock_products_usecase.dart';
import '../controllers/inventory_controller.dart';
import '../../../sales/presentation/widgets/summary_stat_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../widgets/low_stock_dashboard_card.dart';

/// Screen displaying low stock and out of stock products
class LowStockDashboardScreen extends StatefulWidget {
  const LowStockDashboardScreen({super.key});

  @override
  State<LowStockDashboardScreen> createState() => _LowStockDashboardScreenState();
}

class _LowStockDashboardScreenState extends State<LowStockDashboardScreen> {
  bool _isLoading = false;
  LowStockResult? _lowStockResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLowStockData();
    });
  }

  Future<void> _loadLowStockData() async {
    if (_isLoading) return; // Prevent concurrent calls

    final controller = context.read<InventoryController>();

    // Load products if not loaded first, before setState
    if (controller.allProducts.isEmpty) {
      await controller.loadProducts();
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = controller.allProducts;

      // Separate into out of stock and low stock
      final outOfStock = products.where((p) => p.isOutOfStock).toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));

      final lowStock = products.where((p) => p.isLowStock && !p.isOutOfStock).toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));

      if (mounted) {
        setState(() {
          _lowStockResult = LowStockResult(
            outOfStockProducts: outOfStock,
            lowStockProducts: lowStock,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background, // ✅ Brutal white background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dashboard Stok Rendah'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: NeoBrutalTheme.blockYellow, // ✅ Bold yellow background
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 6, // ✅ Extra thick bottom border
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _lowStockResult == null
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
              border: Border.all(
                color: Colors.black,
                width: 4, // ✅ Bold border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          Text(
            'Terjadi Kesalahan',
            style: NeoBrutalTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            _errorMessage ?? 'Unknown error',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          ElevatedButton.icon(
            onPressed: _loadLowStockData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoBrutalTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: NeoBrutalTheme.spaceLG,
                vertical: NeoBrutalTheme.spaceMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                side: BorderSide(
                  color: Colors.black,
                  width: 4, // ✅ Bold border
                ),
              ),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.success, // ✅ Solid bold green
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 4, // ✅ Bold border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 70,
              color: Colors.white,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          Text(
            'Semua Stok Aman',
            style: NeoBrutalTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            'Tidak ada produk dengan stok rendah',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final result = _lowStockResult!;

    return RefreshIndicator(
      onRefresh: _loadLowStockData,
      color: NeoBrutalTheme.primary, // ✅ Brutal primary color
      backgroundColor: NeoBrutalTheme.blockYellow.withValues(alpha: 0.3),
      strokeWidth: 4, // ✅ Thicker indicator
      child: SingleChildScrollView(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(result),
            SizedBox(height: NeoBrutalTheme.spaceLG),

            // Out of Stock Section
            if (result.outOfStockProducts.isNotEmpty) ...[
              _buildSectionHeader(
                'KRITIS - Stok Habis',
                Icons.block,
                AppTheme.errorColor,
                result.outOfStockProducts.length,
              ),
              SizedBox(height: NeoBrutalTheme.spaceMD),
              ...result.outOfStockProducts.map((product) =>
                  LowStockDashboardCard(
                    product: product,
                    stockStatus: StockStatus.outOfStock,
                    onEditPressed: () => _editProduct(product),
                  ),
              ),
              SizedBox(height: NeoBrutalTheme.spaceLG),
            ],

            // Low Stock Section
            if (result.lowStockProducts.isNotEmpty) ...[
              _buildSectionHeader(
                'PERINGATAN - Stok Rendah',
                Icons.warning_amber,
                AppTheme.warningColor,
                result.lowStockProducts.length,
              ),
              const SizedBox(height: 12),
              ...result.lowStockProducts.map((product) =>
                  LowStockDashboardCard(
                    product: product,
                    stockStatus: StockStatus.lowStock,
                    onEditPressed: () => _editProduct(product),
                  ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(LowStockResult result) {
    return Row(
      children: [
        Expanded(
          child: SummaryStatCard(
            title: 'Stok Habis',
            value: result.totalOutOfStock.toString(),
            icon: Icons.block,
            color: AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryStatCard(
            title: 'Stok Rendah',
            value: result.totalLowStock.toString(),
            icon: Icons.warning_amber,
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    int count,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(NeoBrutalTheme.spaceSM),
          decoration: BoxDecoration(
            color: color, // ✅ Solid bold color
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
            border: Border.all(
              color: Colors.black, // ✅ Bold black border
              width: 3, // ✅ Bold 3px border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Icon(
            icon,
            color: Colors.white, // ✅ White icon for contrast
            size: 24,
          ),
        ),
        SizedBox(width: NeoBrutalTheme.spaceMD),
        Expanded(
          child: Text(
            title,
            style: NeoBrutalTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMD,
            vertical: NeoBrutalTheme.spaceSM,
          ),
          decoration: BoxDecoration(
            color: color, // ✅ Solid bold color
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
            border: Border.all(
              color: Colors.black, // ✅ Bold black border
              width: 3, // ✅ Bold 3px border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Text(
            '$count produk',
            style: NeoBrutalTheme.labelMedium.copyWith(
              color: Colors.white, // ✅ White text
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  void _editProduct(Product product) {
    // Navigate to edit product dialog
    // This will be implemented with the existing edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit produk: ${product.name}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
