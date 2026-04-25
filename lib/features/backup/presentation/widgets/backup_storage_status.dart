/// BackupStorageStatusWidget
///
/// **Purpose:** Displays storage usage statistics and progress bars
/// **Used by:** BackupScreen
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/backup_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../controllers/backup_controller.dart';

class BackupStorageStatusWidget extends StatefulWidget {
  final BackupController controller;

  const BackupStorageStatusWidget({super.key, required this.controller});

  @override
  State<BackupStorageStatusWidget> createState() =>
      _BackupStorageStatusWidgetState();
}

class _BackupStorageStatusWidgetState extends State<BackupStorageStatusWidget> {
  @override
  Widget build(BuildContext context) {
    final localBackups = widget.controller.backups
        .where((b) => b.location == StorageLocation.local)
        .toList();
    final driveBackups = widget.controller.backups
        .where((b) => b.location == StorageLocation.drive)
        .toList();

    final localSize = localBackups.fold<int>(0, (sum, b) => sum + b.size);
    final driveSize = driveBackups.fold<int>(0, (sum, b) => sum + b.size);
    final totalSize = localSize + driveSize;

    const maxStorage = 5 * 1024 * 1024 * 1024; // 5GB
    final localUsage = localSize / maxStorage;
    final driveUsage = driveSize / maxStorage;

    return GestureDetector(
      onTap: () =>
          _showStorageDetailsDialog(context, localSize, driveSize, maxStorage),
      child: Container(
        margin: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NeoBrutalTheme.primary.withValues(alpha: 0.15),
              NeoBrutalTheme.secondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: NeoBrutalTheme.spaceMD),
            _StorageProgressBar(
              label: 'Local Storage',
              used: localSize,
              total: maxStorage,
              color: _getStatusColor(localUsage),
              icon: Icons.smartphone,
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),
            _StorageProgressBar(
              label: 'Google Drive',
              used: driveSize,
              total: maxStorage,
              color: _getStatusColor(driveUsage),
              icon: Icons.cloud,
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),
            _buildQuickStats(
              totalSize,
              localBackups.length,
              driveBackups.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _IconBox(icon: Icons.storage, color: NeoBrutalTheme.primary),
            SizedBox(width: NeoBrutalTheme.spaceSM),
            Text(
              'STORAGE STATUS',
              style: NeoBrutalTheme.labelLarge.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        _RefreshButton(onPressed: () => widget.controller.loadBackups()),
      ],
    );
  }

  Widget _buildQuickStats(int totalSize, int localCount, int driveCount) {
    return Row(
      children: [
        Expanded(
          child: _StorageStat(
            label: 'Total Size',
            value: _formatBytes(totalSize),
            icon: Icons.folder,
            color: NeoBrutalTheme.primary,
          ),
        ),
        _Divider(),
        Expanded(
          child: _StorageStat(
            label: 'Local',
            value: localCount.toString(),
            icon: Icons.backup,
            color: AppTheme.infoColor,
          ),
        ),
        _Divider(),
        Expanded(
          child: _StorageStat(
            label: 'Drive',
            value: driveCount.toString(),
            icon: Icons.cloud,
            color: AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(double usage) {
    if (usage < 0.5) {
      return AppTheme.successColor;
    }
    if (usage < 0.8) {
      return AppTheme.warningColor;
    }
    return AppTheme.errorColor;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showStorageDetailsDialog(
    BuildContext context,
    int localSize,
    int driveSize,
    int maxStorage,
  ) {
    showDialog(
      context: context,
      builder: (context) => _StorageDetailsDialog(
        localSize: localSize,
        driveSize: driveSize,
        maxStorage: maxStorage,
      ),
    );
  }
}

// --- PRIVATE HELPERS ---

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RefreshButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: NeoBrutalTheme.primary,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
    width: 2,
    height: 40,
    color: Colors.black.withValues(alpha: 0.2),
  );
}

class _StorageProgressBar extends StatelessWidget {
  final String label;
  final int used;
  final int total;
  final Color color;
  final IconData icon;

  const _StorageProgressBar({
    required this.label,
    required this.used,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (used / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text('${(percentage * 100).toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.black12,
          color: color,
          minHeight: 8,
        ),
      ],
    );
  }
}

class _StorageStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StorageStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _StorageDetailsDialog extends StatelessWidget {
  final int localSize;
  final int driveSize;
  final int maxStorage;

  const _StorageDetailsDialog({
    required this.localSize,
    required this.driveSize,
    required this.maxStorage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Storage Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DetailRow(
            label: 'Local',
            value: localSize.toString(),
            color: AppTheme.infoColor,
          ),
          _DetailRow(
            label: 'Cloud',
            value: driveSize.toString(),
            color: AppTheme.successColor,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
