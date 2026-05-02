import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/audio_feedback_helper.dart';
import '../../../../core/utils/logger.dart' as logger;

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

  /// Callback when user confirms a scanned item in preview mode
  /// Returns true to close scanner, false to keep it open
  final Function(String barcode, Map<String, String>? productInfo)? onConfirmWithProduct;

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
    this.onConfirmWithProduct,
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

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  String? _scannedBarcode;
  String? _validationError;
  String? _detectedFormatName;
  Map<String, String>? _productInfo;

  // Continuous mode state
  final List<Map<String, String>> _scannedProducts = [];
  final Set<String> _uniqueBarcodes = {};

  // History state
  final List<String> _scanHistory = [];

  // Settings persistence
  static const String _cameraFacingKey = 'scanner_camera_facing';
  static const String _historyKey = 'scanner_history';

  @override
  void initState() {
    super.initState();
    logger.AppLogger.info('BarcodeScannerScreen: initState called', tag: 'CAMERA');
    WidgetsBinding.instance.addObserver(this);
    AudioFeedbackHelper.instance.init();
    _loadSettings();
    _loadHistory();
  }

  @override
  void dispose() {
    logger.AppLogger.info('BarcodeScannerScreen: dispose called', tag: 'CAMERA');
    logger.AppLogger.info('Note: BufferQueue abandonment errors are expected during camera stop and can be ignored', tag: 'CAMERA');
    WidgetsBinding.instance.removeObserver(this);
    _saveSettings();
    // Properly dispose the camera controller to prevent resource leaks
    // BufferQueue abandonment errors are expected when stopping a camera that's processing frames
    try {
      logger.AppLogger.debug('Disposing camera controller...', tag: 'CAMERA');
      _controller.dispose();
      logger.AppLogger.info('Camera controller disposed successfully', tag: 'CAMERA');
    } catch (e) {
      logger.AppLogger.error('Error disposing camera controller', error: e, tag: 'CAMERA');
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.AppLogger.info('App lifecycle changed to: $state', tag: 'CAMERA');

    switch (state) {
      case AppLifecycleState.resumed:
        logger.AppLogger.info('App resumed, camera should be active', tag: 'CAMERA');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        logger.AppLogger.warning('App inactive/paused/detached, stopping camera', tag: 'CAMERA');
        try {
          _controller.stop();
          logger.AppLogger.info('Camera stopped due to app lifecycle change', tag: 'CAMERA');
        } catch (e) {
          logger.AppLogger.error('Error stopping camera on lifecycle change', error: e, tag: 'CAMERA');
        }
        break;
      case AppLifecycleState.hidden:
        logger.AppLogger.warning('App hidden, stopping camera', tag: 'CAMERA');
        try {
          _controller.stop();
          logger.AppLogger.info('Camera stopped due to app hidden', tag: 'CAMERA');
        } catch (e) {
          logger.AppLogger.error('Error stopping camera on app hidden', error: e, tag: 'CAMERA');
        }
        break;
    }

    super.didChangeAppLifecycleState(state);
  }

  Future<void> _loadSettings() async {
    logger.AppLogger.debug('Loading camera settings...', tag: 'CAMERA');
    final prefs = await SharedPreferences.getInstance();
    final useFrontCamera = prefs.getBool(_cameraFacingKey) ?? false;
    logger.AppLogger.debug('Front camera preference: $useFrontCamera', tag: 'CAMERA');

    // Set camera facing after a brief delay to ensure camera is ready
    if (useFrontCamera) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        try {
          logger.AppLogger.debug('Switching to front camera during init...', tag: 'CAMERA');
          _controller.switchCamera();
          logger.AppLogger.info('Front camera set successfully', tag: 'CAMERA');
        } catch (e) {
          logger.AppLogger.error('Error switching to front camera during init', error: e, tag: 'CAMERA');
          // Ignore camera switch errors during initialization
        }
      }
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
    logger.AppLogger.debug('_onBarcodeDetected called, isScanning: $_isScanning', tag: 'CAMERA');

    if (!_isScanning) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
      // Detect format
      final formatName = barcode.getFormatName();
      logger.AppLogger.info('Barcode detected: ${barcode.rawValue} (format: $formatName)', tag: 'CAMERA');

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
          logger.AppLogger.warning('Barcode validation failed: $error', tag: 'CAMERA');
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
        logger.AppLogger.debug('Product lookup result: $productInfo', tag: 'CAMERA');
      }

      // Handle based on mode
      if (widget.mode == ScannerMode.instant) {
        logger.AppLogger.info('Instant mode: stopping camera and returning', tag: 'CAMERA');

        // Disable scanning immediately to prevent race condition
        setState(() {
          _isScanning = false;
        });
        logger.AppLogger.info('Scanning disabled in instant mode', tag: 'CAMERA');

        // Instant mode: stop camera and return immediately
        try {
          logger.AppLogger.debug('Stopping camera in instant mode...', tag: 'CAMERA');
          _controller.stop();
          logger.AppLogger.info('Camera stopped in instant mode', tag: 'CAMERA');
        } catch (e) {
          logger.AppLogger.error('Error stopping camera in instant mode', error: e, tag: 'CAMERA');
          // Continue anyway - camera will be disposed
        }

        // Call the callback and let IT handle navigation
        // This prevents double navigation issues
        logger.AppLogger.info('Instant mode: calling onScanned callback', tag: 'CAMERA');
        widget.onScanned?.call(barcode.rawValue!);
        logger.AppLogger.info('Instant mode: waiting for callback to handle navigation (BufferQueue errors are expected)', tag: 'CAMERA');
      } else if (widget.mode == ScannerMode.continuous) {
        logger.AppLogger.info('Continuous mode: adding barcode to list', tag: 'CAMERA');
        // Continuous mode: add to list and keep scanning
        _addContinuousScan(barcode.rawValue!);
      } else {
        logger.AppLogger.info('Preview mode: waiting for user confirmation', tag: 'CAMERA');
      }
      // Preview mode: wait for user confirmation (tap on scan result)
    } else {
      logger.AppLogger.warning('Barcode detected but value is null or empty', tag: 'CAMERA');
    }
  }

  void _addContinuousScan(String barcode) {
    // Look up product info if callback provided
    final productInfo = widget.productLookup?.call(barcode);

    setState(() {
      if (_uniqueBarcodes.add(barcode)) {
        _scannedProducts.add({
          'barcode': barcode,
          'name': productInfo?['name'] ?? 'Unknown Product',
          'price': productInfo?['price'] ?? '',
          'stock': productInfo?['stock'] ?? '',
        });
      }
      _isScanning = true; // Keep scanning
      _scannedBarcode = null; // Clear to show we're ready for next
    });

    // Enhanced feedback for continuous scanning
    AudioFeedbackHelper.instance.playContinuousScanBeep();
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
    logger.AppLogger.info('_confirmScan called with barcode: $_scannedBarcode', tag: 'CAMERA');

    if (_scannedBarcode != null) {
      // Check if we have the new callback that keeps scanner open
      if (widget.onConfirmWithProduct != null) {
        logger.AppLogger.info('Using onConfirmWithProduct callback (scanner stays open)', tag: 'CAMERA');

        // Call the callback with product info
        final shouldClose = widget.onConfirmWithProduct!(_scannedBarcode!, _productInfo);
        logger.AppLogger.info('onConfirmWithProduct returned: $shouldClose', tag: 'CAMERA');

        if (shouldClose) {
          // Close scanner if callback returns true
          logger.AppLogger.info('Closing scanner per callback request', tag: 'CAMERA');
          try {
            Navigator.pop(context);
          } catch (e) {
            logger.AppLogger.error('Error closing scanner', error: e, tag: 'CAMERA');
          }
        } else {
          // Keep scanner open and re-enable scanning
          logger.AppLogger.info('Keeping scanner open, re-enabling scanning', tag: 'CAMERA');
          setState(() {
            _isScanning = true;
            _scannedBarcode = null;
            _productInfo = null;
          });
        }
      } else {
        // Original behavior - disable scanning and let callback handle navigation
        logger.AppLogger.info('Using original onScanned callback (scanner may close)', tag: 'CAMERA');

        // Disable scanning immediately to prevent race condition
        setState(() {
          _isScanning = false;
        });
        logger.AppLogger.info('Scanning disabled', tag: 'CAMERA');

        // Stop camera before navigation to prevent BufferQueue errors
        try {
          logger.AppLogger.debug('Stopping camera before navigation...', tag: 'CAMERA');
          _controller.stop();
          logger.AppLogger.info('Camera stopped successfully', tag: 'CAMERA');
        } catch (e) {
          logger.AppLogger.error('Error stopping camera', error: e, tag: 'CAMERA');
          // Continue anyway - camera will be disposed
        }

        // Call the callback and let IT handle navigation
        widget.onScanned?.call(_scannedBarcode!);
        logger.AppLogger.info('onScanned callback called', tag: 'CAMERA');

        // Note: BufferQueue abandonment errors are expected and harmless during camera stop
        logger.AppLogger.info('Waiting for callback to handle navigation (BufferQueue errors are expected)', tag: 'CAMERA');
      }
    } else {
      logger.AppLogger.warning('_confirmScan called but no barcode available', tag: 'CAMERA');
    }
  }

  void _completeContinuousScan() {
    logger.AppLogger.info('_completeContinuousScan called with ${_scannedProducts.length} products', tag: 'CAMERA');

    if (_scannedProducts.isNotEmpty) {
      // Disable scanning immediately to prevent race condition
      setState(() {
        _isScanning = false;
      });
      logger.AppLogger.info('Scanning disabled', tag: 'CAMERA');

      // Stop camera before navigation to prevent BufferQueue errors
      try {
        logger.AppLogger.debug('Stopping camera before navigation...', tag: 'CAMERA');
        _controller.stop();
        logger.AppLogger.info('Camera stopped successfully', tag: 'CAMERA');
      } catch (e) {
        logger.AppLogger.error('Error stopping camera', error: e, tag: 'CAMERA');
        // Continue anyway - camera will be disposed
      }

      // Extract barcodes for backward compatibility
      final barcodes = _scannedProducts.map((p) => p['barcode']!).toList();

      // Call the callback and let IT handle navigation
      // This prevents double navigation issues
      widget.onBatchComplete?.call(barcodes);
      logger.AppLogger.info('onBatchComplete callback called', tag: 'CAMERA');

      // Note: BufferQueue abandonment errors are expected and harmless during camera stop
      logger.AppLogger.info('Waiting for callback to handle navigation (BufferQueue errors are expected)', tag: 'CAMERA');
    } else {
      logger.AppLogger.warning('_completeContinuousScan called but no products available', tag: 'CAMERA');
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusXLarge)),
        title: Text('Enter Barcode Manually', style: NeoBrutalTheme.headlineSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Barcode',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge)),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(NeoBrutalTheme.radiusXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Row(
                children: [
                  Icon(Icons.history, color: AppTheme.primaryColor),
                  SizedBox(width: NeoBrutalTheme.spaceSM),
                  Text(
                    'Scan History',
                    style: NeoBrutalTheme.headlineSmall,
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
                padding: EdgeInsets.all(NeoBrutalTheme.spaceXL),
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
          // Full-screen camera view - separated to prevent rebuilds
          _ScannerView(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Centered scanning frame overlay
          Center(child: ScanningFrame(instruction: widget.instruction)),

          // Top bar with controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScannerTopBar(
              title: widget.title,
              onClose: () {
                logger.AppLogger.info('Close button pressed, navigating back', tag: 'CAMERA');
                Navigator.pop(context);
              },
              onToggleFlash: () {
                logger.AppLogger.debug('Toggling flash...', tag: 'CAMERA');
                try {
                  _controller.toggleTorch();
                  logger.AppLogger.debug('Flash toggled successfully', tag: 'CAMERA');
                } catch (e) {
                  logger.AppLogger.error('Error toggling flash', error: e, tag: 'CAMERA');
                }
              },
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
              scannedProducts: _scannedProducts,
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
              onFlipCamera: () {
                logger.AppLogger.info('Switching camera...', tag: 'CAMERA');
                try {
                  _controller.switchCamera();
                  logger.AppLogger.info('Camera switched successfully', tag: 'CAMERA');
                } catch (e) {
                  logger.AppLogger.error('Error switching camera', error: e, tag: 'CAMERA');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Separate camera view widget that doesn't rebuild on state changes
/// This prevents the camera from becoming choppy
class _ScannerView extends StatefulWidget {
  final MobileScannerController controller;
  final Function(BarcodeCapture) onDetect;

  const _ScannerView({
    required this.controller,
    required this.onDetect,
  });

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView> {
  @override
  Widget build(BuildContext context) {
    logger.AppLogger.debug('_ScannerView building...', tag: 'CAMERA');
    return MobileScanner(
      controller: widget.controller,
      onDetect: (capture) {
        logger.AppLogger.debug('Barcode capture detected in _ScannerView', tag: 'CAMERA');
        widget.onDetect(capture);
      },
      onDetectError: (error, stackTrace) {
        logger.AppLogger.error('MobileScanner detection error occurred', error: error, stackTrace: stackTrace, tag: 'CAMERA');
      },
    );
  }
}
