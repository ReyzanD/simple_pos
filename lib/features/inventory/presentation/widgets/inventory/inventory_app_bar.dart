import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/features/inventory/presentation/providers/inventory_providers.dart';

/// Simple inventory app bar
class InventoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final bool isLoading;

  const InventoryAppBar({
    super.key,
    required this.onMenuTap,
    this.isLoading = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuTap,
      ),
      title: const Text('Manage Inventory'),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: NeoBrutalTheme.spaceXS),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
              ],
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final products = ref.watch(inventoryProvider);
                return IconButton(
                  icon: Icon(
                    products.isEmpty ? Icons.grid_view : Icons.view_list,
                    color: NeoBrutalTheme.primary,
                    size: 22,
                  ),
                  tooltip: products.isEmpty ? 'Show Grid' : 'Show List',
                  onPressed: null, // View mode toggle to be implemented
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: NeoBrutalTheme.blockYellow,
          border: Border(
            bottom: BorderSide(
                  color: Colors.black,
                  width: 6,
                ),
          ),
        ),
      ),
    );
  }
}
