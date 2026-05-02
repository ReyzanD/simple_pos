/// BackupRestoreDialog
///
/// **Purpose:** Configuration and confirmation for data restoration
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/backup_constants.dart';
import '../controllers/backup_controller.dart';
import '../../domain/entities/backup_metadata.dart';

class BackupRestoreDialog extends StatefulWidget {
  final BackupMetadata backup;
  final BackupController controller;

  const BackupRestoreDialog({
    super.key,
    required this.backup,
    required this.controller,
  });

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog> {
  final RestoreMode _mode = RestoreMode.merge;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore Backup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose how you want to restore your data:'),
          const SizedBox(height: 16),
          RadioListTile<RestoreMode>(
            title: const Text('Merge'),
            subtitle: const Text('Keep existing data and add missing items'),
            value: RestoreMode.merge,
          ),
          RadioListTile<RestoreMode>(
            title: const Text('Replace'),
            subtitle: const Text('Wipe current data and use backup instead'),
            value: RestoreMode.replaceAll,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isRestoring ? null : _handleRestore,
          child: const Text('Restore Now'),
        ),
      ],
    );
  }

  Future<void> _handleRestore() async {
    setState(() => _isRestoring = true);
    final success = await widget.controller.restoreBackup(_mode);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Restored' : 'Restore Failed')),
      );
    }
  }
}
