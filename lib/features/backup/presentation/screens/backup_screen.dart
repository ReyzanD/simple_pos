import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/backup_constants.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../shared/presentation/main_navigation.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            final mainNavState =
                context.findAncestorStateOfType<MainNavigationState>();
            mainNavState?.openDrawer();
          },
        ),
        title: const Text('Backup & Restore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BackupController>().loadBackups();
            },
            tooltip: 'Refresh',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
            onPressed: () => _showCreateBackupDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Create Backup'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            controller.error?.userMessage ?? 'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              controller.clearError();
              controller.loadBackups();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
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
          Icon(
            Icons.backup_outlined,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada ${type == BackupType.full ? "backup penuh" : "backup inkremental"}',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk membuat backup',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
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
}

/// Storage Status Widget
class _StorageStatusWidget extends StatelessWidget {
  final BackupController controller;

  const _StorageStatusWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Calculate total backup size
    final totalSize = controller.backups.fold<int>(
      0,
      (sum, backup) => sum + backup.size,
    );

    final fullBackups = controller.backups
        .where((b) => b.type == BackupType.full)
        .length;
    final incrementalBackups = controller.backups
        .where((b) => b.type == BackupType.incremental)
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.08),
            AppTheme.secondaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Storage Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StorageStat(
                  label: 'Total Size',
                  value: _formatBytes(totalSize),
                  icon: Icons.folder,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.getBorderColor(context),
              ),
              Expanded(
                child: _StorageStat(
                  label: 'Full Backups',
                  value: fullBackups.toString(),
                  icon: Icons.backup,
                  color: AppTheme.infoColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.getBorderColor(context),
              ),
              Expanded(
                child: _StorageStat(
                  label: 'Incremental',
                  value: incrementalBackups.toString(),
                  icon: Icons.update,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backup.type == BackupType.full
                        ? AppTheme.infoColor.withValues(alpha: 0.1)
                        : AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    backup.type == BackupType.full
                        ? Icons.backup
                        : Icons.update,
                    color: backup.type == BackupType.full
                        ? AppTheme.infoColor
                        : AppTheme.successColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(backup.createdAt),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(backup.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  icon: Icons.storage,
                  label: backup.sizeFormatted,
                  color: AppTheme.infoColor,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  icon: backup.location == StorageLocation.local
                      ? Icons.smartphone
                      : Icons.cloud,
                  label: backup.location.name.toUpperCase(),
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  icon: Icons.verified,
                  label: 'v${backup.appVersion}',
                  color: AppTheme.successColor,
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
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
                  const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
class _DeleteBackupDialog extends StatelessWidget {
  final BackupMetadata backup;

  const _DeleteBackupDialog({required this.backup});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Backup'),
      content: Text(
        'Are you sure you want to delete backup from ${_formatDate(backup.createdAt)}?\n\nThis action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final controller = context.read<BackupController>();
            final success = await controller.deleteBackup();

            if (context.mounted) {
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup deleted successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
