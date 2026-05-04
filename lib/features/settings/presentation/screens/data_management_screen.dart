import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/export_service.dart';
import '../../../../features/backup/domain/entities/backup_metadata.dart';
import '../../../../features/backup/domain/entities/backup_config.dart';
import '../../../../core/constants/backup_constants.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/database/database_helper.dart';

/// Screen for data management (export, backup, restore)
class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  final ExportService _exportService = ExportService(
    databaseHelper: DatabaseHelper.instance,
  );

  bool _isExporting = false;

  List<BackupMetadata> get _backups =>
      ref.watch(backupControllerProvider).backups;
  bool get _isLoadingBackups => ref.watch(backupControllerProvider).isLoading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupControllerProvider).loadBackups();
    });
  }

  Future<void> _exportTransactions() async {
    setState(() => _isExporting = true);
    try {
      final path = await _exportService.exportTransactionsToCsv();
      await _exportService.shareExport(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.export_transactions_success,
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.export_failed(e.toString()),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportProducts() async {
    setState(() => _isExporting = true);
    try {
      final path = await _exportService.exportProductsToCsv();
      await _exportService.shareExport(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.export_products_success,
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.export_failed(e.toString()),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportExpenses() async {
    setState(() => _isExporting = true);
    try {
      final path = await _exportService.exportExpensesToCsv();
      await _exportService.shareExport(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.export_expenses_success,
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.export_failed(e.toString()),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _createBackup() async {
    final controller = ref.read(backupControllerProvider);
    final config = BackupConfig(
      type: BackupType.full,
      dataTypes: [BackupDataType.all],
      location: StorageLocation.local,
    );

    final success = await controller.createManualBackup(config);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.backup_created_success),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _deleteBackup(BackupMetadata backup) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.delete_backup_title),
        content: Text(l10n.confirm_delete_backup),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = ref.read(backupControllerProvider);
      controller.selectBackup(backup);
      await controller.deleteBackup();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backup_deleted),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      appBar: AppBar(title: Text(l10n.manage_data)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Export Section
          _buildSectionHeader(l10n.export_data, Icons.ios_share_rounded),
          const SizedBox(height: 12),
          _buildExportCard(
            'Transaksi',
            Icons.receipt_long_rounded,
            _exportTransactions,
            _isExporting,
          ),
          const SizedBox(height: 8),
          _buildExportCard(
            'Produk',
            Icons.inventory_2_rounded,
            _exportProducts,
            _isExporting,
          ),
          const SizedBox(height: 8),
          _buildExportCard(
            'Pengeluaran',
            Icons.payments_rounded,
            _exportExpenses,
            _isExporting,
          ),

          const SizedBox(height: 24),

          // Backup Section
          _buildSectionHeader('Backup & Restore', Icons.backup_rounded),
          const SizedBox(height: 12),
          _buildBackupCreateCard(),
          if (_backups.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._backups.map((backup) => _buildBackupCard(backup)),
          ],
          if (_isLoadingBackups)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildExportCard(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isLoading,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: isLoading ? null : onTap,
      ),
    );
  }

  Widget _buildBackupCreateCard() {
    final controller = ref.watch(backupControllerProvider);
    final isCreating = controller.isProcessing;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.add_circle_outline, color: AppTheme.successColor),
        title: Text('Buat Backup Baru'),
        subtitle: Text('Backup lengkap semua data'),
        trailing: isCreating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: isCreating ? null : _createBackup,
      ),
    );
  }

  Widget _buildBackupCard(BackupMetadata backup) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          backup.type == BackupType.full ? Icons.backup : Icons.description,
          color: AppTheme.infoColor,
        ),
        title: Text(
          backup.type == BackupType.full ? 'Full Backup' : 'Incremental',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${backup.createdAt.day}/${backup.createdAt.month}/${backup.createdAt.year} ${backup.createdAt.hour}:${backup.createdAt.minute.toString().padLeft(2, '0')} - ${backup.sizeFormatted}',
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: AppTheme.errorColor),
          onPressed: () => _deleteBackup(backup),
        ),
      ),
    );
  }
}
