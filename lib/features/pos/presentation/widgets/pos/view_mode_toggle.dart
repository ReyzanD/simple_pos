import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import '../../controllers/pos_controller.dart';

/// View Mode Toggle - Switch between grid and list view
class ViewModeToggle extends StatelessWidget {
  final ViewMode viewMode;
  final VoidCallback onToggle;

  const ViewModeToggle({super.key, required this.viewMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(
            color: Colors.black,
            width: 2, // ✅ Bold border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ViewModeIcon(
              mode: ViewMode.grid,
              isSelected: viewMode == ViewMode.grid,
            ),
            const SizedBox(width: 4),
            ViewModeIcon(
              mode: ViewMode.list,
              isSelected: viewMode == ViewMode.list,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual view mode icon
class ViewModeIcon extends StatelessWidget {
  final ViewMode mode;
  final bool isSelected;

  const ViewModeIcon({super.key, required this.mode, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected
            ? NeoBrutalTheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? NeoBrutalTheme.primary : Colors.black.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        mode == ViewMode.grid ? Icons.grid_view : Icons.view_list,
        size: 16,
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
