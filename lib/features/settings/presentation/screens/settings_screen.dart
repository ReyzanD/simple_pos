import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/l10n/app_localizations.dart';
import '../controllers/settings_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../shared/presentation/main_navigation.dart';
import 'printer_settings_screen.dart';
import 'data_management_screen.dart';
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../shared/presentation/providers.dart';

/// Settings screen with 6 expandable sections using grouped card layout
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final controller = ref.watch(settingsControllerProvider);
    final themeController = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            final mainNavState = context
                .findAncestorStateOfType<MainNavigationState>();
            mainNavState?.openDrawer();
          },
        ),
        title: Text(AppLocalizations.of(context)!.display),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: NeoBrutalTheme.spaceSM),
            child: Container(
              decoration: BoxDecoration(
                color: NeoBrutalTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: IconButton(
                icon: Icon(Icons.restore, color: NeoBrutalTheme.warning),
                tooltip: AppLocalizations.of(context)!.reset_settings,
                onPressed: () => _showResetDialog(context, controller),
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppTheme.darkSurface,
                      AppTheme.darkSurface.withValues(alpha: 0.95),
                    ]
                  : [AppTheme.primaryColor, AppTheme.primaryLight],
            ),
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(
                left: NeoBrutalTheme.spaceMD,
                right: NeoBrutalTheme.spaceMD,
                top: NeoBrutalTheme.spaceMD,
                bottom: 100, // Space for floating nav
              ),
              children: [
                // Appearance section with dark mode toggle
                _buildExpandableSection(
                  context,
                  title: AppLocalizations.of(context)!.display,
                  icon: Icons.palette_outlined,
                  children: [
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.dark_mode),
                      subtitle: Text(
                        themeController.isDarkMode
                            ? AppLocalizations.of(context)!.active
                            : AppLocalizations.of(context)!.inactive,
                      ),
                      value: themeController.isDarkMode,
                      onChanged: (value) => themeController.setThemeMode(value),
                      secondary: Icon(
                        themeController.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoBrutalTheme.spaceMD),

                // 6 Expandable sections
                _buildExpandableSection(
                  context,
                  title: AppLocalizations.of(context)!.business_info,
                  icon: Icons.business_outlined,
                  children: [
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.business_name,
                      subtitle: controller.businessInfo.name.isEmpty
                          ? AppLocalizations.of(context)!.not_filled
                          : controller.businessInfo.name,
                      icon: Icons.store,
                      onTap: () => _editBusinessName(
                        context,
                        controller,
                        controller.businessInfo.name,
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.address,
                      subtitle: controller.businessInfo.address.isEmpty
                          ? AppLocalizations.of(context)!.not_filled
                          : controller.businessInfo.address,
                      icon: Icons.location_on_outlined,
                      onTap: () => _editBusinessAddress(
                        context,
                        controller,
                        controller.businessInfo.address,
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.phone,
                      subtitle: controller.businessInfo.phone.isEmpty
                          ? AppLocalizations.of(context)!.not_filled
                          : controller.businessInfo.phone,
                      icon: Icons.phone_outlined,
                      onTap: () => _editBusinessPhone(
                        context,
                        controller,
                        controller.businessInfo.phone,
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.email,
                      subtitle: controller.businessInfo.email.isEmpty
                          ? AppLocalizations.of(context)!.not_filled
                          : controller.businessInfo.email,
                      icon: Icons.email_outlined,
                      onTap: () => _editBusinessEmail(
                        context,
                        controller,
                        controller.businessInfo.email,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoBrutalTheme.spaceMD),

                _buildExpandableSection(
                  context,
                  title: AppLocalizations.of(context)!.tax,
                  icon: Icons.percent_outlined,
                  children: [
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.enable_tax),
                      subtitle: Text(
                        'Pajak: ${(controller.taxRate * 100).toStringAsFixed(1)}%',
                      ),
                      value: controller.taxEnabled,
                      onChanged: (value) => controller.toggleTax(value),
                      secondary: const Icon(Icons.calculate_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: NeoBrutalTheme.spaceMD),

                _buildExpandableSection(
                  context,
                  title: AppLocalizations.of(context)!.currency,
                  icon: Icons.attach_money,
                  children: [
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.currency_symbol,
                      subtitle: controller.currencySymbol,
                      icon: Icons.tag,
                      onTap: () => _editCurrencySymbol(
                        context,
                        controller,
                        controller.currencySymbol,
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.currency_code,
                      subtitle: controller.currencyCode,
                      icon: Icons.code,
                      onTap: () => _editCurrencyCode(
                        context,
                        controller,
                        controller.currencyCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoBrutalTheme.spaceMD),

                _buildExpandableSection(
                  context,
                  title: AppLocalizations.of(context)!.receipt,
                  icon: Icons.receipt_long,
                  children: [
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.printer_settings,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.bluetooth_thermal_printer,
                      icon: Icons.print_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrinterSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.receipt_footer,
                      subtitle: controller.receiptFooter,
                      icon: Icons.message_outlined,
                      maxLines: 2,
                      onTap: () => _editReceiptFooter(
                        context,
                        controller,
                        controller.receiptFooter,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoBrutalTheme.spaceMD),

                _buildExpandableSection(
                  context,
                  title: AppLocalizations.of(context)!.inventory,
                  icon: Icons.inventory_2_outlined,
                  children: [
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.low_stock_threshold,
                      subtitle: '${controller.lowStockThreshold} item',
                      icon: Icons.warning_outlined,
                      onTap: () => _editLowStockThreshold(
                        context,
                        controller,
                        controller.lowStockThreshold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoBrutalTheme.spaceMD),

                _buildExpandableSection(
                  context,
                  title: AppLocalizations.of(context)!.data_management,
                  icon: Icons.storage,
                  children: [
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.manage_data,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.export_data_backup,
                      icon: Icons.manage_search_outlined,
                      iconColor: AppTheme.infoColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DataManagementScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.export_settings,
                      subtitle: AppLocalizations.of(context)!.save_settings,
                      icon: Icons.file_download_outlined,
                      iconColor: AppTheme.successColor,
                      onTap: () => _exportSettings(context, controller),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context: context,
                      title: AppLocalizations.of(context)!.delete_all_data,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.delete_all_data_desc,
                      icon: Icons.delete_sweep,
                      iconColor: AppTheme.errorColor,
                      onTap: () => _showClearDataDialog(context, controller),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  /// Build an expandable card section with chevron
  static Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    return BrutalCard(
      padding: EdgeInsets.all(0),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.05),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.08),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.primary,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(color: borderColor, width: 3),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          title: Text(
            title,
            style: NeoBrutalTheme.headlineSmall.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          trailing: Icon(Icons.expand_more, color: secondaryTextColor),
          children: children,
        ),
      ),
    );
  }

  /// Build a settings list tile with chevron
  static Widget _buildSettingsTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    int maxLines = 1,
  }) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    final defaultIconColor = iconColor ?? NeoBrutalTheme.primary;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: NeoBrutalTheme.spaceSM),
      child: BrutalCard(
        onTap: onTap,
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: defaultIconColor,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(color: borderColor, width: 3),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NeoBrutalTheme.headlineSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceXS),
                  Text(
                    subtitle,
                    style: NeoBrutalTheme.bodySmall.copyWith(
                      color: secondaryTextColor,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: secondaryTextColor, size: 24),
          ],
        ),
      ),
    );
  }

  // Edit dialogs

  Future<void> _editBusinessName(
    BuildContext context,
    SettingsController controller,
    String currentValue,
  ) async {
    final result = await _showEditDialog(
      context,
      title: AppLocalizations.of(context)!.business_name,
      currentValue: currentValue,
      hintText: AppLocalizations.of(context)!.enter_business_name,
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(name: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.business_name_updated,
        );
      }
    }
  }

  Future<void> _editBusinessAddress(
    BuildContext context,
    SettingsController controller,
    String currentValue,
  ) async {
    final result = await _showEditDialog(
      context,
      title: AppLocalizations.of(context)!.address,
      currentValue: currentValue,
      hintText: AppLocalizations.of(context)!.enter_address,
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(address: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.address_updated,
        );
      }
    }
  }

  Future<void> _editBusinessPhone(
    BuildContext context,
    SettingsController controller,
    String currentValue,
  ) async {
    final result = await _showEditDialog(
      context,
      title: AppLocalizations.of(context)!.phone,
      currentValue: currentValue,
      hintText: AppLocalizations.of(context)!.enter_phone,
      keyboardType: TextInputType.phone,
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(phone: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.phone_updated,
        );
      }
    }
  }

  Future<void> _editBusinessEmail(
    BuildContext context,
    SettingsController controller,
    String currentValue,
  ) async {
    final result = await _showEditDialog(
      context,
      title: AppLocalizations.of(context)!.email,
      currentValue: currentValue,
      hintText: AppLocalizations.of(context)!.enter_email,
      keyboardType: TextInputType.emailAddress,
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(email: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.email_updated,
        );
      }
    }
  }

  Future<void> _editCurrencySymbol(
    BuildContext context,
    SettingsController controller,
    String currentValue,
  ) async {
    final result = await _showEditDialog(
      context,
      title: AppLocalizations.of(context)!.currency_symbol,
      currentValue: currentValue,
      hintText: AppLocalizations.of(context)!.currency_symbol_hint,
    );
    if (result != null) {
      await controller.updateCurrency(
        symbol: result,
        code: controller.currencyCode,
      );
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.currency_symbol_updated,
        );
      }
    }
  }

  Future<void> _editCurrencyCode(
    BuildContext context,
    SettingsController controller,
    String currentValue,
  ) async {
    final result = await _showEditDialog(
      context,
      title: AppLocalizations.of(context)!.currency_code,
      currentValue: currentValue,
      hintText: AppLocalizations.of(context)!.currency_code_hint,
    );
    if (result != null) {
      await controller.updateCurrency(
        symbol: controller.currencySymbol,
        code: result,
      );
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.currency_code_updated,
        );
      }
    }
  }

  Future<void> _editReceiptFooter(
    BuildContext context,
    SettingsController controller,
    String currentValue,
  ) async {
    final result = await _showEditDialog(
      context,
      title: AppLocalizations.of(context)!.receipt_footer,
      currentValue: currentValue,
      hintText: AppLocalizations.of(context)!.enter_footer_message,
      maxLines: 3,
    );
    if (result != null) {
      await controller.updateReceiptFooter(result);
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.receipt_footer_updated,
        );
      }
    }
  }

  Future<void> _editLowStockThreshold(
    BuildContext context,
    SettingsController controller,
    int currentValue,
  ) async {
    final result = await _showNumberDialog(
      context,
      title: AppLocalizations.of(context)!.low_stock_threshold,
      currentValue: currentValue.toDouble(),
      hintText: AppLocalizations.of(context)!.low_stock_hint,
    );
    if (result != null) {
      await controller.updateLowStockThreshold(result.toInt());
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.stock_threshold_updated,
        );
      }
    }
  }

  Future<String?> _showEditDialog(
    BuildContext context, {
    required String title,
    required String currentValue,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final l10n = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppTheme.getCardColor(context),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<double?> _showNumberDialog(
    BuildContext context, {
    required String title,
    required double currentValue,
    required String hintText,
  }) async {
    final controller = TextEditingController(text: currentValue.toString());
    final l10n = AppLocalizations.of(context)!;

    return showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppTheme.getCardColor(context),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(dialogContext, value);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.reset_settings_title),
        content: Text(l10n.reset_confirm_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.resetSettings();
      if (success && context.mounted) {
        _showSuccessSnackBar(context, l10n.settings_reset_default);
      }
    }
  }

  Future<void> _showClearDataDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.delete_all_data),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.delete_all_data_warning,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.delete_all_data_items),
            Text(l10n.delete_all_data_transactions),
            Text(l10n.delete_all_data_categories),
            const SizedBox(height: 8),
            Text(
              l10n.delete_all_data_cannot_undo,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.delete,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.clearAllData();
      if (success && context.mounted) {
        _showSuccessSnackBar(context, l10n.all_data_deleted);
      }
    }
  }

  Future<void> _exportSettings(
    BuildContext context,
    SettingsController controller,
  ) async {
    final data = await controller.exportSettings();
    if (data != null && context.mounted) {
      _showSuccessSnackBar(context, 'Pengaturan diekspor');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
        ),
      ),
    );
  }
}
