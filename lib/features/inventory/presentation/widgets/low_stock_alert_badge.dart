import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Widget displaying low stock alert badge
class LowStockAlertBadge extends StatelessWidget {
  final int lowStockCount;
  final VoidCallback? onTap;

  const LowStockAlertBadge({
    super.key,
    required this.lowStockCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lowStockCount == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber,
              size: 16,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              '$lowStockCount',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Stok Menipis',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displaying low stock products list
class LowStockProductsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> lowStockProducts;

  const LowStockProductsDialog({
    super.key,
    required this.lowStockProducts,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text('Produk Stok Menipis'),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: lowStockProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Semua stok aman',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  final stock = product['stock'] as int;
                  final isOutOfStock = stock <= AppConstants.outOfStockThreshold;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOutOfStock
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                        child: Icon(
                          isOutOfStock ? Icons.block : Icons.inventory_2,
                          color: isOutOfStock
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        product['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text('Sisa stok: $stock'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? Colors.red.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOutOfStock ? 'Habis' : 'Menipis',
                          style: TextStyle(
                            color: isOutOfStock
                                ? Colors.red.shade900
                                : Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigate to inventory screen filtered by low stock
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Lihat Semua'),
        ),
      ],
    );
  }
}

/// Shows low stock products dialog
void showLowStockDialog({
  required BuildContext context,
  required List<Map<String, dynamic>> lowStockProducts,
}) {
  showDialog(
    context: context,
    builder: (context) => LowStockProductsDialog(
      lowStockProducts: lowStockProducts,
    ),
  );
}
