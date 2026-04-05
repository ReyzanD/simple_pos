import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/shifts/domain/entities/cash_denomination.dart';

/// Button for counting bill denominations in cash count screen
class BillCounterButton extends StatelessWidget {
  final CashDenomination denomination;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onTap;
  final bool isSelected;

  const BillCounterButton({
    super.key,
    required this.denomination,
    required this.count,
    required this.onIncrement,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              denomination.display,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onIncrement,
                  child: Icon(
                    Icons.add_circle,
                    size: 24,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
