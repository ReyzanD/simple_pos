import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Scanned result display widget
class ScannedResultDisplay extends StatelessWidget {
  final String barcode;
  final String mode;
  final String? detectedFormat;
  final VoidCallback? onConfirm;

  const ScannedResultDisplay({
    super.key,
    required this.barcode,
    required this.mode,
    this.detectedFormat,
    this.onConfirm,
  });

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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mode == 'preview' ? Icons.touch_app : Icons.check_circle,
                color: mode == 'preview'
                    ? AppTheme.infoColor
                    : AppTheme.successColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                mode == 'preview' ? 'Tap to confirm' : 'Scanned',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Format badge
              if (detectedFormat != null && detectedFormat != 'Unknown')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    detectedFormat!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.infoColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onConfirm,
            child: Text(
              barcode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
