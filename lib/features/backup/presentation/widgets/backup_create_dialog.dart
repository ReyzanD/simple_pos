/// BackupCreateDialog
///
/// **Purpose:** Modal for configuring and launching a new backup
/// **State:** StatefulWidget (manages selection state before submission)
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../controllers/backup_controller.dart';
import '../../domain/entities/backup_config.dart';
import '../../../../core/constants/backup_constants.dart';

class BackupCreateDialog extends StatefulWidget {
  final BackupController controller;

  const BackupCreateDialog({super.key, required this.controller});

  @override
  State<BackupCreateDialog> createState() => _BackupCreateDialogState();
}

class _BackupCreateDialogState extends State<BackupCreateDialog> {
  BackupType _selectedType = BackupType.full;
  StorageLocation _selectedLocation = StorageLocation.local;
  BackupDataType _selectedDataType = BackupDataType.all;
  bool _compress = true;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSectionTitle('Backup Type', Icons.backup),
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildSectionTitle('Data to Backup', Icons.data_object),
            _buildDataSelector(),
            const SizedBox(height: 20),
            _buildSectionTitle('Storage Location', Icons.cloud_upload),
            _buildLocationSelector(),
            const SizedBox(height: 32),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.backup, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        const Text(
          'Create Backup',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<BackupType>(
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
      onSelectionChanged: (set) => setState(() => _selectedType = set.first),
    );
  }

  Widget _buildDataSelector() {
    return Wrap(
      spacing: 8,
      children: BackupDataType.values.map((type) {
        return ChoiceChip(
          label: Text(type.name.toUpperCase()),
          selected: _selectedDataType == type,
          onSelected: (val) => setState(() => _selectedDataType = type),
        );
      }).toList(),
    );
  }

  Widget _buildLocationSelector() {
    return SegmentedButton<StorageLocation>(
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
      onSelectionChanged: (set) =>
          setState(() => _selectedLocation = set.first),
    );
  }

  Widget _buildActions() {
    return Row(
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
            text: 'Start',
            isLoading: _isCreating,
            onPressed: _isCreating ? null : _handleCreate,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    setState(() => _isCreating = true);

    final config = BackupConfig(
      type: _selectedType,
      dataTypes: [_selectedDataType],
      location: _selectedLocation,
      compress: _compress,
    );

    final success = await widget.controller.createManualBackup(config);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Backup Complete' : 'Backup Failed'),
          backgroundColor: success
              ? AppTheme.successColor
              : AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
