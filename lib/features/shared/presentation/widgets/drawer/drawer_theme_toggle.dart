import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';
import '../../providers.dart';

/// Theme Toggle Item
class DrawerThemeToggle extends ConsumerWidget {
  const DrawerThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.watch(themeControllerProvider);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceXS,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.getTextSecondaryColor(context), // ✅ Solid bold color
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
          border: Border.all(
            color: Colors.black, // ✅ Bold black border
            width: 4, // ✅ Bold 4px border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Icon(
          themeController.isDarkMode
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          color: Colors.white, // ✅ White icon
          size: 26,
        ),
      ),
      title: Text(
        themeController.isDarkMode ? 'Light Mode' : 'Dark Mode',
        style: NeoBrutalTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      subtitle: Text(
        'Toggle app theme',
        style: NeoBrutalTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextSecondaryColor(context),
        ),
      ),
      trailing: Switch(
        value: themeController.isDarkMode,
        onChanged: (_) => themeController.toggleTheme(),
      ),
      onTap: () {
        HapticHelper.lightImpact();
        themeController.toggleTheme();
      },
    );
  }
}
