import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/audio_feedback_helper.dart';

// Import extracted scanner widgets
import 'scanner/scanner_top_bar.dart';
import 'scanner/scanner_bottom_bar.dart';
import 'scanner/scanning_frame.dart';

/// Scanner behavior modes
enum ScannerMode {
  /// Automatically closes and returns result after scanning (no preview)
  instant,

  /// Shows preview of scanned barcode with confirmation before returning
  preview,

  /// Continuous scanning for batch operations (stays open, accumulates scans)
  continuous,
}

/// Extension to get format name from mobile_scanner Barcode
extension BarcodeFormatExtension on Barcode {
  String getFormatName() {
    // Return the format name in a more readable format
    final fmt = format;
    if (fmt == BarcodeFormat.ean13) return 'EAN-13';
    if (fmt == BarcodeFormat.ean8) return 'EAN-8';
    if (fmt == BarcodeFormat.upcA) return 'UPC-A';
    if (fmt == BarcodeFormat.upcE) return 'UPC-E';
    if (fmt == BarcodeFormat.code128) return 'Code 128';
    if (fmt == BarcodeFormat.code39) return 'Code 39';
    if (fmt == BarcodeFormat.code93) return 'Code 93';
    if (fmt == BarcodeFormat.dataMatrix) return 'DataMatrix';
    if (fmt == BarcodeFormat.pdf417) return 'PDF417';
    if (fmt == BarcodeFormat.aztec) return 'Aztec';
    if (fmt == BarcodeFormat.codabar) return 'Codabar';
    if (fmt == BarcodeFormat.itf14) return 'ITF-14';
    // For formats that might not exist in all versions, return the enum name
    return format.name.replaceAll('_', ' ');
  }
}

/// Full-screen barcode/QR scanner with scanning frame overlay
///
/// Features:
/// - Full-screen camera view with mobile_scanner
/// - Centered scanning frame overlay with corner markers
/// - Flash toggle button at top
/// - Camera switch and scan again controls at bottom
/// - Haptic feedback on successful scan
/// - Configurable title, instructions, and validation
/// - Manual barcode entry option
/// - Continuous scanning mode for batch operations
/// - Scan history with quick re-scan
/// - Barcode format detection
/// - Camera selection persistence
/// - Product preview for POS
///
/// Example usage:
/// ```dart
/// // Simple instant scan
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => BarcodeScannerScreen(
///       title: 'Scan Product',
///       instruction: 'Align barcode within frame',
///       mode: ScannerMode.instant,
///       onScanned: (barcode) => handleBarcode(barcode),
///     ),
///   ),
/// )
///
/// // Continuous scan for batch operations
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => BarcodeScannerScreen(
///       title: 'Batch Scan Products',
///       mode: ScannerMode.continuous,
///       onBatchComplete: (barcodes) => handleBatch(barcodes),
///     ),
///   ),
/// )
/// ```
class BarcodeScannerScreen extends StatefulWidget {
  /// Callback when a barcode is successfully scanned
  final Function(String barcode)? onScanned;

  /// Callback for batch complete (only used in continuous mode)
  final Function(List<String> barcodes)? onBatchComplete;

  /// Scanner behavior mode
  final ScannerMode mode;

  /// Title shown in the top bar
  final String title;

  /// Instruction text shown in the scanning frame
  final String instruction;

  /// Optional validation callback to check if scanned barcode is valid
  /// Return null if valid, or an error message to display to user
  final String? Function(String barcode)? onValidate;

  /// Enable manual barcode entry option
  final bool enableManualEntry;

  /// Enable scan history (shows recent scans)
  final bool enableHistory;

  /// Maximum history items to keep
  final int maxHistoryItems;

  /// Callback to get product info for preview (for POS)
  final Map<String, String>? Function(String barcode)? productLookup;

  const BarcodeScannerScreen({
    super.key,
    this.onScanned,
    this.onBatchComplete,
    this.mode = ScannerMode.preview,
    this.title = 'Scan Barcode',
    this.instruction = 'Align barcode within frame',
    this.onValidate,
    this.enableManualEntry = true,
    this.enableHistory = true,
    this.maxHistoryItems = 10,
    this.productLookup,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  String? _scannedBarcode;
  String? _validationError;
  String? _detectedFormatName;
  Map<String, String>? _productInfo;

  // Continuous mode state
  final List<String> _scannedBarcodes = [];
  final Set<String> _uniqueBarcodes = {};

  // History state
  final List<String> _scanHistory = [];

  // Settings persistence
  static const String _cameraFacingKey = 'scanner_camera_facing';
  static const String _historyKey = 'scanner_history';

  @override
  void initState() {
    super.initState();
    AudioFeedbackHelper.instance.init();
    _loadSettings();
    _loadHistory();
    _controller.barcodes.listen(_onBarcodeDetected);
  }

  @override
  void dispose() {
    _saveSettings();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final useFrontCamera = prefs.getBool(_cameraFacingKey) ?? false;
    // Set camera facing on next frame
    if (useFrontCamera) {
      // Switch to front camera
      _controller.switchCamera();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Note: We can't reliably detect which camera is active in mobile_scanner
    // So we just save the user's preference when they explicitly switch

    // Save history
    if (widget.enableHistory) {
      await prefs.setStringList(
        _historyKey,
        _scanHistory.take(widget.maxHistoryItems).toList(),
      );
    }
  }

  Future<void> _loadHistory() async {
    if (!widget.enableHistory) return;
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    setState(() {
      _scanHistory.clear();
      _scanHistory.addAll(history);
    });
  }

  void _addToHistory(String barcode) {
    if (!widget.enableHistory) return;
    setState(() {
      _scanHistory.remove(barcode); // Remove if exists
      _scanHistory.insert(0, barcode); // Add to front
      if (_scanHistory.length > widget.maxHistoryItems) {
        _scanHistory.removeLast();
      }
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
      // Detect format
      final formatName = barcode.getFormatName();

      setState(() {
        _scannedBarcode = barcode.rawValue;
        _validationError = null;
        _detectedFormatName = formatName;
      });

      // Audio and haptic feedback on successful scan
      AudioFeedbackHelper.instance.playBeep();

      // Run validation if provided
      if (widget.onValidate != null) {
        final error = widget.onValidate!(barcode.rawValue!);
        if (error != null) {
          setState(() {
            _validationError = error;
            _isScanning = true; // Allow scanning again
          });
          return;
        }
      }

      // Add to history
      _addToHistory(barcode.rawValue!);

      // Look up product info if callback provided
      if (widget.productLookup != null) {
        final productInfo = widget.productLookup!(barcode.rawValue!);
        setState(() {
          _productInfo = productInfo;
        });
      }

      // Handle based on mode
      if (widget.mode == ScannerMode.instant) {
        // Instant mode: return immediately after short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onScanned?.call(barcode.rawValue!);
            Navigator.pop(context, barcode.rawValue);
          }
        });
      } else if (widget.mode == ScannerMode.continuous) {
        // Continuous mode: add to list and keep scanning
        _addContinuousScan(barcode.rawValue!);
      }
      // Preview mode: wait for user confirmation (tap on scan result)
    }
  }

  void _addContinuousScan(String barcode) {
    setState(() {
      if (_uniqueBarcodes.add(barcode)) {
        _scannedBarcodes.add(barcode);
      }
      _isScanning = true; // Keep scanning
      _scannedBarcode = null; // Clear to show we're ready for next
    });

    // Brief feedback
    AudioFeedbackHelper.instance.playClick();
  }

  void _resetScanner() {
    setState(() {
      _scannedBarcode = null;
      _validationError = null;
      _isScanning = true;
      _productInfo = null;
    });
  }

  void _confirmScan() {
    if (_scannedBarcode != null) {
      widget.onScanned?.call(_scannedBarcode!);
      Navigator.pop(context, _scannedBarcode);
    }
  }

  void _completeContinuousScan() {
    if (_scannedBarcodes.isNotEmpty) {
      widget.onBatchComplete?.call(_scannedBarcodes);
      Navigator.pop(context, _scannedBarcodes);
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enter Barcode Manually'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Barcode',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.barcode_reader),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final barcode = controller.text.trim();
              if (barcode.isNotEmpty) {
                Navigator.pop(dialogContext);
                // Trigger the same flow as if scanned
                _onBarcodeDetected(
                  BarcodeCapture(barcodes: [Barcode(rawValue: barcode)]),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.history, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Text(
                    'Scan History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            if (_scanHistory.isEmpty)
              Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No scan history yet',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                itemCount: _scanHistory.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final barcode = _scanHistory[index];
                  return ListTile(
                    leading: Icon(
                      Icons.qr_code_2,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(
                      barcode,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      // Rescan this barcode
                      _onBarcodeDetected(
                        BarcodeCapture(barcodes: [Barcode(rawValue: barcode)]),
                      );
                    },
                  );
                },
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen camera view
          MobileScanner(controller: _controller, onDetect: _onBarcodeDetected),

          // Centered scanning frame overlay
          Center(child: ScanningFrame(instruction: widget.instruction)),

          // Top bar with controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScannerTopBar(
              title: widget.title,
              onClose: () => Navigator.pop(context),
              onToggleFlash: () => _controller.toggleTorch(),
              isFlashOn: _controller.torchEnabled,
            ),
          ),

          // Bottom bar with scan controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ScannerBottomBar(
              mode: widget.mode.name,
              scannedBarcodes: _scannedBarcodes,
              scannedBarcode: _scannedBarcode,
              validationError: _validationError,
              detectedFormat: _detectedFormatName,
              productInfo: _productInfo,
              scanHistoryCount: _scanHistory.length,
              enableManualEntry: widget.enableManualEntry,
              enableHistory: widget.enableHistory,
              onReset: _resetScanner,
              onConfirm: _confirmScan,
              onManualEntry: _showManualEntryDialog,
              onShowHistory: _showHistorySheet,
              onCompleteContinuous: _completeContinuousScan,
              onFlipCamera: () => _controller.switchCamera(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),

          // Title
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Flash toggle button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => _controller.toggleTorch(),
              padding: EdgeInsets.zero,
              tooltip: 'Toggle Flash',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
          if (widget.mode == ScannerMode.continuous &&
              _scannedBarcodes.isNotEmpty)
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Scanned: ${_scannedBarcodes.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _completeContinuousScan,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            textStyle: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  // List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: _scannedBarcodes.length,
                      itemBuilder: (context, index) {
                        final barcode = _scannedBarcodes[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  barcode,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Validation error display
          if (_validationError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationError!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Product preview (for POS with product lookup)
          if (_productInfo != null && _scannedBarcode != null)
            Container(
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
                      Icon(
                        Icons.shopping_cart,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _productInfo!['name'] ?? 'Unknown Product',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (_productInfo!['price'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Text(
                            'Price: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            _productInfo!['price']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                          if (_productInfo!['stock'] != null) ...[
                            SizedBox(width: 16),
                            Text(
                              'Stock: ${_productInfo!['stock']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: _productInfo!['stock'] == '0'
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
            ),

          // Scanned result display
          if (_scannedBarcode != null &&
              _validationError == null &&
              widget.mode != ScannerMode.continuous)
            Container(
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
                        widget.mode == ScannerMode.preview
                            ? Icons.touch_app
                            : Icons.check_circle,
                        color: widget.mode == ScannerMode.preview
                            ? AppTheme.infoColor
                            : AppTheme.successColor,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        widget.mode == ScannerMode.preview
                            ? 'Tap to confirm'
                            : 'Scanned',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      // Format badge
                      if (_detectedFormatName != null &&
                          _detectedFormatName != 'Unknown')
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _detectedFormatName!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.infoColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: widget.mode == ScannerMode.preview
                        ? _confirmScan
                        : null,
                    child: Text(
                      _scannedBarcode!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

          // Control buttons
          if (widget.mode == ScannerMode.continuous)
            Row(
              children: [
                // Manual entry button
                if (widget.enableManualEntry)
                  Expanded(
                    child: _buildControlButton(
                      icon: Icons.keyboard,
                      label: 'Manual Entry',
                      backgroundColor: AppTheme.infoColor,
                      onTap: _showManualEntryDialog,
                    ),
                  ),
                if (widget.enableManualEntry) SizedBox(width: 12),
                // Scan history button
                if (widget.enableHistory)
                  Expanded(
                    child: _buildControlButton(
                      icon: Icons.history,
                      label: 'History (${_scanHistory.length})',
                      backgroundColor: AppTheme.warningColor,
                      onTap: _showHistorySheet,
                    ),
                  ),
                if (widget.enableHistory) SizedBox(width: 12),
                // Complete batch button
                Expanded(
                  child: _buildControlButton(
                    icon: Icons.check_circle,
                    label: 'Done (${_scannedBarcodes.length})',
                    backgroundColor: AppTheme.successColor,
                    onTap: _completeContinuousScan,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                // Scan again / refresh button
                Expanded(
                  child: _buildControlButton(
                    icon: Icons.refresh,
                    label: 'Scan Again',
                    backgroundColor: AppTheme.primaryColor,
                    onTap: _resetScanner,
                  ),
                ),
                SizedBox(width: 12),
                // Manual entry button
                if (widget.enableManualEntry)
                  Expanded(
                    child: _buildControlButton(
                      icon: Icons.keyboard,
                      label: 'Manual Entry',
                      backgroundColor: AppTheme.infoColor,
                      onTap: _showManualEntryDialog,
                    ),
                  ),
                if (widget.enableManualEntry) SizedBox(width: 12),
                // History or flip camera button
                if (widget.enableHistory)
                  Expanded(
                    child: _buildControlButton(
                      icon: Icons.history,
                      label: 'History',
                      backgroundColor: AppTheme.warningColor,
                      onTap: _showHistorySheet,
                    ),
                  )
                else
                  Expanded(
                    child: _buildControlButton(
                      icon: Icons.flip_camera_ios,
                      label: 'Flip Camera',
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      border: Border.all(color: Colors.white, width: 1.5),
                      onTap: () => _controller.switchCamera(),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    Color? foregroundColor,
    BoxBorder? border,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor ?? Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Centered scanning frame overlay with corner markers
  Widget _buildScanningFrame() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.8),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Top corner markers
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildCornerMarker(), _buildCornerMarker()],
            ),
          ),

          // Scan instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.instruction,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Bottom corner markers
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildCornerMarker(), _buildCornerMarker()],
            ),
          ),
        ],
      ),
    );
  }

  /// Corner marker for scanning frame
  Widget _buildCornerMarker() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
