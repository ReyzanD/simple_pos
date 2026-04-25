import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Themes & Constants
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/constants/backup_constants.dart';
import '../../../shared/presentation/providers.dart';

// EXTRACTED WIDGETS (We are creating these next)
import '../widgets/backup_storage_status.dart';
import '../widgets/backup_list_item.dart';
import '../widgets/backup_create_dialog.dart';
import '../widgets/backup_schedule_dialog.dart';

/// BackupScreen
///
/// **Refactored:** 2,743 lines -> ~180 lines
/// **Purpose:** Main orchestrator for the Backup feature UI.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupControllerProvider).loadBackups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(backupControllerProvider);

    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(controller),
      floatingActionButton: _buildFAB(controller),
    );
  }

  Widget _buildBody(controller) {
    if (controller.isLoading && controller.backups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError) {
      return _buildErrorState(controller);
    }

    return Column(
      children: [
        // Extracted Storage Widget
        BackupStorageStatusWidget(controller: controller),

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
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Backup & Restore'),
      backgroundColor: NeoBrutalTheme.blockYellow,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 6)),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black.withValues(alpha: 0.5),
        indicatorWeight: 4,
        tabs: const [
          Tab(text: 'Full Backups'),
          Tab(text: 'Incremental'),
        ],
      ),
    );
  }

  Widget _buildBackupList(dynamic controller, BackupType type) {
    final filteredBackups =
        controller.backups.where((backup) => backup.type == type).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (filteredBackups.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadBackups(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBackups.length,
        itemBuilder: (context, index) {
          // Extracted List Item Widget
          return BackupListItem(
            backup: filteredBackups[index],
            isSelected:
                controller.selectedBackup?.id == filteredBackups[index].id,
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

  Widget _buildFAB(dynamic controller) {
    if (controller.isProcessing) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: () => _showBackupOptions(context, controller),
      icon: const Icon(Icons.add),
      label: const Text('Backup'),
      backgroundColor: NeoBrutalTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        side: const BorderSide(color: Colors.black, width: 4),
      ),
    );
  }

  // --- HELPER METHODS ---

  void _showBackupOptions(BuildContext context, dynamic controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Create Backup'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => BackupCreateDialog(controller: controller),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule Backup'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => BackupScheduleDialog(controller: controller),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BackupType type) {
    return Center(child: Text('No ${type.name} backups found'));
  }

  Widget _buildErrorState(dynamic controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(controller.error?.userMessage ?? 'An error occurred'),
          ElevatedButton(
            onPressed: () => controller.loadBackups(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
