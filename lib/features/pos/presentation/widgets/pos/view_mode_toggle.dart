import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import '../../controllers/pos_controller.dart';

/// Improved View Mode Toggle with consistent Neo-Brutalism styling
///
/// Changes:
/// - Consistent 2px border thickness
/// - Larger 18px icons
/// - Better padding and alignment
class ViewModeToggle extends StatelessWidget {
  final ViewMode viewMode;
  final VoidCallback onToggle;

  const ViewModeToggle({
    super.key,
    required this.viewMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final cardColor = NeoBrutalTheme.getCardColor(context);

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: NeoBrutalTheme.getShadowColor(context),
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

class ViewModeIcon extends StatelessWidget {
  final ViewMode mode;
  final bool isSelected;
  const ViewModeIcon({super.key, required this.mode, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? NeoBrutalTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? NeoBrutalTheme.primary
              : borderColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          mode == ViewMode.grid ? Icons.grid_view : Icons.view_list,
          size: 16,
          color: isSelected
              ? Colors.white
              : NeoBrutalTheme.getTextColor(context),
        ),
      ),
    );
  }
}
