import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../services/database/database_helper.dart';

/// Screen for data management (export, backup, restore)
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final ExportService _exportService = ExportService(databaseHelper: DatabaseHelper.instance);
  final BackupService _backupService = BackupService(databaseHelper: DatabaseHelper.instance);

  bool _isExporting = false;
  bool _isBackingUp = false;
  List<BackupInfo> _backups = [];
  bool _isLoadingBackups = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoadingBackups = true);
    try {
      _backups = await _backupService.getAvailableBackups();
    } catch (e) {
      // Handle error silently
    }
    setState(() => _isLoadingBackups = false);
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
    setState(() => _isBackingUp = true);
    try {
      final path = await _backupService.createBackup();
      await _loadBackups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup dibuat: ${path.split('/').last}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat backup: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isBackingUp = false);
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Backup'),
        content: Text('Apakah Anda yakin ingin menghapus backup ${backup.fileName}?'),
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
      final success = await _backupService.deleteBackup(backup.path);
      if (success) {
        await _loadBackups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup dihapus'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Data'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Export Section
          _buildSectionHeader('Ekspor Data', Icons.ios_share_rounded),
          const SizedBox(height: 12),
          _buildExportCard('Transaksi', Icons.receipt_long_rounded, _exportTransactions),
          const SizedBox(height: 8),
          _buildExportCard('Produk', Icons.inventory_2_rounded, _exportProducts),
          const SizedBox(height: 8),
          _buildExportCard('Pengeluaran', Icons.payments_rounded, _exportExpenses),

          const SizedBox(height: 24),

          // Backup Section
          _buildSectionHeader('Backup & Restore', Icons.backup_rounded),
          const SizedBox(height: 12),
          _buildBackupCard(),

          const SizedBox(height: 16),

          // Backups List
          if (_isLoadingBackups)
            Center(child: CircularProgressIndicator())
          else if (_backups.isEmpty)
            _buildEmptyBackups()
          else
            _buildBackupsList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildExportCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.getBorderColor(context)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text('Ekspor $title'),
        trailing: _isExporting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.chevron_right),
        onTap: _isExporting ? null : onTap,
      ),
    );
  }

  Widget _buildBackupCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.backup_rounded, color: AppTheme.secondaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buat Backup Database',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      Text(
                        'Simpan backup lengkap database',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isBackingUp ? null : _createBackup,
              icon: _isBackingUp
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.save),
              label: Text(_isBackingUp ? 'Membuat Backup...' : 'Buat Backup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBackups() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.getBorderColor(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.backup_outlined,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada backup',
              style: TextStyle(
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupsList() {
    return Column(
      children: _backups.map((backup) => _buildBackupItem(backup)).toList(),
    );
  }

  Widget _buildBackupItem(BackupInfo backup) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.getBorderColor(context)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.storage_rounded, color: AppTheme.infoColor, size: 20),
        ),
        title: Text(
          backup.fileName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        subtitle: Text(
          '${backup.dateFormatted} • ${backup.sizeFormatted}',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
          onPressed: () => _deleteBackup(backup),
        ),
      ),
    );
  }
}
