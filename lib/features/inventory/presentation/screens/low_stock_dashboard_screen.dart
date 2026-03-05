import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_low_stock_products_usecase.dart';
import '../controllers/inventory_controller.dart';
import '../../../sales/presentation/widgets/summary_stat_card.dart';
import '../../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        title: const Text('Dashboard Stok Rendah'),
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadLowStockData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
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
              color: AppTheme.successColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.successColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Semua Stok Aman',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada produk dengan stok rendah',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(result),
            const SizedBox(height: 24),

            // Out of Stock Section
            if (result.outOfStockProducts.isNotEmpty) ...[
              _buildSectionHeader(
                'KRITIS - Stok Habis',
                Icons.block,
                AppTheme.errorColor,
                result.outOfStockProducts.length,
              ),
              const SizedBox(height: 12),
              ...result.outOfStockProducts.map((product) =>
                  LowStockDashboardCard(
                    product: product,
                    stockStatus: StockStatus.outOfStock,
                    onEditPressed: () => _editProduct(product),
                  ),
              ),
              const SizedBox(height: 24),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count produk',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
