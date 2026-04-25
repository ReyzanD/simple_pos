import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
  ConsumerState<DataManagementScreen> createState() => _DataManagementScreenState();
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
            content: Text('Ekspor transaksi berhasil'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor: $e'),
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
            content: Text('Ekspor produk berhasil'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor: $e'),
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
            content: Text('Ekspor pengeluaran berhasil'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor: $e'),
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
          content: Text('Backup berhasil dibuat'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _deleteBackup(BackupMetadata backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Backup'),
        content: Text('Apakah Anda yakin ingin menghapus backup ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Hapus'),
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
          content: Text('Backup dihapus'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Data')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Export Section
          _buildSectionHeader('Ekspor Data', Icons.ios_share_rounded),
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
