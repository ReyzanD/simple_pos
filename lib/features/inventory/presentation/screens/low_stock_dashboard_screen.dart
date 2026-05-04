import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_low_stock_products_usecase.dart';
import '../../../shared/presentation/providers.dart';
import '../../../sales/presentation/widgets/summary_stat_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../widgets/low_stock_dashboard_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen displaying low stock and out of stock products
class LowStockDashboardScreen extends ConsumerStatefulWidget {
  const LowStockDashboardScreen({super.key});

  @override
  ConsumerState<LowStockDashboardScreen> createState() =>
      _LowStockDashboardScreenState();
}

class _LowStockDashboardScreenState
    extends ConsumerState<LowStockDashboardScreen> {
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

    final controller = ref.read(inventoryControllerProvider);

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

      final lowStock =
          products.where((p) => p.isLowStock && !p.isOutOfStock).toList()
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background, // ✅ Brutal white background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.stock_dashboard),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(context)
          : _lowStockResult == null
          ? _buildEmptyState(context)
          : _buildContent(l10n),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                color: NeoBrutalTheme.getBorderColor(context),
                width: 4, // ✅ Bold border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(Icons.error_outline, size: 50, color: Colors.white),
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          Text(
            l10n.common_error,
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
            label: Text(l10n.common_retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoBrutalTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: NeoBrutalTheme.spaceLG,
                vertical: NeoBrutalTheme.spaceMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  NeoBrutalTheme.radiusMedium,
                ),
                side: BorderSide(
                  color: NeoBrutalTheme.getBorderColor(context),
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

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                color: NeoBrutalTheme.getBorderColor(context),
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
            l10n.stock_adequate,
            style: NeoBrutalTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            l10n.stock_noLow,
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final result = _lowStockResult!;

    return RefreshIndicator(
      onRefresh: _loadLowStockData,
      color: NeoBrutalTheme.primary, // ✅ Brutal primary color
      backgroundColor: NeoBrutalTheme.blockBlue.withValues(alpha: 0.3),
      strokeWidth: 4, // ✅ Thicker indicator
      child: SingleChildScrollView(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(result, l10n),
            SizedBox(height: NeoBrutalTheme.spaceLG),

            // Out of Stock Section
            if (result.outOfStockProducts.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                l10n,
                l10n.stock_out,
                Icons.block,
                AppTheme.errorColor,
                result.outOfStockProducts.length,
              ),
              SizedBox(height: NeoBrutalTheme.spaceMD),
              ...result.outOfStockProducts.map(
                (product) => LowStockDashboardCard(
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
                context,
                l10n,
                l10n.stock_low,
                Icons.warning_amber,
                AppTheme.warningColor,
                result.lowStockProducts.length,
              ),
              const SizedBox(height: 12),
              ...result.lowStockProducts.map(
                (product) => LowStockDashboardCard(
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

  Widget _buildSummaryCards(LowStockResult result, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SummaryStatCard(
            title: l10n.stock_out,
            value: result.totalOutOfStock.toString(),
            icon: Icons.block,
            color: AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryStatCard(
            title: l10n.stock_low,
            value: result.totalLowStock.toString(),
            icon: Icons.warning_amber,
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    AppLocalizations l10n,
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
            borderRadius: BorderRadius.circular(
              NeoBrutalTheme.radiusMedium,
            ), // ✅ Brutal 8px
            border: Border.all(
              color: NeoBrutalTheme.getBorderColor(
                context,
              ), // ✅ Bold black border
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
            borderRadius: BorderRadius.circular(
              NeoBrutalTheme.radiusMedium,
            ), // ✅ Brutal 8px
            border: Border.all(
              color: NeoBrutalTheme.getBorderColor(
                context,
              ), // ✅ Bold black border
              width: 3, // ✅ Bold 3px border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Text(
            l10n.product_stock_count(count),
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
        content: Text(
          AppLocalizations.of(context)!.common_editProductMessage(product.name),
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.common_ok,
          onPressed: () {},
        ),
      ),
    );
  }
}
