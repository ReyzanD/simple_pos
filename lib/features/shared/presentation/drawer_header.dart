import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neo_brutal_theme.dart';
import '../../../core/utils/haptic_helper.dart';

/// Material 3 compatible user drawer header for NavigationDrawer
///
/// Features:
/// - User avatar with online status
/// - Store name display
/// - Compact design for M3 drawer
/// - Smooth gradient background
class UserDrawerHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final String storeName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;

  const UserDrawerHeader({
    super.key,
    required this.userName,
    required this.userRole,
    required this.storeName,
    this.onProfileTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue, // ✅ Bold blue background
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 4, // ✅ Bold border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with store info
          Row(
            children: [
              // Avatar with online indicator
              GestureDetector(
                onTap: () {
                  HapticHelper.lightImpact();
                  onProfileTap?.call();
                },
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: NeoBrutalTheme.primary,
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                        border: Border.all(
                          color: Colors.black,
                          width: 4, // ✅ Bold border
                        ),
                        boxShadow: NeoBrutalTheme.chunkyShadow,
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : 'U',
                          style: NeoBrutalTheme.displayLarge.copyWith(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    // Online status indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: NeoBrutalTheme.success,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: Colors.black,
                            width: 3, // ✅ Bold border
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: NeoBrutalTheme.spaceMD),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: NeoBrutalTheme.headlineSmall.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceXS),
                    Text(
                      userRole,
                      style: NeoBrutalTheme.bodySmall.copyWith(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings button
              if (onSettingsTap != null)
                GestureDetector(
                  onTap: () {
                    HapticHelper.lightImpact();
                    onSettingsTap!();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                      border: Border.all(
                        color: Colors.black,
                        width: 3, // ✅ Bold border
                      ),
                    ),
                    child: Icon(
                      Icons.settings,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: NeoBrutalTheme.spaceSM),

          // Store name chip
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: NeoBrutalTheme.spaceMD,
              vertical: NeoBrutalTheme.spaceSM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(
                color: Colors.black,
                width: 3, // ✅ Bold border
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront,
                  size: 16,
                  color: Colors.black,
                ),
                SizedBox(width: NeoBrutalTheme.spaceXS),
                Text(
                  storeName.toUpperCase(),
                  style: NeoBrutalTheme.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern drawer header with user profile (full width)
///
/// Features:
/// - User avatar with online status
/// - Quick action buttons
/// - Smooth animations
class ModernDrawerHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final String storeName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;

  const ModernDrawerHeader({
    super.key,
    required this.userName,
    required this.userRole,
    required this.storeName,
    this.onProfileTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Profile section
            _ProfileSection(
              userName: userName,
              userRole: userRole,
              storeName: storeName,
              onProfileTap: onProfileTap,
              onSettingsTap: onSettingsTap,
            ),

            const SizedBox(height: 16),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                color: AppTheme.getBorderColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String userName;
  final String userRole;
  final String storeName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;

  const _ProfileSection({
    required this.userName,
    required this.userRole,
    required this.storeName,
    this.onProfileTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Avatar with online indicator
          GestureDetector(
            onTap: () {
              HapticHelper.lightImpact();
              onProfileTap?.call();
            },
            child: Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Online status indicator
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.getCardColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userRole,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        storeName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Settings button
          if (onSettingsTap != null)
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              onPressed: () {
                HapticHelper.lightImpact();
                onSettingsTap!();
              },
            ),
        ],
      ),
    );
  }
}

/// Drawer menu item with icon and optional badge
class ModernDrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? badge;
  final bool isSelected;

  const ModernDrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.badge,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? AppTheme.primaryColor : AppTheme.getTextSecondaryColor(context),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : AppTheme.getTextPrimaryColor(context),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ?trailing,
          ],
        ),
        onTap: () {
          HapticHelper.lightImpact();
          onTap?.call();
        },
      ),
    );
  }
}

/// Section divider for drawer
class DrawerSectionDivider extends StatelessWidget {
  final String title;
  final IconData? icon;

  const DrawerSectionDivider({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondaryColor(context),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
