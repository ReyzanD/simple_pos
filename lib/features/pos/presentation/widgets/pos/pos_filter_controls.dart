import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/widgets/brutal_widgets.dart';
import '../../controllers/pos_controller.dart';
import 'sort_dropdown.dart';
import 'view_mode_toggle.dart';

/// Improved POS Filter Controls with aligned heights
///
/// Changes:
/// - All controls fixed at height: 44
/// - Consistent padding and alignment
/// - Better visual hierarchy
class POSFilterControls extends StatelessWidget {
  final POSController controller;

  const POSFilterControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NeoBrutalTheme.spaceMD,
        NeoBrutalTheme.spaceSM,
        NeoBrutalTheme.spaceMD,
        NeoBrutalTheme.spaceSM,
      ),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            // Stock filter chip
            SizedBox(
              height: 44,
              child: BrutalActionChip(
                label: 'Stok Tersedia',
                icon: controller.inStockOnly
                    ? Icons.check_circle
                    : Icons.inventory_2_outlined,
                onTap: () => controller.toggleInStockOnly(),
                isSelected: controller.inStockOnly,
                backgroundColor: controller.inStockOnly
                    ? NeoBrutalTheme.success
                    : NeoBrutalTheme.surface,
              ),
            ),
            SizedBox(width: NeoBrutalTheme.spaceSM),
            // Sort dropdown
            SizedBox(
              height: 44,
              child: SortDropdown(
                selectedOption: controller.sortOption,
                onOptionChanged: (option) => controller.setSortOption(option),
              ),
            ),
            const Spacer(),
            // Grid/List view toggle
            SizedBox(
              height: 44,
              child: ViewModeToggle(
                viewMode: controller.viewMode,
                onToggle: () => controller.toggleViewMode(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
