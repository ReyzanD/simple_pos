import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../inventory/domain/entities/category.dart';
import '../../../../core/theme.dart';

/// Category Discounts Tab Widget - manages category-wide discounts
class CategoryDiscountsTabWidget extends StatelessWidget {
  const CategoryDiscountsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage ?? 'Terjadi kesalahan',
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadCategories(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: AppTheme.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'Belum ada kategori',
                  style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Buat kategori di Inventory untuk mengatur diskon',
                  style: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return _buildCategoryCard(context, category, controller);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Category category,
    CategoryController controller,
  ) {
    final hasDiscount = category.hasDiscount;

    return Card(
      elevation: hasDiscount ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: hasDiscount
              ? Border.all(color: AppTheme.successColor.withValues(alpha: 0.3), width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: hasDiscount
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: hasDiscount
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${category.discountPercentage!.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'OFF',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        Icons.category,
                        color: AppTheme.textTertiary,
                        size: 28,
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // Category details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasDiscount ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (category.description != null && category.description!.isNotEmpty)
                    Text(
                      category.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  if (hasDiscount)
                    Text(
                      'Diskon kategori berlaku untuk semua produk',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.successColor,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Text(
                      'Tidak ada diskon',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                ],
              ),
            ),

            // Edit button
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.infoColor, size: 20),
              onPressed: () => _showEditDialog(context, category, controller),
              tooltip: 'Edit Diskon',
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    Category category,
    CategoryController controller,
  ) {
    final discountController = TextEditingController(
      text: category.discountPercentage?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Diskon Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori: ${category.name}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Diskon (%)',
                border: OutlineInputBorder(),
                helperText: '0-100, kosongkan untuk tidak ada diskon',
                suffixIcon: Icon(Icons.percent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final discountText = discountController.text.trim();
              double? discount;

              if (discountText.isNotEmpty) {
                discount = double.tryParse(discountText);
                if (discount == null || discount < 0 || discount > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan angka 0-100')),
                  );
                  return;
                }
              }

              final updated = category.copyWith(discountPercentage: discount);
              controller.updateCategory(updated);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
