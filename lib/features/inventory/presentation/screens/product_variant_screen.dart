import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../controllers/product_variant_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';
import 'add_edit_variant_dialog.dart';

/// Screen for managing product variants
class ProductVariantScreen extends StatefulWidget {
  final Product product;

  const ProductVariantScreen({super.key, required this.product});

  @override
  State<ProductVariantScreen> createState() => _ProductVariantScreenState();
}

class _ProductVariantScreenState extends State<ProductVariantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductVariantController>().loadVariants(widget.product.id!);
    });
  }

  Future<void> _addVariant() async {
    final controller = context.read<ProductVariantController>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditVariantDialog(
        productId: widget.product.id!,
        existingVariant: null,
        existingAttributes: controller.attributes,
      ),
    );

    if (result != null && mounted) {
      final variant = ProductVariant(
        productId: widget.product.id!,
        name: result['name'],
        price: result['price'],
        costPrice: result['costPrice'] ?? 0,
        stock: result['stock'],
        barcode: result['barcode'],
        sku: result['sku'],
        attributes: result['attributes'],
        createdAt: DateTime.now(),
      );

      await controller.addVariant(variant);
    }
  }

  Future<void> _editVariant(ProductVariant variant) async {
    final controller = context.read<ProductVariantController>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditVariantDialog(
        productId: widget.product.id!,
        existingVariant: variant,
        existingAttributes: controller.attributes,
      ),
    );

    if (result != null && mounted) {
      final updatedVariant = variant.copyWith(
        name: result['name'],
        price: result['price'],
        costPrice: result['costPrice'] ?? 0,
        stock: result['stock'],
        barcode: result['barcode'],
        sku: result['sku'],
        attributes: result['attributes'],
      );

      await controller.updateVariant(updatedVariant);
    }
  }

  Future<void> _deleteVariant(ProductVariant variant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Varian'),
        content: Text(
          'Apakah Anda yakin ingin menghapus varian "${variant.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ProductVariantController>().deleteVariant(variant.id!);
    }
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text('Varian: ${widget.product.name}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addVariant(),
            tooltip: 'Tambah Varian',
          ),
        ],
      ),
      body: Consumer<ProductVariantController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.variants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError) {
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
                    controller.error?.userMessage ?? 'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        controller.loadVariants(widget.product.id!),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (controller.variants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Varian',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan varian untuk produk ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ModernButton(
                    text: 'Tambah Varian',
                    icon: Icons.add,
                    onPressed: () => _addVariant(),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${controller.variants.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'Varian',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.borderColor,
                    ),
                    Column(
                      children: [
                        Text(
                          '${controller.totalStock}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                        Text(
                          'Total Stok',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Variant list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.variants.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final variant = controller.variants[index];
                    return _buildVariantCard(variant, controller);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVariantCard(
    ProductVariant variant,
    ProductVariantController controller,
  ) {
    final isOutOfStock = variant.isOutOfStock;
    final isLowStock = variant.isLowStock;

    Color stockColor = AppTheme.successColor;
    String stockText = 'Stok: ${variant.stock}';

    if (isOutOfStock) {
      stockColor = AppTheme.errorColor;
      stockText = 'Habis';
    } else if (isLowStock) {
      stockColor = AppTheme.warningColor;
      stockText = 'Stok Rendah: ${variant.stock}';
    }

    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (variant.sku != null || variant.barcode != null)
                      Wrap(
                        spacing: 8,
                        children: [
                          if (variant.sku != null)
                            Chip(
                              label: Text('SKU: ${variant.sku}'),
                              labelStyle: TextStyle(fontSize: 11),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: AppTheme.infoColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          if (variant.barcode != null)
                            Chip(
                              label: Text('Barcode: ${variant.barcode}'),
                              labelStyle: TextStyle(fontSize: 11),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stockText,
                  style: TextStyle(
                    color: stockColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCurrency(variant.price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (variant.costPrice > 0)
                    Text(
                      'Modal: ${_formatCurrency(variant.costPrice)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editVariant(variant),
                    tooltip: 'Edit',
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteVariant(variant),
                    tooltip: 'Hapus',
                    color: AppTheme.errorColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
