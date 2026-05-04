import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/l10n/app_localizations.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';

/// Cart Modal Empty State - Shows when cart is empty
class CartModalEmptyState extends StatelessWidget {
  const CartModalEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.blockCoral.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
              border: Border.all(color: borderColor, width: 4),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: NeoBrutalTheme.blockCoral,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          Text(
            AppLocalizations.of(context)!.cart_empty,
            style: NeoBrutalTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            AppLocalizations.of(context)!.cart_empty_subtitle,
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
