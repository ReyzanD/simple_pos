import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../sales/presentation/controllers/cart_controller.dart';
import 'cart_item_tile.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class CartSidebarSection extends StatelessWidget {
  const CartSidebarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        border: Border(left: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.yellow,
            child: const Text(
              'KERANJANG',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),

          // ITEMS LIST
          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) =>
                        CartItemTile(item: cart.items[index]),
                  ),
          ),

          // SUMMARY & CHECKOUT
          _buildSummary(context, cart),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartController cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', CurrencyFormatter.format(cart.subtotal)),
          _summaryRow(
            'Diskon',
            '-${CurrencyFormatter.format(cart.discount)}',
            isRed: true,
          ),
          const Divider(thickness: 2, color: Colors.black),
          const SizedBox(height: 8),
          _summaryRow(
            'TOTAL',
            CurrencyFormatter.format(cart.totalAmount),
            isBold: true,
          ),
          const SizedBox(height: 16),

          // CHECKOUT BUTTON
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty
                  ? null
                  : () => _handleCheckout(context, cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                elevation: 0,
                side: const BorderSide(color: Colors.black, width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'PROSES BAYAR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isRed = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isRed ? Colors.red : Colors.black,
              fontSize: isBold ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, CartController cart) async {
    // Trigger checkout logic and show success/failure dialogs
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Text('Keranjang kosong', style: TextStyle(color: Colors.grey)),
    );
  }
}
