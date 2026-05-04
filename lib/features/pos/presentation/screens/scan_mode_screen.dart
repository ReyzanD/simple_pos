import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../domain/entities/cart_item.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../shared/presentation/providers.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Full-screen scan mode for rapid barcode scanning
class ScanModeScreen extends ConsumerStatefulWidget {
  const ScanModeScreen({super.key});

  @override
  ConsumerState<ScanModeScreen> createState() => _ScanModeScreenState();
}

class _ScanModeScreenState extends ConsumerState<ScanModeScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;

  // Frame-aware debounce state
  String? _lastScannedBarcode;
  DateTime? _lastScanTime;
  int _consecutiveDetections = 0;
  static const int _cooldownMs = 2000; // 2s cooldown for same barcode
  static const int _newBarcodeCooldownMs = 300; // 300ms for different barcode
  static const int _requiredConsecutive = 3; // frames before first trigger

  // Scan feedback
  bool _showScanFlash = false;
  String? _lastProductName;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(posControllerProvider);
    final cart = controller.cart;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.checkout_title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => controller.exitScanMode(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                _handleBarcodeCapture(capture, controller);
              },
            ),
          ),

          // Scan frame overlay
          Positioned.fill(child: _buildScanOverlay()),

          // Scan flash feedback
          if (_showScanFlash)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showScanFlash ? 0.3 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(color: Colors.green),
                ),
              ),
            ),

          // Top: Last scanned product card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildLastScannedCard(controller, cart),
          ),

          // Bottom: Cart summary
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCartSummary(controller, cart),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Text(
              _lastProductName != null
                  ? '✓ $_lastProductName'
                  : AppLocalizations.of(context)!.product_search,
              style: TextStyle(
                color: _lastProductName != null
                    ? Colors.greenAccent
                    : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(blurRadius: 8, color: Colors.black),
                  Shadow(blurRadius: 16, color: Colors.black),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastScannedCard(dynamic controller, List<CartItem> cart) {
    if (cart.isEmpty) return const SizedBox.shrink();

    final lastItem = cart.last;
    final product = lastItem.product;
    if (product.name.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 80, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'x${lastItem.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(dynamic controller, List<CartItem> cart) {
    final total = controller.cartTotal;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: Colors.white24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.cart_total_items.replaceAll('{count}', '${cart.length}'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: AppLocalizations.of(context)!.held_order_hold,
                    onPressed: () => _holdOrder(controller),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: AppLocalizations.of(context)!.checkout_title,
                    onPressed: () => _checkout(controller),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleBarcodeCapture(BarcodeCapture capture, dynamic controller) {
    final barcode = capture.barcodes.first.displayValue;
    if (barcode == null || barcode.isEmpty) return;
    final now = DateTime.now();
    final isSameBarcode = barcode == _lastScannedBarcode;
    // --- Frame-aware debounce logic ---
    if (isSameBarcode) {
      // Same barcode still in frame: enforce cooldown
      if (_lastScanTime != null &&
          now.difference(_lastScanTime!).inMilliseconds < _cooldownMs) {
        return; // Still cooling down, ignore
      }
    } else {
      // Different barcode detected: require consecutive frames to confirm
      _consecutiveDetections++;
      if (_consecutiveDetections < _requiredConsecutive) {
        _lastScannedBarcode = barcode;
        _lastScanTime =
            null; // Clear old cooldown so it won't block this barcode
        return;
      }
      // Small cooldown even for new barcodes to prevent double-fire
      if (_lastScanTime != null &&
          now.difference(_lastScanTime!).inMilliseconds <
              _newBarcodeCooldownMs) {
        return;
      }
    }
    // --- Barcode confirmed, process it ---
    _lastScannedBarcode = barcode;
    _lastScanTime = now;
    _consecutiveDetections = 0;
    // Check if products exist
    if (controller.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.product_no_products,
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    // Find product by barcode
    Product? product;
    try {
      product = controller.products.firstWhere((p) => p.barcode == barcode);
    } catch (e) {
      product = null;
    }
    if (product == null) {
      setState(() => _lastProductName = null);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.nav_product_not_found.replaceAll('{barcode}', barcode),
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: AppTheme.warningColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    // Add to cart
    controller.addToCart(product);
    HapticFeedback.mediumImpact();
    // Visual feedback
    setState(() => _lastProductName = product!.name);
    _triggerScanFlash();
  }

  void _triggerScanFlash() {
    setState(() => _showScanFlash = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showScanFlash = false);
    });
  }

  void _holdOrder(dynamic controller) {
    controller.holdCart(AppLocalizations.of(context)!.scan_order_held);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.held_order_saved,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _checkout(dynamic controller) {
    controller.exitScanMode();
  }
}

/// Custom painter for the scan overlay with corner brackets
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Scan area dimensions
    final scanSize = size.width * 0.7;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanSize, scanSize);

    // Draw dark overlay with hole
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(bgPath, bgPaint);

    // Top-left
    canvas.drawArc(
      Rect.fromLTWH(left, top, 32, 32),
      3.14,
      1.57,
      false,
      framePaint,
    );
    // Top-right
    canvas.drawArc(
      Rect.fromLTWH(left + scanSize - 32, top, 32, 32),
      -1.57,
      1.57,
      false,
      framePaint,
    );
    // Bottom-left
    canvas.drawArc(
      Rect.fromLTWH(left, top + scanSize - 32, 32, 32),
      1.57,
      1.57,
      false,
      framePaint,
    );
    // Bottom-right
    canvas.drawArc(
      Rect.fromLTWH(left + scanSize - 32, top + scanSize - 32, 32, 32),
      0,
      1.57,
      false,
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
