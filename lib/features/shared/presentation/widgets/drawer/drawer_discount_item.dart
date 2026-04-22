import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import 'package:simple_pos/features/sales/presentation/controllers/discount_controller.dart';
import 'package:simple_pos/features/sales/presentation/screens/discount_management_screen.dart';

/// Modern Discount Management Item
class DrawerDiscountItem extends StatelessWidget {
  const DrawerDiscountItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, controller, _) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: NeoBrutalTheme.spaceMD,
            vertical: NeoBrutalTheme.spaceXS,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.successColor, // ✅ Solid bold color
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              border: Border.all(
                color: Colors.black, // ✅ Bold black border
                width: 4, // ✅ Bold 4px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.discount_outlined,
              color: Colors.white, // ✅ White icon
              size: 26,
            ),
          ),
          title: Text(
            'Discount Management',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          subtitle: Text(
            'Manage promotions & discounts',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 20,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          onTap: () {
            HapticHelper.lightImpact();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: controller,
                  child: const DiscountManagementScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
