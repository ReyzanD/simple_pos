import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/utils/haptic_helper.dart';

/// App Info Section - Version, help, about
class DrawerAppInfo extends StatelessWidget {
  const DrawerAppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.help_outline,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          title: Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          onTap: () {
            HapticHelper.lightImpact();
            // Show help dialog
          },
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline_rounded,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          title: Text(
            'About',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          onTap: () {
            HapticHelper.lightImpact();
            // Show about dialog
          },
        ),
      ],
    );
  }
}
