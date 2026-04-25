import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
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
  }

  @override
  void dispose() {
    _saveSettings();
    // Let MobileScanner widget handle its own cleanup
    // Manual stop can cause race conditions with the widget's lifecycle
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final useFrontCamera = prefs.getBool(_cameraFacingKey) ?? false;
    // Set camera facing after a brief delay to ensure camera is ready
    if (useFrontCamera) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        try {
          _controller.switchCamera();
        } catch (e) {
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
}

/// Separate camera view widget that doesn't rebuild on state changes
/// This prevents the camera from becoming choppy
class _ScannerView extends StatelessWidget {
  final MobileScannerController controller;
  final Function(BarcodeCapture) onDetect;

  const _ScannerView({
    required this.controller,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: onDetect,
    );
  }
}
