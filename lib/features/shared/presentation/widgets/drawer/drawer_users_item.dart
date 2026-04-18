import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import 'package:simple_pos/features/users/presentation/screens/user_management_screen.dart';

/// Modern Users Item
class DrawerUsersItem extends StatelessWidget {
  const DrawerUsersItem({super.key});

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
          color: AppTheme.primaryColor, // ✅ Solid bold color
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
          border: Border.all(
            color: Colors.black, // ✅ Bold black border
            width: 4, // ✅ Bold 4px border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Icon(
          Icons.people_outline,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        'Pengguna',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Kelola pengguna aplikasi',
        style: NeoBrutalTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
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
            builder: (context) => const UserManagementScreen(),
          ),
        );
      },
    );
  }
}
