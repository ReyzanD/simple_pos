import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/l10n/app_localizations.dart';
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

  String _getOptionLabel(SortOption option, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (option) {
      case SortOption.nameAsc:
        return l10n.sort_by_name;
      case SortOption.nameDesc:
        return l10n.sort_by_name; // Will need descending indicator
      case SortOption.priceAsc:
        return l10n.sort_by_price;
      case SortOption.priceDesc:
        return l10n.sort_by_price; // Will need descending indicator
      case SortOption.stockLevel:
        return l10n.sort_by_stock;
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
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final cardColor = NeoBrutalTheme.getCardColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);

    return PopupMenuButton<SortOption>(
      initialValue: selectedOption,
      onSelected: onOptionChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        side: BorderSide(color: borderColor, width: 3),
      ),
      color: cardColor,
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            Icon(_getOptionIcon(selectedOption), size: 14, color: textColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _getOptionLabel(selectedOption, context),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          SortOption.nameAsc,
          AppLocalizations.of(context)!.sort_by_name,
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.nameDesc,
          AppLocalizations.of(context)!.sort_by_name,
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.priceAsc,
          AppLocalizations.of(context)!.sort_by_price,
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.priceDesc,
          AppLocalizations.of(context)!.sort_by_price,
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.stockLevel,
          AppLocalizations.of(context)!.sort_by_stock,
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
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final isSelected = selectedOption == option;
    return PopupMenuItem<SortOption>(
      value: option,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NeoBrutalTheme.primary, width: 2),
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
                    : NeoBrutalTheme.getSurfaceVariantColor(context),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? NeoBrutalTheme.primary
                      : NeoBrutalTheme.getBorderColor(
                          context,
                        ).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : NeoBrutalTheme.getTextColor(context),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isSelected
                      ? NeoBrutalTheme.primary
                      : NeoBrutalTheme.getTextColor(context),
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoBrutalTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Icon(Icons.check, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
