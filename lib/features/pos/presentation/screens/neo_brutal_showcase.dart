import 'package:flutter/material.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Neo-Brutalist POS Screen Showcase
///
/// This is what makes your POS UNFORGETTABLE:
/// - Bold 4px black borders on everything
/// - Chunky buttons with dramatic shadows
/// - Massive, confident typography
/// - High-contrast color blocks
/// - Asymmetric, overlapping layouts
class NeoBrutalPOSShowcase extends StatelessWidget {
  const NeoBrutalPOSShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // BOLD HEADER - Massive and unforgettable
            Container(
              padding: const EdgeInsets.all(NeoBrutalTheme.spaceLG),
              decoration: BoxDecoration(
                color: NeoBrutalTheme.blockYellow,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 6,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POINT OF SALE',
                          style: NeoBrutalTheme.displayMassive.copyWith(
                            fontSize: 48,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: NeoBrutalTheme.spaceXS),
                        Text(
                          'Welcome back! Ready to sell?',
                          style: NeoBrutalTheme.bodyLarge.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.blockCoral,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                      border: Border.all(
                        color: Colors.black,
                        width: 4,
                      ),
                      boxShadow: NeoBrutalTheme.chunkyShadow,
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),

            // STATS ROW - Chunky and bold
            Container(
              padding: const EdgeInsets.all(NeoBrutalTheme.spaceMD),
              child: Row(
                children: [
                  Expanded(
                    child: BrutalStatCard(
                      title: 'Revenue',
                      value: '\$12.4K',
                      icon: Icons.payments_rounded,
                      iconColor: NeoBrutalTheme.primary,
                      subtitle: '+15% today',
                    ),
                  ),
                  const SizedBox(width: NeoBrutalTheme.spaceMD),
                  Expanded(
                    child: BrutalStatCard(
                      title: 'Orders',
                      value: '48',
                      icon: Icons.receipt_long,
                      iconColor: NeoBrutalTheme.success,
                      subtitle: 'Today',
                    ),
                  ),
                ],
              ),
            ),

            // CATEGORY CHIPS - Bold blocks
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoBrutalTheme.spaceMD,
                vertical: NeoBrutalTheme.spaceSM,
              ),
              child: Wrap(
                spacing: NeoBrutalTheme.spaceSM,
                runSpacing: NeoBrutalTheme.spaceSM,
                children: [
                  BrutalActionChip(
                    label: 'All',
                    icon: Icons.apps,
                    isSelected: true,
                  ),
                  BrutalActionChip(
                    label: 'Electronics',
                    icon: Icons.devices,
                    backgroundColor: NeoBrutalTheme.blockBlue,
                  ),
                  BrutalActionChip(
                    label: 'Clothing',
                    icon: Icons.checkroom,
                    backgroundColor: NeoBrutalTheme.blockPink,
                  ),
                  BrutalActionChip(
                    label: 'Food',
                    icon: Icons.restaurant,
                    backgroundColor: NeoBrutalTheme.blockGreen,
                  ),
                ],
              ),
            ),

            // PRODUCT GRID - Asymmetric and bold
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(NeoBrutalTheme.spaceMD),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: NeoBrutalTheme.spaceMD,
                  mainAxisSpacing: NeoBrutalTheme.spaceMD,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildBrutalProductCard(
                    context,
                    _sampleProducts[index],
                  );
                },
              ),
            ),

            // FLOATING ACTION BLOCK
            Positioned(
              bottom: NeoBrutalTheme.spaceXXL,
              right: NeoBrutalTheme.spaceMD,
              child: BrutalFab(
                label: 'Cart',
                icon: Icons.shopping_cart,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrutalProductCard(BuildContext context, Product product) {
    return BrutalCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRODUCT IMAGE AREA - Bold color block
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.black54,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: NeoBrutalTheme.spaceSM),
          // PRODUCT NAME - Bold and uppercase
          Text(
            product.name.toUpperCase(),
            style: NeoBrutalTheme.headlineSmall.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: NeoBrutalTheme.spaceXS),
          // PRICE - Massive and bold
          Text(
            CurrencyFormatter.format(product.price),
            style: NeoBrutalTheme.displayMedium.copyWith(
              fontSize: 24,
              color: NeoBrutalTheme.primary,
            ),
          ),
          const SizedBox(height: NeoBrutalTheme.spaceSM),
          // ADD BUTTON - Chunky and satisfying
          BrutalButton(
            text: 'ADD',
            icon: Icons.add,
            isFullWidth: true,
            backgroundColor: NeoBrutalTheme.success,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// Sample products for demonstration
final List<Product> _sampleProducts = [
  Product(
    id: 1,
    name: 'Wireless Headphones',
    price: 89.99,
    costPrice: 50.00,
    stock: 25,
    barcode: '1234567890',
  ),
  Product(
    id: 2,
    name: 'USB-C Cable',
    price: 19.99,
    costPrice: 8.00,
    stock: 100,
    barcode: '2345678901',
  ),
  Product(
    id: 3,
    name: 'Phone Case',
    price: 24.99,
    costPrice: 10.00,
    stock: 50,
    barcode: '3456789012',
  ),
  Product(
    id: 4,
    name: 'Laptop Stand',
    price: 45.00,
    costPrice: 20.00,
    stock: 15,
    barcode: '4567890123',
  ),
  Product(
    id: 5,
    name: 'Keyboard',
    price: 75.00,
    costPrice: 35.00,
    stock: 30,
    barcode: '5678901234',
  ),
  Product(
    id: 6,
    name: 'Mouse',
    price: 35.00,
    costPrice: 15.00,
    stock: 40,
    barcode: '6789012345',
  ),
];
