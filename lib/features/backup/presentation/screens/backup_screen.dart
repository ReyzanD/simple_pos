import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/constants/backup_constants.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';
import '../controllers/backup_controller.dart';
import '../../domain/entities/backup_metadata.dart';
import '../../domain/entities/backup_config.dart';

/// Backup & Restore Screen
/// Main screen for managing backups with Material 3 design
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load backups when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackupController>().loadBackups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background, // ✅ Brutal white background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Backup & Restore'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: NeoBrutalTheme.blockYellow, // ✅ Bold yellow background
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 6, // ✅ Extra thick bottom border
              ),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black.withValues(alpha: 0.5),
          indicatorWeight: 4, // ✅ Bold indicator
          labelStyle: NeoBrutalTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
          tabs: const [
            Tab(text: 'Full Backups'),
            Tab(text: 'Incremental'),
          ],
        ),
      ),
      body: Consumer<BackupController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.backups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError) {
            return _buildErrorState(controller);
          }

          return Column(
            children: [
              // Storage Status Widget
              _StorageStatusWidget(controller: controller),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBackupList(controller, BackupType.full),
                    _buildBackupList(controller, BackupType.incremental),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<BackupController>(
        builder: (context, controller, _) {
          if (controller.isProcessing) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            heroTag: 'backup_fab', // ✅ Unique hero tag
            onPressed: () => _showBackupOptionsDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Backup'),
            backgroundColor: NeoBrutalTheme.primary, // ✅ Brutal primary color
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              side: BorderSide(
                color: Colors.black,
                width: 4, // ✅ Bold 4px border
              ),
            ),
            elevation: 6,
          );
        },
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(BackupController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
              border: Border.all(
                color: Colors.black,
                width: 4, // ✅ Bold border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),
          Text(
            controller.error?.userMessage ?? 'Terjadi kesalahan',
            style: NeoBrutalTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          ElevatedButton.icon(
            onPressed: () {
              controller.clearError();
              controller.loadBackups();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoBrutalTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: NeoBrutalTheme.spaceLG,
                vertical: NeoBrutalTheme.spaceMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                side: BorderSide(
                  color: Colors.black,
                  width: 4, // ✅ Bold border
                ),
              ),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }

  /// Build backup list for specific type
  Widget _buildBackupList(BackupController controller, BackupType type) {
    final filteredBackups = controller.backups
        .where((backup) => backup.type == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (filteredBackups.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadBackups(),
      color: NeoBrutalTheme.primary, // ✅ Brutal primary color
      backgroundColor: NeoBrutalTheme.blockYellow.withValues(alpha: 0.3),
      strokeWidth: 4, // ✅ Thicker indicator
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100,
        ),
        itemCount: filteredBackups.length,
        itemBuilder: (context, index) {
          return _BackupListItem(
            backup: filteredBackups[index],
            isSelected: controller.selectedBackup?.id == filteredBackups[index].id,
            onTap: () => controller.selectBackup(
              controller.selectedBackup?.id == filteredBackups[index].id
                  ? null
                  : filteredBackups[index],
            ),
          );
        },
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(BackupType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.blockCoral.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
              border: Border.all(
                color: Colors.black,
                width: 4, // ✅ Bold border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.backup_outlined,
              size: 60,
              color: NeoBrutalTheme.blockCoral,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          Text(
            'Belum ada ${type == BackupType.full ? "backup penuh" : "backup inkremental"}',
            style: NeoBrutalTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            'Tap tombol + untuk membuat backup',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Show backup options dialog
  void _showBackupOptionsDialog(BuildContext context, BackupController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Backup Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.backup,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              title: const Text('Create Backup'),
              subtitle: const Text('Create a manual backup now'),
              onTap: () {
                Navigator.pop(context);
                _showCreateBackupDialog(context, controller);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.schedule,
                  color: AppTheme.secondaryColor,
                  size: 20,
                ),
              ),
              title: const Text('Schedule Backup'),
              subtitle: const Text('Set up automatic backups'),
              onTap: () {
                Navigator.pop(context);
                _showScheduleBackupDialog(context, controller);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show create backup dialog
  void _showCreateBackupDialog(BuildContext context, BackupController controller) {
    showDialog(
      context: context,
      builder: (context) => _CreateBackupDialog(
        controller: controller,
      ),
    );
  }

  /// Show schedule backup dialog
  void _showScheduleBackupDialog(BuildContext context, BackupController controller) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleBackupDialog(
        controller: controller,
      ),
    );
  }
}

/// Storage Status Widget
class _StorageStatusWidget extends StatefulWidget {
  final BackupController controller;

  const _StorageStatusWidget({required this.controller});

  @override
  State<_StorageStatusWidget> createState() => _StorageStatusWidgetState();
}

class _StorageStatusWidgetState extends State<_StorageStatusWidget> {
  @override
  Widget build(BuildContext context) {
    // Calculate storage metrics
    final localBackups = widget.controller.backups
        .where((b) => b.location == StorageLocation.local)
        .toList();
    final driveBackups = widget.controller.backups
        .where((b) => b.location == StorageLocation.drive)
        .toList();

    final localSize = localBackups.fold<int>(0, (sum, b) => sum + b.size);
    final driveSize = driveBackups.fold<int>(0, (sum, b) => sum + b.size);
    final totalSize = localSize + driveSize;

    // Calculate usage percentages (assume 5GB limit for demo)
    const maxStorage = 5 * 1024 * 1024 * 1024; // 5GB
    final localUsage = localSize / maxStorage;
    final driveUsage = driveSize / maxStorage;

    // Determine status colors
    final localStatusColor = _getStatusColor(localUsage);
    final driveStatusColor = _getStatusColor(driveUsage);

    return GestureDetector(
      onTap: () => _showStorageDetailsDialog(context, localSize, driveSize, maxStorage),
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
          border: Border.all(
            color: Colors.black,
            width: 4, // ✅ Bold border
          ),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: NeoBrutalTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.storage,
                        size: 20,
                        color: NeoBrutalTheme.primary,
                      ),
                    ),
                    SizedBox(width: NeoBrutalTheme.spaceSM),
                    Text(
                      'STORAGE STATUS',
                      style: NeoBrutalTheme.labelLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    onPressed: () => widget.controller.loadBackups(),
                    tooltip: 'Refresh storage info',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: NeoBrutalTheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),

            // Progress bars
            _StorageProgressBar(
              label: 'Local Storage',
              used: localSize,
              total: maxStorage,
              color: localStatusColor,
              icon: Icons.smartphone,
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),
            _StorageProgressBar(
              label: 'Google Drive',
              used: driveSize,
              total: maxStorage,
              color: driveStatusColor,
              icon: Icons.cloud,
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),

            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _StorageStat(
                    label: 'Total Size',
                    value: _formatBytes(totalSize),
                    icon: Icons.folder,
                    color: NeoBrutalTheme.primary,
                  ),
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _StorageStat(
                    label: 'Local',
                    value: localBackups.length.toString(),
                    icon: Icons.backup,
                    color: AppTheme.infoColor,
                  ),
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _StorageStat(
                    label: 'Drive',
                    value: driveBackups.length.toString(),
                    icon: Icons.cloud,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),

            // Tap hint
            SizedBox(height: NeoBrutalTheme.spaceSM),
            Center(
              child: Text(
                'Tap for detailed breakdown',
                style: NeoBrutalTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(double usage) {
    if (usage < 0.5) return AppTheme.successColor;
    if (usage < 0.8) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
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

/// Storage Progress Bar
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
                SizedBox(width: NeoBrutalTheme.spaceXS),
                Text(
                  label,
                  style: NeoBrutalTheme.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              '${_formatBytes(used)} / ${_formatBytes(total)}',
              style: NeoBrutalTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
        SizedBox(height: NeoBrutalTheme.spaceXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.9), color],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}% used',
          style: NeoBrutalTheme.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} MB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Storage Details Dialog
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
    final totalUsed = localSize + driveSize;
    final available = maxStorage - totalUsed;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.storage,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Detailed breakdown of backup storage',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Storage breakdown
            _DetailRow(
              icon: Icons.smartphone,
              label: 'Local Storage',
              value: _formatBytes(localSize),
              color: AppTheme.infoColor,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.cloud,
              label: 'Google Drive',
              value: _formatBytes(driveSize),
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.folder,
              label: 'Total Used',
              value: _formatBytes(totalUsed),
              color: AppTheme.primaryColor,
              isBold: true,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.check_circle,
              label: 'Available Space',
              value: _formatBytes(available),
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} MB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Detail row for storage dialog
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }
}

/// Storage Stat Item
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
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }
}

/// Backup List Item
class _BackupListItem extends StatelessWidget {
  final BackupMetadata backup;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackupListItem({
    required this.backup,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
        padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
        decoration: BoxDecoration(
          color: isSelected
              ? NeoBrutalTheme.primary.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          border: Border.all(
            color: isSelected
                ? NeoBrutalTheme.primary
                : Colors.black,
            width: isSelected ? 4 : 3, // ✅ Bold border
          ),
          boxShadow: isSelected
              ? NeoBrutalTheme.chunkyShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backup.type == BackupType.full
                        ? AppTheme.infoColor.withValues(alpha: 0.15)
                        : AppTheme.successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                    border: Border.all(
                      color: backup.type == BackupType.full
                          ? AppTheme.infoColor
                          : AppTheme.successColor,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    backup.type == BackupType.full
                        ? Icons.backup
                        : Icons.update,
                    color: backup.type == BackupType.full
                        ? AppTheme.infoColor
                        : AppTheme.successColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: NeoBrutalTheme.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(backup.createdAt),
                        style: NeoBrutalTheme.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _formatTime(backup.createdAt),
                        style: NeoBrutalTheme.bodyMedium.copyWith(
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: NeoBrutalTheme.spaceSM,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.primary,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'SELECTED',
                      style: NeoBrutalTheme.labelSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  icon: Icons.storage,
                  label: backup.sizeFormatted,
                  color: AppTheme.infoColor,
                ),
                SizedBox(width: NeoBrutalTheme.spaceSM),
                _buildInfoChip(
                  context,
                  icon: backup.location == StorageLocation.local
                      ? Icons.smartphone
                      : Icons.cloud,
                  label: backup.location.name.toUpperCase(),
                  color: NeoBrutalTheme.secondary,
                ),
                SizedBox(width: NeoBrutalTheme.spaceSM),
                _buildInfoChip(
                  context,
                  icon: Icons.verified,
                  label: 'v${backup.appVersion}',
                  color: AppTheme.successColor,
                ),
              ],
            ),
            if (isSelected) ...[
              SizedBox(height: NeoBrutalTheme.spaceMD),
              Container(
                height: 3,
                color: Colors.black.withValues(alpha: 0.1),
              ),
              SizedBox(height: NeoBrutalTheme.spaceMD),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.restore,
                      label: 'Restore',
                      color: AppTheme.successColor,
                      onPressed: () => _showRestoreDialog(context),
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceSM),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.delete,
                      label: 'Delete',
                      color: AppTheme.errorColor,
                      onPressed: () => _showDeleteDialog(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: NeoBrutalTheme.spaceSM, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
        border: Border.all(
          color: color,
          width: 2, // ✅ Bold border
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: NeoBrutalTheme.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 3), // ✅ Bold border
        padding: EdgeInsets.symmetric(horizontal: NeoBrutalTheme.spaceMD, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        ),
        textStyle: NeoBrutalTheme.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RestoreDialog(backup: backup),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DeleteBackupDialog(backup: backup),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Create Backup Dialog
class _CreateBackupDialog extends StatefulWidget {
  final BackupController controller;

  const _CreateBackupDialog({required this.controller});

  @override
  State<_CreateBackupDialog> createState() => _CreateBackupDialogState();
}

class _CreateBackupDialogState extends State<_CreateBackupDialog> {
  BackupType _selectedType = BackupType.full;
  StorageLocation _selectedLocation = StorageLocation.local;
  BackupDataType _selectedDataType = BackupDataType.all;
  bool _compress = true;
  bool _isCreating = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.backup,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Backup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configure your backup settings',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Backup Type Selection
            _buildSectionTitle('Backup Type', Icons.backup),
            const SizedBox(height: 12),
            SegmentedButton<BackupType>(
              segments: const [
                ButtonSegment(
                  value: BackupType.full,
                  label: Text('Full'),
                  icon: Icon(Icons.backup),
                ),
                ButtonSegment(
                  value: BackupType.incremental,
                  label: Text('Incremental'),
                  icon: Icon(Icons.update),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<BackupType> selected) {
                setState(() {
                  _selectedType = selected.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.primaryColor.withValues(alpha: 0.1);
                  }
                  return null;
                }),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedType == BackupType.full
                  ? 'Complete backup of all data'
                  : 'Backup changes since last full backup',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 20),

            // Data Type Selection
            _buildSectionTitle('Data to Backup', Icons.data_object),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BackupDataType.values.map((type) {
                final isSelected = _selectedDataType == type;
                return FilterChip(
                  label: Text(_getDataTypeLabel(type)),
                  avatar: Icon(
                    _getDataTypeIcon(type),
                    size: 18,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDataType = type;
                    });
                  },
                  backgroundColor: AppTheme.getCardColor(context),
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.getBorderColor(context),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Compression Toggle
            Row(
              children: [
                Icon(
                  Icons.compress,
                  size: 20,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Compress Backup',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _compress,
                  onChanged: (value) {
                    setState(() {
                      _compress = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Storage Location
            _buildSectionTitle('Storage Location', Icons.cloud_upload),
            const SizedBox(height: 12),
            SegmentedButton<StorageLocation>(
              segments: const [
                ButtonSegment(
                  value: StorageLocation.local,
                  label: Text('Local'),
                  icon: Icon(Icons.smartphone),
                ),
                ButtonSegment(
                  value: StorageLocation.drive,
                  label: Text('Drive'),
                  icon: Icon(Icons.cloud),
                ),
              ],
              selected: {_selectedLocation},
              onSelectionChanged: (Set<StorageLocation> selected) {
                setState(() {
                  _selectedLocation = selected.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.primaryColor.withValues(alpha: 0.1);
                  }
                  return null;
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ModernSecondaryButton(
                    text: 'Cancel',
                    onPressed: _isCreating ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Create Backup',
                    icon: Icons.backup,
                    onPressed: _isCreating
                        ? null
                        : () async {
                            setState(() {
                              _isCreating = true;
                            });

                            final config = BackupConfig(
                              type: _selectedType,
                              dataTypes: [_selectedDataType],
                              location: _selectedLocation,
                              compress: _compress,
                            );

                            final success = await widget.controller.createManualBackup(config);

                            if (mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Backup created successfully'),
                                    backgroundColor: AppTheme.successColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    isLoading: _isCreating,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.getTextSecondaryColor(context),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  String _getDataTypeLabel(BackupDataType type) {
    switch (type) {
      case BackupDataType.database:
        return 'Database';
      case BackupDataType.images:
        return 'Images';
      case BackupDataType.all:
        return 'All Data';
    }
  }

  IconData _getDataTypeIcon(BackupDataType type) {
    switch (type) {
      case BackupDataType.database:
        return Icons.storage;
      case BackupDataType.images:
        return Icons.image;
      case BackupDataType.all:
        return Icons.apps;
    }
  }
}

/// Restore Dialog
class _RestoreDialog extends StatefulWidget {
  final BackupMetadata backup;

  const _RestoreDialog({required this.backup});

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  RestoreMode _selectedMode = RestoreMode.replaceAll;
  bool _showConfirmation = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    if (_showConfirmation) {
      return _buildConfirmationDialog(context);
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restore,
                    color: AppTheme.warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restore Backup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Restore data from this backup',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Backup Details Card
            ModernCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: _formatDate(widget.backup.createdAt),
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _formatTime(widget.backup.createdAt),
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: Icons.storage,
                    label: 'Size',
                    value: widget.backup.sizeFormatted,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: widget.backup.type == BackupType.full
                        ? Icons.backup
                        : Icons.update,
                    label: 'Type',
                    value: widget.backup.type == BackupType.full ? 'Full' : 'Incremental',
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: widget.backup.location == StorageLocation.local
                        ? Icons.smartphone
                        : Icons.cloud,
                    label: 'Location',
                    value: widget.backup.location.name.toUpperCase(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Restore Mode Selection
            _buildSectionTitle('Restore Mode', Icons.settings),
            const SizedBox(height: 12),
            SegmentedButton<RestoreMode>(
              segments: const [
                ButtonSegment(
                  value: RestoreMode.replaceAll,
                  label: Text('Replace All'),
                  icon: Icon(Icons.delete_sweep),
                ),
                ButtonSegment(
                  value: RestoreMode.merge,
                  label: Text('Merge'),
                  icon: Icon(Icons.merge_type),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (Set<RestoreMode> selected) {
                setState(() {
                  _selectedMode = selected.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.warningColor.withValues(alpha: 0.1);
                  }
                  return null;
                }),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedMode == RestoreMode.replaceAll
                  ? 'Replace all existing data with backup data'
                  : 'Merge backup data with existing data',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),

            // Warning for Replace All mode
            if (_selectedMode == RestoreMode.replaceAll) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Warning: This will replace all your current data. This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ModernSecondaryButton(
                    text: 'Cancel',
                    onPressed: _isRestoring ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Restore',
                    icon: Icons.restore,
                    backgroundColor: AppTheme.warningColor,
                    onPressed: _isRestoring
                        ? null
                        : () {
                            setState(() {
                              _showConfirmation = true;
                            });
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              size: 48,
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Restore',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to restore this backup?',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedMode == RestoreMode.replaceAll) ...[
              const SizedBox(height: 12),
              Text(
                'All current data will be replaced.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ModernSecondaryButton(
                    text: 'Back',
                    onPressed: _isRestoring
                        ? null
                        : () {
                            setState(() {
                              _showConfirmation = false;
                            });
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Confirm',
                    icon: Icons.check,
                    backgroundColor: AppTheme.warningColor,
                    onPressed: _isRestoring
                        ? null
                        : () async {
                            setState(() {
                              _isRestoring = true;
                            });

                            final controller = context.read<BackupController>();
                            final success = await controller.restoreBackup(_selectedMode);

                            if (mounted) {
                              Navigator.pop(context); // Close confirmation
                              Navigator.pop(context); // Close restore dialog
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Backup restored successfully'),
                                    backgroundColor: AppTheme.successColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    isLoading: _isRestoring,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.getTextSecondaryColor(context),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.getTextSecondaryColor(context),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Delete Backup Dialog
class _DeleteBackupDialog extends StatefulWidget {
  final BackupMetadata backup;

  const _DeleteBackupDialog({required this.backup});

  @override
  State<_DeleteBackupDialog> createState() => _DeleteBackupDialogState();
}

class _DeleteBackupDialogState extends State<_DeleteBackupDialog> {
  bool _confirmationChecked = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    color: AppTheme.errorColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Backup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This action cannot be undone',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Backup Details Card
            ModernCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppTheme.errorColor.withValues(alpha: 0.05),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: _formatDate(widget.backup.createdAt),
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _formatTime(widget.backup.createdAt),
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: Icons.storage,
                    label: 'Size',
                    value: widget.backup.sizeFormatted,
                    valueColor: AppTheme.errorColor,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: widget.backup.type == BackupType.full
                        ? Icons.backup
                        : Icons.update,
                    label: 'Type',
                    value: widget.backup.type == BackupType.full ? 'Full' : 'Incremental',
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    icon: widget.backup.location == StorageLocation.local
                        ? Icons.smartphone
                        : Icons.cloud,
                    label: 'Location',
                    value: widget.backup.location.name.toUpperCase(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Warning if last full backup
            if (widget.backup.type == BackupType.full) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a full backup. Deleting it may affect incremental backups that depend on it.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Space to be freed
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.successColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This will free up ${widget.backup.sizeFormatted} of storage space',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Confirmation checkbox
            Row(
              children: [
                Checkbox(
                  value: _confirmationChecked,
                  onChanged: (value) {
                    setState(() {
                      _confirmationChecked = value ?? false;
                    });
                  },
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.errorColor;
                    }
                    return null;
                  }),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _confirmationChecked = !_confirmationChecked;
                      });
                    },
                    child: Text(
                      'I understand this action cannot be undone',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ModernSecondaryButton(
                    text: 'Cancel',
                    onPressed: _isDeleting ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Delete',
                    icon: Icons.delete_forever,
                    backgroundColor: AppTheme.errorColor,
                    onPressed: _isDeleting || !_confirmationChecked
                        ? null
                        : () async {
                            if (!mounted) return;

                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);

                            setState(() {
                              _isDeleting = true;
                            });

                            final controller = context.read<BackupController>();
                            final success = await controller.deleteBackup();

                            if (!mounted) return;

                            navigator.pop();
                            if (success) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Backup deleted successfully\n${widget.backup.sizeFormatted} freed',
                                  ),
                                  backgroundColor: AppTheme.successColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                    isLoading: _isDeleting,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.getTextSecondaryColor(context),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Schedule Backup Dialog
class _ScheduleBackupDialog extends StatefulWidget {
  final BackupController controller;

  const _ScheduleBackupDialog({required this.controller});

  @override
  State<_ScheduleBackupDialog> createState() => _ScheduleBackupDialogState();
}

class _ScheduleBackupDialogState extends State<_ScheduleBackupDialog> {
  final TextEditingController _nameController = TextEditingController();
  BackupFrequency _frequency = BackupFrequency.daily;
  BackupType _backupType = BackupType.full;
  BackupDataType _dataType = BackupDataType.all;
  StorageLocation _location = StorageLocation.local;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 2, minute: 0);
  int? _selectedDayOfWeek; // 1-7 (Monday-Sunday)
  int? _selectedDayOfMonth; // 1-31
  bool _isScheduling = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Backup',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextPrimaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set up automatic backups',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Schedule Name
              _buildSectionTitle('Schedule Name', Icons.label),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Daily Backup at 2 AM',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.getCardColor(context),
                ),
              ),
              const SizedBox(height: 20),

              // Frequency Selection
              _buildSectionTitle('Frequency', Icons.repeat),
              const SizedBox(height: 12),
              SegmentedButton<BackupFrequency>(
                segments: const [
                  ButtonSegment(
                    value: BackupFrequency.daily,
                    label: Text('Daily'),
                    icon: Icon(Icons.today),
                  ),
                  ButtonSegment(
                    value: BackupFrequency.weekly,
                    label: Text('Weekly'),
                    icon: Icon(Icons.calendar_view_week),
                  ),
                  ButtonSegment(
                    value: BackupFrequency.monthly,
                    label: Text('Monthly'),
                    icon: Icon(Icons.calendar_view_month),
                  ),
                ],
                selected: {_frequency},
                onSelectionChanged: (Set<BackupFrequency> selected) {
                  setState(() {
                    _frequency = selected.first;
                    // Reset day selections when frequency changes
                    _selectedDayOfWeek = null;
                    _selectedDayOfMonth = null;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.secondaryColor.withValues(alpha: 0.1);
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Time Picker
              _buildSectionTitle('Time', Icons.access_time),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppTheme.primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedTime = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.getBorderColor(context),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Day Selector for Weekly
              if (_frequency == BackupFrequency.weekly) ...[
                _buildSectionTitle('Day of Week', Icons.calendar_today),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (index) {
                    final day = index + 1; // 1-7 (Monday-Sunday)
                    final isSelected = _selectedDayOfWeek == day;
                    final dayName = _getDayName(day);
                    return FilterChip(
                      label: Text(dayName.substring(0, 3)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDayOfWeek = selected ? day : null;
                        });
                      },
                      backgroundColor: AppTheme.getCardColor(context),
                      selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.secondaryColor,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.secondaryColor
                            : AppTheme.getBorderColor(context),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],

              // Day Selector for Monthly
              if (_frequency == BackupFrequency.monthly) ...[
                _buildSectionTitle('Day of Month', Icons.date_range),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(31, (index) {
                    final day = index + 1; // 1-31
                    final isSelected = _selectedDayOfMonth == day;
                    return FilterChip(
                      label: Text('$day'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDayOfMonth = selected ? day : null;
                        });
                      },
                      backgroundColor: AppTheme.getCardColor(context),
                      selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.secondaryColor,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.secondaryColor
                            : AppTheme.getBorderColor(context),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],

              // Backup Type
              _buildSectionTitle('Backup Type', Icons.backup),
              const SizedBox(height: 12),
              SegmentedButton<BackupType>(
                segments: const [
                  ButtonSegment(
                    value: BackupType.full,
                    label: Text('Full'),
                    icon: Icon(Icons.backup),
                  ),
                  ButtonSegment(
                    value: BackupType.incremental,
                    label: Text('Incremental'),
                    icon: Icon(Icons.update),
                  ),
                ],
                selected: {_backupType},
                onSelectionChanged: (Set<BackupType> selected) {
                  setState(() {
                    _backupType = selected.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.primaryColor.withValues(alpha: 0.1);
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Data Type
              _buildSectionTitle('Data to Backup', Icons.data_object),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BackupDataType.values.map((type) {
                  final isSelected = _dataType == type;
                  return FilterChip(
                    label: Text(_getDataTypeLabel(type)),
                    avatar: Icon(
                      _getDataTypeIcon(type),
                      size: 18,
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _dataType = type;
                      });
                    },
                    backgroundColor: AppTheme.getCardColor(context),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.getBorderColor(context),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Storage Location
              _buildSectionTitle('Storage Location', Icons.cloud_upload),
              const SizedBox(height: 12),
              SegmentedButton<StorageLocation>(
                segments: const [
                  ButtonSegment(
                    value: StorageLocation.local,
                    label: Text('Local'),
                    icon: Icon(Icons.smartphone),
                  ),
                  ButtonSegment(
                    value: StorageLocation.drive,
                    label: Text('Drive'),
                    icon: Icon(Icons.cloud),
                  ),
                ],
                selected: {_location},
                onSelectionChanged: (Set<StorageLocation> selected) {
                  setState(() {
                    _location = selected.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.primaryColor.withValues(alpha: 0.1);
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ModernSecondaryButton(
                      text: 'Cancel',
                      onPressed: _isScheduling ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernButton(
                      text: 'Schedule',
                      icon: Icons.schedule,
                      backgroundColor: AppTheme.secondaryColor,
                      onPressed: _isScheduling ? null : _validateAndSchedule,
                      isLoading: _isScheduling,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndSchedule() async {
    // Validate schedule name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a schedule name'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Validate day selection
    if (_frequency == BackupFrequency.weekly && _selectedDayOfWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a day of the week'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_frequency == BackupFrequency.monthly && _selectedDayOfMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a day of the month'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isScheduling = true;
    });

    // TODO: Implement scheduling logic
    // For now, just show a success message
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup "${_nameController.text}" scheduled successfully'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.getTextSecondaryColor(context),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }

  String _getDataTypeLabel(BackupDataType type) {
    switch (type) {
      case BackupDataType.database:
        return 'Database';
      case BackupDataType.images:
        return 'Images';
      case BackupDataType.all:
        return 'All Data';
    }
  }

  IconData _getDataTypeIcon(BackupDataType type) {
    switch (type) {
      case BackupDataType.database:
        return Icons.storage;
      case BackupDataType.images:
        return Icons.image;
      case BackupDataType.all:
        return Icons.apps;
    }
  }
}
