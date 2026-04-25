import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import 'package:simple_pos/features/backup/presentation/screens/backup_screen.dart';
import '../../providers.dart';

/// Modern Backup Item
class DrawerBackupItem extends ConsumerWidget {
  const DrawerBackupItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(backupControllerProvider);
    final backupCount = controller.backups.length;

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
          Icons.backup_outlined,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        'Backup & Restore',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Kelola backup data',
        style: NeoBrutalTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: backupCount > 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: NeoBrutalTheme.spaceSM, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2, // ✅ Bold border
                ),
              ),
              child: Text(
                backupCount.toString(),
                style: NeoBrutalTheme.labelSmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Icon(
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
            builder: (context) => const BackupScreen(),
          ),
        );
      },
    );
  }
}
