import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import '../../controllers/pos_controller.dart';

/// Sort Dropdown - Product sorting options
class SortDropdown extends StatelessWidget {
  final SortOption selectedOption;
  final ValueChanged<SortOption> onOptionChanged;

  const SortDropdown({
    super.key,
    required this.selectedOption,
    required this.onOptionChanged,
  });

  String _getOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'A-Z';
      case SortOption.nameDesc:
        return 'Z-A';
      case SortOption.priceAsc:
        return 'Termurah';
      case SortOption.priceDesc:
        return 'Termahal';
      case SortOption.stockLevel:
        return 'Stok';
    }
  }

  IconData _getOptionIcon(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
      case SortOption.nameDesc:
        return Icons.sort_by_alpha;
      case SortOption.priceAsc:
      case SortOption.priceDesc:
        return Icons.attach_money;
      case SortOption.stockLevel:
        return Icons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      initialValue: selectedOption,
      onSelected: onOptionChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        side: BorderSide(
          color: Colors.black,
          width: 3, // ✅ Bold border
        ),
      ),
      color: Colors.white,
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            Icon(
              _getOptionIcon(selectedOption),
              size: 14,
              color: Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              _getOptionLabel(selectedOption),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.black,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          SortOption.nameAsc,
          'A-Z',
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.nameDesc,
          'Z-A',
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.priceAsc,
          'Termurah',
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.priceDesc,
          'Termahal',
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.stockLevel,
          'Stok',
          Icons.inventory,
        ),
      ],
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem(
    BuildContext context,
    SortOption option,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedOption == option;
    return PopupMenuItem<SortOption>(
      value: option,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NeoBrutalTheme.primary,
                  width: 2,
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? NeoBrutalTheme.primary
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? NeoBrutalTheme.primary : Colors.black.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isSelected ? NeoBrutalTheme.primary : Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoBrutalTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
