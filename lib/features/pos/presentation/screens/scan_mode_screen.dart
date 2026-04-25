import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../domain/entities/cart_item.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../shared/presentation/providers.dart';

/// Full-screen scan mode for rapid barcode scanning
class ScanModeScreen extends ConsumerStatefulWidget {
  const ScanModeScreen({super.key});

  @override
  ConsumerState<ScanModeScreen> createState() => _ScanModeScreenState();
}

class _ScanModeScreenState extends ConsumerState<ScanModeScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  DateTime? _lastScanTime;

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
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scan Mode', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
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

  Widget _buildLastScannedCard(dynamic controller, List<CartItem> cart) {
    if (cart.isEmpty) {
      return const SizedBox.shrink();
    }

    final lastItem = cart.last;
    final product = lastItem.product;

    // Validate product data
    if (product.name.isEmpty) {
      return const SizedBox.shrink();
    }

    // Make card not clickable to prevent black screen
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rp ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'x${lastItem.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(dynamic controller, List<CartItem> cart) {
    final total = controller.cartTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${cart.length} items',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rp ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Tahan',
                    onPressed: () => _holdOrder(controller),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Checkout',
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
    // Debounce scans (500ms)
    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 500) {
      return;
    }
    _lastScanTime = now;

    final barcode = capture.barcodes.first.displayValue;
    if (barcode == null) return;

    // Check if there are any products
    if (controller.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk dalam database'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Find product by barcode
    Product? product;
    try {
      product = controller.products.firstWhere((p) => p.barcode == barcode);
    } catch (e) {
      // Product not found - firstWhere throws StateError
      product = null;
    }

    if (product == null) {
      // Product not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk tidak ditemukan'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Add to cart
    controller.addToCart(product);

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _holdOrder(dynamic controller) {
    controller.holdCart('Scan Order');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order ditahan'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _checkout(dynamic controller) {
    // Exit scan mode - POS screen will handle checkout
    controller.exitScanMode();
  }
}
