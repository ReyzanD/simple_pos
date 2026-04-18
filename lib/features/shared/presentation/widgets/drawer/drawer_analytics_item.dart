import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import 'package:simple_pos/features/sales/presentation/screens/analytics_screen.dart';

/// Modern Analytics Item
class DrawerAnalyticsItem extends StatelessWidget {
  const DrawerAnalyticsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceXS,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NeoBrutalTheme.primary, // ✅ Solid bold gradient
              NeoBrutalTheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
          border: Border.all(
            color: Colors.black, // ✅ Bold black border
            width: 4, // ✅ Bold 4px border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: const Icon(
          Icons.analytics_outlined,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        'Analitik Penjualan',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Tren & insight penjualan',
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
            builder: (context) => const AnalyticsScreen(),
          ),
        );
      },
    );
  }
}
