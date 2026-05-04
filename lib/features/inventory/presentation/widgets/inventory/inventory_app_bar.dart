import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/inventory_controller.dart';

import '../../../../shared/presentation/providers.dart';
import '../../../../../../l10n/app_localizations.dart';

/// Simple inventory app bar with view mode toggle
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
      leading: IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap),
      title: Text(AppLocalizations.of(context)!.stock_manageInventory),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: NeoBrutalTheme.spaceXS),
          child: Consumer(
            builder: (context, ref, _) {
              final controller = ref.watch(inventoryControllerProvider);
              final isGrid = controller.viewMode == ProductViewMode.grid;

              return Container(
                decoration: BoxDecoration(
                  color: isGrid ? NeoBrutalTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isGrid ? Icons.grid_view : Icons.view_list,
                    color: isGrid ? Colors.white : NeoBrutalTheme.primary,
                    size: 22,
                  ),
                  tooltip: isGrid
                      ? AppLocalizations.of(context)!.common_switchToList
                      : AppLocalizations.of(context)!.common_switchToGrid,
                  onPressed: () =>
                      ref.read(inventoryControllerProvider).toggleViewMode(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
