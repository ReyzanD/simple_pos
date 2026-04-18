import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'scanner_control_button.dart';
import 'continuous_scan_list.dart';
import 'validation_error_display.dart';
import 'scanned_result_display.dart';
import 'scanner_product_preview.dart';

/// Scanner bottom bar with controls
class ScannerBottomBar extends StatelessWidget {
  final String mode;
  final List<String> scannedBarcodes;
  final String? scannedBarcode;
  final String? validationError;
  final String? detectedFormat;
  final Map<String, String>? productInfo;
  final int scanHistoryCount;
  final bool enableManualEntry;
  final bool enableHistory;
  final VoidCallback onReset;
  final VoidCallback? onConfirm;
  final VoidCallback? onManualEntry;
  final VoidCallback? onShowHistory;
  final VoidCallback? onCompleteContinuous;
  final VoidCallback? onFlipCamera;

  const ScannerBottomBar({
    super.key,
    required this.mode,
    required this.scannedBarcodes,
    this.scannedBarcode,
    this.validationError,
    this.detectedFormat,
    this.productInfo,
    required this.scanHistoryCount,
    this.enableManualEntry = true,
    this.enableHistory = true,
    required this.onReset,
    this.onConfirm,
    this.onManualEntry,
    this.onShowHistory,
    this.onCompleteContinuous,
    this.onFlipCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Continuous mode scan list
          if (mode == 'continuous' && scannedBarcodes.isNotEmpty)
            ContinuousScanList(
              scannedBarcodes: scannedBarcodes,
              onComplete: onCompleteContinuous!,
            ),

          // Validation error display
          if (validationError != null)
            ValidationErrorDisplay(errorMessage: validationError!),

          // Product preview (for POS with product lookup)
          if (productInfo != null && scannedBarcode != null)
            ScannerProductPreview(productInfo: productInfo!),

          // Scanned result display
          if (scannedBarcode != null &&
              validationError == null &&
              mode != 'continuous')
            ScannedResultDisplay(
              barcode: scannedBarcode!,
              mode: mode,
              detectedFormat: detectedFormat,
              onConfirm: onConfirm,
            ),

          // Control buttons
          if (mode == 'continuous')
            Row(
              children: [
                // Manual entry button
                if (enableManualEntry)
                  Expanded(
                    child: ScannerControlButton(
                      icon: Icons.keyboard,
                      label: 'Manual Entry',
                      backgroundColor: AppTheme.infoColor,
                      onTap: onManualEntry!,
                    ),
                  ),
                if (enableManualEntry) const SizedBox(width: 12),
                // Scan history button
                if (enableHistory)
                  Expanded(
                    child: ScannerControlButton(
                      icon: Icons.history,
                      label: 'History ($scanHistoryCount)',
                      backgroundColor: AppTheme.warningColor,
                      onTap: onShowHistory!,
                    ),
                  ),
                if (enableHistory) const SizedBox(width: 12),
                // Complete batch button
                Expanded(
                  child: ScannerControlButton(
                    icon: Icons.check_circle,
                    label: 'Done (${scannedBarcodes.length})',
                    backgroundColor: AppTheme.successColor,
                    onTap: onCompleteContinuous!,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                // Scan again / refresh button
                Expanded(
                  child: ScannerControlButton(
                    icon: Icons.refresh,
                    label: 'Scan Again',
                    backgroundColor: AppTheme.primaryColor,
                    onTap: onReset,
                  ),
                ),
                const SizedBox(width: 12),
                // Manual entry button
                if (enableManualEntry)
                  Expanded(
                    child: ScannerControlButton(
                      icon: Icons.keyboard,
                      label: 'Manual Entry',
                      backgroundColor: AppTheme.infoColor,
                      onTap: onManualEntry!,
                    ),
                  ),
                if (enableManualEntry) const SizedBox(width: 12),
                // History or flip camera button
                if (enableHistory)
                  Expanded(
                    child: ScannerControlButton(
                      icon: Icons.history,
                      label: 'History',
                      backgroundColor: AppTheme.warningColor,
                      onTap: onShowHistory!,
                    ),
                  )
                else
                  Expanded(
                    child: ScannerControlButton(
                      icon: Icons.flip_camera_ios,
                      label: 'Flip Camera',
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      border: Border.all(color: Colors.white, width: 1.5),
                      onTap: onFlipCamera!,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
