/// BackupDeleteDialog
///
/// **Purpose:** Destructive action confirmation for removing backups
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/backup_controller.dart';
import '../../domain/entities/backup_metadata.dart';

class BackupDeleteDialog extends StatefulWidget {
  final BackupMetadata backup;
  final BackupController controller;

  const BackupDeleteDialog({
    super.key,
    required this.backup,
    required this.controller,
  });

  @override
  State<BackupDeleteDialog> createState() => _BackupDeleteDialogState();
}

class _BackupDeleteDialogState extends State<BackupDeleteDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Backup?'),
      content: Text(
        'This will permanently delete the backup from ${widget.backup.sizeFormatted}. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    final success = await widget.controller.deleteBackup();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Deleted' : 'Failed to delete'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
