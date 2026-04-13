import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/controllers/theme_controller.dart';
import '../../../shared/presentation/main_navigation.dart';
import 'printer_settings_screen.dart';
import 'data_management_screen.dart';
import '../../../../core/widgets/brutal_widgets.dart';

/// Settings screen with 6 expandable sections using grouped card layout
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<SettingsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
                mainNavState?.openDrawer();
              },
            ),
            title: const Text('Pengaturan'),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: NeoBrutalTheme.spaceSM),
                child: Container(
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.restore,
                      color: NeoBrutalTheme.warning,
                    ),
                    tooltip: 'Reset ke Default',
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
                      : [
                          AppTheme.primaryColor,
                          AppTheme.primaryLight,
                        ],
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
                      title: 'Tampilan',
                      icon: Icons.palette_outlined,
                      children: [
                        Consumer<ThemeController>(
                          builder: (context, themeController, _) {
                            return SwitchListTile(
                              title: const Text('Mode Gelap'),
                              subtitle: Text(themeController.isDarkMode ? 'Aktif' : 'Nonaktif'),
                              value: themeController.isDarkMode,
                              onChanged: (value) => themeController.setThemeMode(value),
                              secondary: Icon(
                                themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoBrutalTheme.spaceMD),

                    // 6 Expandable sections
                    _buildExpandableSection(
                      context,
                      title: 'Informasi Bisnis',
                      icon: Icons.business_outlined,
                      children: [
                        _buildSettingsTile(
                          title: 'Nama Bisnis',
                          subtitle: controller.businessInfo.name,
                          icon: Icons.store,
                          onTap: () => _editBusinessName(context, controller, controller.businessInfo.name),
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          title: 'Alamat',
                          subtitle: controller.businessInfo.address.isEmpty ? 'Belum diisi' : controller.businessInfo.address,
                          icon: Icons.location_on_outlined,
                          onTap: () => _editBusinessAddress(context, controller, controller.businessInfo.address),
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          title: 'Telepon',
                          subtitle: controller.businessInfo.phone.isEmpty ? 'Belum diisi' : controller.businessInfo.phone,
                          icon: Icons.phone_outlined,
                          onTap: () => _editBusinessPhone(context, controller, controller.businessInfo.phone),
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          title: 'Email',
                          subtitle: controller.businessInfo.email.isEmpty ? 'Belum diisi' : controller.businessInfo.email,
                          icon: Icons.email_outlined,
                          onTap: () => _editBusinessEmail(context, controller, controller.businessInfo.email),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoBrutalTheme.spaceMD),

                    _buildExpandableSection(
                      context,
                      title: 'Pajak',
                      icon: Icons.percent_outlined,
                      children: [
                        SwitchListTile(
                          title: const Text('Aktifkan Pajak'),
                          subtitle: Text('Pajak: ${(controller.taxRate * 100).toStringAsFixed(1)}%'),
                          value: controller.taxEnabled,
                          onChanged: (value) => controller.toggleTax(value),
                          secondary: const Icon(Icons.calculate_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoBrutalTheme.spaceMD),

                    _buildExpandableSection(
                      context,
                      title: 'Mata Uang',
                      icon: Icons.attach_money,
                      children: [
                        _buildSettingsTile(
                          title: 'Simbol Mata Uang',
                          subtitle: controller.currencySymbol,
                          icon: Icons.tag,
                          onTap: () => _editCurrencySymbol(context, controller, controller.currencySymbol),
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          title: 'Kode Mata Uang',
                          subtitle: controller.currencyCode,
                          icon: Icons.code,
                          onTap: () => _editCurrencyCode(context, controller, controller.currencyCode),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoBrutalTheme.spaceMD),

                    _buildExpandableSection(
                      context,
                      title: 'Struk',
                      icon: Icons.receipt_long,
                      children: [
                        _buildSettingsTile(
                          title: 'Pengaturan Printer',
                          subtitle: 'Bluetooth thermal printer',
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
                          title: 'Footer Struk',
                          subtitle: controller.receiptFooter,
                          icon: Icons.message_outlined,
                          maxLines: 2,
                          onTap: () => _editReceiptFooter(context, controller, controller.receiptFooter),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoBrutalTheme.spaceMD),

                    _buildExpandableSection(
                      context,
                      title: 'Inventaris',
                      icon: Icons.inventory_2_outlined,
                      children: [
                        _buildSettingsTile(
                          title: 'Batas Stok Rendah',
                          subtitle: '${controller.lowStockThreshold} item',
                          icon: Icons.warning_outlined,
                          onTap: () => _editLowStockThreshold(context, controller, controller.lowStockThreshold),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoBrutalTheme.spaceMD),

                    _buildExpandableSection(
                      context,
                      title: 'Manajemen Data',
                      icon: Icons.storage,
                      children: [
                        _buildSettingsTile(
                          title: 'Kelola Data',
                          subtitle: 'Ekspor data dan backup',
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
                          title: 'Ekspor Pengaturan',
                          subtitle: 'Simpan pengaturan ke file',
                          icon: Icons.file_download_outlined,
                          iconColor: AppTheme.successColor,
                          onTap: () => _exportSettings(context, controller),
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          title: 'Hapus Semua Data',
                          subtitle: 'Hapus semua data transaksi dan produk',
                          icon: Icons.delete_sweep,
                          iconColor: AppTheme.errorColor,
                          onTap: () => _showClearDataDialog(context, controller),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// Build an expandable card section with chevron
  static Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: NeoBrutalTheme.headlineSmall.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          trailing: Icon(
            Icons.expand_more,
            color: AppTheme.textSecondary,
          ),
          children: children,
        ),
      ),
    );
  }

  /// Build a settings list tile with chevron
  static Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    int maxLines = 1,
  }) {
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
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
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
                    ),
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceXS),
                  Text(
                    subtitle,
                    style: NeoBrutalTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // Edit dialogs

  Future<void> _editBusinessName(BuildContext context, SettingsController controller, String currentValue) async {
    final result = await _showEditDialog(
      context,
      title: 'Nama Bisnis',
      currentValue: currentValue,
      hintText: 'Masukkan nama bisnis',
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(name: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Nama bisnis diperbarui');
      }
    }
  }

  Future<void> _editBusinessAddress(BuildContext context, SettingsController controller, String currentValue) async {
    final result = await _showEditDialog(
      context,
      title: 'Alamat Bisnis',
      currentValue: currentValue,
      hintText: 'Masukkan alamat',
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(address: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Alamat diperbarui');
      }
    }
  }

  Future<void> _editBusinessPhone(BuildContext context, SettingsController controller, String currentValue) async {
    final result = await _showEditDialog(
      context,
      title: 'Telepon Bisnis',
      currentValue: currentValue,
      hintText: 'Masukkan nomor telepon',
      keyboardType: TextInputType.phone,
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(phone: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Telepon diperbarui');
      }
    }
  }

  Future<void> _editBusinessEmail(BuildContext context, SettingsController controller, String currentValue) async {
    final result = await _showEditDialog(
      context,
      title: 'Email Bisnis',
      currentValue: currentValue,
      hintText: 'Masukkan email',
      keyboardType: TextInputType.emailAddress,
    );
    if (result != null) {
      final updated = controller.businessInfo.copyWith(email: result);
      await controller.updateBusinessInfo(updated);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Email diperbarui');
      }
    }
  }

  Future<void> _editCurrencySymbol(BuildContext context, SettingsController controller, String currentValue) async {
    final result = await _showEditDialog(
      context,
      title: 'Simbol Mata Uang',
      currentValue: currentValue,
      hintText: 'Contoh: Rp',
    );
    if (result != null) {
      await controller.updateCurrency(symbol: result, code: controller.currencyCode);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Simbol mata uang diperbarui');
      }
    }
  }

  Future<void> _editCurrencyCode(BuildContext context, SettingsController controller, String currentValue) async {
    final result = await _showEditDialog(
      context,
      title: 'Kode Mata Uang',
      currentValue: currentValue,
      hintText: 'Contoh: IDR',
    );
    if (result != null) {
      await controller.updateCurrency(symbol: controller.currencySymbol, code: result);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Kode mata uang diperbarui');
      }
    }
  }

  Future<void> _editReceiptFooter(BuildContext context, SettingsController controller, String currentValue) async {
    final result = await _showEditDialog(
      context,
      title: 'Footer Struk',
      currentValue: currentValue,
      hintText: 'Masukkan pesan footer',
      maxLines: 3,
    );
    if (result != null) {
      await controller.updateReceiptFooter(result);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Footer struk diperbarui');
      }
    }
  }

  Future<void> _editLowStockThreshold(BuildContext context, SettingsController controller, int currentValue) async {
    final result = await _showNumberDialog(
      context,
      title: 'Batas Stok Rendah',
      currentValue: currentValue.toDouble(),
      hintText: 'Masukkan jumlah',
    );
    if (result != null) {
      await controller.updateLowStockThreshold(result.toInt());
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Batas stok diperbarui');
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

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('Simpan'),
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

    return showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, SettingsController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Reset Pengaturan'),
        content: const Text('Apakah Anda yakin ingin mereset semua pengaturan ke nilai default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.resetSettings();
      if (success && context.mounted) {
        _showSuccessSnackBar(context, 'Pengaturan direset ke default');
      }
    }
  }

  Future<void> _showClearDataDialog(BuildContext context, SettingsController controller) async {
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
            const Text('Hapus Semua Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERINGATAN: Tindakan ini akan menghapus semua data:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
            SizedBox(height: 12),
            Text('• Semua produk dan inventaris'),
            Text('• Semua riwayat transaksi'),
            Text('• Semua kategori dan supplier'),
            SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
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
            child: const Text('Batal'),
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
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.clearAllData();
      if (success && context.mounted) {
        _showSuccessSnackBar(context, 'Semua data berhasil dihapus');
      }
    }
  }

  Future<void> _exportSettings(BuildContext context, SettingsController controller) async {
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
