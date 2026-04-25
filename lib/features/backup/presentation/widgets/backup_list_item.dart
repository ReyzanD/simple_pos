/// BackupListItem
///
/// **Purpose:** Individual card representing a backup entry
/// **State:** Stateless (receives callbacks for actions)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/constants/backup_constants.dart';
import '../../../shared/presentation/providers.dart';
import '../../domain/entities/backup_metadata.dart';
import 'backup_restore_dialog.dart'; // We'll create this soon
import 'backup_delete_dialog.dart'; // We'll create this soon

class BackupListItem extends ConsumerWidget {
  final BackupMetadata backup;
  final bool isSelected;
  final VoidCallback onTap;

  const BackupListItem({
    super.key,
    required this.backup,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(backupControllerProvider);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
        padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
        decoration: BoxDecoration(
          color: isSelected
              ? NeoBrutalTheme.primary.withValues(alpha:0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? NeoBrutalTheme.primary : Colors.black,
            width: isSelected ? 4 : 3,
          ),
          boxShadow: isSelected
              ? NeoBrutalTheme.chunkyShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    offset: const Offset(4, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: NeoBrutalTheme.spaceMD),
            _buildChips(context),
            if (isSelected) _buildActionArea(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _TypeIcon(type: backup.type),
        SizedBox(width: NeoBrutalTheme.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${backup.createdAt.day}/${backup.createdAt.month}/${backup.createdAt.year}',
                style: NeoBrutalTheme.headlineSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${backup.createdAt.hour.toString().padLeft(2, '0')}:${backup.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
        if (isSelected) _SelectedBadge(),
      ],
    );
  }

  Widget _buildChips(BuildContext context) {
    return Wrap(
      spacing: NeoBrutalTheme.spaceSM,
      children: [
        _InfoChip(
          icon: Icons.storage,
          label: backup.sizeFormatted,
          color: AppTheme.infoColor,
        ),
        _InfoChip(
          icon: backup.location == StorageLocation.local
              ? Icons.smartphone
              : Icons.cloud,
          label: backup.location.name.toUpperCase(),
          color: NeoBrutalTheme.secondary,
        ),
      ],
    );
  }

  Widget _buildActionArea(BuildContext context, dynamic controller) {
    return Column(
      children: [
        SizedBox(height: NeoBrutalTheme.spaceMD),
        const Divider(thickness: 2, color: Colors.black12),
        SizedBox(height: NeoBrutalTheme.spaceMD),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Restore',
                icon: Icons.restore,
                color: AppTheme.successColor,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BackupRestoreDialog(backup: backup, controller: controller),
                ),
              ),
            ),
            SizedBox(width: NeoBrutalTheme.spaceSM),
            Expanded(
              child: _ActionButton(
                label: 'Delete',
                icon: Icons.delete,
                color: AppTheme.errorColor,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BackupDeleteDialog(backup: backup, controller: controller),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Helper Private Widgets ---

class _TypeIcon extends StatelessWidget {
  final BackupType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final isFull = type == BackupType.full;
    final color = isFull ? AppTheme.infoColor : AppTheme.successColor;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 3),
      ),
      child: Icon(isFull ? Icons.backup : Icons.update, color: color),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.primary,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Text(
        'SELECTED',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
