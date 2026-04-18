import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Product preview widget for scanner
class ScannerProductPreview extends StatelessWidget {
  final Map<String, String> productInfo;

  const ScannerProductPreview({super.key, required this.productInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart,
                color: AppTheme.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                productInfo['name'] ?? 'Unknown Product',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (productInfo['price'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Text(
                    'Price: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    productInfo['price']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                  if (productInfo['stock'] != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Stock: ${productInfo['stock']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: productInfo['stock'] == '0'
                            ? AppTheme.errorColor
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
